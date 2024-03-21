library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity axis_mux is
generic (C_TDATA_WIDTH : integer := 32);
port ( sel             : in  std_logic;
       dataIn_1        : in  std_logic_vector(C_TDATA_WIDTH-1 downto 0);
       dataInVld_1     : in  std_logic;
       dataIn_2        : in  std_logic_vector(C_TDATA_WIDTH-1 downto 0);
       dataInVld_2     : in  std_logic;
       dataOut         : out std_logic_vector(C_TDATA_WIDTH-1 downto 0);
       dataOutVld      : out std_logic
			);
end axis_mux;

architecture rtl of axis_mux is

begin

dataOut    <= dataIn_1 when sel = '0' else dataIn_2;
dataOutVld <= dataInVld_1 when sel = '0' else dataInVld_2;

end rtl;

