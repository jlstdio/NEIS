----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:57:43 10/07/2013 
-- Design Name: 
-- Module Name:    clk_domain_xing_rst - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity clk_domain_xing_rst is
    Port ( reset_a 	: in  std_logic;
           reset_b 	: out  std_logic;
           clk_b		: in  std_logic
			);
end clk_domain_xing_rst;

architecture Behavioral of clk_domain_xing_rst is

--signals
signal reset_shift_reg : std_logic_vector(2 downto 0);

begin

process (clk_b)
begin
	if clk_b = '1' and clk_b'event then
		reset_shift_reg <= reset_shift_reg(1 downto 0) & reset_a;
		reset_b <= reset_shift_reg(2) or reset_shift_reg(1);
	end if;	
end process;

end Behavioral;

