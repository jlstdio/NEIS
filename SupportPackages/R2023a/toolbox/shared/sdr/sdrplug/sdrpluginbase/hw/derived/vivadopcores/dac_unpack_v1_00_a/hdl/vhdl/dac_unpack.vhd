----------------------------------------------------------------------------------
-- Company: MATHWORKS
-- Engineer: 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity dac_unpack is
generic (
             bus_width : integer := 64
     );
    port (clk          : in  STD_LOGIC;
          aresetn      : in  STD_LOGIC;
          stream_enb   : in  STD_LOGIC;
          data_in      : in  STD_LOGIC_VECTOR (bus_width-1 downto 0);
          data_out_i0  : out STD_LOGIC_VECTOR (15 downto 0);
          data_out_q0  : out STD_LOGIC_VECTOR (15 downto 0);
          data_out_i1  : out STD_LOGIC_VECTOR (15 downto 0);
          data_out_q1  : out STD_LOGIC_VECTOR (15 downto 0);
          data_out_i2  : out STD_LOGIC_VECTOR (15 downto 0);
          data_out_q2  : out STD_LOGIC_VECTOR (15 downto 0);
          data_out_i3  : out STD_LOGIC_VECTOR (15 downto 0);
          data_out_q3  : out STD_LOGIC_VECTOR (15 downto 0)
             );
end dac_unpack;

architecture Behavioral of dac_unpack is

--signal declaration
signal data_out         : std_logic_vector(bus_width-1 downto 0);
signal stream_enb_sync1 : std_logic;
signal stream_enb_sync2 : std_logic;
signal stream_enb_int   : std_logic;

begin

clk_sync_proc: process(clk)
begin
  if rising_edge(clk) then
    stream_enb_sync1 <=  stream_enb;
    stream_enb_sync2 <=  stream_enb_sync1;
    stream_enb_int   <=  stream_enb_sync2;
  end if;
end process;


process(clk, aresetn, stream_enb_int, data_in)
begin
    if aresetn = '0' then
        data_out <= (others=>'0');
    elsif rising_edge(clk) then
        if stream_enb_int = '1' then
            data_out <= data_in;
        else
            data_out <= (others=>'0');
        end if;
    end if;
end process;

data_out_i0 <= data_out(15 downto 0);
data_out_q0 <= data_out(31 downto 16);
data_out_i1 <= data_out(47 downto 32);
data_out_q1 <= data_out(63 downto 48);

data_out_2channels: if(bus_width=128) generate
    data_out_i2 <= data_out(79 downto 64);
    data_out_q2 <= data_out(95 downto 80);
    data_out_i3 <= data_out(111 downto 96);
    data_out_q3 <= data_out(127 downto 112);
end generate data_out_2channels; 

data_out_4channels: if(bus_width=64) generate
    data_out_i2 <= (others=>'0');
    data_out_q2 <= (others=>'0');
    data_out_i3 <= (others=>'0');
    data_out_q3 <= (others=>'0');
end generate data_out_4channels;

end Behavioral;
