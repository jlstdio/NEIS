----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 

----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity basic_mux is
    generic (
                bit_width : integer := 1
    );  
    Port ( In_0 : in  std_logic_vector(bit_width-1 downto 0);
           In_1 : in  std_logic_vector(bit_width-1 downto 0);
           Sel : in  STD_LOGIC;
           Out_1 : out  std_logic_vector(bit_width-1 downto 0)
              );
end basic_mux;

architecture Behavioral of basic_mux is

begin

Out_1 <= In_0 when Sel='0' else In_1;

end Behavioral;

