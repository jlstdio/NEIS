library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity axis_split is
generic (C_TDATA_WIDTH : integer := 32);
port ( dataIn        : in  std_logic_vector(C_TDATA_WIDTH-1 downto 0);
       dataInVld     : in  std_logic;
       dataOut_1     : out std_logic_vector(C_TDATA_WIDTH-1 downto 0);
       dataOutVld_1  : out std_logic;
       dataOut_2     : out std_logic_vector(C_TDATA_WIDTH-1 downto 0);
       dataOutVld_2  : out std_logic;
       dataOut_3     : out std_logic_vector(C_TDATA_WIDTH-1 downto 0);
       dataOutVld_3  : out std_logic
			);
end axis_split;

architecture rtl of axis_split is

begin

  dataOut_1    <= dataIn;
  dataOutVld_1 <= dataInVld;
  dataOut_2    <= dataIn;
  dataOutVld_2 <= dataInVld;
  dataOut_3    <= dataIn;
  dataOutVld_3 <= dataInVld;

end rtl;

