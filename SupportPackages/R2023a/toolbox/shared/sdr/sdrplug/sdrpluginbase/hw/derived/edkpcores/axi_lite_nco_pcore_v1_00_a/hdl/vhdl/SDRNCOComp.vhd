LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY SDRNCOComp IS
  PORT( clk                               :   IN    std_logic;
        reset                             :   IN    std_logic;
        enb                               :   IN    std_logic;
        inc                               :   IN    std_logic_vector(31 DOWNTO 0);  -- int32
        validIn                           :   IN    std_logic;
        sine                              :   OUT   std_logic_vector(19 DOWNTO 0);  -- sfix20_En18
        cosine                            :   OUT   std_logic_vector(19 DOWNTO 0);  -- sfix20_En18
        validOut                          :   OUT   std_logic
        );
END SDRNCOComp;


ARCHITECTURE rtl OF SDRNCOComp IS

  -- Component Declarations
  COMPONENT SDRNCODitherGen
    PORT( clk                             :   IN    std_logic;
          reset                           :   IN    std_logic;
          enb                             :   IN    std_logic;
          dither                          :   OUT   std_logic_vector(6 DOWNTO 0)  -- ufix7
          );
  END COMPONENT;

  COMPONENT SDRNCOWaveformGen
    PORT( clk                             :   IN    std_logic;
          reset                           :   IN    std_logic;
          enb                             :   IN    std_logic;
          phaseIdx                        :   IN    std_logic_vector(19 DOWNTO 0);  -- ufix20_E7
          sine                            :   OUT   std_logic_vector(19 DOWNTO 0);  -- sfix20_En18
          cosine                          :   OUT   std_logic_vector(19 DOWNTO 0)  -- sfix20_En18
          );
  END COMPONENT;

  -- Component Configuration Statements
  FOR ALL : SDRNCODitherGen
    USE ENTITY work.SDRNCODitherGen(rtl);

  FOR ALL : SDRNCOWaveformGen
    USE ENTITY work.SDRNCOWaveformGen(rtl);

  -- Signals
  SIGNAL const0                           : signed(26 DOWNTO 0);  -- sfix27
  SIGNAL inc_signed                       : signed(31 DOWNTO 0);  -- int32
  SIGNAL pInc                             : signed(26 DOWNTO 0);  -- sfix27
  SIGNAL validPInc                        : signed(26 DOWNTO 0);  -- sfix27
  SIGNAL accphase_reg                     : signed(26 DOWNTO 0);  -- sfix27
  SIGNAL addpInc                          : signed(26 DOWNTO 0);  -- sfix27
  SIGNAL pOffset                          : signed(26 DOWNTO 0);  -- sfix27
  SIGNAL accoffset                        : signed(26 DOWNTO 0);  -- sfix27
  SIGNAL accoffsete_reg                   : signed(26 DOWNTO 0);  -- sfix27
  SIGNAL dither                           : std_logic_vector(6 DOWNTO 0);  -- ufix7
  SIGNAL dither_unsigned                  : unsigned(6 DOWNTO 0);  -- ufix7
  SIGNAL casteddither                     : signed(26 DOWNTO 0);  -- sfix27
  SIGNAL dither_reg                       : signed(26 DOWNTO 0);  -- sfix27
  SIGNAL accumulator                      : signed(26 DOWNTO 0);  -- sfix27
  SIGNAL accQuantized                     : unsigned(19 DOWNTO 0);  -- ufix20_E7
  SIGNAL outsine                          : std_logic_vector(19 DOWNTO 0);  -- ufix20
  SIGNAL outcos                           : std_logic_vector(19 DOWNTO 0);  -- ufix20
  SIGNAL outsine_signed                   : signed(19 DOWNTO 0);  -- sfix20_En18
  SIGNAL sine_tmp                         : signed(19 DOWNTO 0);  -- sfix20_En18
  SIGNAL outcos_signed                    : signed(19 DOWNTO 0);  -- sfix20_En18
  SIGNAL cosine_tmp                       : signed(19 DOWNTO 0);  -- sfix20_En18
  SIGNAL validOut_reg_reg                 : std_logic_vector(0 TO 5);  -- ufix1 [6]

BEGIN
  u_dither_inst : SDRNCODitherGen
    PORT MAP( clk => clk,
              reset => reset,
              enb => enb,
              dither => dither  -- ufix7
              );

  u_Wave_inst : SDRNCOWaveformGen
    PORT MAP( clk => clk,
              reset => reset,
              enb => enb,
              phaseIdx => std_logic_vector(accQuantized),  -- ufix20_E7
              sine => outsine,  -- sfix20_En18
              cosine => outcos  -- sfix20_En18
              );

  -- Constant Zero
  const0 <= to_signed(2#000000000000000000000000000#, 27);

  inc_signed <= signed(inc);

  pInc <= inc_signed(26 DOWNTO 0);

  
  validPInc <= const0 WHEN validIn = '0' ELSE
      pInc;

  -- Add phase increment
  addpInc <= accphase_reg + validPInc;

  -- Phase increment accumulator register
  AccPhaseRegister_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        accphase_reg <= to_signed(2#000000000000000000000000000#, 27);
      ELSIF enb = '1' THEN
        accphase_reg <= addpInc;
      END IF;
    END IF;
  END PROCESS AccPhaseRegister_process;


  pOffset <= to_signed(2#000000000000000000000000000#, 27);

  -- Add phase offset
  accoffset <= accphase_reg + pOffset;

  -- Phase offset accumulator register
  AccOffsetRegister_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        accoffsete_reg <= to_signed(2#000000000000000000000000000#, 27);
      ELSIF enb = '1' THEN
        accoffsete_reg <= accoffset;
      END IF;
    END IF;
  END PROCESS AccOffsetRegister_process;


  dither_unsigned <= unsigned(dither);

  casteddither <= signed(resize(dither_unsigned, 27));

  -- Dither input register
  DitherRegister_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        dither_reg <= to_signed(2#000000000000000000000000000#, 27);
      ELSIF enb = '1' THEN
        dither_reg <= casteddither;
      END IF;
    END IF;
  END PROCESS DitherRegister_process;


  -- Add dither
  accumulator <= accoffsete_reg + dither_reg;

  -- Phase quantization
  accQuantized <= unsigned(accumulator(26 DOWNTO 7));

  outsine_signed <= signed(outsine);

  -- Output sine register
  OutSineRegister_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        sine_tmp <= to_signed(16#00000#, 20);
      ELSIF enb = '1' THEN
        sine_tmp <= outsine_signed;
      END IF;
    END IF;
  END PROCESS OutSineRegister_process;


  sine <= std_logic_vector(sine_tmp);

  outcos_signed <= signed(outcos);

  -- Output cosine register
  OutCosineRegister_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        cosine_tmp <= to_signed(16#00000#, 20);
      ELSIF enb = '1' THEN
        cosine_tmp <= outcos_signed;
      END IF;
    END IF;
  END PROCESS OutCosineRegister_process;


  cosine <= std_logic_vector(cosine_tmp);

  -- validOut register
  validOut_reg_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        validOut_reg_reg <= (OTHERS => '0');
      ELSIF enb = '1' THEN
        validOut_reg_reg(0) <= validIn;
        validOut_reg_reg(1 TO 5) <= validOut_reg_reg(0 TO 4);
      END IF;
    END IF;
  END PROCESS validOut_reg_process;

  validOut <= validOut_reg_reg(5);

END rtl;

