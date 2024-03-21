
-- -------------------------------------------------------------
-- HDL Code Generation Options:
--
-- TargetLanguage: VHDL
-- MultiplierInputPipeline: 2
-- MultiplierOutputPipeline: 2
-- TargetDirectory: ddc_temp3
-- AddPipelineRegisters: on
-- Name: ddc_filters
-- InputComplex: on
-- AddRatePort: on
-- TestBenchName: ddc_filters_tb
-- TestBenchUserStimulus:  User data, length 16000
-- TestBenchRateStimulus: 3

-- -------------------------------------------------------------
-- HDL Implementation    : Fully parallel
-- -------------------------------------------------------------
-- Filter Settings:
--
-- Discrete-Time FIR Multirate Filter (real)
-- -----------------------------------------
-- Filter Structure        : Cascaded Integrator-Comb Decimator
-- Decimation Factor       : 128
-- Differential Delay      : 1
-- Number of Sections      : 5
-- Stable                  : Yes
-- Linear Phase            : Yes (Type 2)
--
-- Input                   : s14,0
-- Output                  : s16,0
-- Filter Internals        : Specified Word Lengths and Fraction Lengths
--   Integrator Section 1  : s49,0
--   Integrator Section 2  : s49,0
--   Integrator Section 3  : s49,0
--   Integrator Section 4  : s49,0
--   Integrator Section 5  : s49,0
--   Comb Section 1        : s49,0
--   Comb Section 2        : s49,0
--   Comb Section 3        : s49,0
--   Comb Section 4        : s49,0
--   Comb Section 5        : s49,0
-- -------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;
ENTITY SDRDDCStage1 IS
   PORT( clk                             :   IN    std_logic; 
         clk_enable_stage1               :   IN    std_logic; 
         reset                           :   IN    std_logic; 
         filter_in_stage1_re             :   IN    std_logic_vector(13 DOWNTO 0); -- sfix14
         filter_in_stage1_im             :   IN    std_logic_vector(13 DOWNTO 0); -- sfix14
         rate                            :   IN    std_logic_vector(7 DOWNTO 0); -- ufix8
         filter_out_stage1_re            :   OUT   std_logic_vector(15 DOWNTO 0); -- sfix16
         filter_out_stage1_im            :   OUT   std_logic_vector(15 DOWNTO 0); -- sfix16
         ce_out_stage1                   :   OUT   std_logic  
         );

END SDRDDCStage1;


