library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dataPacker is
generic(
    bit_width : integer := 64
);
port (  clk                : in  std_logic;
        rst                : in  std_logic;
        -- channel select signal; channel[i] is enabled if wr_sel[i]=1
        wr_sel             : in  std_logic_vector (3 downto 0);
        rd_sel             : out std_logic_vector (3 downto 0);
        ch_sel             : out std_logic_vector (3 downto 0);
        -- input AXIS
        s_axis_tvalid      : in  std_logic;
        s_axis_tdata       : in  std_logic_vector (bit_width-1 downto 0);
        -- output AXIS
        m_axis_tdata       : out std_logic_vector (bit_width-1 downto 0);
        m_axis_tvalid      : out std_logic
      );
end;

architecture rtl of dataPacker is

--signal declaration
signal m_axis_tdata_int_lsb     : std_logic_vector(63 downto 0);
signal m_axis_tvalid_int_lsb    : std_logic;
signal cnt_lsb                  : std_logic;
signal data_selected_lsb        : std_logic_vector(31 downto 0);

signal m_axis_tdata_int_msb     : std_logic_vector(63 downto 0);
signal m_axis_tvalid_int_msb    : std_logic;
signal cnt_msb                  : std_logic;
signal data_selected_msb        : std_logic_vector(31 downto 0);

signal m_axis_tdata_int         : std_logic_vector(bit_width-1 downto 0);
signal m_axis_tvalid_int        : std_logic;
signal cnt                      : std_logic;
signal data_selected            : std_logic_vector(63 downto 0);

signal cnt_vld                  : std_logic;
signal m_axis_tvalid_int_com    : std_logic;

begin

----------------------------------------------------------------------------
-- 2-channel case --
----------------------------------------------------------------------------                     
data_selected_lsb <= s_axis_tdata (31 downto 0)  when wr_sel = "0001" else
                     s_axis_tdata (63 downto 32) when wr_sel = "0010" else
                     (others => '0');
                     
-- generate axi stream output for one channel case
process(clk)
begin
  if rising_edge(clk) then
    if (rst = '1') then
      m_axis_tdata_int_lsb   <= (others=>'0');
      m_axis_tvalid_int_lsb  <= '0';
      cnt_lsb                <= '0';
    else
      -- counter
      if (s_axis_tvalid = '1') then
        cnt_lsb <= not cnt_lsb;
      end if;
      -- data
      if (s_axis_tvalid = '1') and (cnt_lsb = '0') then -- first sample in
        m_axis_tdata_int_lsb(31 downto 0)  <= data_selected_lsb;
        m_axis_tvalid_int_lsb <= '0';
      elsif (s_axis_tvalid = '1') and (cnt_lsb = '1') then -- second sample in
        m_axis_tdata_int_lsb(63 downto 32) <= data_selected_lsb;
        m_axis_tvalid_int_lsb <= '1';
      else -- hold when no valid signal
        m_axis_tdata_int_lsb <= m_axis_tdata_int_lsb;
        m_axis_tvalid_int_lsb <= '0';
      end if;
    end if;
  end if;
end process;

m_axis_tvalid_int_com_64: if (bit_width=64) generate                 
    m_axis_tvalid <= m_axis_tvalid_int_lsb  when (wr_sel = "0001" or wr_sel = "0010") else
                             s_axis_tvalid  when (wr_sel = "0011") else
                             '0';
                     
    m_axis_tdata <= m_axis_tdata_int_lsb        when (wr_sel = "0001" or wr_sel = "0010") else
                    s_axis_tdata(63 downto 0)   when wr_sel = "0011" else
                    (others => '0');
                         
end generate m_axis_tvalid_int_com_64;


----------------------------------------------------------------------------                     
-- end 2-channel case
----------------------------------------------------------------------------                     

----------------------------------------------------------------------------                     
-- 4-channel case --
----------------------------------------------------------------------------  
four_channel_data_ouput: if (bit_width=128) generate

data_selected_msb <= s_axis_tdata (95 downto 64)   when wr_sel = "0100" else
                     s_axis_tdata (127 downto 96)  when wr_sel = "1000" else
                     (others => '0');

