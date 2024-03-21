Library UNISIM;
use UNISIM.vcomponents.all;
library IEEE;
use IEEE.std_logic_1164.all;

entity clockGen is
generic(
    clk_div: string := "4"
);
port (clkIn : in std_logic;
      clkOut: out std_logic);
end entity;

architecture rtl of clockGen is
signal clk_int : std_logic;

begin

  BUFR_inst : BUFR
  generic map (
  BUFR_DIVIDE => clk_div,
  SIM_DEVICE => "7SERIES"
  )
  port map (
  O => clk_int,
  CE => '1', 
  CLR => '0',
  I => clkIn
  );
  
  BUFG_inst : BUFG
  port map (
  O => clkOut,
  I => clk_int
  );  
  

end rtl;