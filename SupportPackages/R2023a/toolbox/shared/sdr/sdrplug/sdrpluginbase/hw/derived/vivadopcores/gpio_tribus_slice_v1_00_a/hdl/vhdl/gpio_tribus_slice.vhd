---------------------------------------------------------------------------------
-- GPIO_TRIBUS_SLICE
-- Split GPIO bus from Ps& in Vivado IP Integrator
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity gpio_tribus_slice is
generic (
     bit_width : integer := 49;
     out_width  : integer := 17
);
port (
    GPIO_0_tri_i 		: out STD_LOGIC_VECTOR ( bit_width-1 downto 0 );
    GPIO_0_tri_o 		: in STD_LOGIC_VECTOR ( bit_width-1 downto 0 );
    GPIO_0_tri_t 		: in STD_LOGIC_VECTOR ( bit_width-1 downto 0 );
    gpio_io             : inout STD_LOGIC_VECTOR(out_width-1 downto 0)
);
end gpio_tribus_slice;

architecture Behavioral of gpio_tribus_slice is
component IOBUF is
port 
    (
    I : in STD_LOGIC;
    O : out STD_LOGIC;
    T : in STD_LOGIC;
    IO : inout STD_LOGIC
    );
end component IOBUF;

signal gpio_i : STD_LOGIC_VECTOR ( bit_width-1 downto 0 );
signal gpio_o : STD_LOGIC_VECTOR ( bit_width-1 downto 0 );
signal gpio_t : STD_LOGIC_VECTOR ( bit_width-1 downto 0 );

begin

GPIO_0_tri_i <= gpio_i;
gpio_o <= GPIO_0_tri_o;
gpio_t <= GPIO_0_tri_t;


gen_gpio_iobufs:
   for n in 0 to out_width-1 generate
      i_iobuf_gpio : IOBUF 
      port map(
        gpio_o(32+n), 
        gpio_i(32+n), 
        gpio_t(32+n), 
        gpio_io(n)
        );
   end generate gen_gpio_iobufs;

end Behavioral;