process(clk)
begin
  if rising_edge(clk) then
    if (rst = '1') then
      m_axis_tdata_int_msb   <= (others=>'0');
      m_axis_tvalid_int_msb  <= '0';
      cnt_msb                <= '0';
    else
      -- counter
      if (s_axis_tvalid = '1') then
        cnt_msb <= not cnt_msb;
      end if;
      -- data
      if (s_axis_tvalid = '1') and (cnt_msb = '0') then -- first sample in
        m_axis_tdata_int_msb(31 downto 0)  <= data_selected_msb;
        m_axis_tvalid_int_msb <= '0';
      elsif (s_axis_tvalid = '1') and (cnt_msb = '1') then -- second sample in
        m_axis_tdata_int_msb(63 downto 32) <= data_selected_msb;
        m_axis_tvalid_int_msb <= '1';
      else -- hold when no valid signal
        m_axis_tdata_int_msb <= m_axis_tdata_int_msb;
        m_axis_tvalid_int_msb <= '0';
      end if;
    end if;
  end if;
end process;

m_axis_tvalid_int_com <= m_axis_tvalid_int_lsb when (wr_sel = "0001" or wr_sel = "0010" or wr_sel = "0100" or wr_sel = "1000") else
                         s_axis_tvalid         when (wr_sel = "0011" or wr_sel = "1100" or wr_sel = "0101" or wr_sel = "0110" or wr_sel = "1001" or wr_sel = "1010" ) else
                         '0';
m_axis_tdata  <= s_axis_tdata      when (wr_sel = "1111") else
                 m_axis_tdata_int  when (wr_sel = "0001" or wr_sel = "0010" or wr_sel = "0011" or wr_sel = "0100" or wr_sel = "0101" or wr_sel = "0110" or wr_sel = "1000" or wr_sel = "1001" or wr_sel = "1010" or wr_sel = "1100") else
                 (others => '0');
                 
m_axis_tvalid <= s_axis_tvalid     when (wr_sel = "1111") else
                 m_axis_tvalid_int when (wr_sel = "0001" or wr_sel = "0010" or wr_sel = "0011" or wr_sel = "0100" or wr_sel = "0101" or wr_sel = "0110" or wr_sel = "1000" or wr_sel = "1001" or wr_sel = "1010" or wr_sel = "1100") else
                 '0';
data_selected <= m_axis_tdata_int_lsb                                       when (wr_sel = "0001" or wr_sel = "0010") else
                 s_axis_tdata(63 downto 0)                                  when wr_sel = "0011" else
                 m_axis_tdata_int_msb                                       when (wr_sel = "0100" or wr_sel = "1000") else
                 s_axis_tdata(127 downto 64)                                when wr_sel = "1100" else
                 s_axis_tdata(95 downto 64)   & s_axis_tdata (31 downto 0)  when wr_sel = "0101" else
                 s_axis_tdata(95 downto 64)   & s_axis_tdata (63 downto 32) when wr_sel = "0110" else
                 s_axis_tdata(127 downto 96) & s_axis_tdata (31 downto 0)   when wr_sel = "1001" else
                 s_axis_tdata(127 downto 96) & s_axis_tdata (63 downto 32)  when wr_sel = "1010" else
                (others => '0');

process(clk)
begin
  if rising_edge(clk) then
    if (rst = '1') then
      m_axis_tdata_int   <= (others=>'0');
      m_axis_tvalid_int  <= '0';
      cnt                <= '0';
    else
      -- counter
      if (m_axis_tvalid_int_com = '1') then
        cnt <= not cnt;
      end if;
      -- data
      if (m_axis_tvalid_int_com = '1') and (cnt = '0') then -- first sample in
        m_axis_tdata_int(63 downto 0)  <= data_selected;
        m_axis_tvalid_int <= '0';
      elsif (m_axis_tvalid_int_com = '1') and (cnt = '1') then -- second sample in
        m_axis_tdata_int(127 downto 64) <= data_selected;
        m_axis_tvalid_int <= '1';
      else -- hold when no valid signal
        m_axis_tdata_int <= m_axis_tdata_int;
        m_axis_tvalid_int <= '0';
      end if;
    end if;
  end if;
end process;  

end generate four_channel_data_ouput;
----------------------------------------------------------------------------                     
-- end 4-channel case
----------------------------------------------------------------------------                                          

rd_sel <= wr_sel;
ch_sel <= wr_sel;

end rtl;




