LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY SDRNCO IS
  PORT( clk                               :   IN    std_logic;
        reset                             :   IN    std_logic;
        clk_enable                        :   IN    std_logic;
        dataIn_I                          :   IN    std_logic_vector(15 DOWNTO 0);  -- sfix16_En14
        dataIn_Q                          :   IN    std_logic_vector(15 DOWNTO 0);  -- sfix16_En14
        dataInVld                         :   IN    std_logic;
        phaseInc                          :   IN    std_logic_vector(31 DOWNTO 0);  -- int32
        debugNCO                          :   IN    std_logic;
        dataOut_I                         :   OUT   std_logic_vector(15 DOWNTO 0);  -- sfix16_En14
        dataOut_Q                         :   OUT   std_logic_vector(15 DOWNTO 0);  -- sfix16_En14
        dataOutVld                        :   OUT   std_logic
        );
END SDRNCO;


ARCHITECTURE rtl OF SDRNCO IS

  -- Component Declarations
  COMPONENT SDRNCOComp
    PORT( clk                             :   IN    std_logic;
          reset                           :   IN    std_logic;
          enb                             :   IN    std_logic;
          inc                             :   IN    std_logic_vector(31 DOWNTO 0);  -- int32
          validIn                         :   IN    std_logic;
          sine                            :   OUT   std_logic_vector(19 DOWNTO 0);  -- sfix20_En18
          cosine                          :   OUT   std_logic_vector(19 DOWNTO 0);  -- sfix20_En18
          validOut                        :   OUT   std_logic
          );
  END COMPONENT;

  -- Component Configuration Statements
  FOR ALL : SDRNCOComp
    USE ENTITY work.SDRNCOComp(rtl);

  -- Signals
  SIGNAL enb                              : std_logic;
  SIGNAL phaseInc_signed                  : signed(31 DOWNTO 0);  -- int32
  SIGNAL Compare_To_Zero_out1             : std_logic;
  SIGNAL dataVldIn_1                      : std_logic;
  SIGNAL NCO_out1                         : std_logic_vector(19 DOWNTO 0);  -- ufix20
  SIGNAL nco_vld                          : std_logic_vector(19 DOWNTO 0);  -- ufix20
  SIGNAL NCO_out3                         : std_logic;
  SIGNAL nco_vld_signed                   : signed(19 DOWNTO 0);  -- sfix20_En18
  SIGNAL Delay1_out1                      : signed(19 DOWNTO 0);  -- sfix20_En18
  SIGNAL dataIn_I_signed                  : signed(15 DOWNTO 0);  -- sfix16_En14
  SIGNAL Constant_out1                    : signed(15 DOWNTO 0);  -- sfix16_En14
  SIGNAL Switch_out1                      : signed(15 DOWNTO 0);  -- sfix16_En14
  SIGNAL Delay2_out1                      : signed(15 DOWNTO 0);  -- sfix16_En14
  SIGNAL Product_out1                     : signed(35 DOWNTO 0);  -- sfix36_En32
  SIGNAL Delay4_out1                      : signed(35 DOWNTO 0);  -- sfix36_En32
  SIGNAL NCO_out1_signed                  : signed(19 DOWNTO 0);  -- sfix20_En18
  SIGNAL Delay_out1                       : signed(19 DOWNTO 0);  -- sfix20_En18
  SIGNAL dataIn_Q_signed                  : signed(15 DOWNTO 0);  -- sfix16_En14
  SIGNAL Constant1_out1                   : signed(15 DOWNTO 0);  -- sfix16_En14
  SIGNAL Switch1_out1                     : signed(15 DOWNTO 0);  -- sfix16_En14
  SIGNAL Delay3_out1                      : signed(15 DOWNTO 0);  -- sfix16_En14
  SIGNAL Product1_out1                    : signed(35 DOWNTO 0);  -- sfix36_En32
  SIGNAL Delay5_out1                      : signed(35 DOWNTO 0);  -- sfix36_En32
  SIGNAL Sum_sub_cast                     : signed(36 DOWNTO 0);  -- sfix37_En32
  SIGNAL Sum_sub_cast_1                   : signed(36 DOWNTO 0);  -- sfix37_En32
  SIGNAL Sum_sub_temp                     : signed(36 DOWNTO 0);  -- sfix37_En32
  SIGNAL Sum_out1                         : signed(15 DOWNTO 0);  -- sfix16_En14
  SIGNAL Delay8_out1                      : signed(15 DOWNTO 0);  -- sfix16_En14
  SIGNAL Switch2_out1                     : signed(15 DOWNTO 0);  -- sfix16_En14
  SIGNAL Product2_out1                    : signed(35 DOWNTO 0);  -- sfix36_En32
  SIGNAL Delay6_out1                      : signed(35 DOWNTO 0);  -- sfix36_En32
  SIGNAL Product3_out1                    : signed(35 DOWNTO 0);  -- sfix36_En32
  SIGNAL Delay7_out1                      : signed(35 DOWNTO 0);  -- sfix36_En32
  SIGNAL Sum1_add_cast                    : signed(36 DOWNTO 0);  -- sfix37_En32
  SIGNAL Sum1_add_cast_1                  : signed(36 DOWNTO 0);  -- sfix37_En32
  SIGNAL Sum1_add_temp                    : signed(36 DOWNTO 0);  -- sfix37_En32
  SIGNAL Sum1_out1                        : signed(15 DOWNTO 0);  -- sfix16_En14
  SIGNAL Delay9_out1                      : signed(15 DOWNTO 0);  -- sfix16_En14
  SIGNAL Switch3_out1                     : signed(15 DOWNTO 0);  -- sfix16_En14
  SIGNAL Delay10_reg                      : std_logic_vector(0 TO 2);  -- ufix1 [3]
  SIGNAL Delay10_out1                     : std_logic;
  SIGNAL Switch4_out1                     : std_logic;