----------------------------------------------------------------
--Module Architecture: SDRDDCStage1
----------------------------------------------------------------
ARCHITECTURE rtl OF SDRDDCStage1 IS
  -- Local Functions
  -- Type Definitions
  -- Constants
  -- Signals
  SIGNAL rate_register                    : unsigned(7 DOWNTO 0); -- ufix8
  SIGNAL cur_count                        : unsigned(7 DOWNTO 0); -- ufix8
  SIGNAL phase_1                          : std_logic; -- boolean
  SIGNAL ce_delayline                     : std_logic; -- boolean
  SIGNAL int_delay_pipe                   : std_logic_vector(0 TO 3); -- boolean
  SIGNAL ce_gated                         : std_logic; -- boolean
  SIGNAL ce_out_reg                       : std_logic; -- boolean
  --   
  SIGNAL input_register_re                : signed(13 DOWNTO 0); -- sfix14
  SIGNAL input_register_im                : signed(13 DOWNTO 0); -- sfix14
  --   -- Section 1 Signals 
  SIGNAL section_in1_re                   : signed(13 DOWNTO 0); -- sfix14
  SIGNAL section_in1_im                   : signed(13 DOWNTO 0); -- sfix14
  SIGNAL section_cast1_re                 : signed(48 DOWNTO 0); -- sfix49
  SIGNAL section_cast1_im                 : signed(48 DOWNTO 0); -- sfix49
  SIGNAL sum1_re                          : signed(48 DOWNTO 0); -- sfix49
  SIGNAL sum1_im                          : signed(48 DOWNTO 0); -- sfix49
  SIGNAL section_out1_re                  : signed(48 DOWNTO 0); -- sfix49
  SIGNAL section_out1_im                  : signed(48 DOWNTO 0); -- sfix49
  SIGNAL add_cast                         : signed(48 DOWNTO 0); -- sfix49
  SIGNAL add_cast_1                       : signed(48 DOWNTO 0); -- sfix49
  SIGNAL add_temp                         : signed(49 DOWNTO 0); -- sfix50
  SIGNAL add_cast_2                       : signed(48 DOWNTO 0); -- sfix49
  SIGNAL add_cast_3                       : signed(48 DOWNTO 0); -- sfix49
  SIGNAL add_temp_1                       : signed(49 DOWNTO 0); -- sfix50
  --   -- Section 2 Signals 
  SIGNAL section_in2_re                   : signed(48 DOWNTO 0); -- sfix49
  SIGNAL section_in2_im                   : signed(48 DOWNTO 0); -- sfix49
  SIGNAL sum2_re                          : signed(48 DOWNTO 0); -- sfix49
  SIGNAL sum2_im                          : signed(48 DOWNTO 0); -- sfix49
  SIGNAL section_out2_re                  : signed(48 DOWNTO 0); -- sfix49
  SIGNAL section_out2_im                  : signed(48 DOWNTO 0); -- sfix49
  SIGNAL add_cast_4                       : signed(48 DOWNTO 0); -- sfix49
  SIGNAL add_cast_5                       : signed(48 DOWNTO 0); -- sfix49
  SIGNAL add_temp_2                       : signed(49 DOWNTO 0); -- sfix50
  SIGNAL add_cast_6                       : signed(48 DOWNTO 0); -- sfix49
  SIGNAL add_cast_7                       : signed(48 DOWNTO 0); -- sfix49
  SIGNAL add_temp_3                       : signed(49 DOWNTO 0); -- sfix50
  --   -- Section 3 Signals 
  SIGNAL section_in3_re                   : signed(48 DOWNTO 0); -- sfix49
  SIGNAL section_in3_im                   : signed(48 DOWNTO 0); -- sfix49
  SIGNAL sum3_re                          : signed(48 DOWNTO 0); -- sfix49
  SIGNAL sum3_im                          : signed(48 DOWNTO 0); -- sfix49
  SIGNAL section_out3_re                  : signed(48 DOWNTO 0); -- sfix49
  SIGNAL section_out3_im                  : signed(48 DOWNTO 0); -- sfix49
  SIGNAL add_cast_8                       : signed(48 DOWNTO 0); -- sfix49
  SIGNAL add_cast_9                       : signed(48 DOWNTO 0); -- sfix49
  SIGNAL add_temp_4                       : signed(49 DOWNTO 0); -- sfix50
  SIGNAL add_cast_10                      : signed(48 DOWNTO 0); -- sfix49
  SIGNAL add_cast_11                      : signed(48 DOWNTO 0); -- sfix49
  SIGNAL add_temp_5                       : signed(49 DOWNTO 0); -- sfix50
  --   -- Section 4 Signals 
  SIGNAL section_in4_re                   : signed(48 DOWNTO 0); -- sfix49
  SIGNAL section_in4_im                   : signed(48 DOWNTO 0); -- sfix49
  SIGNAL sum4_re                          : signed(48 DOWNTO 0); -- sfix49
  SIGNAL sum4_im                          : signed(48 DOWNTO 0); -- sfix49
  SIGNAL section_out4_re                  : signed(48 DOWNTO 0); -- sfix49
  SIGNAL section_out4_im                  : signed(48 DOWNTO 0); -- sfix49
  SIGNAL add_cast_12                      : signed(48 DOWNTO 0); -- sfix49
  SIGNAL add_cast_13                      : signed(48 DOWNTO 0); -- sfix49
  SIGNAL add_temp_6                       : signed(49 DOWNTO 0); -- sfix50
  SIGNAL add_cast_14                      : signed(48 DOWNTO 0); -- sfix49
  SIGNAL add_cast_15                      : signed(48 DOWNTO 0); -- sfix49
  SIGNAL add_temp_7                       : signed(49 DOWNTO 0); -- sfix50
  --   -- Section 5 Signals 
  SIGNAL section_in5_re                   : signed(48 DOWNTO 0); -- sfix49
  SIGNAL section_in5_im                   : signed(48 DOWNTO 0); -- sfix49
  SIGNAL sum5_re                          : signed(48 DOWNTO 0); -- sfix49
  SIGNAL sum5_im                          : signed(48 DOWNTO 0); -- sfix49
  SIGNAL section_out5_re                  : signed(48 DOWNTO 0); -- sfix49
  SIGNAL section_out5_im                  : signed(48 DOWNTO 0); -- sfix49
  SIGNAL add_cast_16                      : signed(48 DOWNTO 0); -- sfix49
  SIGNAL add_cast_17                      : signed(48 DOWNTO 0); -- sfix49
  SIGNAL add_temp_8                       : signed(49 DOWNTO 0); -- sfix50
  SIGNAL add_cast_18                      : signed(48 DOWNTO 0); -- sfix49
  SIGNAL add_cast_19                      : signed(48 DOWNTO 0); -- sfix49
  SIGNAL add_temp_9                       : signed(49 DOWNTO 0); -- sfix50
  --   -- Section 6 Signals 
  SIGNAL section_in6_re                   : signed(48 DOWNTO 0); -- sfix49
  SIGNAL section_in6_im                   : signed(48 DOWNTO 0); -- sfix49
  SIGNAL diff1_re                         : signed(48 DOWNTO 0); -- sfix49
  SIGNAL diff1_im                         : signed(48 DOWNTO 0); -- sfix49
  SIGNAL section_out6_re                  : signed(48 DOWNTO 0); -- sfix49
  SIGNAL section_out6_im                  : signed(48 DOWNTO 0); -- sfix49
  SIGNAL sub_cast                         : signed(48 DOWNTO 0); -- sfix49
  SIGNAL sub_cast_1                       : signed(48 DOWNTO 0); -- sfix49
  SIGNAL sub_temp                         : signed(49 DOWNTO 0); -- sfix50
  SIGNAL sub_cast_2                       : signed(48 DOWNTO 0); -- sfix49
  SIGNAL sub_cast_3                       : signed(48 DOWNTO 0); -- sfix49
  SIGNAL sub_temp_1                       : signed(49 DOWNTO 0); -- sfix50
  SIGNAL cic_pipeline6_re                 : signed(48 DOWNTO 0); -- sfix49
  SIGNAL cic_pipeline6_im                 : signed(48 DOWNTO 0); -- sfix49
  --   -- Section 7 Signals 
  SIGNAL section_in7_re                   : signed(48 DOWNTO 0); -- sfix49
  SIGNAL section_in7_im                   : signed(48 DOWNTO 0); -- sfix49
  SIGNAL diff2_re                         : signed(48 DOWNTO 0); -- sfix49
  SIGNAL diff2_im                         : signed(48 DOWNTO 0); -- sfix49
  SIGNAL section_out7_re                  : signed(48 DOWNTO 0); -- sfix49
  SIGNAL section_out7_im                  : signed(48 DOWNTO 0); -- sfix49
  SIGNAL sub_cast_4                       : signed(48 DOWNTO 0); -- sfix49
  SIGNAL sub_cast_5                       : signed(48 DOWNTO 0); -- sfix49
  SIGNAL sub_temp_2                       : signed(49 DOWNTO 0); -- sfix50
  SIGNAL sub_cast_6                       : signed(48 DOWNTO 0); -- sfix49
  SIGNAL sub_cast_7                       : signed(48 DOWNTO 0); -- sfix49
  SIGNAL sub_temp_3                       : signed(49 DOWNTO 0); -- sfix50
  SIGNAL cic_pipeline7_re                 : signed(48 DOWNTO 0); -- sfix49
  SIGNAL cic_pipeline7_im                 : signed(48 DOWNTO 0); -- sfix49
  --   -- Section 8 Signals 
  SIGNAL section_in8_re                   : signed(48 DOWNTO 0); -- sfix49
  SIGNAL section_in8_im                   : signed(48 DOWNTO 0); -- sfix49
  SIGNAL diff3_re                         : signed(48 DOWNTO 0); -- sfix49
  SIGNAL diff3_im                         : signed(48 DOWNTO 0); -- sfix49
  SIGNAL section_out8_re                  : signed(48 DOWNTO 0); -- sfix49
  SIGNAL section_out8_im                  : signed(48 DOWNTO 0); -- sfix49
  SIGNAL sub_cast_8                       : signed(48 DOWNTO 0); -- sfix49
  SIGNAL sub_cast_9                       : signed(48 DOWNTO 0); -- sfix49
  SIGNAL sub_temp_4                       : signed(49 DOWNTO 0); -- sfix50
  SIGNAL sub_cast_10                      : signed(48 DOWNTO 0); -- sfix49
  SIGNAL sub_cast_11                      : signed(48 DOWNTO 0); -- sfix49
  SIGNAL sub_temp_5                       : signed(49 DOWNTO 0); -- sfix50
  SIGNAL cic_pipeline8_re                 : signed(48 DOWNTO 0); -- sfix49
  SIGNAL cic_pipeline8_im                 : signed(48 DOWNTO 0); -- sfix49
  --   -- Section 9 Signals 
  SIGNAL section_in9_re                   : signed(48 DOWNTO 0); -- sfix49
  SIGNAL section_in9_im                   : signed(48 DOWNTO 0); -- sfix49
  SIGNAL diff4_re                         : signed(48 DOWNTO 0); -- sfix49
  SIGNAL diff4_im                         : signed(48 DOWNTO 0); -- sfix49
  SIGNAL section_out9_re                  : signed(48 DOWNTO 0); -- sfix49
  SIGNAL section_out9_im                  : signed(48 DOWNTO 0); -- sfix49
  SIGNAL sub_cast_12                      : signed(48 DOWNTO 0); -- sfix49
  SIGNAL sub_cast_13                      : signed(48 DOWNTO 0); -- sfix49
  SIGNAL sub_temp_6                       : signed(49 DOWNTO 0); -- sfix50
  SIGNAL sub_cast_14                      : signed(48 DOWNTO 0); -- sfix49
  SIGNAL sub_cast_15                      : signed(48 DOWNTO 0); -- sfix49
  SIGNAL sub_temp_7                       : signed(49 DOWNTO 0); -- sfix50
  SIGNAL cic_pipeline9_re                 : signed(48 DOWNTO 0); -- sfix49
  SIGNAL cic_pipeline9_im                 : signed(48 DOWNTO 0); -- sfix49
  --   -- Section 10 Signals 
  SIGNAL section_in10_re                  : signed(48 DOWNTO 0); -- sfix49
  SIGNAL section_in10_im                  : signed(48 DOWNTO 0); -- sfix49
  SIGNAL diff5_re                         : signed(48 DOWNTO 0); -- sfix49
  SIGNAL diff5_im                         : signed(48 DOWNTO 0); -- sfix49
  SIGNAL section_out10_re                 : signed(48 DOWNTO 0); -- sfix49
  SIGNAL section_out10_im                 : signed(48 DOWNTO 0); -- sfix49
  SIGNAL sub_cast_16                      : signed(48 DOWNTO 0); -- sfix49
  SIGNAL sub_cast_17                      : signed(48 DOWNTO 0); -- sfix49
  SIGNAL sub_temp_8                       : signed(49 DOWNTO 0); -- sfix50
  SIGNAL sub_cast_18                      : signed(48 DOWNTO 0); -- sfix49
  SIGNAL sub_cast_19                      : signed(48 DOWNTO 0); -- sfix49
  SIGNAL sub_temp_9                       : signed(49 DOWNTO 0); -- sfix50
  SIGNAL bitgain                          : unsigned(5 DOWNTO 0); -- ufix6
  SIGNAL output_typeconvert_re            : signed(15 DOWNTO 0); -- sfix16
  SIGNAL output_typeconvert_im            : signed(15 DOWNTO 0); -- sfix16
  SIGNAL muxinput_0_re                    : signed(15 DOWNTO 0); -- sfix16
  SIGNAL muxinput_0_im                    : signed(15 DOWNTO 0); -- sfix16
  SIGNAL muxinput_5_re                    : signed(15 DOWNTO 0); -- sfix16_E5
  SIGNAL muxinput_5_im                    : signed(15 DOWNTO 0); -- sfix16_E5
  SIGNAL muxinput_8_re                    : signed(15 DOWNTO 0); -- sfix16_E8
  SIGNAL muxinput_8_im                    : signed(15 DOWNTO 0); -- sfix16_E8
  SIGNAL muxinput_10_re                   : signed(15 DOWNTO 0); -- sfix16_E10
  SIGNAL muxinput_10_im                   : signed(15 DOWNTO 0); -- sfix16_E10
  SIGNAL muxinput_12_re                   : signed(15 DOWNTO 0); -- sfix16_E12
  SIGNAL muxinput_12_im                   : signed(15 DOWNTO 0); -- sfix16_E12
  SIGNAL muxinput_13_re                   : signed(15 DOWNTO 0); -- sfix16_E13
  SIGNAL muxinput_13_im                   : signed(15 DOWNTO 0); -- sfix16_E13
  SIGNAL muxinput_15_re                   : signed(15 DOWNTO 0); -- sfix16_E15
  SIGNAL muxinput_15_im                   : signed(15 DOWNTO 0); -- sfix16_E15
  SIGNAL muxinput_16_re                   : signed(15 DOWNTO 0); -- sfix16_E16
  SIGNAL muxinput_16_im                   : signed(15 DOWNTO 0); -- sfix16_E16
  SIGNAL muxinput_17_re                   : signed(15 DOWNTO 0); -- sfix16_E17
  SIGNAL muxinput_17_im                   : signed(15 DOWNTO 0); -- sfix16_E17
  SIGNAL muxinput_18_re                   : signed(15 DOWNTO 0); -- sfix16_E18
  SIGNAL muxinput_18_im                   : signed(15 DOWNTO 0); -- sfix16_E18
  SIGNAL muxinput_19_re                   : signed(15 DOWNTO 0); -- sfix16_E19
  SIGNAL muxinput_19_im                   : signed(15 DOWNTO 0); -- sfix16_E19
  SIGNAL muxinput_20_re                   : signed(15 DOWNTO 0); -- sfix16_E20
  SIGNAL muxinput_20_im                   : signed(15 DOWNTO 0); -- sfix16_E20
  SIGNAL muxinput_21_re                   : signed(15 DOWNTO 0); -- sfix16_E21
  SIGNAL muxinput_21_im                   : signed(15 DOWNTO 0); -- sfix16_E21
  SIGNAL muxinput_22_re                   : signed(15 DOWNTO 0); -- sfix16_E22
  SIGNAL muxinput_22_im                   : signed(15 DOWNTO 0); -- sfix16_E22
  SIGNAL muxinput_23_re                   : signed(15 DOWNTO 0); -- sfix16_E23
  SIGNAL muxinput_23_im                   : signed(15 DOWNTO 0); -- sfix16_E23
  SIGNAL muxinput_24_re                   : signed(15 DOWNTO 0); -- sfix16_E24
  SIGNAL muxinput_24_im                   : signed(15 DOWNTO 0); -- sfix16_E24
  SIGNAL muxinput_25_re                   : signed(15 DOWNTO 0); -- sfix16_E25
  SIGNAL muxinput_25_im                   : signed(15 DOWNTO 0); -- sfix16_E25
  SIGNAL muxinput_26_re                   : signed(15 DOWNTO 0); -- sfix16_E26
  SIGNAL muxinput_26_im                   : signed(15 DOWNTO 0); -- sfix16_E26
  SIGNAL muxinput_27_re                   : signed(15 DOWNTO 0); -- sfix16_E27
  SIGNAL muxinput_27_im                   : signed(15 DOWNTO 0); -- sfix16_E27
  SIGNAL muxinput_28_re                   : signed(15 DOWNTO 0); -- sfix16_E28
  SIGNAL muxinput_28_im                   : signed(15 DOWNTO 0); -- sfix16_E28
  SIGNAL muxinput_29_re                   : signed(15 DOWNTO 0); -- sfix16_E29
  SIGNAL muxinput_29_im                   : signed(15 DOWNTO 0); -- sfix16_E29
  SIGNAL muxinput_30_re                   : signed(15 DOWNTO 0); -- sfix16_E30
  SIGNAL muxinput_30_im                   : signed(15 DOWNTO 0); -- sfix16_E30
  SIGNAL muxinput_31_re                   : signed(15 DOWNTO 0); -- sfix16_E31
  SIGNAL muxinput_31_im                   : signed(15 DOWNTO 0); -- sfix16_E31
  SIGNAL muxinput_32_re                   : signed(15 DOWNTO 0); -- sfix16_E32
  SIGNAL muxinput_32_im                   : signed(15 DOWNTO 0); -- sfix16_E32
  SIGNAL muxinput_33_re                   : signed(15 DOWNTO 0); -- sfix16_E33
  SIGNAL muxinput_33_im                   : signed(15 DOWNTO 0); -- sfix16_E33
  SIGNAL muxinput_34_re                   : signed(15 DOWNTO 0); -- sfix16_E34
  SIGNAL muxinput_34_im                   : signed(15 DOWNTO 0); -- sfix16_E34
  SIGNAL muxinput_35_re                   : signed(15 DOWNTO 0); -- sfix16_E35
  SIGNAL muxinput_35_im                   : signed(15 DOWNTO 0); -- sfix16_E35
  --   
  SIGNAL output_register_re               : signed(15 DOWNTO 0); -- sfix16
  SIGNAL output_register_im               : signed(15 DOWNTO 0); -- sfix16


