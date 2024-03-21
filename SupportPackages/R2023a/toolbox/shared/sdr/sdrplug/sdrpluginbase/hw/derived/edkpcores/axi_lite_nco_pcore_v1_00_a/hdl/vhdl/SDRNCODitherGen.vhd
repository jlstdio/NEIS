LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY SDRNCODitherGen IS
  PORT( clk                               :   IN    std_logic;
        reset                             :   IN    std_logic;
        enb                               :   IN    std_logic;
        dither                            :   OUT   std_logic_vector(6 DOWNTO 0)  -- ufix7
        );
END SDRNCODitherGen;


ARCHITECTURE rtl OF SDRNCODitherGen IS

  -- Signals
  SIGNAL pn_newvalue6                     : unsigned(18 DOWNTO 0);  -- ufix19
  SIGNAL pn_newvaluesf6                   : unsigned(17 DOWNTO 0);  -- ufix18
  SIGNAL bit0_6                           : std_logic;  -- ufix1
  SIGNAL bit14_6                          : std_logic;  -- ufix1
  SIGNAL bit17_6                          : std_logic;  -- ufix1
  SIGNAL pn_newvalue5                     : unsigned(18 DOWNTO 0);  -- ufix19
  SIGNAL pn_newvaluesf5                   : unsigned(17 DOWNTO 0);  -- ufix18
  SIGNAL bit0_5                           : std_logic;  -- ufix1
  SIGNAL bit14_5                          : std_logic;  -- ufix1
  SIGNAL bit17_5                          : std_logic;  -- ufix1
  SIGNAL pn_newvalue4                     : unsigned(18 DOWNTO 0);  -- ufix19
  SIGNAL pn_newvaluesf4                   : unsigned(17 DOWNTO 0);  -- ufix18
  SIGNAL bit0_4                           : std_logic;  -- ufix1
  SIGNAL bit14_4                          : std_logic;  -- ufix1
  SIGNAL bit17_4                          : std_logic;  -- ufix1
  SIGNAL pn_newvalue3                     : unsigned(18 DOWNTO 0);  -- ufix19
  SIGNAL pn_newvaluesf3                   : unsigned(17 DOWNTO 0);  -- ufix18
  SIGNAL bit0_3                           : std_logic;  -- ufix1
  SIGNAL bit14_3                          : std_logic;  -- ufix1
  SIGNAL bit17_3                          : std_logic;  -- ufix1
  SIGNAL pn_newvalue2                     : unsigned(18 DOWNTO 0);  -- ufix19
  SIGNAL pn_newvaluesf2                   : unsigned(17 DOWNTO 0);  -- ufix18
  SIGNAL bit0_2                           : std_logic;  -- ufix1
  SIGNAL bit14_2                          : std_logic;  -- ufix1
  SIGNAL bit17_2                          : std_logic;  -- ufix1
  SIGNAL pn_newvalue1                     : unsigned(18 DOWNTO 0);  -- ufix19
  SIGNAL pn_newvaluesf1                   : unsigned(17 DOWNTO 0);  -- ufix18
  SIGNAL bit0_1                           : std_logic;  -- ufix1
  SIGNAL bit14_1                          : std_logic;  -- ufix1
  SIGNAL bit17_1                          : std_logic;  -- ufix1
  SIGNAL pn_reg                           : unsigned(18 DOWNTO 0);  -- ufix19
  SIGNAL pn_newvaluesf0                   : unsigned(17 DOWNTO 0);  -- ufix18
  SIGNAL bit14_0                          : std_logic;  -- ufix1
  SIGNAL bit17_0                          : std_logic;  -- ufix1
  SIGNAL bit18_0                          : std_logic;  -- ufix1
  SIGNAL bit0_0                           : std_logic;  -- ufix1
  SIGNAL bit18_0_1                        : std_logic;  -- ufix1
  SIGNAL bit18_1                          : std_logic;  -- ufix1
  SIGNAL bit18_1_1                        : std_logic;  -- ufix1
  SIGNAL bit18_2                          : std_logic;  -- ufix1
  SIGNAL bit18_2_1                        : std_logic;  -- ufix1
  SIGNAL bit18_3                          : std_logic;  -- ufix1
  SIGNAL bit18_3_1                        : std_logic;  -- ufix1
  SIGNAL bit18_4                          : std_logic;  -- ufix1
  SIGNAL bit18_4_1                        : std_logic;  -- ufix1
  SIGNAL bit18_5                          : std_logic;  -- ufix1
  SIGNAL bit18_5_1                        : std_logic;  -- ufix1
  SIGNAL bit18_6                          : std_logic;  -- ufix1
  SIGNAL bit18_6_1                        : std_logic;  -- ufix1
  SIGNAL pn_newvalue7                     : unsigned(18 DOWNTO 0);  -- ufix19
  SIGNAL dither_tmp                       : unsigned(6 DOWNTO 0);  -- ufix7

