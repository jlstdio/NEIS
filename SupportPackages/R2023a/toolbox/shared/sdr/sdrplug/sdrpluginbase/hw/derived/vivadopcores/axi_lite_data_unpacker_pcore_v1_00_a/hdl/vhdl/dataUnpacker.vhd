library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dataUnpacker is
generic(
    bit_width : integer := 64
    );
port (  clk                : in  std_logic;
        rst                : in  std_logic;
        stream_en          : in  std_logic;
        -- channel wr_select signal; channel[i] is enabled if wr_sel[i]=1
        wr_sel             : in   std_logic_vector (3 downto 0);
        rd_sel             : out  std_logic_vector (3 downto 0);
        ch_sel             : out  std_logic_vector (3 downto 0);
        -- input AXIS
        s_axis_tvalid      : in  std_logic;
        s_axis_tdata       : in  std_logic_vector (bit_width-1 downto 0);
        s_axis_tready      : out std_logic;
        -- output AXIS
        m_axis_tdata       : out std_logic_vector (bit_width-1 downto 0);
        m_axis_tvalid      : out std_logic
      );
end;

architecture rtl of dataUnpacker is

--signal decleration
signal stream_en_sync1       : std_logic;
signal stream_en_sync2       : std_logic;
signal s_axis_tready_int     : std_logic;
signal m_axis_tdata_int      : std_logic_vector (31 downto 0);
signal m_axis_tdata_int1     : std_logic_vector (31 downto 0);
signal m_axis_tdata_int_tmp  : std_logic_vector (((bit_width/2)-1) downto 0);
signal m_axis_tvalid_int     : std_logic;
signal valid_and_ready       : std_logic;
signal num_channels          : integer := 0;

begin

-- sync stream_en to DAC/data clock domain
sync_proc : process(clk)
begin
  if rising_edge(clk) then 
    stream_en_sync1 <= stream_en;
    stream_en_sync2 <= stream_en_sync1;
  end if;
end process sync_proc;

s_axis_tready <= s_axis_tready_int;

valid_and_ready <= s_axis_tvalid and s_axis_tready_int;

data_and_valid_64: if bit_width=64 generate

signal valid_and_ready_d     : std_logic;

begin
-- generate axi stream tready signal
tready_gen : process(clk)
begin
  if rising_edge(clk) then
    if (rst = '1') then
      s_axis_tready_int <= '0';
    elsif(stream_en_sync2 = '1' and wr_sel = "0011") then
      s_axis_tready_int <= '1';
    elsif(stream_en_sync2 = '1' and (wr_sel = "0010" or wr_sel = "0001")) then
      s_axis_tready_int <= not s_axis_tready_int;
    else
      s_axis_tready_int <= '0';
    end if;
  end if;    
end process;
                 
-- delay valid_and_ready for data output
process(clk)
begin
  if rising_edge(clk) then 
    valid_and_ready_d <= valid_and_ready;
  end if;
end process;           
-- generate axi stream output for one channel case
process(clk)
begin
  if rising_edge(clk) then
    if (rst = '1') then
      m_axis_tdata_int       <= (others=>'0');
      m_axis_tdata_int_tmp   <= (others=>'0');
      m_axis_tvalid_int      <= '0';
    else
      if (valid_and_ready = '1') then
        m_axis_tdata_int     <= s_axis_tdata(31 downto 0);
        m_axis_tdata_int_tmp <= s_axis_tdata(63 downto 32);
        m_axis_tvalid_int    <= '1';
      elsif (valid_and_ready_d = '1') then
        m_axis_tdata_int     <= m_axis_tdata_int_tmp;
        m_axis_tvalid_int    <= '1';
      else
        m_axis_tdata_int   <= m_axis_tdata_int;
        m_axis_tvalid_int  <= '0';
      end if;
    end if;
  end if;
end process;

m_axis_tdata  <= s_axis_tdata                    when (wr_sel = "0011") else
                 X"00000000" & m_axis_tdata_int  when (wr_sel = "0001") else
                 m_axis_tdata_int & X"00000000"  when (wr_sel = "0010") else
                 (others => '0');
                 
m_axis_tvalid <= valid_and_ready   when (wr_sel = "0011") else
                 m_axis_tvalid_int when (wr_sel = "0010" or wr_sel = "0001") else
                 '0';
                 
end generate data_and_valid_64;
           
data_and_valid_128: if bit_width=128 generate

signal counter : unsigned(1 downto 0);