BEGIN
  u_NCO : SDRNCOComp
    PORT MAP( clk => clk,
              reset => reset,
              enb => clk_enable,
              inc => phaseInc,  -- int32
              validIn => dataVldIn_1,
              sine => NCO_out1,  -- sfix20_En18
              cosine => nco_vld,  -- sfix20_En18
              validOut => NCO_out3
              );

  phaseInc_signed <= signed(phaseInc);

  
  Compare_To_Zero_out1 <= '1' WHEN phaseInc_signed = 0 ELSE
      '0';

  dataVldIn_1 <= dataInVld OR debugNCO;

  nco_vld_signed <= signed(nco_vld);

  enb <= clk_enable;

  Delay1_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        Delay1_out1 <= to_signed(16#00000#, 20);
      ELSIF enb = '1' THEN
        Delay1_out1 <= nco_vld_signed;
      END IF;
    END IF;
  END PROCESS Delay1_process;


  dataIn_I_signed <= signed(dataIn_I);

  Constant_out1 <= to_signed(16#4000#, 16);

  
  Switch_out1 <= dataIn_I_signed WHEN debugNCO = '0' ELSE
      Constant_out1;

  Delay2_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        Delay2_out1 <= to_signed(16#0000#, 16);
      ELSIF enb = '1' THEN
        Delay2_out1 <= Switch_out1;
      END IF;
    END IF;
  END PROCESS Delay2_process;


  Product_out1 <= Delay1_out1 * Delay2_out1;

  Delay4_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        Delay4_out1 <= to_signed(0, 36);
      ELSIF enb = '1' THEN
        Delay4_out1 <= Product_out1;
      END IF;
    END IF;
  END PROCESS Delay4_process;


  NCO_out1_signed <= signed(NCO_out1);

  Delay_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        Delay_out1 <= to_signed(16#00000#, 20);
      ELSIF enb = '1' THEN
        Delay_out1 <= NCO_out1_signed;
      END IF;
    END IF;
  END PROCESS Delay_process;


  dataIn_Q_signed <= signed(dataIn_Q);

  Constant1_out1 <= to_signed(16#0000#, 16);

  
  Switch1_out1 <= dataIn_Q_signed WHEN debugNCO = '0' ELSE
      Constant1_out1;

  Delay3_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        Delay3_out1 <= to_signed(16#0000#, 16);
      ELSIF enb = '1' THEN
        Delay3_out1 <= Switch1_out1;
      END IF;
    END IF;
  END PROCESS Delay3_process;


  Product1_out1 <= Delay_out1 * Delay3_out1;

  Delay5_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        Delay5_out1 <= to_signed(0, 36);
      ELSIF enb = '1' THEN
        Delay5_out1 <= Product1_out1;
      END IF;
    END IF;
  END PROCESS Delay5_process;


  Sum_sub_cast <= resize(Delay4_out1, 37);
  Sum_sub_cast_1 <= resize(Delay5_out1, 37);
  Sum_sub_temp <= Sum_sub_cast - Sum_sub_cast_1;
  Sum_out1 <= Sum_sub_temp(33 DOWNTO 18) + ('0' & Sum_sub_temp(17));

  Delay8_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        Delay8_out1 <= to_signed(16#0000#, 16);
      ELSIF enb = '1' THEN
        Delay8_out1 <= Sum_out1;
      END IF;
    END IF;
  END PROCESS Delay8_process;


  
  Switch2_out1 <= Delay8_out1 WHEN Compare_To_Zero_out1 = '0' ELSE
      Switch_out1;

  dataOut_I <= std_logic_vector(Switch2_out1);

  Product2_out1 <= Delay1_out1 * Delay3_out1;

  Delay6_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        Delay6_out1 <= to_signed(0, 36);
      ELSIF enb = '1' THEN
        Delay6_out1 <= Product2_out1;
      END IF;
    END IF;
  END PROCESS Delay6_process;


  Product3_out1 <= Delay_out1 * Delay2_out1;

  Delay7_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        Delay7_out1 <= to_signed(0, 36);
      ELSIF enb = '1' THEN
        Delay7_out1 <= Product3_out1;
      END IF;
    END IF;
  END PROCESS Delay7_process;


  Sum1_add_cast <= resize(Delay6_out1, 37);
  Sum1_add_cast_1 <= resize(Delay7_out1, 37);
  Sum1_add_temp <= Sum1_add_cast + Sum1_add_cast_1;
  Sum1_out1 <= Sum1_add_temp(33 DOWNTO 18) + ('0' & Sum1_add_temp(17));

  Delay9_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        Delay9_out1 <= to_signed(16#0000#, 16);
      ELSIF enb = '1' THEN
        Delay9_out1 <= Sum1_out1;
      END IF;
    END IF;
  END PROCESS Delay9_process;


  
  Switch3_out1 <= Delay9_out1 WHEN Compare_To_Zero_out1 = '0' ELSE
      Switch1_out1;

  dataOut_Q <= std_logic_vector(Switch3_out1);

  Delay10_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        Delay10_reg <= (OTHERS => '0');
      ELSIF enb = '1' THEN
        Delay10_reg(0) <= NCO_out3;
        Delay10_reg(1 TO 2) <= Delay10_reg(0 TO 1);
      END IF;
    END IF;
  END PROCESS Delay10_process;

  Delay10_out1 <= Delay10_reg(2);

  
  Switch4_out1 <= Delay10_out1 WHEN Compare_To_Zero_out1 = '0' ELSE
      dataVldIn_1;

  dataOutVld <= Switch4_out1;

END rtl;