BEGIN

  -- Block Statements
  --   ------------------ CE Output Generation ------------------

  ce_output : PROCESS (clk)
  BEGIN
   IF clk'event AND clk = '1' THEN
     IF reset = '1' THEN
       cur_count <= to_unsigned(0, 8);
     ELSIF clk_enable_stage1 = '1' THEN
        IF cur_count = rate_register - 1 THEN
          cur_count <= to_unsigned(0, 8);
        ELSE
          cur_count <= cur_count + 1;
        END IF;
     END IF;
   END IF; 
  END PROCESS ce_output;

  phase_1 <= '1' WHEN cur_count = to_unsigned(1, 8) AND clk_enable_stage1 = '1' ELSE '0';

  ce_delay : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
        int_delay_pipe <= (OTHERS => '0');
      ELSIF phase_1 = '1' THEN
        int_delay_pipe(1 TO 3) <= int_delay_pipe(0 TO 2);
        int_delay_pipe(0) <= clk_enable_stage1;
      END IF;
    END IF;
  END PROCESS ce_delay;
  ce_delayline <= int_delay_pipe(3);

  ce_gated <=  ce_delayline AND phase_1;

  --   ------------------ CE Output Register ------------------

  ce_output_register : PROCESS (clk, reset)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
        ce_out_reg <= '0';
      ELSE
        ce_out_reg <= ce_gated;
      END IF; 
    END if;
  END PROCESS ce_output_register;

  --   ------------------ Input Register ------------------

  input_reg_process : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
         input_register_re <= (OTHERS => '0');
         input_register_im <= (OTHERS => '0');
         --rate_register <= (OTHERS => '0');
      ELSIF clk_enable_stage1 = '1' THEN
        input_register_re <= signed(filter_in_stage1_re);
        input_register_im <= signed(filter_in_stage1_im);
        --rate_register <= unsigned(rate);
      END IF;
    END IF; 
  END PROCESS input_reg_process;
  rate_register <= unsigned(rate);
  --   ------------------ Section # 1 : Integrator ------------------

  section_in1_re <= input_register_re;
  section_in1_im <= input_register_im;

  section_cast1_re <= resize(section_in1_re, 49);
  section_cast1_im <= resize(section_in1_im, 49);

  add_cast <= section_cast1_re;
  add_cast_1 <= section_out1_re;
  add_temp <= resize(add_cast, 50) + resize(add_cast_1, 50);
  sum1_re <= add_temp(48 DOWNTO 0);

  add_cast_2 <= section_cast1_im;
  add_cast_3 <= section_out1_im;
  add_temp_1 <= resize(add_cast_2, 50) + resize(add_cast_3, 50);
  sum1_im <= add_temp_1(48 DOWNTO 0);

  integrator_delay_section1 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
        section_out1_re <= (OTHERS => '0');
        section_out1_im <= (OTHERS => '0');
      ELSIF clk_enable_stage1 = '1' THEN
        section_out1_re <= sum1_re;
        section_out1_im <= sum1_im;
      END IF;
    END IF; 
  END PROCESS integrator_delay_section1;

  --   ------------------ Section # 2 : Integrator ------------------

  section_in2_re <= section_out1_re;
  section_in2_im <= section_out1_im;

  add_cast_4 <= section_in2_re;
  add_cast_5 <= section_out2_re;
  add_temp_2 <= resize(add_cast_4, 50) + resize(add_cast_5, 50);
  sum2_re <= add_temp_2(48 DOWNTO 0);

  add_cast_6 <= section_in2_im;
  add_cast_7 <= section_out2_im;
  add_temp_3 <= resize(add_cast_6, 50) + resize(add_cast_7, 50);
  sum2_im <= add_temp_3(48 DOWNTO 0);

  integrator_delay_section2 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
        section_out2_re <= (OTHERS => '0');
        section_out2_im <= (OTHERS => '0');
      ELSIF clk_enable_stage1 = '1' THEN
        section_out2_re <= sum2_re;
        section_out2_im <= sum2_im;
      END IF;
    END IF; 
  END PROCESS integrator_delay_section2;

  --   ------------------ Section # 3 : Integrator ------------------

  section_in3_re <= section_out2_re;
  section_in3_im <= section_out2_im;

  add_cast_8 <= section_in3_re;
  add_cast_9 <= section_out3_re;
  add_temp_4 <= resize(add_cast_8, 50) + resize(add_cast_9, 50);
  sum3_re <= add_temp_4(48 DOWNTO 0);

  add_cast_10 <= section_in3_im;
  add_cast_11 <= section_out3_im;
  add_temp_5 <= resize(add_cast_10, 50) + resize(add_cast_11, 50);
  sum3_im <= add_temp_5(48 DOWNTO 0);

  integrator_delay_section3 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
        section_out3_re <= (OTHERS => '0');
        section_out3_im <= (OTHERS => '0');
      ELSIF clk_enable_stage1 = '1' THEN
        section_out3_re <= sum3_re;
        section_out3_im <= sum3_im;
      END IF;
    END IF; 
  END PROCESS integrator_delay_section3;

  --   ------------------ Section # 4 : Integrator ------------------

  section_in4_re <= section_out3_re;
  section_in4_im <= section_out3_im;

  add_cast_12 <= section_in4_re;
  add_cast_13 <= section_out4_re;
  add_temp_6 <= resize(add_cast_12, 50) + resize(add_cast_13, 50);
  sum4_re <= add_temp_6(48 DOWNTO 0);

  add_cast_14 <= section_in4_im;
  add_cast_15 <= section_out4_im;
  add_temp_7 <= resize(add_cast_14, 50) + resize(add_cast_15, 50);
  sum4_im <= add_temp_7(48 DOWNTO 0);

  integrator_delay_section4 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
        section_out4_re <= (OTHERS => '0');
        section_out4_im <= (OTHERS => '0');
      ELSIF clk_enable_stage1 = '1' THEN
        section_out4_re <= sum4_re;
        section_out4_im <= sum4_im;
      END IF;
    END IF; 
  END PROCESS integrator_delay_section4;

  --   ------------------ Section # 5 : Integrator ------------------

  section_in5_re <= section_out4_re;
  section_in5_im <= section_out4_im;

  add_cast_16 <= section_in5_re;
  add_cast_17 <= section_out5_re;
  add_temp_8 <= resize(add_cast_16, 50) + resize(add_cast_17, 50);
  sum5_re <= add_temp_8(48 DOWNTO 0);

  add_cast_18 <= section_in5_im;
  add_cast_19 <= section_out5_im;
  add_temp_9 <= resize(add_cast_18, 50) + resize(add_cast_19, 50);
  sum5_im <= add_temp_9(48 DOWNTO 0);

  integrator_delay_section5 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
        section_out5_re <= (OTHERS => '0');
        section_out5_im <= (OTHERS => '0');
      ELSIF clk_enable_stage1 = '1' THEN
        section_out5_re <= sum5_re;
        section_out5_im <= sum5_im;
      END IF;
    END IF; 
  END PROCESS integrator_delay_section5;

  --   ------------------ Section # 6 : Comb ------------------

  section_in6_re <= section_out5_re;
  section_in6_im <= section_out5_im;

  sub_cast <= section_in6_re;
  sub_cast_1 <= diff1_re;
  sub_temp <= resize(sub_cast, 50) - resize(sub_cast_1, 50);
  section_out6_re <= sub_temp(48 DOWNTO 0);

  sub_cast_2 <= section_in6_im;
  sub_cast_3 <= diff1_im;
  sub_temp_1 <= resize(sub_cast_2, 50) - resize(sub_cast_3, 50);
  section_out6_im <= sub_temp_1(48 DOWNTO 0);

  comb_delay_section6 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
        diff1_re <= (OTHERS => '0');
        diff1_im <= (OTHERS => '0');
      ELSIF phase_1 = '1' THEN
        diff1_re <= section_in6_re;
        diff1_im <= section_in6_im;
      END IF;
    END IF; 
  END PROCESS comb_delay_section6;

  cic_pipeline_process_section6 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
        cic_pipeline6_re <= (OTHERS => '0');
        cic_pipeline6_im <= (OTHERS => '0');
      ELSIF phase_1 = '1' THEN
        cic_pipeline6_re <= section_out6_re;
        cic_pipeline6_im <= section_out6_im;
      END IF;
    END IF; 
  END PROCESS cic_pipeline_process_section6;

  --   ------------------ Section # 7 : Comb ------------------

  section_in7_re <= cic_pipeline6_re;
  section_in7_im <= cic_pipeline6_im;

  sub_cast_4 <= section_in7_re;
  sub_cast_5 <= diff2_re;
  sub_temp_2 <= resize(sub_cast_4, 50) - resize(sub_cast_5, 50);
  section_out7_re <= sub_temp_2(48 DOWNTO 0);

  sub_cast_6 <= section_in7_im;
  sub_cast_7 <= diff2_im;
  sub_temp_3 <= resize(sub_cast_6, 50) - resize(sub_cast_7, 50);
  section_out7_im <= sub_temp_3(48 DOWNTO 0);

  comb_delay_section7 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
        diff2_re <= (OTHERS => '0');
        diff2_im <= (OTHERS => '0');
      ELSIF phase_1 = '1' THEN
        diff2_re <= section_in7_re;
        diff2_im <= section_in7_im;
      END IF;
    END IF; 
  END PROCESS comb_delay_section7;

  cic_pipeline_process_section7 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
        cic_pipeline7_re <= (OTHERS => '0');
        cic_pipeline7_im <= (OTHERS => '0');
      ELSIF phase_1 = '1' THEN
        cic_pipeline7_re <= section_out7_re;
        cic_pipeline7_im <= section_out7_im;
      END IF;
    END IF; 
  END PROCESS cic_pipeline_process_section7;

  --   ------------------ Section # 8 : Comb ------------------

  section_in8_re <= cic_pipeline7_re;
  section_in8_im <= cic_pipeline7_im;

  sub_cast_8 <= section_in8_re;
  sub_cast_9 <= diff3_re;
  sub_temp_4 <= resize(sub_cast_8, 50) - resize(sub_cast_9, 50);
  section_out8_re <= sub_temp_4(48 DOWNTO 0);

  sub_cast_10 <= section_in8_im;
  sub_cast_11 <= diff3_im;
  sub_temp_5 <= resize(sub_cast_10, 50) - resize(sub_cast_11, 50);
  section_out8_im <= sub_temp_5(48 DOWNTO 0);

  comb_delay_section8 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
        diff3_re <= (OTHERS => '0');
        diff3_im <= (OTHERS => '0');
      ELSIF phase_1 = '1' THEN
        diff3_re <= section_in8_re;
        diff3_im <= section_in8_im;
      END IF;
    END IF; 
  END PROCESS comb_delay_section8;

  cic_pipeline_process_section8 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
        cic_pipeline8_re <= (OTHERS => '0');
        cic_pipeline8_im <= (OTHERS => '0');
      ELSIF phase_1 = '1' THEN
        cic_pipeline8_re <= section_out8_re;
        cic_pipeline8_im <= section_out8_im;
      END IF;
    END IF; 
  END PROCESS cic_pipeline_process_section8;

  --   ------------------ Section # 9 : Comb ------------------

  section_in9_re <= cic_pipeline8_re;
  section_in9_im <= cic_pipeline8_im;

  sub_cast_12 <= section_in9_re;
  sub_cast_13 <= diff4_re;
  sub_temp_6 <= resize(sub_cast_12, 50) - resize(sub_cast_13, 50);
  section_out9_re <= sub_temp_6(48 DOWNTO 0);

  sub_cast_14 <= section_in9_im;
  sub_cast_15 <= diff4_im;
  sub_temp_7 <= resize(sub_cast_14, 50) - resize(sub_cast_15, 50);
  section_out9_im <= sub_temp_7(48 DOWNTO 0);

  comb_delay_section9 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
        diff4_re <= (OTHERS => '0');
        diff4_im <= (OTHERS => '0');
      ELSIF phase_1 = '1' THEN
        diff4_re <= section_in9_re;
        diff4_im <= section_in9_im;
      END IF;
    END IF; 
  END PROCESS comb_delay_section9;

  cic_pipeline_process_section9 : PROCESS (clk)
  BEGIN
     IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
        cic_pipeline9_re <= (OTHERS => '0');
        cic_pipeline9_im <= (OTHERS => '0');
      ELSIF phase_1 = '1' THEN
        cic_pipeline9_re <= section_out9_re;
        cic_pipeline9_im <= section_out9_im;
      END IF;
    END IF; 
  END PROCESS cic_pipeline_process_section9;

  --   ------------------ Section # 10 : Comb ------------------

  section_in10_re <= cic_pipeline9_re;
  section_in10_im <= cic_pipeline9_im;

  sub_cast_16 <= section_in10_re;
  sub_cast_17 <= diff5_re;
  sub_temp_8 <= resize(sub_cast_16, 50) - resize(sub_cast_17, 50);
  section_out10_re <= sub_temp_8(48 DOWNTO 0);

  sub_cast_18 <= section_in10_im;
  sub_cast_19 <= diff5_im;
  sub_temp_9 <= resize(sub_cast_18, 50) - resize(sub_cast_19, 50);
  section_out10_im <= sub_temp_9(48 DOWNTO 0);

  comb_delay_section10 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
        diff5_re <= (OTHERS => '0');
        diff5_im <= (OTHERS => '0');
      ELSIF phase_1 = '1' THEN
        diff5_re <= section_in10_re;
        diff5_im <= section_in10_im;
      END IF;
    END IF; 
  END PROCESS comb_delay_section10;

  PROCESS(rate_register)
  BEGIN
    CASE rate_register IS
      WHEN "00000001" => bitgain <= "000000";
      WHEN "00000010" => bitgain <= "000101";
      WHEN "00000011" => bitgain <= "001000";
      WHEN "00000100" => bitgain <= "001010";
      WHEN "00000101" => bitgain <= "001100";
      WHEN "00000110" => bitgain <= "001101";
      WHEN "00000111" => bitgain <= "001111";
      WHEN "00001000" => bitgain <= "001111";
      WHEN "00001001" => bitgain <= "010000";
      WHEN "00001010" => bitgain <= "010001";
      WHEN "00001011" => bitgain <= "010010";
      WHEN "00001100" => bitgain <= "010010";
      WHEN "00001101" => bitgain <= "010011";
      WHEN "00001110" => bitgain <= "010100";
      WHEN "00001111" => bitgain <= "010100";
      WHEN "00010000" => bitgain <= "010100";
      WHEN "00010001" => bitgain <= "010101";
      WHEN "00010010" => bitgain <= "010101";
      WHEN "00010011" => bitgain <= "010110";
      WHEN "00010100" => bitgain <= "010110";
      WHEN "00010101" => bitgain <= "010110";
      WHEN "00010110" => bitgain <= "010111";
      WHEN "00010111" => bitgain <= "010111";
      WHEN "00011000" => bitgain <= "010111";
      WHEN "00011001" => bitgain <= "011000";
      WHEN "00011010" => bitgain <= "011000";
      WHEN "00011011" => bitgain <= "011000";
      WHEN "00011100" => bitgain <= "011001";
      WHEN "00011101" => bitgain <= "011001";
      WHEN "00011110" => bitgain <= "011001";
      WHEN "00011111" => bitgain <= "011001";
      WHEN "00100000" => bitgain <= "011001";
      WHEN "00100001" => bitgain <= "011010";
      WHEN "00100010" => bitgain <= "011010";
      WHEN "00100011" => bitgain <= "011010";
      WHEN "00100100" => bitgain <= "011010";
      WHEN "00100101" => bitgain <= "011011";
      WHEN "00100110" => bitgain <= "011011";
      WHEN "00100111" => bitgain <= "011011";
      WHEN "00101000" => bitgain <= "011011";
      WHEN "00101001" => bitgain <= "011011";
      WHEN "00101010" => bitgain <= "011011";
      WHEN "00101011" => bitgain <= "011100";
      WHEN "00101100" => bitgain <= "011100";
      WHEN "00101101" => bitgain <= "011100";
      WHEN "00101110" => bitgain <= "011100";
      WHEN "00101111" => bitgain <= "011100";
      WHEN "00110000" => bitgain <= "011100";
      WHEN "00110001" => bitgain <= "011101";
      WHEN "00110010" => bitgain <= "011101";
      WHEN "00110011" => bitgain <= "011101";
      WHEN "00110100" => bitgain <= "011101";
      WHEN "00110101" => bitgain <= "011101";
      WHEN "00110110" => bitgain <= "011101";
      WHEN "00110111" => bitgain <= "011101";
      WHEN "00111000" => bitgain <= "011110";
      WHEN "00111001" => bitgain <= "011110";
      WHEN "00111010" => bitgain <= "011110";
      WHEN "00111011" => bitgain <= "011110";
      WHEN "00111100" => bitgain <= "011110";
      WHEN "00111101" => bitgain <= "011110";
      WHEN "00111110" => bitgain <= "011110";
      WHEN "00111111" => bitgain <= "011110";
      WHEN "01000000" => bitgain <= "011110";
      WHEN "01000001" => bitgain <= "011111";
      WHEN "01000010" => bitgain <= "011111";
      WHEN "01000011" => bitgain <= "011111";
      WHEN "01000100" => bitgain <= "011111";
      WHEN "01000101" => bitgain <= "011111";
      WHEN "01000110" => bitgain <= "011111";
      WHEN "01000111" => bitgain <= "011111";
      WHEN "01001000" => bitgain <= "011111";
      WHEN "01001001" => bitgain <= "011111";
      WHEN "01001010" => bitgain <= "100000";
      WHEN "01001011" => bitgain <= "100000";
      WHEN "01001100" => bitgain <= "100000";
      WHEN "01001101" => bitgain <= "100000";
      WHEN "01001110" => bitgain <= "100000";
      WHEN "01001111" => bitgain <= "100000";
      WHEN "01010000" => bitgain <= "100000";
      WHEN "01010001" => bitgain <= "100000";
      WHEN "01010010" => bitgain <= "100000";
      WHEN "01010011" => bitgain <= "100000";
      WHEN "01010100" => bitgain <= "100000";
      WHEN "01010101" => bitgain <= "100001";
      WHEN "01010110" => bitgain <= "100001";
      WHEN "01010111" => bitgain <= "100001";
      WHEN "01011000" => bitgain <= "100001";
      WHEN "01011001" => bitgain <= "100001";
      WHEN "01011010" => bitgain <= "100001";
      WHEN "01011011" => bitgain <= "100001";
      WHEN "01011100" => bitgain <= "100001";
      WHEN "01011101" => bitgain <= "100001";
      WHEN "01011110" => bitgain <= "100001";
      WHEN "01011111" => bitgain <= "100001";
      WHEN "01100000" => bitgain <= "100001";
      WHEN "01100001" => bitgain <= "100001";
      WHEN "01100010" => bitgain <= "100010";
      WHEN "01100011" => bitgain <= "100010";
      WHEN "01100100" => bitgain <= "100010";
      WHEN "01100101" => bitgain <= "100010";
      WHEN "01100110" => bitgain <= "100010";
      WHEN "01100111" => bitgain <= "100010";
      WHEN "01101000" => bitgain <= "100010";
      WHEN "01101001" => bitgain <= "100010";
      WHEN "01101010" => bitgain <= "100010";
      WHEN "01101011" => bitgain <= "100010";
      WHEN "01101100" => bitgain <= "100010";
      WHEN "01101101" => bitgain <= "100010";
      WHEN "01101110" => bitgain <= "100010";
      WHEN "01101111" => bitgain <= "100010";
      WHEN "01110000" => bitgain <= "100011";
      WHEN "01110001" => bitgain <= "100011";
      WHEN "01110010" => bitgain <= "100011";
      WHEN "01110011" => bitgain <= "100011";
      WHEN "01110100" => bitgain <= "100011";
      WHEN "01110101" => bitgain <= "100011";
      WHEN "01110110" => bitgain <= "100011";
      WHEN "01110111" => bitgain <= "100011";
      WHEN "01111000" => bitgain <= "100011";
      WHEN "01111001" => bitgain <= "100011";
      WHEN "01111010" => bitgain <= "100011";
      WHEN "01111011" => bitgain <= "100011";
      WHEN "01111100" => bitgain <= "100011";
      WHEN "01111101" => bitgain <= "100011";
      WHEN "01111110" => bitgain <= "100011";
      WHEN "01111111" => bitgain <= "100011";
      WHEN "10000000" => bitgain <= "100011";
      WHEN OTHERS => bitgain <= "100011";
    END CASE;
  END PROCESS;

  muxinput_0_re <= section_out10_re(15 DOWNTO 0);
  muxinput_0_im <= section_out10_im(15 DOWNTO 0);

  muxinput_5_re <= section_out10_re(20 DOWNTO 5);
  muxinput_5_im <= section_out10_im(20 DOWNTO 5);

  muxinput_8_re <= section_out10_re(23 DOWNTO 8);
  muxinput_8_im <= section_out10_im(23 DOWNTO 8);

  muxinput_10_re <= section_out10_re(25 DOWNTO 10);
  muxinput_10_im <= section_out10_im(25 DOWNTO 10);

  muxinput_12_re <= section_out10_re(27 DOWNTO 12);
  muxinput_12_im <= section_out10_im(27 DOWNTO 12);

  muxinput_13_re <= section_out10_re(28 DOWNTO 13);
  muxinput_13_im <= section_out10_im(28 DOWNTO 13);

  muxinput_15_re <= section_out10_re(30 DOWNTO 15);
  muxinput_15_im <= section_out10_im(30 DOWNTO 15);

  muxinput_16_re <= section_out10_re(31 DOWNTO 16);
  muxinput_16_im <= section_out10_im(31 DOWNTO 16);

  muxinput_17_re <= section_out10_re(32 DOWNTO 17);
  muxinput_17_im <= section_out10_im(32 DOWNTO 17);

  muxinput_18_re <= section_out10_re(33 DOWNTO 18);
  muxinput_18_im <= section_out10_im(33 DOWNTO 18);

  muxinput_19_re <= section_out10_re(34 DOWNTO 19);
  muxinput_19_im <= section_out10_im(34 DOWNTO 19);

  muxinput_20_re <= section_out10_re(35 DOWNTO 20);
  muxinput_20_im <= section_out10_im(35 DOWNTO 20);

  muxinput_21_re <= section_out10_re(36 DOWNTO 21);
  muxinput_21_im <= section_out10_im(36 DOWNTO 21);

  muxinput_22_re <= section_out10_re(37 DOWNTO 22);
  muxinput_22_im <= section_out10_im(37 DOWNTO 22);

  muxinput_23_re <= section_out10_re(38 DOWNTO 23);
  muxinput_23_im <= section_out10_im(38 DOWNTO 23);

  muxinput_24_re <= section_out10_re(39 DOWNTO 24);
  muxinput_24_im <= section_out10_im(39 DOWNTO 24);

  muxinput_25_re <= section_out10_re(40 DOWNTO 25);
  muxinput_25_im <= section_out10_im(40 DOWNTO 25);

  muxinput_26_re <= section_out10_re(41 DOWNTO 26);
  muxinput_26_im <= section_out10_im(41 DOWNTO 26);

  muxinput_27_re <= section_out10_re(42 DOWNTO 27);
  muxinput_27_im <= section_out10_im(42 DOWNTO 27);

  muxinput_28_re <= section_out10_re(43 DOWNTO 28);
  muxinput_28_im <= section_out10_im(43 DOWNTO 28);

  muxinput_29_re <= section_out10_re(44 DOWNTO 29);
  muxinput_29_im <= section_out10_im(44 DOWNTO 29);

  muxinput_30_re <= section_out10_re(45 DOWNTO 30);
  muxinput_30_im <= section_out10_im(45 DOWNTO 30);

  muxinput_31_re <= section_out10_re(46 DOWNTO 31);
  muxinput_31_im <= section_out10_im(46 DOWNTO 31);

  muxinput_32_re <= section_out10_re(47 DOWNTO 32);
  muxinput_32_im <= section_out10_im(47 DOWNTO 32);

  muxinput_33_re <= section_out10_re(48 DOWNTO 33);
  muxinput_33_im <= section_out10_im(48 DOWNTO 33);

  muxinput_34_re <= resize(section_out10_re(48 DOWNTO 34), 16);
  muxinput_34_im <= resize(section_out10_im(48 DOWNTO 34), 16);

  muxinput_35_re <= resize(section_out10_re(48 DOWNTO 35), 16);
  muxinput_35_im <= resize(section_out10_im(48 DOWNTO 35), 16);

  output_typeconvert_re <= muxinput_0_re WHEN ( bitgain = to_unsigned(0, 6) ) ELSE
                                muxinput_5_re WHEN ( bitgain = to_unsigned(5, 6) ) ELSE
                                muxinput_8_re WHEN ( bitgain = to_unsigned(8, 6) ) ELSE
                                muxinput_10_re WHEN ( bitgain = to_unsigned(10, 6) ) ELSE
                                muxinput_12_re WHEN ( bitgain = to_unsigned(12, 6) ) ELSE
                                muxinput_13_re WHEN ( bitgain = to_unsigned(13, 6) ) ELSE
                                muxinput_15_re WHEN ( bitgain = to_unsigned(15, 6) ) ELSE
                                muxinput_16_re WHEN ( bitgain = to_unsigned(16, 6) ) ELSE
                                muxinput_17_re WHEN ( bitgain = to_unsigned(17, 6) ) ELSE
                                muxinput_18_re WHEN ( bitgain = to_unsigned(18, 6) ) ELSE
                                muxinput_19_re WHEN ( bitgain = to_unsigned(19, 6) ) ELSE
                                muxinput_20_re WHEN ( bitgain = to_unsigned(20, 6) ) ELSE
                                muxinput_21_re WHEN ( bitgain = to_unsigned(21, 6) ) ELSE
                                muxinput_22_re WHEN ( bitgain = to_unsigned(22, 6) ) ELSE
                                muxinput_23_re WHEN ( bitgain = to_unsigned(23, 6) ) ELSE
                                muxinput_24_re WHEN ( bitgain = to_unsigned(24, 6) ) ELSE
                                muxinput_25_re WHEN ( bitgain = to_unsigned(25, 6) ) ELSE
                                muxinput_26_re WHEN ( bitgain = to_unsigned(26, 6) ) ELSE
                                muxinput_27_re WHEN ( bitgain = to_unsigned(27, 6) ) ELSE
                                muxinput_28_re WHEN ( bitgain = to_unsigned(28, 6) ) ELSE
                                muxinput_29_re WHEN ( bitgain = to_unsigned(29, 6) ) ELSE
                                muxinput_30_re WHEN ( bitgain = to_unsigned(30, 6) ) ELSE
                                muxinput_31_re WHEN ( bitgain = to_unsigned(31, 6) ) ELSE
                                muxinput_32_re WHEN ( bitgain = to_unsigned(32, 6) ) ELSE
                                muxinput_33_re WHEN ( bitgain = to_unsigned(33, 6) ) ELSE
                                muxinput_34_re WHEN ( bitgain = to_unsigned(34, 6) ) ELSE
                                muxinput_35_re;
  output_typeconvert_im <= muxinput_0_im WHEN ( bitgain = to_unsigned(0, 6) ) ELSE
                                muxinput_5_im WHEN ( bitgain = to_unsigned(5, 6) ) ELSE
                                muxinput_8_im WHEN ( bitgain = to_unsigned(8, 6) ) ELSE
                                muxinput_10_im WHEN ( bitgain = to_unsigned(10, 6) ) ELSE
                                muxinput_12_im WHEN ( bitgain = to_unsigned(12, 6) ) ELSE
                                muxinput_13_im WHEN ( bitgain = to_unsigned(13, 6) ) ELSE
                                muxinput_15_im WHEN ( bitgain = to_unsigned(15, 6) ) ELSE
                                muxinput_16_im WHEN ( bitgain = to_unsigned(16, 6) ) ELSE
                                muxinput_17_im WHEN ( bitgain = to_unsigned(17, 6) ) ELSE
                                muxinput_18_im WHEN ( bitgain = to_unsigned(18, 6) ) ELSE
                                muxinput_19_im WHEN ( bitgain = to_unsigned(19, 6) ) ELSE
                                muxinput_20_im WHEN ( bitgain = to_unsigned(20, 6) ) ELSE
                                muxinput_21_im WHEN ( bitgain = to_unsigned(21, 6) ) ELSE
                                muxinput_22_im WHEN ( bitgain = to_unsigned(22, 6) ) ELSE
                                muxinput_23_im WHEN ( bitgain = to_unsigned(23, 6) ) ELSE
                                muxinput_24_im WHEN ( bitgain = to_unsigned(24, 6) ) ELSE
                                muxinput_25_im WHEN ( bitgain = to_unsigned(25, 6) ) ELSE
                                muxinput_26_im WHEN ( bitgain = to_unsigned(26, 6) ) ELSE
                                muxinput_27_im WHEN ( bitgain = to_unsigned(27, 6) ) ELSE
                                muxinput_28_im WHEN ( bitgain = to_unsigned(28, 6) ) ELSE
                                muxinput_29_im WHEN ( bitgain = to_unsigned(29, 6) ) ELSE
                                muxinput_30_im WHEN ( bitgain = to_unsigned(30, 6) ) ELSE
                                muxinput_31_im WHEN ( bitgain = to_unsigned(31, 6) ) ELSE
                                muxinput_32_im WHEN ( bitgain = to_unsigned(32, 6) ) ELSE
                                muxinput_33_im WHEN ( bitgain = to_unsigned(33, 6) ) ELSE
                                muxinput_34_im WHEN ( bitgain = to_unsigned(34, 6) ) ELSE
                                muxinput_35_im;
  --   ------------------ Output Register ------------------

  output_reg_process : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
        output_register_re <= (OTHERS => '0');
        output_register_im <= (OTHERS => '0');
      ELSIF phase_1 = '1' THEN
        output_register_re <= output_typeconvert_re;
        output_register_im <= output_typeconvert_im;
      END IF;
    END IF; 
  END PROCESS output_reg_process;

  -- Assignment Statements
  ce_out_stage1 <= ce_out_reg;
  filter_out_stage1_re <= std_logic_vector(output_register_re);
  filter_out_stage1_im <= std_logic_vector(output_register_im);
END rtl;