begin
num_channels <= 4 when wr_sel = "1111" else
                2 when (wr_sel = "0011" or wr_sel = "0101" or wr_sel = "0110" or wr_sel = "1001" or wr_sel = "1010" or wr_sel = "1100") else
                1 when (wr_sel = "0001" or wr_sel = "0010" or wr_sel = "0100" or wr_sel = "1000") else
                0;

-- counter process
counter_proc: process(clk, rst, stream_en_sync2)
begin
    if rst = '1' then
        counter <= (others=>'0');
        s_axis_tready_int <= '0';
    elsif rising_edge(clk) and stream_en_sync2 = '1' then 
        if (num_channels = 4) then
            s_axis_tready_int <= '1';
        elsif (num_channels = 2) then 
            s_axis_tready_int <= not s_axis_tready_int;
        elsif (num_channels = 1) then 
            if counter = "11" then
                s_axis_tready_int <= '1';
            else
                s_axis_tready_int <= '0'; 
            end if;
            counter <= counter + "01"; 
        else
            s_axis_tready_int <= '0';
        end if;
    end if;
end process;

m_axis_tdata  <=  s_axis_tdata                                                         when (wr_sel = "1111") else -- 4-channels
                  X"00000000" & X"00000000" & m_axis_tdata_int1 & m_axis_tdata_int     when (wr_sel = "0011") else -- 2-channels
                  X"00000000" & m_axis_tdata_int1 & m_axis_tdata_int & X"00000000"     when (wr_sel = "0110") else -- 2-channels
                  m_axis_tdata_int1 & m_axis_tdata_int & X"00000000" & X"00000000"     when (wr_sel = "1100") else -- 2-channels
                  X"00000000" & m_axis_tdata_int1 & X"00000000" & m_axis_tdata_int     when (wr_sel = "0101") else -- 2-channels
                  m_axis_tdata_int1 & X"00000000" & m_axis_tdata_int & X"00000000"     when (wr_sel = "1010") else -- 2-channels
                  m_axis_tdata_int1 & X"00000000" & X"00000000" & m_axis_tdata_int     when (wr_sel = "1001") else -- 2-channels
                  X"00000000" & X"00000000" & X"00000000" & m_axis_tdata_int           when (wr_sel = "0001") else -- 1-channel
                  X"00000000" & X"00000000" & m_axis_tdata_int & X"00000000"           when (wr_sel = "0010") else -- 1-channel
                  X"00000000" & m_axis_tdata_int & X"00000000" & X"00000000"           when (wr_sel = "0100") else -- 1-channel
                  m_axis_tdata_int & X"00000000" & X"00000000" & X"00000000"           when (wr_sel = "1000") else -- 1-channel
                 (others => '0');
                 
m_axis_tvalid <= valid_and_ready   when (wr_sel = "1111") else
                 m_axis_tvalid_int;
                 
-- generate axi stream output 
process(clk) 
begin
  if rising_edge(clk) then
    if (rst = '1') then
      m_axis_tdata_int       <= (others=>'0');
      m_axis_tdata_int_tmp   <= (others=>'0');
      m_axis_tvalid_int      <= '0';
    else
        if (s_axis_tready_int = '1') then
        m_axis_tdata_int      <= s_axis_tdata(31 downto 0);
        m_axis_tdata_int1     <= s_axis_tdata(63 downto 32);
        m_axis_tdata_int_tmp  <= s_axis_tdata(127 downto 64);
        m_axis_tvalid_int     <= '1';
        elsif (num_channels = 2) then 
        m_axis_tdata_int     <= m_axis_tdata_int_tmp(31 downto 0);
        m_axis_tdata_int1    <= m_axis_tdata_int_tmp(63 downto 32);
        m_axis_tvalid_int    <= not(s_axis_tready_int);--'1';
        elsif (num_channels = 1) and (counter = "01") then
        m_axis_tdata_int     <= m_axis_tdata_int1;
        elsif (num_channels = 1) and (counter = "10") then
        m_axis_tdata_int     <= m_axis_tdata_int_tmp(31 downto 0);
        m_axis_tvalid_int    <= not(s_axis_tready_int);--'1';
        elsif (num_channels = 1) and (counter = "11") then
        m_axis_tdata_int     <= m_axis_tdata_int_tmp(63 downto 32);
        m_axis_tvalid_int    <= not(s_axis_tready_int);--'1';
        else
        m_axis_tdata_int   <= m_axis_tdata_int;
        m_axis_tvalid_int  <= '0';
        end if;
    end if;
  end if;
end process;
                 
end generate data_and_valid_128;

rd_sel <= wr_sel;
ch_sel <= wr_sel;

end rtl;