BEGIN
  pn_newvaluesf6 <= pn_newvalue6(18 DOWNTO 1);

  bit0_6 <= pn_newvalue6(0);

  bit14_6 <= pn_newvalue6(14);

  bit17_6 <= pn_newvalue6(17);

  pn_newvaluesf5 <= pn_newvalue5(18 DOWNTO 1);

  bit0_5 <= pn_newvalue5(0);

  bit14_5 <= pn_newvalue5(14);

  bit17_5 <= pn_newvalue5(17);

  pn_newvaluesf4 <= pn_newvalue4(18 DOWNTO 1);

  bit0_4 <= pn_newvalue4(0);

  bit14_4 <= pn_newvalue4(14);

  bit17_4 <= pn_newvalue4(17);

  pn_newvaluesf3 <= pn_newvalue3(18 DOWNTO 1);

  bit0_3 <= pn_newvalue3(0);

  bit14_3 <= pn_newvalue3(14);

  bit17_3 <= pn_newvalue3(17);

  pn_newvaluesf2 <= pn_newvalue2(18 DOWNTO 1);

  bit0_2 <= pn_newvalue2(0);

  bit14_2 <= pn_newvalue2(14);

  bit17_2 <= pn_newvalue2(17);

  pn_newvaluesf1 <= pn_newvalue1(18 DOWNTO 1);

  bit0_1 <= pn_newvalue1(0);

  bit14_1 <= pn_newvalue1(14);

  bit17_1 <= pn_newvalue1(17);

  pn_newvaluesf0 <= pn_reg(18 DOWNTO 1);

  bit14_0 <= pn_reg(14);

  bit17_0 <= pn_reg(17);

  bit18_0 <= pn_reg(18);

  -- Stage1: Compute register output and shift
  bit18_0_1 <= bit0_0 XOR (bit14_0 XOR (bit18_0 XOR bit17_0));

  pn_newvalue1 <= bit18_0_1 & pn_newvaluesf0;

  bit18_1 <= pn_newvalue1(18);

  -- Stage2: Compute register output and shift
  bit18_1_1 <= bit0_1 XOR (bit14_1 XOR (bit18_1 XOR bit17_1));

  pn_newvalue2 <= bit18_1_1 & pn_newvaluesf1;

  bit18_2 <= pn_newvalue2(18);

  -- Stage3: Compute register output and shift
  bit18_2_1 <= bit0_2 XOR (bit14_2 XOR (bit18_2 XOR bit17_2));

  pn_newvalue3 <= bit18_2_1 & pn_newvaluesf2;

  bit18_3 <= pn_newvalue3(18);

  -- Stage4: Compute register output and shift
  bit18_3_1 <= bit0_3 XOR (bit14_3 XOR (bit18_3 XOR bit17_3));

  pn_newvalue4 <= bit18_3_1 & pn_newvaluesf3;

  bit18_4 <= pn_newvalue4(18);

  -- Stage5: Compute register output and shift
  bit18_4_1 <= bit0_4 XOR (bit14_4 XOR (bit18_4 XOR bit17_4));

  pn_newvalue5 <= bit18_4_1 & pn_newvaluesf4;

  bit18_5 <= pn_newvalue5(18);

  -- Stage6: Compute register output and shift
  bit18_5_1 <= bit0_5 XOR (bit14_5 XOR (bit18_5 XOR bit17_5));

  pn_newvalue6 <= bit18_5_1 & pn_newvaluesf5;

  bit18_6 <= pn_newvalue6(18);

  -- Stage7: Compute register output and shift
  bit18_6_1 <= bit0_6 XOR (bit14_6 XOR (bit18_6 XOR bit17_6));

  pn_newvalue7 <= bit18_6_1 & pn_newvaluesf6;

  -- PNgen register
  PNgenRegister_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        pn_reg <= to_unsigned(2#0000000000000000001#, 19);
      ELSIF enb = '1' THEN
        pn_reg <= pn_newvalue7;
      END IF;
    END IF;
  END PROCESS PNgenRegister_process;


  bit0_0 <= pn_reg(0);

  -- Dither Output
  dither_tmp <= unsigned'(bit0_0 & bit0_1 & bit0_2 & bit0_3 & bit0_4 & bit0_5 & bit0_6);

  dither <= std_logic_vector(dither_tmp);

END rtl;

