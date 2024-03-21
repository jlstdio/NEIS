library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity txRateCtrl is
port (  clk                : in  std_logic;
        rst                : in  std_logic;
        stream_en          : in  std_logic;
        isDoubleChannels   : in  std_logic; 
        -- input AXIS
        s_axis_tvalid      : in  std_logic;
        s_axis_tdata       : in  std_logic_vector (63 downto 0);
        s_axis_tready      : out std_logic;
        -- output AXIS
        m_axis_tdata       : out std_logic_vector (63 downto 0);
        m_axis_tvalid      : out std_logic
      );
end txRateCtrl;

architecture rtl of txRateCtrl is

--signal decleration
signal stream_en_sync1       : std_logic;
signal stream_en_sync2       : std_logic;
signal s_axis_tready_int     : std_logic;
signal m_axis_tdata_int      : std_logic_vector (63 downto 0);
signal m_axis_tdata_int_tmp  : std_logic_vector (63 downto 0);
signal m_axis_tvalid_int     : std_logic;

signal valid_and_ready       : std_logic;
signal valid_and_ready_d     : std_logic;

begin

-- sync interpolation factor to DAC/data clock domain
sync_proc : process(clk)
begin
  if rising_edge(clk) then 
    stream_en_sync1 <= stream_en;
    stream_en_sync2 <= stream_en_sync1;
  end if;
end process sync_proc;

-- generate axi stream tready signal
tready_gen : process(clk)
begin
  if rising_edge(clk) then
    if (rst = '1') then
      s_axis_tready_int <= '0';
    elsif(stream_en_sync2 = '1'and isDoubleChannels = '1')then
      s_axis_tready_int <= '1';
    elsif(stream_en_sync2 = '1'and isDoubleChannels = '0') then
      s_axis_tready_int <= not s_axis_tready_int;
    else
      s_axis_tready_int <= '0';
    end if;
  end if;    
end process;

s_axis_tready <= s_axis_tready_int;

valid_and_ready <= s_axis_tvalid and s_axis_tready_int;
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
      m_axis_tdata_int     <= (others=>'0');
      m_axis_tdata_int_tmp <= (others=>'0'); 
      m_axis_tvalid_int    <= '0';
    else
      if (valid_and_ready = '1') then
        m_axis_tdata_int     <= X"00000000" & s_axis_tdata(31 downto 0);
        m_axis_tdata_int_tmp <= X"00000000" & s_axis_tdata(63 downto 32);
        m_axis_tvalid_int    <= '1';
      elsif (valid_and_ready_d = '1') then
        m_axis_tdata_int  <= m_axis_tdata_int_tmp;
        m_axis_tvalid_int <= '1';
      else
        m_axis_tdata_int   <= m_axis_tdata_int;
        m_axis_tvalid_int  <= '0';
      end if;
    end if;
  end if;
end process;

m_axis_tdata  <= s_axis_tdata when (isDoubleChannels = '1') else m_axis_tdata_int;
m_axis_tvalid <= valid_and_ready when (isDoubleChannels = '1') else m_axis_tvalid_int;

end rtl;

