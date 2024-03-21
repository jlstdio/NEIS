library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rxRateCtrl is
port (  clk                : in  std_logic;
        rst                : in  std_logic;
        isDoubleChannels   : in  std_logic; 
        -- input AXIS
        s_axis_tvalid      : in  std_logic;
        s_axis_tdata       : in  std_logic_vector (63 downto 0);
        -- output AXIS
        m_axis_tdata       : out std_logic_vector (63 downto 0);
        m_axis_tvalid      : out std_logic
      );
end rxRateCtrl;

architecture rtl of rxRateCtrl is

--signal decleration
signal m_axis_tdata_int     : std_logic_vector(63 downto 0);
signal m_axis_tvalid_int    : std_logic;
signal cnt                  : std_logic;

begin
-- generate axi stream output for one channel case
process(clk)
begin
  if rising_edge(clk) then
    if (rst = '1') then
      m_axis_tdata_int   <= (others=>'0');
      m_axis_tvalid_int  <= '0';
      cnt                <= '0';
    else
      -- counter
      if (s_axis_tvalid = '1') then
        cnt <= not cnt;
      end if;
      -- data
      if (s_axis_tvalid = '1') and (cnt = '0') then -- first sample in
        m_axis_tdata_int(31 downto 0) <= s_axis_tdata (31 downto 0);
        m_axis_tvalid_int <= '0';
      elsif (s_axis_tvalid = '1') and (cnt = '1') then -- second sample in
        m_axis_tdata_int(63 downto 32) <= s_axis_tdata (31 downto 0);
        m_axis_tvalid_int <= '1';
      else -- hold when no valid signal
        m_axis_tdata_int <= m_axis_tdata_int;
        m_axis_tvalid_int <= '0';
      end if;
    end if;
  end if;
end process;

m_axis_tdata  <= s_axis_tdata when (isDoubleChannels = '1') else m_axis_tdata_int;
m_axis_tvalid <= s_axis_tvalid when (isDoubleChannels = '1') else m_axis_tvalid_int;

end rtl;

