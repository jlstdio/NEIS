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

-- Filter Specifications:
--
-- Sampling Frequency : N/A (normalized frequency)
-- Response           : Nyquist
-- Specification      : TW,Ast
-- Multirate Type     : Decimator
-- Decimation Factor  : 2
-- Band               : 2
-- Transition Width   : 0.2
-- Stopband Atten.    : 90 dB
-- -------------------------------------------------------------

-- -------------------------------------------------------------
-- HDL Implementation    : Fully parallel
-- Multipliers           : 13
-- Folding Factor        : 1
-- -------------------------------------------------------------
-- Filter Settings:
--
-- Discrete-Time FIR Multirate Filter (real)
-- -----------------------------------------
-- Filter Structure   : Direct-Form FIR Polyphase Decimator
-- Decimation Factor  : 2
-- Polyphase Length   : 28
-- Filter Length      : 55
-- Stable             : Yes
-- Linear Phase       : Yes (Type 1)
--
-- Arithmetic         : fixed
-- Numerator          : s16,15 -> [-1 1)
-- Input              : s16,0 -> [-32768 32768)
-- Filter Internals   : Specify Precision
--   Output           : s16,0 -> [-32768 32768)
--   Product          : s31,15 -> [-32768 32768)
--   Accumulator      : s32,15 -> [-65536 65536)
--   Round Mode       : convergent
--   Overflow Mode    : wrap
-- -------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;
ENTITY SDRDDCStage5 IS
   PORT( clk                             :   IN    std_logic; 
         clk_enable_stage5               :   IN    std_logic; 
         reset                           :   IN    std_logic; 
         filter_in_stage5_re             :   IN    std_logic_vector(15 DOWNTO 0); -- sfix16
         filter_in_stage5_im             :   IN    std_logic_vector(15 DOWNTO 0); -- sfix16
         filter_out_stage5_re            :   OUT   std_logic_vector(15 DOWNTO 0); -- sfix16
         filter_out_stage5_im            :   OUT   std_logic_vector(15 DOWNTO 0); -- sfix16
         ce_out_stage5                   :   OUT   std_logic  
         );

END SDRDDCStage5;


----------------------------------------------------------------
--Module Architecture: SDRDDCStage5
----------------------------------------------------------------
ARCHITECTURE rtl OF SDRDDCStage5 IS
  -- Local Functions
  -- Type Definitions
  TYPE input_pipeline_type IS ARRAY (NATURAL range <>) OF signed(15 DOWNTO 0); -- sfix16
  TYPE vector_of_signed16               IS ARRAY (NATURAL RANGE <>) OF signed(15 DOWNTO 0);
  TYPE vector_of_signed31               IS ARRAY (NATURAL RANGE <>) OF signed(30 DOWNTO 0);
  TYPE sumdelay_pipeline_type IS ARRAY (NATURAL range <>) OF signed(31 DOWNTO 0); -- sfix32_En15
  -- Constants
  CONSTANT coeffphase1_1                  : signed(15 DOWNTO 0) := to_signed(-2, 16); -- sfix16_En15
  CONSTANT coeffphase1_2                  : signed(15 DOWNTO 0) := to_signed(7, 16); -- sfix16_En15
  CONSTANT coeffphase1_3                  : signed(15 DOWNTO 0) := to_signed(-17, 16); -- sfix16_En15
  CONSTANT coeffphase1_4                  : signed(15 DOWNTO 0) := to_signed(36, 16); -- sfix16_En15
  CONSTANT coeffphase1_5                  : signed(15 DOWNTO 0) := to_signed(-69, 16); -- sfix16_En15
  CONSTANT coeffphase1_6                  : signed(15 DOWNTO 0) := to_signed(123, 16); -- sfix16_En15
  CONSTANT coeffphase1_7                  : signed(15 DOWNTO 0) := to_signed(-204, 16); -- sfix16_En15
  CONSTANT coeffphase1_8                  : signed(15 DOWNTO 0) := to_signed(325, 16); -- sfix16_En15
  CONSTANT coeffphase1_9                  : signed(15 DOWNTO 0) := to_signed(-502, 16); -- sfix16_En15
  CONSTANT coeffphase1_10                 : signed(15 DOWNTO 0) := to_signed(761, 16); -- sfix16_En15
  CONSTANT coeffphase1_11                 : signed(15 DOWNTO 0) := to_signed(-1158, 16); -- sfix16_En15
  CONSTANT coeffphase1_12                 : signed(15 DOWNTO 0) := to_signed(1836, 16); -- sfix16_En15
  CONSTANT coeffphase1_13                 : signed(15 DOWNTO 0) := to_signed(-3321, 16); -- sfix16_En15
  CONSTANT coeffphase1_14                 : signed(15 DOWNTO 0) := to_signed(10378, 16); -- sfix16_En15
  CONSTANT coeffphase1_15                 : signed(15 DOWNTO 0) := to_signed(10378, 16); -- sfix16_En15
  CONSTANT coeffphase1_16                 : signed(15 DOWNTO 0) := to_signed(-3321, 16); -- sfix16_En15
  CONSTANT coeffphase1_17                 : signed(15 DOWNTO 0) := to_signed(1836, 16); -- sfix16_En15
  CONSTANT coeffphase1_18                 : signed(15 DOWNTO 0) := to_signed(-1158, 16); -- sfix16_En15
  CONSTANT coeffphase1_19                 : signed(15 DOWNTO 0) := to_signed(761, 16); -- sfix16_En15
  CONSTANT coeffphase1_20                 : signed(15 DOWNTO 0) := to_signed(-502, 16); -- sfix16_En15
  CONSTANT coeffphase1_21                 : signed(15 DOWNTO 0) := to_signed(325, 16); -- sfix16_En15
  CONSTANT coeffphase1_22                 : signed(15 DOWNTO 0) := to_signed(-204, 16); -- sfix16_En15
  CONSTANT coeffphase1_23                 : signed(15 DOWNTO 0) := to_signed(123, 16); -- sfix16_En15
  CONSTANT coeffphase1_24                 : signed(15 DOWNTO 0) := to_signed(-69, 16); -- sfix16_En15
  CONSTANT coeffphase1_25                 : signed(15 DOWNTO 0) := to_signed(36, 16); -- sfix16_En15
  CONSTANT coeffphase1_26                 : signed(15 DOWNTO 0) := to_signed(-17, 16); -- sfix16_En15
  CONSTANT coeffphase1_27                 : signed(15 DOWNTO 0) := to_signed(7, 16); -- sfix16_En15
  CONSTANT coeffphase1_28                 : signed(15 DOWNTO 0) := to_signed(-2, 16); -- sfix16_En15
  CONSTANT coeffphase2_1                  : signed(15 DOWNTO 0) := to_signed(0, 16); -- sfix16_En15
  CONSTANT coeffphase2_2                  : signed(15 DOWNTO 0) := to_signed(0, 16); -- sfix16_En15
  CONSTANT coeffphase2_3                  : signed(15 DOWNTO 0) := to_signed(0, 16); -- sfix16_En15
  CONSTANT coeffphase2_4                  : signed(15 DOWNTO 0) := to_signed(0, 16); -- sfix16_En15
  CONSTANT coeffphase2_5                  : signed(15 DOWNTO 0) := to_signed(0, 16); -- sfix16_En15
  CONSTANT coeffphase2_6                  : signed(15 DOWNTO 0) := to_signed(0, 16); -- sfix16_En15
  CONSTANT coeffphase2_7                  : signed(15 DOWNTO 0) := to_signed(0, 16); -- sfix16_En15
  CONSTANT coeffphase2_8                  : signed(15 DOWNTO 0) := to_signed(0, 16); -- sfix16_En15
  CONSTANT coeffphase2_9                  : signed(15 DOWNTO 0) := to_signed(0, 16); -- sfix16_En15
  CONSTANT coeffphase2_10                 : signed(15 DOWNTO 0) := to_signed(0, 16); -- sfix16_En15
  CONSTANT coeffphase2_11                 : signed(15 DOWNTO 0) := to_signed(0, 16); -- sfix16_En15
  CONSTANT coeffphase2_12                 : signed(15 DOWNTO 0) := to_signed(0, 16); -- sfix16_En15
  CONSTANT coeffphase2_13                 : signed(15 DOWNTO 0) := to_signed(0, 16); -- sfix16_En15
  CONSTANT coeffphase2_14                 : signed(15 DOWNTO 0) := to_signed(16384, 16); -- sfix16_En15
  CONSTANT coeffphase2_15                 : signed(15 DOWNTO 0) := to_signed(0, 16); -- sfix16_En15
  CONSTANT coeffphase2_16                 : signed(15 DOWNTO 0) := to_signed(0, 16); -- sfix16_En15
  CONSTANT coeffphase2_17                 : signed(15 DOWNTO 0) := to_signed(0, 16); -- sfix16_En15
  CONSTANT coeffphase2_18                 : signed(15 DOWNTO 0) := to_signed(0, 16); -- sfix16_En15
  CONSTANT coeffphase2_19                 : signed(15 DOWNTO 0) := to_signed(0, 16); -- sfix16_En15
  CONSTANT coeffphase2_20                 : signed(15 DOWNTO 0) := to_signed(0, 16); -- sfix16_En15
  CONSTANT coeffphase2_21                 : signed(15 DOWNTO 0) := to_signed(0, 16); -- sfix16_En15
  CONSTANT coeffphase2_22                 : signed(15 DOWNTO 0) := to_signed(0, 16); -- sfix16_En15
  CONSTANT coeffphase2_23                 : signed(15 DOWNTO 0) := to_signed(0, 16); -- sfix16_En15
  CONSTANT coeffphase2_24                 : signed(15 DOWNTO 0) := to_signed(0, 16); -- sfix16_En15
  CONSTANT coeffphase2_25                 : signed(15 DOWNTO 0) := to_signed(0, 16); -- sfix16_En15
  CONSTANT coeffphase2_26                 : signed(15 DOWNTO 0) := to_signed(0, 16); -- sfix16_En15
  CONSTANT coeffphase2_27                 : signed(15 DOWNTO 0) := to_signed(0, 16); -- sfix16_En15
  CONSTANT coeffphase2_28                 : signed(15 DOWNTO 0) := to_signed(0, 16); -- sfix16_En15

  -- Signals
  SIGNAL ring_count                       : unsigned(1 DOWNTO 0); -- ufix2
  SIGNAL phase_0                          : std_logic; -- boolean
  SIGNAL phase_1                          : std_logic; -- boolean
  SIGNAL ce_out_reg                       : std_logic; -- boolean
  SIGNAL input_typeconvert_re             : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_typeconvert_im             : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re         : input_pipeline_type(0 TO 26); -- sfix16
  SIGNAL input_pipeline_phase0_im         : input_pipeline_type(0 TO 26); -- sfix16
  SIGNAL input_pipeline_phase1_re         : input_pipeline_type(0 TO 13); -- sfix16
  SIGNAL input_pipeline_phase1_im         : input_pipeline_type(0 TO 13); -- sfix16
  SIGNAL product_phase0_1_re              : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_phase0_1_im              : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL input_typeconvert_re_pipe_re     : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_typeconvert_re_pipe_im     : signed(15 DOWNTO 0); -- sfix16
  SIGNAL int_delay_pipe_re                : vector_of_signed16(0 TO 1); -- sfix16
  SIGNAL int_delay_pipe_im                : vector_of_signed16(0 TO 1); -- sfix16
  SIGNAL product_phase0_1_re_pipe_re      : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_phase0_1_re_pipe_im      : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL int_delay_pipe_1_re              : vector_of_signed31(0 TO 1); -- sfix31_En15
  SIGNAL int_delay_pipe_1_im              : vector_of_signed31(0 TO 1); -- sfix31_En15
  SIGNAL mulpwr2_temp                     : signed(16 DOWNTO 0); -- sfix17
  SIGNAL mulpwr2_temp_1                   : signed(16 DOWNTO 0); -- sfix17
  SIGNAL product_phase0_2_re              : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_phase0_2_im              : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL input_pipeline_phase0_re_0_under_pipe_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_0_under_pipe_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_0_under_pipe_1_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_0_under_pipe_1_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL coeffphase1_2_pipe               : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL coeffphase1_2_pipe_1             : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL product_phase0_2_re_pipe_re      : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_2_re_pipe_im      : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_2_re_pipe_1_re    : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_2_re_pipe_1_im    : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_3_re              : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_phase0_3_im              : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL input_pipeline_phase0_re_1_under_pipe_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_1_under_pipe_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_1_under_pipe_1_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_1_under_pipe_1_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL coeffphase1_3_pipe               : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL coeffphase1_3_pipe_1             : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL product_phase0_3_re_pipe_re      : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_3_re_pipe_im      : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_3_re_pipe_1_re    : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_3_re_pipe_1_im    : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_4_re              : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_phase0_4_im              : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL input_pipeline_phase0_re_2_under_pipe_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_2_under_pipe_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_2_under_pipe_1_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_2_under_pipe_1_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL coeffphase1_4_pipe               : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL coeffphase1_4_pipe_1             : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL product_phase0_4_re_pipe_re      : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_4_re_pipe_im      : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_4_re_pipe_1_re    : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_4_re_pipe_1_im    : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_5_re              : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_phase0_5_im              : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL input_pipeline_phase0_re_3_under_pipe_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_3_under_pipe_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_3_under_pipe_1_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_3_under_pipe_1_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL coeffphase1_5_pipe               : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL coeffphase1_5_pipe_1             : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL product_phase0_5_re_pipe_re      : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_5_re_pipe_im      : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_5_re_pipe_1_re    : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_5_re_pipe_1_im    : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_6_re              : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_phase0_6_im              : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL input_pipeline_phase0_re_4_under_pipe_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_4_under_pipe_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_4_under_pipe_1_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_4_under_pipe_1_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL coeffphase1_6_pipe               : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL coeffphase1_6_pipe_1             : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL product_phase0_6_re_pipe_re      : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_6_re_pipe_im      : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_6_re_pipe_1_re    : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_6_re_pipe_1_im    : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_7_re              : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_phase0_7_im              : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL input_pipeline_phase0_re_5_under_pipe_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_5_under_pipe_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_5_under_pipe_1_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_5_under_pipe_1_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL coeffphase1_7_pipe               : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL coeffphase1_7_pipe_1             : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL product_phase0_7_re_pipe_re      : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_7_re_pipe_im      : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_7_re_pipe_1_re    : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_7_re_pipe_1_im    : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_8_re              : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_phase0_8_im              : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL input_pipeline_phase0_re_6_under_pipe_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_6_under_pipe_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_6_under_pipe_1_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_6_under_pipe_1_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL coeffphase1_8_pipe               : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL coeffphase1_8_pipe_1             : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL product_phase0_8_re_pipe_re      : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_8_re_pipe_im      : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_8_re_pipe_1_re    : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_8_re_pipe_1_im    : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_9_re              : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_phase0_9_im              : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL input_pipeline_phase0_re_7_under_pipe_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_7_under_pipe_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_7_under_pipe_1_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_7_under_pipe_1_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL coeffphase1_9_pipe               : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL coeffphase1_9_pipe_1             : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL product_phase0_9_re_pipe_re      : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_9_re_pipe_im      : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_9_re_pipe_1_re    : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_9_re_pipe_1_im    : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_10_re             : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_phase0_10_im             : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL input_pipeline_phase0_re_8_under_pipe_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_8_under_pipe_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_8_under_pipe_1_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_8_under_pipe_1_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL coeffphase1_10_pipe              : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL coeffphase1_10_pipe_1            : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL product_phase0_10_re_pipe_re     : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_10_re_pipe_im     : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_10_re_pipe_1_re   : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_10_re_pipe_1_im   : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_11_re             : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_phase0_11_im             : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL input_pipeline_phase0_re_9_under_pipe_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_9_under_pipe_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_9_under_pipe_1_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_9_under_pipe_1_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL coeffphase1_11_pipe              : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL coeffphase1_11_pipe_1            : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL product_phase0_11_re_pipe_re     : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_11_re_pipe_im     : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_11_re_pipe_1_re   : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_11_re_pipe_1_im   : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_12_re             : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_phase0_12_im             : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL input_pipeline_phase0_re_10_under_pipe_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_10_under_pipe_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_10_under_pipe_1_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_10_under_pipe_1_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL coeffphase1_12_pipe              : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL coeffphase1_12_pipe_1            : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL product_phase0_12_re_pipe_re     : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_12_re_pipe_im     : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_12_re_pipe_1_re   : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_12_re_pipe_1_im   : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_13_re             : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_phase0_13_im             : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL input_pipeline_phase0_re_11_under_pipe_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_11_under_pipe_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_11_under_pipe_1_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_11_under_pipe_1_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL coeffphase1_13_pipe              : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL coeffphase1_13_pipe_1            : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL product_phase0_13_re_pipe_re     : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_13_re_pipe_im     : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_13_re_pipe_1_re   : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_13_re_pipe_1_im   : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_14_re             : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_phase0_14_im             : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL input_pipeline_phase0_re_12_under_pipe_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_12_under_pipe_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_12_under_pipe_1_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_12_under_pipe_1_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL coeffphase1_14_pipe              : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL coeffphase1_14_pipe_1            : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL product_phase0_14_re_pipe_re     : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_14_re_pipe_im     : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_14_re_pipe_1_re   : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_14_re_pipe_1_im   : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_15_re             : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_phase0_15_im             : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL input_pipeline_phase0_re_13_under_pipe_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_13_under_pipe_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_13_under_pipe_1_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_13_under_pipe_1_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL coeffphase1_15_pipe              : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL coeffphase1_15_pipe_1            : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL product_phase0_15_re_pipe_re     : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_15_re_pipe_im     : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_15_re_pipe_1_re   : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_15_re_pipe_1_im   : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_16_re             : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_phase0_16_im             : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL input_pipeline_phase0_re_14_under_pipe_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_14_under_pipe_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_14_under_pipe_1_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_14_under_pipe_1_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL coeffphase1_16_pipe              : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL coeffphase1_16_pipe_1            : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL product_phase0_16_re_pipe_re     : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_16_re_pipe_im     : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_16_re_pipe_1_re   : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_16_re_pipe_1_im   : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_17_re             : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_phase0_17_im             : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL input_pipeline_phase0_re_15_under_pipe_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_15_under_pipe_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_15_under_pipe_1_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_15_under_pipe_1_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL coeffphase1_17_pipe              : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL coeffphase1_17_pipe_1            : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL product_phase0_17_re_pipe_re     : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_17_re_pipe_im     : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_17_re_pipe_1_re   : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_17_re_pipe_1_im   : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_18_re             : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_phase0_18_im             : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL input_pipeline_phase0_re_16_under_pipe_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_16_under_pipe_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_16_under_pipe_1_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_16_under_pipe_1_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL coeffphase1_18_pipe              : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL coeffphase1_18_pipe_1            : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL product_phase0_18_re_pipe_re     : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_18_re_pipe_im     : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_18_re_pipe_1_re   : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_18_re_pipe_1_im   : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_19_re             : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_phase0_19_im             : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL input_pipeline_phase0_re_17_under_pipe_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_17_under_pipe_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_17_under_pipe_1_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_17_under_pipe_1_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL coeffphase1_19_pipe              : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL coeffphase1_19_pipe_1            : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL product_phase0_19_re_pipe_re     : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_19_re_pipe_im     : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_19_re_pipe_1_re   : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_19_re_pipe_1_im   : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_20_re             : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_phase0_20_im             : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL input_pipeline_phase0_re_18_under_pipe_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_18_under_pipe_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_18_under_pipe_1_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_18_under_pipe_1_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL coeffphase1_20_pipe              : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL coeffphase1_20_pipe_1            : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL product_phase0_20_re_pipe_re     : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_20_re_pipe_im     : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_20_re_pipe_1_re   : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_20_re_pipe_1_im   : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_21_re             : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_phase0_21_im             : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL input_pipeline_phase0_re_19_under_pipe_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_19_under_pipe_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_19_under_pipe_1_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_19_under_pipe_1_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL coeffphase1_21_pipe              : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL coeffphase1_21_pipe_1            : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL product_phase0_21_re_pipe_re     : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_21_re_pipe_im     : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_21_re_pipe_1_re   : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_21_re_pipe_1_im   : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_22_re             : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_phase0_22_im             : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL input_pipeline_phase0_re_20_under_pipe_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_20_under_pipe_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_20_under_pipe_1_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_20_under_pipe_1_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL coeffphase1_22_pipe              : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL coeffphase1_22_pipe_1            : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL product_phase0_22_re_pipe_re     : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_22_re_pipe_im     : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_22_re_pipe_1_re   : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_22_re_pipe_1_im   : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_23_re             : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_phase0_23_im             : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL input_pipeline_phase0_re_21_under_pipe_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_21_under_pipe_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_21_under_pipe_1_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_21_under_pipe_1_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL coeffphase1_23_pipe              : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL coeffphase1_23_pipe_1            : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL product_phase0_23_re_pipe_re     : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_23_re_pipe_im     : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_23_re_pipe_1_re   : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_23_re_pipe_1_im   : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_24_re             : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_phase0_24_im             : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL input_pipeline_phase0_re_22_under_pipe_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_22_under_pipe_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_22_under_pipe_1_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_22_under_pipe_1_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL coeffphase1_24_pipe              : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL coeffphase1_24_pipe_1            : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL product_phase0_24_re_pipe_re     : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_24_re_pipe_im     : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_24_re_pipe_1_re   : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_24_re_pipe_1_im   : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_25_re             : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_phase0_25_im             : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL input_pipeline_phase0_re_23_under_pipe_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_23_under_pipe_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_23_under_pipe_1_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_23_under_pipe_1_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL coeffphase1_25_pipe              : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL coeffphase1_25_pipe_1            : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL product_phase0_25_re_pipe_re     : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_25_re_pipe_im     : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_25_re_pipe_1_re   : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_25_re_pipe_1_im   : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_26_re             : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_phase0_26_im             : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL input_pipeline_phase0_re_24_under_pipe_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_24_under_pipe_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_24_under_pipe_1_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_24_under_pipe_1_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL coeffphase1_26_pipe              : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL coeffphase1_26_pipe_1            : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL product_phase0_26_re_pipe_re     : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_26_re_pipe_im     : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_26_re_pipe_1_re   : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_26_re_pipe_1_im   : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_27_re             : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_phase0_27_im             : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL input_pipeline_phase0_re_25_under_pipe_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_25_under_pipe_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_25_under_pipe_1_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_25_under_pipe_1_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL coeffphase1_27_pipe              : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL coeffphase1_27_pipe_1            : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL product_phase0_27_re_pipe_re     : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_27_re_pipe_im     : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_27_re_pipe_1_re   : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_27_re_pipe_1_im   : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_28_re             : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_phase0_28_im             : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL input_pipeline_phase0_re_26_pipe_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re_26_pipe_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL int_delay_pipe_2_re              : vector_of_signed16(0 TO 1); -- sfix16
  SIGNAL int_delay_pipe_2_im              : vector_of_signed16(0 TO 1); -- sfix16
  SIGNAL product_phase0_28_re_pipe_re     : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_phase0_28_re_pipe_im     : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL int_delay_pipe_3_re              : vector_of_signed31(0 TO 1); -- sfix31_En15
  SIGNAL int_delay_pipe_3_im              : vector_of_signed31(0 TO 1); -- sfix31_En15
  SIGNAL mulpwr2_temp_2                   : signed(16 DOWNTO 0); -- sfix17
  SIGNAL mulpwr2_temp_3                   : signed(16 DOWNTO 0); -- sfix17
  SIGNAL product_phase1_14_re             : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_phase1_14_im             : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL input_pipeline_phase1_re_13_pipe_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase1_re_13_pipe_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL int_delay_pipe_4_re              : vector_of_signed16(0 TO 1); -- sfix16
  SIGNAL int_delay_pipe_4_im              : vector_of_signed16(0 TO 1); -- sfix16
  SIGNAL product_phase1_14_re_pipe_re     : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_phase1_14_re_pipe_im     : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL int_delay_pipe_5_re              : vector_of_signed31(0 TO 1); -- sfix31_En15
  SIGNAL int_delay_pipe_5_im              : vector_of_signed31(0 TO 1); -- sfix31_En15
  SIGNAL product_pipeline_phase0_1_re     : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_1_im     : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_2_re     : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_2_im     : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_3_re     : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_3_im     : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_4_re     : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_4_im     : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_5_re     : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_5_im     : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_6_re     : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_6_im     : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_7_re     : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_7_im     : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_8_re     : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_8_im     : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_9_re     : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_9_im     : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_10_re    : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_10_im    : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_11_re    : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_11_im    : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_12_re    : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_12_im    : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_13_re    : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_13_im    : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_14_re    : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_14_im    : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_15_re    : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_15_im    : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_16_re    : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_16_im    : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_17_re    : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_17_im    : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_18_re    : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_18_im    : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_19_re    : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_19_im    : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_20_re    : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_20_im    : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_21_re    : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_21_im    : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_22_re    : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_22_im    : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_23_re    : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_23_im    : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_24_re    : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_24_im    : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_25_re    : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_25_im    : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_26_re    : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_26_im    : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_27_re    : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_27_im    : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_28_re    : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase0_28_im    : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase1_14_re    : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase1_14_im    : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL quantized_sum_re                 : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL quantized_sum_im                 : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL sumvector1_re                    : sumdelay_pipeline_type(0 TO 14); -- sfix32_En15
  SIGNAL sumvector1_im                    : sumdelay_pipeline_type(0 TO 14); -- sfix32_En15
  SIGNAL add_temp                         : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL add_temp_1                       : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL sumdelay_pipeline1_re            : sumdelay_pipeline_type(0 TO 14); -- sfix32_En15
  SIGNAL sumdelay_pipeline1_im            : sumdelay_pipeline_type(0 TO 14); -- sfix32_En15
  SIGNAL sumvector2_re                    : sumdelay_pipeline_type(0 TO 7); -- sfix32_En15
  SIGNAL sumvector2_im                    : sumdelay_pipeline_type(0 TO 7); -- sfix32_En15
  SIGNAL add_temp_2                       : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL add_temp_3                       : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL add_temp_4                       : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL add_temp_5                       : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL add_temp_6                       : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL add_temp_7                       : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL add_temp_8                       : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL add_temp_9                       : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL add_temp_10                      : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL add_temp_11                      : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL add_temp_12                      : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL add_temp_13                      : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL add_temp_14                      : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL add_temp_15                      : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL sumdelay_pipeline2_re            : sumdelay_pipeline_type(0 TO 7); -- sfix32_En15
  SIGNAL sumdelay_pipeline2_im            : sumdelay_pipeline_type(0 TO 7); -- sfix32_En15
  SIGNAL sumvector3_re                    : sumdelay_pipeline_type(0 TO 3); -- sfix32_En15
  SIGNAL sumvector3_im                    : sumdelay_pipeline_type(0 TO 3); -- sfix32_En15
  SIGNAL add_temp_16                      : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL add_temp_17                      : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL add_temp_18                      : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL add_temp_19                      : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL add_temp_20                      : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL add_temp_21                      : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL add_temp_22                      : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL add_temp_23                      : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL sumdelay_pipeline3_re            : sumdelay_pipeline_type(0 TO 3); -- sfix32_En15
  SIGNAL sumdelay_pipeline3_im            : sumdelay_pipeline_type(0 TO 3); -- sfix32_En15
  SIGNAL sumvector4_re                    : sumdelay_pipeline_type(0 TO 1); -- sfix32_En15
  SIGNAL sumvector4_im                    : sumdelay_pipeline_type(0 TO 1); -- sfix32_En15
  SIGNAL add_temp_24                      : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL add_temp_25                      : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL add_temp_26                      : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL add_temp_27                      : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL sumdelay_pipeline4_re            : sumdelay_pipeline_type(0 TO 1); -- sfix32_En15
  SIGNAL sumdelay_pipeline4_im            : sumdelay_pipeline_type(0 TO 1); -- sfix32_En15
  SIGNAL sum5_re                          : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL sum5_im                          : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL add_temp_28                      : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL add_temp_29                      : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL output_typeconvert_re            : signed(15 DOWNTO 0); -- sfix16
  SIGNAL output_typeconvert_im            : signed(15 DOWNTO 0); -- sfix16
  SIGNAL ce_delayline1                    : std_logic; -- boolean
  SIGNAL ce_delayline2                    : std_logic; -- boolean
  SIGNAL ce_delayline3                    : std_logic; -- boolean
  SIGNAL ce_delayline4                    : std_logic; -- boolean
  SIGNAL ce_delayline5                    : std_logic; -- boolean
  SIGNAL ce_delayline6                    : std_logic; -- boolean
  SIGNAL ce_delayline7                    : std_logic; -- boolean
  SIGNAL ce_delayline8                    : std_logic; -- boolean
  SIGNAL ce_delayline9                    : std_logic; -- boolean
  SIGNAL ce_delayline10                   : std_logic; -- boolean
  SIGNAL ce_delayline11                   : std_logic; -- boolean
  SIGNAL ce_delayline12                   : std_logic; -- boolean
  SIGNAL ce_delayline13                   : std_logic; -- boolean
  SIGNAL ce_delayline14                   : std_logic; -- boolean
  SIGNAL ce_delayline15                   : std_logic; -- boolean
  SIGNAL ce_delayline16                   : std_logic; -- boolean
  SIGNAL ce_delayline17                   : std_logic; -- boolean
  SIGNAL ce_delayline18                   : std_logic; -- boolean
  SIGNAL ce_delayline19                   : std_logic; -- boolean
  SIGNAL ce_gated                         : std_logic; -- boolean
  SIGNAL output_register_re               : signed(15 DOWNTO 0); -- sfix16
  SIGNAL output_register_im               : signed(15 DOWNTO 0); -- sfix16


BEGIN

  -- Block Statements
  ce_output : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
        ring_count <= to_unsigned(1, 2);
      ELSIF clk_enable_stage5 = '1' THEN
        ring_count <= ring_count(0) & ring_count(1);
      END IF;
    END IF; 
  END PROCESS ce_output;

  phase_0 <= ring_count(0)  AND clk_enable_stage5;

  phase_1 <= ring_count(1)  AND clk_enable_stage5;

  --   ------------------ CE Output Register ------------------

  ce_output_register : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
        ce_out_reg <= '0';
      ELSE
       ce_out_reg <= phase_0;
      END IF;
    END IF; 
  END PROCESS ce_output_register;

  input_typeconvert_re <= signed(filter_in_stage5_re);
  input_typeconvert_im <= signed(filter_in_stage5_im);

  Delay_Pipeline_Phase0_process : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
        input_pipeline_phase0_re(0 TO 26) <= (OTHERS => (OTHERS => '0'));
        input_pipeline_phase0_im(0 TO 26) <= (OTHERS => (OTHERS => '0'));
      ELSIF phase_0 = '1' THEN
        input_pipeline_phase0_re(0) <= input_typeconvert_re;
        input_pipeline_phase0_re(1 TO 26) <= input_pipeline_phase0_re(0 TO 25);
        input_pipeline_phase0_im(0) <= input_typeconvert_im;
        input_pipeline_phase0_im(1 TO 26) <= input_pipeline_phase0_im(0 TO 25);
      END IF;
    END IF; 
  END PROCESS Delay_Pipeline_Phase0_process;


  Delay_Pipeline_Phase1_process : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
        input_pipeline_phase1_re(0 TO 13) <= (OTHERS => (OTHERS => '0'));
        input_pipeline_phase1_im(0 TO 13) <= (OTHERS => (OTHERS => '0'));
      ELSIF phase_1 = '1' THEN
        input_pipeline_phase1_re(0) <= input_typeconvert_re;
        input_pipeline_phase1_re(1 TO 13) <= input_pipeline_phase1_re(0 TO 12);
        input_pipeline_phase1_im(0) <= input_typeconvert_im;
        input_pipeline_phase1_im(1 TO 13) <= input_pipeline_phase1_im(0 TO 12);
      END IF;
    END IF; 
  END PROCESS Delay_Pipeline_Phase1_process;


  temp_process1 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
        int_delay_pipe_re <= (OTHERS => (OTHERS => '0'));
        int_delay_pipe_im <= (OTHERS => (OTHERS => '0'));
      ELSIF phase_0 = '1' THEN
        int_delay_pipe_re(1) <= int_delay_pipe_re(0);
        int_delay_pipe_im(1) <= int_delay_pipe_im(0);
        int_delay_pipe_re(0) <= input_typeconvert_re;
        int_delay_pipe_im(0) <= input_typeconvert_im;
      END IF;
    END IF;
  END PROCESS temp_process1;
  input_typeconvert_re_pipe_re <= int_delay_pipe_re(1);
  input_typeconvert_re_pipe_im <= int_delay_pipe_im(1);

  temp_process2 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
        int_delay_pipe_1_re <= (OTHERS => (OTHERS => '0'));
        int_delay_pipe_1_im <= (OTHERS => (OTHERS => '0'));
      ELSIF phase_0 = '1' THEN
        int_delay_pipe_1_re(1) <= int_delay_pipe_1_re(0);
        int_delay_pipe_1_im(1) <= int_delay_pipe_1_im(0);
        int_delay_pipe_1_re(0) <= product_phase0_1_re_pipe_re;
        int_delay_pipe_1_im(0) <= product_phase0_1_re_pipe_im;
      END IF;
    END IF;
  END PROCESS temp_process2;
  product_phase0_1_re <= int_delay_pipe_1_re(1);
  product_phase0_1_im <= int_delay_pipe_1_im(1);

  mulpwr2_temp <= ('0' & input_typeconvert_re_pipe_re) WHEN input_typeconvert_re_pipe_re = "1000000000000000"
      ELSE -resize(input_typeconvert_re_pipe_re,17);

  product_phase0_1_re_pipe_re <= resize(mulpwr2_temp(16 DOWNTO 0) & '0', 31);

  mulpwr2_temp_1 <= ('0' & input_typeconvert_re_pipe_im) WHEN input_typeconvert_re_pipe_im = "1000000000000000"
      ELSE -resize(input_typeconvert_re_pipe_im,17);

  product_phase0_1_re_pipe_im <= resize(mulpwr2_temp_1(16 DOWNTO 0) & '0', 31);

  temp_process3 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
        input_pipeline_phase0_re_0_under_pipe_re <= (OTHERS => '0');
        input_pipeline_phase0_re_0_under_pipe_im <= (OTHERS => '0');
        input_pipeline_phase0_re_0_under_pipe_1_re <= (OTHERS => '0');
        input_pipeline_phase0_re_0_under_pipe_1_im <= (OTHERS => '0');
        coeffphase1_2_pipe <= (OTHERS => '0');
        coeffphase1_2_pipe_1 <= (OTHERS => '0');
        product_phase0_2_re_pipe_re <= (OTHERS => '0');
        product_phase0_2_re_pipe_im <= (OTHERS => '0');
        product_phase0_2_re_pipe_1_re <= (OTHERS => '0');
        product_phase0_2_re_pipe_1_im <= (OTHERS => '0');
      ELSIF phase_0 = '1' THEN
        input_pipeline_phase0_re_0_under_pipe_re <= input_pipeline_phase0_re(0);
        input_pipeline_phase0_re_0_under_pipe_im <= input_pipeline_phase0_im(0);
        input_pipeline_phase0_re_0_under_pipe_1_re <= input_pipeline_phase0_re_0_under_pipe_re;
        input_pipeline_phase0_re_0_under_pipe_1_im <= input_pipeline_phase0_re_0_under_pipe_im;
        coeffphase1_2_pipe <= coeffphase1_2;
        coeffphase1_2_pipe_1 <= coeffphase1_2_pipe;

        product_phase0_2_re_pipe_re <= input_pipeline_phase0_re_0_under_pipe_1_re * coeffphase1_2_pipe_1;
        product_phase0_2_re_pipe_im <= input_pipeline_phase0_re_0_under_pipe_1_im * coeffphase1_2_pipe_1;

        product_phase0_2_re_pipe_1_re <= product_phase0_2_re_pipe_re;
        product_phase0_2_re_pipe_1_im <= product_phase0_2_re_pipe_im;
      END IF;
    END IF;
  END PROCESS temp_process3;

  product_phase0_2_re <= product_phase0_2_re_pipe_1_re(30 DOWNTO 0);
  product_phase0_2_im <= product_phase0_2_re_pipe_1_im(30 DOWNTO 0);

  temp_process4 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
        input_pipeline_phase0_re_1_under_pipe_re <= (OTHERS => '0');
        input_pipeline_phase0_re_1_under_pipe_im <= (OTHERS => '0');
        input_pipeline_phase0_re_1_under_pipe_1_re <= (OTHERS => '0');
        input_pipeline_phase0_re_1_under_pipe_1_im <= (OTHERS => '0');
        coeffphase1_3_pipe <= (OTHERS => '0');
        coeffphase1_3_pipe_1 <= (OTHERS => '0');
        product_phase0_3_re_pipe_re <= (OTHERS => '0');
        product_phase0_3_re_pipe_im <= (OTHERS => '0');
        product_phase0_3_re_pipe_1_re <= (OTHERS => '0');
        product_phase0_3_re_pipe_1_im <= (OTHERS => '0');
      ELSIF phase_0 = '1' THEN
        input_pipeline_phase0_re_1_under_pipe_re <= input_pipeline_phase0_re(1);
        input_pipeline_phase0_re_1_under_pipe_im <= input_pipeline_phase0_im(1);
        input_pipeline_phase0_re_1_under_pipe_1_re <= input_pipeline_phase0_re_1_under_pipe_re;
        input_pipeline_phase0_re_1_under_pipe_1_im <= input_pipeline_phase0_re_1_under_pipe_im;
        coeffphase1_3_pipe <= coeffphase1_3;
        coeffphase1_3_pipe_1 <= coeffphase1_3_pipe;

        product_phase0_3_re_pipe_re <= input_pipeline_phase0_re_1_under_pipe_1_re * coeffphase1_3_pipe_1;
        product_phase0_3_re_pipe_im <= input_pipeline_phase0_re_1_under_pipe_1_im * coeffphase1_3_pipe_1;

        product_phase0_3_re_pipe_1_re <= product_phase0_3_re_pipe_re;
        product_phase0_3_re_pipe_1_im <= product_phase0_3_re_pipe_im;
      END IF;
    END IF;
  END PROCESS temp_process4;

  product_phase0_3_re <= product_phase0_3_re_pipe_1_re(30 DOWNTO 0);
  product_phase0_3_im <= product_phase0_3_re_pipe_1_im(30 DOWNTO 0);

  temp_process5 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
          input_pipeline_phase0_re_2_under_pipe_re <= (OTHERS => '0');
          input_pipeline_phase0_re_2_under_pipe_im <= (OTHERS => '0');
          input_pipeline_phase0_re_2_under_pipe_1_re <= (OTHERS => '0');
          input_pipeline_phase0_re_2_under_pipe_1_im <= (OTHERS => '0');
          coeffphase1_4_pipe <= (OTHERS => '0');
          coeffphase1_4_pipe_1 <= (OTHERS => '0');
          product_phase0_4_re_pipe_re <= (OTHERS => '0');
          product_phase0_4_re_pipe_im <= (OTHERS => '0');
          product_phase0_4_re_pipe_1_re <= (OTHERS => '0');
          product_phase0_4_re_pipe_1_im <= (OTHERS => '0');
      ELSIF phase_0 = '1' THEN
        input_pipeline_phase0_re_2_under_pipe_re <= input_pipeline_phase0_re(2);
        input_pipeline_phase0_re_2_under_pipe_im <= input_pipeline_phase0_im(2);
        input_pipeline_phase0_re_2_under_pipe_1_re <= input_pipeline_phase0_re_2_under_pipe_re;
        input_pipeline_phase0_re_2_under_pipe_1_im <= input_pipeline_phase0_re_2_under_pipe_im;
        coeffphase1_4_pipe <= coeffphase1_4;
        coeffphase1_4_pipe_1 <= coeffphase1_4_pipe;

        product_phase0_4_re_pipe_re <= input_pipeline_phase0_re_2_under_pipe_1_re * coeffphase1_4_pipe_1;
        product_phase0_4_re_pipe_im <= input_pipeline_phase0_re_2_under_pipe_1_im * coeffphase1_4_pipe_1;

        product_phase0_4_re_pipe_1_re <= product_phase0_4_re_pipe_re;
        product_phase0_4_re_pipe_1_im <= product_phase0_4_re_pipe_im;
      END IF;
    END IF;
  END PROCESS temp_process5;

  product_phase0_4_re <= product_phase0_4_re_pipe_1_re(30 DOWNTO 0);
  product_phase0_4_im <= product_phase0_4_re_pipe_1_im(30 DOWNTO 0);

  temp_process6 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
          input_pipeline_phase0_re_3_under_pipe_re <= (OTHERS => '0');
          input_pipeline_phase0_re_3_under_pipe_im <= (OTHERS => '0');
          input_pipeline_phase0_re_3_under_pipe_1_re <= (OTHERS => '0');
          input_pipeline_phase0_re_3_under_pipe_1_im <= (OTHERS => '0');
          coeffphase1_5_pipe <= (OTHERS => '0');
          coeffphase1_5_pipe_1 <= (OTHERS => '0');
          product_phase0_5_re_pipe_re <= (OTHERS => '0');
          product_phase0_5_re_pipe_im <= (OTHERS => '0');
          product_phase0_5_re_pipe_1_re <= (OTHERS => '0');
          product_phase0_5_re_pipe_1_im <= (OTHERS => '0');
      ELSIF phase_0 = '1' THEN
        input_pipeline_phase0_re_3_under_pipe_re <= input_pipeline_phase0_re(3);
        input_pipeline_phase0_re_3_under_pipe_im <= input_pipeline_phase0_im(3);
        input_pipeline_phase0_re_3_under_pipe_1_re <= input_pipeline_phase0_re_3_under_pipe_re;
        input_pipeline_phase0_re_3_under_pipe_1_im <= input_pipeline_phase0_re_3_under_pipe_im;
        coeffphase1_5_pipe <= coeffphase1_5;
        coeffphase1_5_pipe_1 <= coeffphase1_5_pipe;

        product_phase0_5_re_pipe_re <= input_pipeline_phase0_re_3_under_pipe_1_re * coeffphase1_5_pipe_1;
        product_phase0_5_re_pipe_im <= input_pipeline_phase0_re_3_under_pipe_1_im * coeffphase1_5_pipe_1;

        product_phase0_5_re_pipe_1_re <= product_phase0_5_re_pipe_re;
        product_phase0_5_re_pipe_1_im <= product_phase0_5_re_pipe_im;
      END IF;
    END IF;
  END PROCESS temp_process6;

  product_phase0_5_re <= product_phase0_5_re_pipe_1_re(30 DOWNTO 0);
  product_phase0_5_im <= product_phase0_5_re_pipe_1_im(30 DOWNTO 0);

  temp_process7 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
          input_pipeline_phase0_re_4_under_pipe_re <= (OTHERS => '0');
          input_pipeline_phase0_re_4_under_pipe_im <= (OTHERS => '0');
          input_pipeline_phase0_re_4_under_pipe_1_re <= (OTHERS => '0');
          input_pipeline_phase0_re_4_under_pipe_1_im <= (OTHERS => '0');
          coeffphase1_6_pipe <= (OTHERS => '0');
          coeffphase1_6_pipe_1 <= (OTHERS => '0');
          product_phase0_6_re_pipe_re <= (OTHERS => '0');
          product_phase0_6_re_pipe_im <= (OTHERS => '0');
          product_phase0_6_re_pipe_1_re <= (OTHERS => '0');
          product_phase0_6_re_pipe_1_im <= (OTHERS => '0');
      ELSIF phase_0 = '1' THEN
        input_pipeline_phase0_re_4_under_pipe_re <= input_pipeline_phase0_re(4);
        input_pipeline_phase0_re_4_under_pipe_im <= input_pipeline_phase0_im(4);
        input_pipeline_phase0_re_4_under_pipe_1_re <= input_pipeline_phase0_re_4_under_pipe_re;
        input_pipeline_phase0_re_4_under_pipe_1_im <= input_pipeline_phase0_re_4_under_pipe_im;
        coeffphase1_6_pipe <= coeffphase1_6;
        coeffphase1_6_pipe_1 <= coeffphase1_6_pipe;

        product_phase0_6_re_pipe_re <= input_pipeline_phase0_re_4_under_pipe_1_re * coeffphase1_6_pipe_1;
        product_phase0_6_re_pipe_im <= input_pipeline_phase0_re_4_under_pipe_1_im * coeffphase1_6_pipe_1;

        product_phase0_6_re_pipe_1_re <= product_phase0_6_re_pipe_re;
        product_phase0_6_re_pipe_1_im <= product_phase0_6_re_pipe_im;
      END IF;
    END IF;
  END PROCESS temp_process7;

  product_phase0_6_re <= product_phase0_6_re_pipe_1_re(30 DOWNTO 0);
  product_phase0_6_im <= product_phase0_6_re_pipe_1_im(30 DOWNTO 0);

  temp_process8 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
          input_pipeline_phase0_re_5_under_pipe_re <= (OTHERS => '0');
          input_pipeline_phase0_re_5_under_pipe_im <= (OTHERS => '0');
          input_pipeline_phase0_re_5_under_pipe_1_re <= (OTHERS => '0');
          input_pipeline_phase0_re_5_under_pipe_1_im <= (OTHERS => '0');
          coeffphase1_7_pipe <= (OTHERS => '0');
          coeffphase1_7_pipe_1 <= (OTHERS => '0');
          product_phase0_7_re_pipe_re <= (OTHERS => '0');
          product_phase0_7_re_pipe_im <= (OTHERS => '0');
          product_phase0_7_re_pipe_1_re <= (OTHERS => '0');
          product_phase0_7_re_pipe_1_im <= (OTHERS => '0');
      ELSIF phase_0 = '1' THEN
        input_pipeline_phase0_re_5_under_pipe_re <= input_pipeline_phase0_re(5);
        input_pipeline_phase0_re_5_under_pipe_im <= input_pipeline_phase0_im(5);
        input_pipeline_phase0_re_5_under_pipe_1_re <= input_pipeline_phase0_re_5_under_pipe_re;
        input_pipeline_phase0_re_5_under_pipe_1_im <= input_pipeline_phase0_re_5_under_pipe_im;
        coeffphase1_7_pipe <= coeffphase1_7;
        coeffphase1_7_pipe_1 <= coeffphase1_7_pipe;

        product_phase0_7_re_pipe_re <= input_pipeline_phase0_re_5_under_pipe_1_re * coeffphase1_7_pipe_1;
        product_phase0_7_re_pipe_im <= input_pipeline_phase0_re_5_under_pipe_1_im * coeffphase1_7_pipe_1;

        product_phase0_7_re_pipe_1_re <= product_phase0_7_re_pipe_re;
        product_phase0_7_re_pipe_1_im <= product_phase0_7_re_pipe_im;
      END IF;
    END IF;
  END PROCESS temp_process8;

  product_phase0_7_re <= product_phase0_7_re_pipe_1_re(30 DOWNTO 0);
  product_phase0_7_im <= product_phase0_7_re_pipe_1_im(30 DOWNTO 0);

  temp_process9 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
          input_pipeline_phase0_re_6_under_pipe_re <= (OTHERS => '0');
          input_pipeline_phase0_re_6_under_pipe_im <= (OTHERS => '0');
          input_pipeline_phase0_re_6_under_pipe_1_re <= (OTHERS => '0');
          input_pipeline_phase0_re_6_under_pipe_1_im <= (OTHERS => '0');
          coeffphase1_8_pipe <= (OTHERS => '0');
          coeffphase1_8_pipe_1 <= (OTHERS => '0');
          product_phase0_8_re_pipe_re <= (OTHERS => '0');
          product_phase0_8_re_pipe_im <= (OTHERS => '0');
          product_phase0_8_re_pipe_1_re <= (OTHERS => '0');
          product_phase0_8_re_pipe_1_im <= (OTHERS => '0');
      ELSIF phase_0 = '1' THEN
        input_pipeline_phase0_re_6_under_pipe_re <= input_pipeline_phase0_re(6);
        input_pipeline_phase0_re_6_under_pipe_im <= input_pipeline_phase0_im(6);
        input_pipeline_phase0_re_6_under_pipe_1_re <= input_pipeline_phase0_re_6_under_pipe_re;
        input_pipeline_phase0_re_6_under_pipe_1_im <= input_pipeline_phase0_re_6_under_pipe_im;
        coeffphase1_8_pipe <= coeffphase1_8;
        coeffphase1_8_pipe_1 <= coeffphase1_8_pipe;

        product_phase0_8_re_pipe_re <= input_pipeline_phase0_re_6_under_pipe_1_re * coeffphase1_8_pipe_1;
        product_phase0_8_re_pipe_im <= input_pipeline_phase0_re_6_under_pipe_1_im * coeffphase1_8_pipe_1;

        product_phase0_8_re_pipe_1_re <= product_phase0_8_re_pipe_re;
        product_phase0_8_re_pipe_1_im <= product_phase0_8_re_pipe_im;
      END IF;
    END IF;
  END PROCESS temp_process9;

  product_phase0_8_re <= product_phase0_8_re_pipe_1_re(30 DOWNTO 0);
  product_phase0_8_im <= product_phase0_8_re_pipe_1_im(30 DOWNTO 0);

  temp_process10 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
          input_pipeline_phase0_re_7_under_pipe_re <= (OTHERS => '0');
          input_pipeline_phase0_re_7_under_pipe_im <= (OTHERS => '0');
          input_pipeline_phase0_re_7_under_pipe_1_re <= (OTHERS => '0');
          input_pipeline_phase0_re_7_under_pipe_1_im <= (OTHERS => '0');
          coeffphase1_9_pipe <= (OTHERS => '0');
          coeffphase1_9_pipe_1 <= (OTHERS => '0');
          product_phase0_9_re_pipe_re <= (OTHERS => '0');
          product_phase0_9_re_pipe_im <= (OTHERS => '0');
          product_phase0_9_re_pipe_1_re <= (OTHERS => '0');
          product_phase0_9_re_pipe_1_im <= (OTHERS => '0');
      ELSIF phase_0 = '1' THEN
        input_pipeline_phase0_re_7_under_pipe_re <= input_pipeline_phase0_re(7);
        input_pipeline_phase0_re_7_under_pipe_im <= input_pipeline_phase0_im(7);
        input_pipeline_phase0_re_7_under_pipe_1_re <= input_pipeline_phase0_re_7_under_pipe_re;
        input_pipeline_phase0_re_7_under_pipe_1_im <= input_pipeline_phase0_re_7_under_pipe_im;
        coeffphase1_9_pipe <= coeffphase1_9;
        coeffphase1_9_pipe_1 <= coeffphase1_9_pipe;

        product_phase0_9_re_pipe_re <= input_pipeline_phase0_re_7_under_pipe_1_re * coeffphase1_9_pipe_1;
        product_phase0_9_re_pipe_im <= input_pipeline_phase0_re_7_under_pipe_1_im * coeffphase1_9_pipe_1;

        product_phase0_9_re_pipe_1_re <= product_phase0_9_re_pipe_re;
        product_phase0_9_re_pipe_1_im <= product_phase0_9_re_pipe_im;
      END IF;
    END IF;
  END PROCESS temp_process10;

  product_phase0_9_re <= product_phase0_9_re_pipe_1_re(30 DOWNTO 0);
  product_phase0_9_im <= product_phase0_9_re_pipe_1_im(30 DOWNTO 0);

  temp_process11 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
          input_pipeline_phase0_re_8_under_pipe_re <= (OTHERS => '0');
          input_pipeline_phase0_re_8_under_pipe_im <= (OTHERS => '0');
          input_pipeline_phase0_re_8_under_pipe_1_re <= (OTHERS => '0');
          input_pipeline_phase0_re_8_under_pipe_1_im <= (OTHERS => '0');
          coeffphase1_10_pipe <= (OTHERS => '0');
          coeffphase1_10_pipe_1 <= (OTHERS => '0');
          product_phase0_10_re_pipe_re <= (OTHERS => '0');
          product_phase0_10_re_pipe_im <= (OTHERS => '0');
          product_phase0_10_re_pipe_1_re <= (OTHERS => '0');
          product_phase0_10_re_pipe_1_im <= (OTHERS => '0');
      ELSIF phase_0 = '1' THEN
        input_pipeline_phase0_re_8_under_pipe_re <= input_pipeline_phase0_re(8);
        input_pipeline_phase0_re_8_under_pipe_im <= input_pipeline_phase0_im(8);
        input_pipeline_phase0_re_8_under_pipe_1_re <= input_pipeline_phase0_re_8_under_pipe_re;
        input_pipeline_phase0_re_8_under_pipe_1_im <= input_pipeline_phase0_re_8_under_pipe_im;
        coeffphase1_10_pipe <= coeffphase1_10;
        coeffphase1_10_pipe_1 <= coeffphase1_10_pipe;

        product_phase0_10_re_pipe_re <= input_pipeline_phase0_re_8_under_pipe_1_re * coeffphase1_10_pipe_1;
        product_phase0_10_re_pipe_im <= input_pipeline_phase0_re_8_under_pipe_1_im * coeffphase1_10_pipe_1;

        product_phase0_10_re_pipe_1_re <= product_phase0_10_re_pipe_re;
        product_phase0_10_re_pipe_1_im <= product_phase0_10_re_pipe_im;
      END IF;
    END IF;
  END PROCESS temp_process11;

  product_phase0_10_re <= product_phase0_10_re_pipe_1_re(30 DOWNTO 0);
  product_phase0_10_im <= product_phase0_10_re_pipe_1_im(30 DOWNTO 0);

  temp_process12 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
          input_pipeline_phase0_re_9_under_pipe_re <= (OTHERS => '0');
          input_pipeline_phase0_re_9_under_pipe_im <= (OTHERS => '0');
          input_pipeline_phase0_re_9_under_pipe_1_re <= (OTHERS => '0');
          input_pipeline_phase0_re_9_under_pipe_1_im <= (OTHERS => '0');
          coeffphase1_11_pipe <= (OTHERS => '0');
          coeffphase1_11_pipe_1 <= (OTHERS => '0');
          product_phase0_11_re_pipe_re <= (OTHERS => '0');
          product_phase0_11_re_pipe_im <= (OTHERS => '0');
          product_phase0_11_re_pipe_1_re <= (OTHERS => '0');
          product_phase0_11_re_pipe_1_im <= (OTHERS => '0');
      ELSIF phase_0 = '1' THEN
        input_pipeline_phase0_re_9_under_pipe_re <= input_pipeline_phase0_re(9);
        input_pipeline_phase0_re_9_under_pipe_im <= input_pipeline_phase0_im(9);
        input_pipeline_phase0_re_9_under_pipe_1_re <= input_pipeline_phase0_re_9_under_pipe_re;
        input_pipeline_phase0_re_9_under_pipe_1_im <= input_pipeline_phase0_re_9_under_pipe_im;
        coeffphase1_11_pipe <= coeffphase1_11;
        coeffphase1_11_pipe_1 <= coeffphase1_11_pipe;

        product_phase0_11_re_pipe_re <= input_pipeline_phase0_re_9_under_pipe_1_re * coeffphase1_11_pipe_1;
        product_phase0_11_re_pipe_im <= input_pipeline_phase0_re_9_under_pipe_1_im * coeffphase1_11_pipe_1;

        product_phase0_11_re_pipe_1_re <= product_phase0_11_re_pipe_re;
        product_phase0_11_re_pipe_1_im <= product_phase0_11_re_pipe_im;
      END IF;
    END IF;
  END PROCESS temp_process12;

  product_phase0_11_re <= product_phase0_11_re_pipe_1_re(30 DOWNTO 0);
  product_phase0_11_im <= product_phase0_11_re_pipe_1_im(30 DOWNTO 0);

  temp_process13 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
          input_pipeline_phase0_re_10_under_pipe_re <= (OTHERS => '0');
          input_pipeline_phase0_re_10_under_pipe_im <= (OTHERS => '0');
          input_pipeline_phase0_re_10_under_pipe_1_re <= (OTHERS => '0');
          input_pipeline_phase0_re_10_under_pipe_1_im <= (OTHERS => '0');
          coeffphase1_12_pipe <= (OTHERS => '0');
          coeffphase1_12_pipe_1 <= (OTHERS => '0');
          product_phase0_12_re_pipe_re <= (OTHERS => '0');
          product_phase0_12_re_pipe_im <= (OTHERS => '0');
          product_phase0_12_re_pipe_1_re <= (OTHERS => '0');
          product_phase0_12_re_pipe_1_im <= (OTHERS => '0');
      ELSIF phase_0 = '1' THEN
        input_pipeline_phase0_re_10_under_pipe_re <= input_pipeline_phase0_re(10);
        input_pipeline_phase0_re_10_under_pipe_im <= input_pipeline_phase0_im(10);
        input_pipeline_phase0_re_10_under_pipe_1_re <= input_pipeline_phase0_re_10_under_pipe_re;
        input_pipeline_phase0_re_10_under_pipe_1_im <= input_pipeline_phase0_re_10_under_pipe_im;
        coeffphase1_12_pipe <= coeffphase1_12;
        coeffphase1_12_pipe_1 <= coeffphase1_12_pipe;

        product_phase0_12_re_pipe_re <= input_pipeline_phase0_re_10_under_pipe_1_re * coeffphase1_12_pipe_1;
        product_phase0_12_re_pipe_im <= input_pipeline_phase0_re_10_under_pipe_1_im * coeffphase1_12_pipe_1;

        product_phase0_12_re_pipe_1_re <= product_phase0_12_re_pipe_re;
        product_phase0_12_re_pipe_1_im <= product_phase0_12_re_pipe_im;
      END IF;
    END IF;
  END PROCESS temp_process13;

  product_phase0_12_re <= product_phase0_12_re_pipe_1_re(30 DOWNTO 0);
  product_phase0_12_im <= product_phase0_12_re_pipe_1_im(30 DOWNTO 0);

  temp_process14 : PROCESS (clk)
  BEGIN
   IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
          input_pipeline_phase0_re_11_under_pipe_re <= (OTHERS => '0');
          input_pipeline_phase0_re_11_under_pipe_im <= (OTHERS => '0');
          input_pipeline_phase0_re_11_under_pipe_1_re <= (OTHERS => '0');
          input_pipeline_phase0_re_11_under_pipe_1_im <= (OTHERS => '0');
          coeffphase1_13_pipe <= (OTHERS => '0');
          coeffphase1_13_pipe_1 <= (OTHERS => '0');
          product_phase0_13_re_pipe_re <= (OTHERS => '0');
          product_phase0_13_re_pipe_im <= (OTHERS => '0');
          product_phase0_13_re_pipe_1_re <= (OTHERS => '0');
          product_phase0_13_re_pipe_1_im <= (OTHERS => '0');
      ELSIF phase_0 = '1' THEN
        input_pipeline_phase0_re_11_under_pipe_re <= input_pipeline_phase0_re(11);
        input_pipeline_phase0_re_11_under_pipe_im <= input_pipeline_phase0_im(11);
        input_pipeline_phase0_re_11_under_pipe_1_re <= input_pipeline_phase0_re_11_under_pipe_re;
        input_pipeline_phase0_re_11_under_pipe_1_im <= input_pipeline_phase0_re_11_under_pipe_im;
        coeffphase1_13_pipe <= coeffphase1_13;
        coeffphase1_13_pipe_1 <= coeffphase1_13_pipe;

        product_phase0_13_re_pipe_re <= input_pipeline_phase0_re_11_under_pipe_1_re * coeffphase1_13_pipe_1;
        product_phase0_13_re_pipe_im <= input_pipeline_phase0_re_11_under_pipe_1_im * coeffphase1_13_pipe_1;

        product_phase0_13_re_pipe_1_re <= product_phase0_13_re_pipe_re;
        product_phase0_13_re_pipe_1_im <= product_phase0_13_re_pipe_im;
      END IF;
    END IF;
  END PROCESS temp_process14;

  product_phase0_13_re <= product_phase0_13_re_pipe_1_re(30 DOWNTO 0);
  product_phase0_13_im <= product_phase0_13_re_pipe_1_im(30 DOWNTO 0);

  temp_process15 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
          input_pipeline_phase0_re_12_under_pipe_re <= (OTHERS => '0');
          input_pipeline_phase0_re_12_under_pipe_im <= (OTHERS => '0');
          input_pipeline_phase0_re_12_under_pipe_1_re <= (OTHERS => '0');
          input_pipeline_phase0_re_12_under_pipe_1_im <= (OTHERS => '0');
          coeffphase1_14_pipe <= (OTHERS => '0');
          coeffphase1_14_pipe_1 <= (OTHERS => '0');
          product_phase0_14_re_pipe_re <= (OTHERS => '0');
          product_phase0_14_re_pipe_im <= (OTHERS => '0');
          product_phase0_14_re_pipe_1_re <= (OTHERS => '0');
          product_phase0_14_re_pipe_1_im <= (OTHERS => '0');
      ELSIF phase_0 = '1' THEN
        input_pipeline_phase0_re_12_under_pipe_re <= input_pipeline_phase0_re(12);
        input_pipeline_phase0_re_12_under_pipe_im <= input_pipeline_phase0_im(12);
        input_pipeline_phase0_re_12_under_pipe_1_re <= input_pipeline_phase0_re_12_under_pipe_re;
        input_pipeline_phase0_re_12_under_pipe_1_im <= input_pipeline_phase0_re_12_under_pipe_im;
        coeffphase1_14_pipe <= coeffphase1_14;
        coeffphase1_14_pipe_1 <= coeffphase1_14_pipe;

        product_phase0_14_re_pipe_re <= input_pipeline_phase0_re_12_under_pipe_1_re * coeffphase1_14_pipe_1;
        product_phase0_14_re_pipe_im <= input_pipeline_phase0_re_12_under_pipe_1_im * coeffphase1_14_pipe_1;

        product_phase0_14_re_pipe_1_re <= product_phase0_14_re_pipe_re;
        product_phase0_14_re_pipe_1_im <= product_phase0_14_re_pipe_im;
      END IF;
    END IF;
  END PROCESS temp_process15;

  product_phase0_14_re <= product_phase0_14_re_pipe_1_re(30 DOWNTO 0);
  product_phase0_14_im <= product_phase0_14_re_pipe_1_im(30 DOWNTO 0);

  temp_process16 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
          input_pipeline_phase0_re_13_under_pipe_re <= (OTHERS => '0');
          input_pipeline_phase0_re_13_under_pipe_im <= (OTHERS => '0');
          input_pipeline_phase0_re_13_under_pipe_1_re <= (OTHERS => '0');
          input_pipeline_phase0_re_13_under_pipe_1_im <= (OTHERS => '0');
          coeffphase1_15_pipe <= (OTHERS => '0');
          coeffphase1_15_pipe_1 <= (OTHERS => '0');
          product_phase0_15_re_pipe_re <= (OTHERS => '0');
          product_phase0_15_re_pipe_im <= (OTHERS => '0');
          product_phase0_15_re_pipe_1_re <= (OTHERS => '0');
          product_phase0_15_re_pipe_1_im <= (OTHERS => '0');
      ELSIF phase_0 = '1' THEN
        input_pipeline_phase0_re_13_under_pipe_re <= input_pipeline_phase0_re(13);
        input_pipeline_phase0_re_13_under_pipe_im <= input_pipeline_phase0_im(13);
        input_pipeline_phase0_re_13_under_pipe_1_re <= input_pipeline_phase0_re_13_under_pipe_re;
        input_pipeline_phase0_re_13_under_pipe_1_im <= input_pipeline_phase0_re_13_under_pipe_im;
        coeffphase1_15_pipe <= coeffphase1_15;
        coeffphase1_15_pipe_1 <= coeffphase1_15_pipe;

        product_phase0_15_re_pipe_re <= input_pipeline_phase0_re_13_under_pipe_1_re * coeffphase1_15_pipe_1;
        product_phase0_15_re_pipe_im <= input_pipeline_phase0_re_13_under_pipe_1_im * coeffphase1_15_pipe_1;

        product_phase0_15_re_pipe_1_re <= product_phase0_15_re_pipe_re;
        product_phase0_15_re_pipe_1_im <= product_phase0_15_re_pipe_im;
      END IF;
    END IF;
  END PROCESS temp_process16;

  product_phase0_15_re <= product_phase0_15_re_pipe_1_re(30 DOWNTO 0);
  product_phase0_15_im <= product_phase0_15_re_pipe_1_im(30 DOWNTO 0);

  temp_process17 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
          input_pipeline_phase0_re_14_under_pipe_re <= (OTHERS => '0');
          input_pipeline_phase0_re_14_under_pipe_im <= (OTHERS => '0');
          input_pipeline_phase0_re_14_under_pipe_1_re <= (OTHERS => '0');
          input_pipeline_phase0_re_14_under_pipe_1_im <= (OTHERS => '0');
          coeffphase1_16_pipe <= (OTHERS => '0');
          coeffphase1_16_pipe_1 <= (OTHERS => '0');
          product_phase0_16_re_pipe_re <= (OTHERS => '0');
          product_phase0_16_re_pipe_im <= (OTHERS => '0');
          product_phase0_16_re_pipe_1_re <= (OTHERS => '0');
          product_phase0_16_re_pipe_1_im <= (OTHERS => '0');
      ELSIF phase_0 = '1' THEN
        input_pipeline_phase0_re_14_under_pipe_re <= input_pipeline_phase0_re(14);
        input_pipeline_phase0_re_14_under_pipe_im <= input_pipeline_phase0_im(14);
        input_pipeline_phase0_re_14_under_pipe_1_re <= input_pipeline_phase0_re_14_under_pipe_re;
        input_pipeline_phase0_re_14_under_pipe_1_im <= input_pipeline_phase0_re_14_under_pipe_im;
        coeffphase1_16_pipe <= coeffphase1_16;
        coeffphase1_16_pipe_1 <= coeffphase1_16_pipe;

        product_phase0_16_re_pipe_re <= input_pipeline_phase0_re_14_under_pipe_1_re * coeffphase1_16_pipe_1;
        product_phase0_16_re_pipe_im <= input_pipeline_phase0_re_14_under_pipe_1_im * coeffphase1_16_pipe_1;

        product_phase0_16_re_pipe_1_re <= product_phase0_16_re_pipe_re;
        product_phase0_16_re_pipe_1_im <= product_phase0_16_re_pipe_im;
      END IF;
    END IF;
  END PROCESS temp_process17;

  product_phase0_16_re <= product_phase0_16_re_pipe_1_re(30 DOWNTO 0);
  product_phase0_16_im <= product_phase0_16_re_pipe_1_im(30 DOWNTO 0);

  temp_process18 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
          input_pipeline_phase0_re_15_under_pipe_re <= (OTHERS => '0');
          input_pipeline_phase0_re_15_under_pipe_im <= (OTHERS => '0');
          input_pipeline_phase0_re_15_under_pipe_1_re <= (OTHERS => '0');
          input_pipeline_phase0_re_15_under_pipe_1_im <= (OTHERS => '0');
          coeffphase1_17_pipe <= (OTHERS => '0');
          coeffphase1_17_pipe_1 <= (OTHERS => '0');
          product_phase0_17_re_pipe_re <= (OTHERS => '0');
          product_phase0_17_re_pipe_im <= (OTHERS => '0');
          product_phase0_17_re_pipe_1_re <= (OTHERS => '0');
          product_phase0_17_re_pipe_1_im <= (OTHERS => '0');
      ELSIF phase_0 = '1' THEN
        input_pipeline_phase0_re_15_under_pipe_re <= input_pipeline_phase0_re(15);
        input_pipeline_phase0_re_15_under_pipe_im <= input_pipeline_phase0_im(15);
        input_pipeline_phase0_re_15_under_pipe_1_re <= input_pipeline_phase0_re_15_under_pipe_re;
        input_pipeline_phase0_re_15_under_pipe_1_im <= input_pipeline_phase0_re_15_under_pipe_im;
        coeffphase1_17_pipe <= coeffphase1_17;
        coeffphase1_17_pipe_1 <= coeffphase1_17_pipe;

        product_phase0_17_re_pipe_re <= input_pipeline_phase0_re_15_under_pipe_1_re * coeffphase1_17_pipe_1;
        product_phase0_17_re_pipe_im <= input_pipeline_phase0_re_15_under_pipe_1_im * coeffphase1_17_pipe_1;

        product_phase0_17_re_pipe_1_re <= product_phase0_17_re_pipe_re;
        product_phase0_17_re_pipe_1_im <= product_phase0_17_re_pipe_im;
      END IF;
    END IF;
  END PROCESS temp_process18;

  product_phase0_17_re <= product_phase0_17_re_pipe_1_re(30 DOWNTO 0);
  product_phase0_17_im <= product_phase0_17_re_pipe_1_im(30 DOWNTO 0);

  temp_process19 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
          input_pipeline_phase0_re_16_under_pipe_re <= (OTHERS => '0');
          input_pipeline_phase0_re_16_under_pipe_im <= (OTHERS => '0');
          input_pipeline_phase0_re_16_under_pipe_1_re <= (OTHERS => '0');
          input_pipeline_phase0_re_16_under_pipe_1_im <= (OTHERS => '0');
          coeffphase1_18_pipe <= (OTHERS => '0');
          coeffphase1_18_pipe_1 <= (OTHERS => '0');
          product_phase0_18_re_pipe_re <= (OTHERS => '0');
          product_phase0_18_re_pipe_im <= (OTHERS => '0');
          product_phase0_18_re_pipe_1_re <= (OTHERS => '0');
          product_phase0_18_re_pipe_1_im <= (OTHERS => '0');
      ELSIF phase_0 = '1' THEN
        input_pipeline_phase0_re_16_under_pipe_re <= input_pipeline_phase0_re(16);
        input_pipeline_phase0_re_16_under_pipe_im <= input_pipeline_phase0_im(16);
        input_pipeline_phase0_re_16_under_pipe_1_re <= input_pipeline_phase0_re_16_under_pipe_re;
        input_pipeline_phase0_re_16_under_pipe_1_im <= input_pipeline_phase0_re_16_under_pipe_im;
        coeffphase1_18_pipe <= coeffphase1_18;
        coeffphase1_18_pipe_1 <= coeffphase1_18_pipe;

        product_phase0_18_re_pipe_re <= input_pipeline_phase0_re_16_under_pipe_1_re * coeffphase1_18_pipe_1;
        product_phase0_18_re_pipe_im <= input_pipeline_phase0_re_16_under_pipe_1_im * coeffphase1_18_pipe_1;

        product_phase0_18_re_pipe_1_re <= product_phase0_18_re_pipe_re;
        product_phase0_18_re_pipe_1_im <= product_phase0_18_re_pipe_im;
      END IF;
    END IF;
  END PROCESS temp_process19;

  product_phase0_18_re <= product_phase0_18_re_pipe_1_re(30 DOWNTO 0);
  product_phase0_18_im <= product_phase0_18_re_pipe_1_im(30 DOWNTO 0);

  temp_process20 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
          input_pipeline_phase0_re_17_under_pipe_re <= (OTHERS => '0');
          input_pipeline_phase0_re_17_under_pipe_im <= (OTHERS => '0');
          input_pipeline_phase0_re_17_under_pipe_1_re <= (OTHERS => '0');
          input_pipeline_phase0_re_17_under_pipe_1_im <= (OTHERS => '0');
          coeffphase1_19_pipe <= (OTHERS => '0');
          coeffphase1_19_pipe_1 <= (OTHERS => '0');
          product_phase0_19_re_pipe_re <= (OTHERS => '0');
          product_phase0_19_re_pipe_im <= (OTHERS => '0');
          product_phase0_19_re_pipe_1_re <= (OTHERS => '0');
          product_phase0_19_re_pipe_1_im <= (OTHERS => '0');
      ELSIF phase_0 = '1' THEN
        input_pipeline_phase0_re_17_under_pipe_re <= input_pipeline_phase0_re(17);
        input_pipeline_phase0_re_17_under_pipe_im <= input_pipeline_phase0_im(17);
        input_pipeline_phase0_re_17_under_pipe_1_re <= input_pipeline_phase0_re_17_under_pipe_re;
        input_pipeline_phase0_re_17_under_pipe_1_im <= input_pipeline_phase0_re_17_under_pipe_im;
        coeffphase1_19_pipe <= coeffphase1_19;
        coeffphase1_19_pipe_1 <= coeffphase1_19_pipe;

        product_phase0_19_re_pipe_re <= input_pipeline_phase0_re_17_under_pipe_1_re * coeffphase1_19_pipe_1;
        product_phase0_19_re_pipe_im <= input_pipeline_phase0_re_17_under_pipe_1_im * coeffphase1_19_pipe_1;

        product_phase0_19_re_pipe_1_re <= product_phase0_19_re_pipe_re;
        product_phase0_19_re_pipe_1_im <= product_phase0_19_re_pipe_im;
      END IF;
    END IF;
  END PROCESS temp_process20;

  product_phase0_19_re <= product_phase0_19_re_pipe_1_re(30 DOWNTO 0);
  product_phase0_19_im <= product_phase0_19_re_pipe_1_im(30 DOWNTO 0);

  temp_process21 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
          input_pipeline_phase0_re_18_under_pipe_re <= (OTHERS => '0');
          input_pipeline_phase0_re_18_under_pipe_im <= (OTHERS => '0');
          input_pipeline_phase0_re_18_under_pipe_1_re <= (OTHERS => '0');
          input_pipeline_phase0_re_18_under_pipe_1_im <= (OTHERS => '0');
          coeffphase1_20_pipe <= (OTHERS => '0');
          coeffphase1_20_pipe_1 <= (OTHERS => '0');
          product_phase0_20_re_pipe_re <= (OTHERS => '0');
          product_phase0_20_re_pipe_im <= (OTHERS => '0');
          product_phase0_20_re_pipe_1_re <= (OTHERS => '0');
          product_phase0_20_re_pipe_1_im <= (OTHERS => '0');
      ELSIF phase_0 = '1' THEN
        input_pipeline_phase0_re_18_under_pipe_re <= input_pipeline_phase0_re(18);
        input_pipeline_phase0_re_18_under_pipe_im <= input_pipeline_phase0_im(18);
        input_pipeline_phase0_re_18_under_pipe_1_re <= input_pipeline_phase0_re_18_under_pipe_re;
        input_pipeline_phase0_re_18_under_pipe_1_im <= input_pipeline_phase0_re_18_under_pipe_im;
        coeffphase1_20_pipe <= coeffphase1_20;
        coeffphase1_20_pipe_1 <= coeffphase1_20_pipe;

        product_phase0_20_re_pipe_re <= input_pipeline_phase0_re_18_under_pipe_1_re * coeffphase1_20_pipe_1;
        product_phase0_20_re_pipe_im <= input_pipeline_phase0_re_18_under_pipe_1_im * coeffphase1_20_pipe_1;

        product_phase0_20_re_pipe_1_re <= product_phase0_20_re_pipe_re;
        product_phase0_20_re_pipe_1_im <= product_phase0_20_re_pipe_im;
      END IF;
    END IF;
  END PROCESS temp_process21;

  product_phase0_20_re <= product_phase0_20_re_pipe_1_re(30 DOWNTO 0);
  product_phase0_20_im <= product_phase0_20_re_pipe_1_im(30 DOWNTO 0);

  temp_process22 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
          input_pipeline_phase0_re_19_under_pipe_re <= (OTHERS => '0');
          input_pipeline_phase0_re_19_under_pipe_im <= (OTHERS => '0');
          input_pipeline_phase0_re_19_under_pipe_1_re <= (OTHERS => '0');
          input_pipeline_phase0_re_19_under_pipe_1_im <= (OTHERS => '0');
          coeffphase1_21_pipe <= (OTHERS => '0');
          coeffphase1_21_pipe_1 <= (OTHERS => '0');
          product_phase0_21_re_pipe_re <= (OTHERS => '0');
          product_phase0_21_re_pipe_im <= (OTHERS => '0');
          product_phase0_21_re_pipe_1_re <= (OTHERS => '0');
          product_phase0_21_re_pipe_1_im <= (OTHERS => '0');
      ELSIF phase_0 = '1' THEN
        input_pipeline_phase0_re_19_under_pipe_re <= input_pipeline_phase0_re(19);
        input_pipeline_phase0_re_19_under_pipe_im <= input_pipeline_phase0_im(19);
        input_pipeline_phase0_re_19_under_pipe_1_re <= input_pipeline_phase0_re_19_under_pipe_re;
        input_pipeline_phase0_re_19_under_pipe_1_im <= input_pipeline_phase0_re_19_under_pipe_im;
        coeffphase1_21_pipe <= coeffphase1_21;
        coeffphase1_21_pipe_1 <= coeffphase1_21_pipe;

        product_phase0_21_re_pipe_re <= input_pipeline_phase0_re_19_under_pipe_1_re * coeffphase1_21_pipe_1;
        product_phase0_21_re_pipe_im <= input_pipeline_phase0_re_19_under_pipe_1_im * coeffphase1_21_pipe_1;

        product_phase0_21_re_pipe_1_re <= product_phase0_21_re_pipe_re;
        product_phase0_21_re_pipe_1_im <= product_phase0_21_re_pipe_im;
      END IF;
    END IF;
  END PROCESS temp_process22;

  product_phase0_21_re <= product_phase0_21_re_pipe_1_re(30 DOWNTO 0);
  product_phase0_21_im <= product_phase0_21_re_pipe_1_im(30 DOWNTO 0);

  temp_process23 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
          input_pipeline_phase0_re_20_under_pipe_re <= (OTHERS => '0');
          input_pipeline_phase0_re_20_under_pipe_im <= (OTHERS => '0');
          input_pipeline_phase0_re_20_under_pipe_1_re <= (OTHERS => '0');
          input_pipeline_phase0_re_20_under_pipe_1_im <= (OTHERS => '0');
          coeffphase1_22_pipe <= (OTHERS => '0');
          coeffphase1_22_pipe_1 <= (OTHERS => '0');
          product_phase0_22_re_pipe_re <= (OTHERS => '0');
          product_phase0_22_re_pipe_im <= (OTHERS => '0');
          product_phase0_22_re_pipe_1_re <= (OTHERS => '0');
          product_phase0_22_re_pipe_1_im <= (OTHERS => '0');
      ELSIF phase_0 = '1' THEN
        input_pipeline_phase0_re_20_under_pipe_re <= input_pipeline_phase0_re(20);
        input_pipeline_phase0_re_20_under_pipe_im <= input_pipeline_phase0_im(20);
        input_pipeline_phase0_re_20_under_pipe_1_re <= input_pipeline_phase0_re_20_under_pipe_re;
        input_pipeline_phase0_re_20_under_pipe_1_im <= input_pipeline_phase0_re_20_under_pipe_im;
        coeffphase1_22_pipe <= coeffphase1_22;
        coeffphase1_22_pipe_1 <= coeffphase1_22_pipe;

        product_phase0_22_re_pipe_re <= input_pipeline_phase0_re_20_under_pipe_1_re * coeffphase1_22_pipe_1;
        product_phase0_22_re_pipe_im <= input_pipeline_phase0_re_20_under_pipe_1_im * coeffphase1_22_pipe_1;

        product_phase0_22_re_pipe_1_re <= product_phase0_22_re_pipe_re;
        product_phase0_22_re_pipe_1_im <= product_phase0_22_re_pipe_im;
      END IF;
    END IF;
  END PROCESS temp_process23;

  product_phase0_22_re <= product_phase0_22_re_pipe_1_re(30 DOWNTO 0);
  product_phase0_22_im <= product_phase0_22_re_pipe_1_im(30 DOWNTO 0);

  temp_process24 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
          input_pipeline_phase0_re_21_under_pipe_re <= (OTHERS => '0');
          input_pipeline_phase0_re_21_under_pipe_im <= (OTHERS => '0');
          input_pipeline_phase0_re_21_under_pipe_1_re <= (OTHERS => '0');
          input_pipeline_phase0_re_21_under_pipe_1_im <= (OTHERS => '0');
          coeffphase1_23_pipe <= (OTHERS => '0');
          coeffphase1_23_pipe_1 <= (OTHERS => '0');
          product_phase0_23_re_pipe_re <= (OTHERS => '0');
          product_phase0_23_re_pipe_im <= (OTHERS => '0');
          product_phase0_23_re_pipe_1_re <= (OTHERS => '0');
          product_phase0_23_re_pipe_1_im <= (OTHERS => '0');
      ELSIF phase_0 = '1' THEN
        input_pipeline_phase0_re_21_under_pipe_re <= input_pipeline_phase0_re(21);
        input_pipeline_phase0_re_21_under_pipe_im <= input_pipeline_phase0_im(21);
        input_pipeline_phase0_re_21_under_pipe_1_re <= input_pipeline_phase0_re_21_under_pipe_re;
        input_pipeline_phase0_re_21_under_pipe_1_im <= input_pipeline_phase0_re_21_under_pipe_im;
        coeffphase1_23_pipe <= coeffphase1_23;
        coeffphase1_23_pipe_1 <= coeffphase1_23_pipe;

        product_phase0_23_re_pipe_re <= input_pipeline_phase0_re_21_under_pipe_1_re * coeffphase1_23_pipe_1;
        product_phase0_23_re_pipe_im <= input_pipeline_phase0_re_21_under_pipe_1_im * coeffphase1_23_pipe_1;

        product_phase0_23_re_pipe_1_re <= product_phase0_23_re_pipe_re;
        product_phase0_23_re_pipe_1_im <= product_phase0_23_re_pipe_im;
      END IF;
    END IF;
  END PROCESS temp_process24;

  product_phase0_23_re <= product_phase0_23_re_pipe_1_re(30 DOWNTO 0);
  product_phase0_23_im <= product_phase0_23_re_pipe_1_im(30 DOWNTO 0);

  temp_process25 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
          input_pipeline_phase0_re_22_under_pipe_re <= (OTHERS => '0');
          input_pipeline_phase0_re_22_under_pipe_im <= (OTHERS => '0');
          input_pipeline_phase0_re_22_under_pipe_1_re <= (OTHERS => '0');
          input_pipeline_phase0_re_22_under_pipe_1_im <= (OTHERS => '0');
          coeffphase1_24_pipe <= (OTHERS => '0');
          coeffphase1_24_pipe_1 <= (OTHERS => '0');
          product_phase0_24_re_pipe_re <= (OTHERS => '0');
          product_phase0_24_re_pipe_im <= (OTHERS => '0');
          product_phase0_24_re_pipe_1_re <= (OTHERS => '0');
          product_phase0_24_re_pipe_1_im <= (OTHERS => '0');
      ELSIF phase_0 = '1' THEN
        input_pipeline_phase0_re_22_under_pipe_re <= input_pipeline_phase0_re(22);
        input_pipeline_phase0_re_22_under_pipe_im <= input_pipeline_phase0_im(22);
        input_pipeline_phase0_re_22_under_pipe_1_re <= input_pipeline_phase0_re_22_under_pipe_re;
        input_pipeline_phase0_re_22_under_pipe_1_im <= input_pipeline_phase0_re_22_under_pipe_im;
        coeffphase1_24_pipe <= coeffphase1_24;
        coeffphase1_24_pipe_1 <= coeffphase1_24_pipe;

        product_phase0_24_re_pipe_re <= input_pipeline_phase0_re_22_under_pipe_1_re * coeffphase1_24_pipe_1;
        product_phase0_24_re_pipe_im <= input_pipeline_phase0_re_22_under_pipe_1_im * coeffphase1_24_pipe_1;

        product_phase0_24_re_pipe_1_re <= product_phase0_24_re_pipe_re;
        product_phase0_24_re_pipe_1_im <= product_phase0_24_re_pipe_im;
      END IF;
    END IF;
  END PROCESS temp_process25;

  product_phase0_24_re <= product_phase0_24_re_pipe_1_re(30 DOWNTO 0);
  product_phase0_24_im <= product_phase0_24_re_pipe_1_im(30 DOWNTO 0);

  temp_process26 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
          input_pipeline_phase0_re_23_under_pipe_re <= (OTHERS => '0');
          input_pipeline_phase0_re_23_under_pipe_im <= (OTHERS => '0');
          input_pipeline_phase0_re_23_under_pipe_1_re <= (OTHERS => '0');
          input_pipeline_phase0_re_23_under_pipe_1_im <= (OTHERS => '0');
          coeffphase1_25_pipe <= (OTHERS => '0');
          coeffphase1_25_pipe_1 <= (OTHERS => '0');
          product_phase0_25_re_pipe_re <= (OTHERS => '0');
          product_phase0_25_re_pipe_im <= (OTHERS => '0');
          product_phase0_25_re_pipe_1_re <= (OTHERS => '0');
          product_phase0_25_re_pipe_1_im <= (OTHERS => '0');
      ELSIF phase_0 = '1' THEN
        input_pipeline_phase0_re_23_under_pipe_re <= input_pipeline_phase0_re(23);
        input_pipeline_phase0_re_23_under_pipe_im <= input_pipeline_phase0_im(23);
        input_pipeline_phase0_re_23_under_pipe_1_re <= input_pipeline_phase0_re_23_under_pipe_re;
        input_pipeline_phase0_re_23_under_pipe_1_im <= input_pipeline_phase0_re_23_under_pipe_im;
        coeffphase1_25_pipe <= coeffphase1_25;
        coeffphase1_25_pipe_1 <= coeffphase1_25_pipe;

        product_phase0_25_re_pipe_re <= input_pipeline_phase0_re_23_under_pipe_1_re * coeffphase1_25_pipe_1;
        product_phase0_25_re_pipe_im <= input_pipeline_phase0_re_23_under_pipe_1_im * coeffphase1_25_pipe_1;

        product_phase0_25_re_pipe_1_re <= product_phase0_25_re_pipe_re;
        product_phase0_25_re_pipe_1_im <= product_phase0_25_re_pipe_im;
      END IF;
    END IF;
  END PROCESS temp_process26;

  product_phase0_25_re <= product_phase0_25_re_pipe_1_re(30 DOWNTO 0);
  product_phase0_25_im <= product_phase0_25_re_pipe_1_im(30 DOWNTO 0);

  temp_process27 : PROCESS (clk)
  BEGIN
   IF clk'event AND clk = '1' THEN
       IF reset = '1' THEN
          input_pipeline_phase0_re_24_under_pipe_re <= (OTHERS => '0');
          input_pipeline_phase0_re_24_under_pipe_im <= (OTHERS => '0');
          input_pipeline_phase0_re_24_under_pipe_1_re <= (OTHERS => '0');
          input_pipeline_phase0_re_24_under_pipe_1_im <= (OTHERS => '0');
          coeffphase1_26_pipe <= (OTHERS => '0');
          coeffphase1_26_pipe_1 <= (OTHERS => '0');
          product_phase0_26_re_pipe_re <= (OTHERS => '0');
          product_phase0_26_re_pipe_im <= (OTHERS => '0');
          product_phase0_26_re_pipe_1_re <= (OTHERS => '0');
          product_phase0_26_re_pipe_1_im <= (OTHERS => '0');
      ELSIF phase_0 = '1' THEN
        input_pipeline_phase0_re_24_under_pipe_re <= input_pipeline_phase0_re(24);
        input_pipeline_phase0_re_24_under_pipe_im <= input_pipeline_phase0_im(24);
        input_pipeline_phase0_re_24_under_pipe_1_re <= input_pipeline_phase0_re_24_under_pipe_re;
        input_pipeline_phase0_re_24_under_pipe_1_im <= input_pipeline_phase0_re_24_under_pipe_im;
        coeffphase1_26_pipe <= coeffphase1_26;
        coeffphase1_26_pipe_1 <= coeffphase1_26_pipe;

        product_phase0_26_re_pipe_re <= input_pipeline_phase0_re_24_under_pipe_1_re * coeffphase1_26_pipe_1;
        product_phase0_26_re_pipe_im <= input_pipeline_phase0_re_24_under_pipe_1_im * coeffphase1_26_pipe_1;

        product_phase0_26_re_pipe_1_re <= product_phase0_26_re_pipe_re;
        product_phase0_26_re_pipe_1_im <= product_phase0_26_re_pipe_im;
      END IF;
    END IF;
  END PROCESS temp_process27;

  product_phase0_26_re <= product_phase0_26_re_pipe_1_re(30 DOWNTO 0);
  product_phase0_26_im <= product_phase0_26_re_pipe_1_im(30 DOWNTO 0);

  temp_process28 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
          input_pipeline_phase0_re_25_under_pipe_re <= (OTHERS => '0');
          input_pipeline_phase0_re_25_under_pipe_im <= (OTHERS => '0');
          input_pipeline_phase0_re_25_under_pipe_1_re <= (OTHERS => '0');
          input_pipeline_phase0_re_25_under_pipe_1_im <= (OTHERS => '0');
          coeffphase1_27_pipe <= (OTHERS => '0');
          coeffphase1_27_pipe_1 <= (OTHERS => '0');
          product_phase0_27_re_pipe_re <= (OTHERS => '0');
          product_phase0_27_re_pipe_im <= (OTHERS => '0');
          product_phase0_27_re_pipe_1_re <= (OTHERS => '0');
          product_phase0_27_re_pipe_1_im <= (OTHERS => '0');
      ELSIF phase_0 = '1' THEN
        input_pipeline_phase0_re_25_under_pipe_re <= input_pipeline_phase0_re(25);
        input_pipeline_phase0_re_25_under_pipe_im <= input_pipeline_phase0_im(25);
        input_pipeline_phase0_re_25_under_pipe_1_re <= input_pipeline_phase0_re_25_under_pipe_re;
        input_pipeline_phase0_re_25_under_pipe_1_im <= input_pipeline_phase0_re_25_under_pipe_im;
        coeffphase1_27_pipe <= coeffphase1_27;
        coeffphase1_27_pipe_1 <= coeffphase1_27_pipe;

        product_phase0_27_re_pipe_re <= input_pipeline_phase0_re_25_under_pipe_1_re * coeffphase1_27_pipe_1;
        product_phase0_27_re_pipe_im <= input_pipeline_phase0_re_25_under_pipe_1_im * coeffphase1_27_pipe_1;

        product_phase0_27_re_pipe_1_re <= product_phase0_27_re_pipe_re;
        product_phase0_27_re_pipe_1_im <= product_phase0_27_re_pipe_im;
      END IF;
    END IF;
  END PROCESS temp_process28;

  product_phase0_27_re <= product_phase0_27_re_pipe_1_re(30 DOWNTO 0);
  product_phase0_27_im <= product_phase0_27_re_pipe_1_im(30 DOWNTO 0);

  temp_process29 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
          int_delay_pipe_2_re <= (OTHERS => (OTHERS => '0'));
          int_delay_pipe_2_im <= (OTHERS => (OTHERS => '0'));
      ELSIF phase_0 = '1' THEN
        int_delay_pipe_2_re(1) <= int_delay_pipe_2_re(0);
        int_delay_pipe_2_im(1) <= int_delay_pipe_2_im(0);
        int_delay_pipe_2_re(0) <= input_pipeline_phase0_re(26);
        int_delay_pipe_2_im(0) <= input_pipeline_phase0_im(26);
      END IF;
    END IF;
  END PROCESS temp_process29;
  input_pipeline_phase0_re_26_pipe_re <= int_delay_pipe_2_re(1);
  input_pipeline_phase0_re_26_pipe_im <= int_delay_pipe_2_im(1);

  temp_process30 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
          int_delay_pipe_3_re <= (OTHERS => (OTHERS => '0'));
          int_delay_pipe_3_im <= (OTHERS => (OTHERS => '0'));
      ELSIF phase_0 = '1' THEN
        int_delay_pipe_3_re(1) <= int_delay_pipe_3_re(0);
        int_delay_pipe_3_im(1) <= int_delay_pipe_3_im(0);
        int_delay_pipe_3_re(0) <= product_phase0_28_re_pipe_re;
        int_delay_pipe_3_im(0) <= product_phase0_28_re_pipe_im;
      END IF;
    END IF;
  END PROCESS temp_process30;
  product_phase0_28_re <= int_delay_pipe_3_re(1);
  product_phase0_28_im <= int_delay_pipe_3_im(1);

  mulpwr2_temp_2 <= ('0' & input_pipeline_phase0_re_26_pipe_re) WHEN input_pipeline_phase0_re_26_pipe_re = "1000000000000000"
      ELSE -resize(input_pipeline_phase0_re_26_pipe_re,17);

  product_phase0_28_re_pipe_re <= resize(mulpwr2_temp_2(16 DOWNTO 0) & '0', 31);

  mulpwr2_temp_3 <= ('0' & input_pipeline_phase0_re_26_pipe_im) WHEN input_pipeline_phase0_re_26_pipe_im = "1000000000000000"
      ELSE -resize(input_pipeline_phase0_re_26_pipe_im,17);

  product_phase0_28_re_pipe_im <= resize(mulpwr2_temp_3(16 DOWNTO 0) & '0', 31);

  temp_process31 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
          int_delay_pipe_4_re <= (OTHERS => (OTHERS => '0'));
          int_delay_pipe_4_im <= (OTHERS => (OTHERS => '0'));
      ELSIF phase_0 = '1' THEN
        int_delay_pipe_4_re(1) <= int_delay_pipe_4_re(0);
        int_delay_pipe_4_im(1) <= int_delay_pipe_4_im(0);
        int_delay_pipe_4_re(0) <= input_pipeline_phase1_re(13);
        int_delay_pipe_4_im(0) <= input_pipeline_phase1_im(13);
      END IF;
    END IF;
  END PROCESS temp_process31;
  input_pipeline_phase1_re_13_pipe_re <= int_delay_pipe_4_re(1);
  input_pipeline_phase1_re_13_pipe_im <= int_delay_pipe_4_im(1);

  temp_process32 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
          int_delay_pipe_5_re <= (OTHERS => (OTHERS => '0'));
          int_delay_pipe_5_im <= (OTHERS => (OTHERS => '0'));
      ELSIF phase_0 = '1' THEN
        int_delay_pipe_5_re(1) <= int_delay_pipe_5_re(0);
        int_delay_pipe_5_im(1) <= int_delay_pipe_5_im(0);
        int_delay_pipe_5_re(0) <= product_phase1_14_re_pipe_re;
        int_delay_pipe_5_im(0) <= product_phase1_14_re_pipe_im;
      END IF;
    END IF;
  END PROCESS temp_process32;
  product_phase1_14_re <= int_delay_pipe_5_re(1);
  product_phase1_14_im <= int_delay_pipe_5_im(1);

  product_phase1_14_re_pipe_re <= resize(input_pipeline_phase1_re_13_pipe_re(15 DOWNTO 0) & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 31);

  product_phase1_14_re_pipe_im <= resize(input_pipeline_phase1_re_13_pipe_im(15 DOWNTO 0) & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 31);

  product_pipeline_process1 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
          product_pipeline_phase0_1_re <= (OTHERS => '0');
          product_pipeline_phase0_1_im <= (OTHERS => '0');
          product_pipeline_phase0_2_re <= (OTHERS => '0');
          product_pipeline_phase0_2_im <= (OTHERS => '0');
          product_pipeline_phase0_3_re <= (OTHERS => '0');
          product_pipeline_phase0_3_im <= (OTHERS => '0');
          product_pipeline_phase0_4_re <= (OTHERS => '0');
          product_pipeline_phase0_4_im <= (OTHERS => '0');
          product_pipeline_phase0_5_re <= (OTHERS => '0');
          product_pipeline_phase0_5_im <= (OTHERS => '0');
          product_pipeline_phase0_6_re <= (OTHERS => '0');
          product_pipeline_phase0_6_im <= (OTHERS => '0');
          product_pipeline_phase0_7_re <= (OTHERS => '0');
          product_pipeline_phase0_7_im <= (OTHERS => '0');
          product_pipeline_phase0_8_re <= (OTHERS => '0');
          product_pipeline_phase0_8_im <= (OTHERS => '0');
          product_pipeline_phase0_9_re <= (OTHERS => '0');
          product_pipeline_phase0_9_im <= (OTHERS => '0');
          product_pipeline_phase0_10_re <= (OTHERS => '0');
          product_pipeline_phase0_10_im <= (OTHERS => '0');
          product_pipeline_phase0_11_re <= (OTHERS => '0');
          product_pipeline_phase0_11_im <= (OTHERS => '0');
          product_pipeline_phase0_12_re <= (OTHERS => '0');
          product_pipeline_phase0_12_im <= (OTHERS => '0');
          product_pipeline_phase0_13_re <= (OTHERS => '0');
          product_pipeline_phase0_13_im <= (OTHERS => '0');
          product_pipeline_phase0_14_re <= (OTHERS => '0');
          product_pipeline_phase0_14_im <= (OTHERS => '0');
          product_pipeline_phase1_14_re <= (OTHERS => '0');
          product_pipeline_phase1_14_im <= (OTHERS => '0');
          product_pipeline_phase0_15_re <= (OTHERS => '0');
          product_pipeline_phase0_15_im <= (OTHERS => '0');
          product_pipeline_phase0_16_re <= (OTHERS => '0');
          product_pipeline_phase0_16_im <= (OTHERS => '0');
          product_pipeline_phase0_17_re <= (OTHERS => '0');
          product_pipeline_phase0_17_im <= (OTHERS => '0');
          product_pipeline_phase0_18_re <= (OTHERS => '0');
          product_pipeline_phase0_18_im <= (OTHERS => '0');
          product_pipeline_phase0_19_re <= (OTHERS => '0');
          product_pipeline_phase0_19_im <= (OTHERS => '0');
          product_pipeline_phase0_20_re <= (OTHERS => '0');
          product_pipeline_phase0_20_im <= (OTHERS => '0');
          product_pipeline_phase0_21_re <= (OTHERS => '0');
          product_pipeline_phase0_21_im <= (OTHERS => '0');
          product_pipeline_phase0_22_re <= (OTHERS => '0');
          product_pipeline_phase0_22_im <= (OTHERS => '0');
          product_pipeline_phase0_23_re <= (OTHERS => '0');
          product_pipeline_phase0_23_im <= (OTHERS => '0');
          product_pipeline_phase0_24_re <= (OTHERS => '0');
          product_pipeline_phase0_24_im <= (OTHERS => '0');
          product_pipeline_phase0_25_re <= (OTHERS => '0');
          product_pipeline_phase0_25_im <= (OTHERS => '0');
          product_pipeline_phase0_26_re <= (OTHERS => '0');
          product_pipeline_phase0_26_im <= (OTHERS => '0');
          product_pipeline_phase0_27_re <= (OTHERS => '0');
          product_pipeline_phase0_27_im <= (OTHERS => '0');
          product_pipeline_phase0_28_re <= (OTHERS => '0');
          product_pipeline_phase0_28_im <= (OTHERS => '0');
      ELSIF phase_0 = '1' THEN
        product_pipeline_phase0_1_re <= product_phase0_1_re;
        product_pipeline_phase0_1_im <= product_phase0_1_im;
        product_pipeline_phase0_2_re <= product_phase0_2_re;
        product_pipeline_phase0_2_im <= product_phase0_2_im;
        product_pipeline_phase0_3_re <= product_phase0_3_re;
        product_pipeline_phase0_3_im <= product_phase0_3_im;
        product_pipeline_phase0_4_re <= product_phase0_4_re;
        product_pipeline_phase0_4_im <= product_phase0_4_im;
        product_pipeline_phase0_5_re <= product_phase0_5_re;
        product_pipeline_phase0_5_im <= product_phase0_5_im;
        product_pipeline_phase0_6_re <= product_phase0_6_re;
        product_pipeline_phase0_6_im <= product_phase0_6_im;
        product_pipeline_phase0_7_re <= product_phase0_7_re;
        product_pipeline_phase0_7_im <= product_phase0_7_im;
        product_pipeline_phase0_8_re <= product_phase0_8_re;
        product_pipeline_phase0_8_im <= product_phase0_8_im;
        product_pipeline_phase0_9_re <= product_phase0_9_re;
        product_pipeline_phase0_9_im <= product_phase0_9_im;
        product_pipeline_phase0_10_re <= product_phase0_10_re;
        product_pipeline_phase0_10_im <= product_phase0_10_im;
        product_pipeline_phase0_11_re <= product_phase0_11_re;
        product_pipeline_phase0_11_im <= product_phase0_11_im;
        product_pipeline_phase0_12_re <= product_phase0_12_re;
        product_pipeline_phase0_12_im <= product_phase0_12_im;
        product_pipeline_phase0_13_re <= product_phase0_13_re;
        product_pipeline_phase0_13_im <= product_phase0_13_im;
        product_pipeline_phase0_14_re <= product_phase0_14_re;
        product_pipeline_phase0_14_im <= product_phase0_14_im;
        product_pipeline_phase1_14_re <= product_phase1_14_re;
        product_pipeline_phase1_14_im <= product_phase1_14_im;
        product_pipeline_phase0_15_re <= product_phase0_15_re;
        product_pipeline_phase0_15_im <= product_phase0_15_im;
        product_pipeline_phase0_16_re <= product_phase0_16_re;
        product_pipeline_phase0_16_im <= product_phase0_16_im;
        product_pipeline_phase0_17_re <= product_phase0_17_re;
        product_pipeline_phase0_17_im <= product_phase0_17_im;
        product_pipeline_phase0_18_re <= product_phase0_18_re;
        product_pipeline_phase0_18_im <= product_phase0_18_im;
        product_pipeline_phase0_19_re <= product_phase0_19_re;
        product_pipeline_phase0_19_im <= product_phase0_19_im;
        product_pipeline_phase0_20_re <= product_phase0_20_re;
        product_pipeline_phase0_20_im <= product_phase0_20_im;
        product_pipeline_phase0_21_re <= product_phase0_21_re;
        product_pipeline_phase0_21_im <= product_phase0_21_im;
        product_pipeline_phase0_22_re <= product_phase0_22_re;
        product_pipeline_phase0_22_im <= product_phase0_22_im;
        product_pipeline_phase0_23_re <= product_phase0_23_re;
        product_pipeline_phase0_23_im <= product_phase0_23_im;
        product_pipeline_phase0_24_re <= product_phase0_24_re;
        product_pipeline_phase0_24_im <= product_phase0_24_im;
        product_pipeline_phase0_25_re <= product_phase0_25_re;
        product_pipeline_phase0_25_im <= product_phase0_25_im;
        product_pipeline_phase0_26_re <= product_phase0_26_re;
        product_pipeline_phase0_26_im <= product_phase0_26_im;
        product_pipeline_phase0_27_re <= product_phase0_27_re;
        product_pipeline_phase0_27_im <= product_phase0_27_im;
        product_pipeline_phase0_28_re <= product_phase0_28_re;
        product_pipeline_phase0_28_im <= product_phase0_28_im;
      END IF;
    END IF; 
  END PROCESS product_pipeline_process1;

  quantized_sum_re <= resize(product_pipeline_phase1_14_re, 32);
  quantized_sum_im <= resize(product_pipeline_phase1_14_im, 32);

  add_temp <= resize(quantized_sum_re, 33) + resize(product_pipeline_phase0_1_re, 33);
  sumvector1_re(0) <= add_temp(31 DOWNTO 0);

  add_temp_1 <= resize(quantized_sum_im, 33) + resize(product_pipeline_phase0_1_im, 33);
  sumvector1_im(0) <= add_temp_1(31 DOWNTO 0);

  sumvector1_re(1) <= resize(product_pipeline_phase0_2_re, 32) + resize(product_pipeline_phase0_3_re, 32);

  sumvector1_im(1) <= resize(product_pipeline_phase0_2_im, 32) + resize(product_pipeline_phase0_3_im, 32);

  sumvector1_re(2) <= resize(product_pipeline_phase0_4_re, 32) + resize(product_pipeline_phase0_5_re, 32);

  sumvector1_im(2) <= resize(product_pipeline_phase0_4_im, 32) + resize(product_pipeline_phase0_5_im, 32);

  sumvector1_re(3) <= resize(product_pipeline_phase0_6_re, 32) + resize(product_pipeline_phase0_7_re, 32);

  sumvector1_im(3) <= resize(product_pipeline_phase0_6_im, 32) + resize(product_pipeline_phase0_7_im, 32);

  sumvector1_re(4) <= resize(product_pipeline_phase0_8_re, 32) + resize(product_pipeline_phase0_9_re, 32);

  sumvector1_im(4) <= resize(product_pipeline_phase0_8_im, 32) + resize(product_pipeline_phase0_9_im, 32);

  sumvector1_re(5) <= resize(product_pipeline_phase0_10_re, 32) + resize(product_pipeline_phase0_11_re, 32);

  sumvector1_im(5) <= resize(product_pipeline_phase0_10_im, 32) + resize(product_pipeline_phase0_11_im, 32);

  sumvector1_re(6) <= resize(product_pipeline_phase0_12_re, 32) + resize(product_pipeline_phase0_13_re, 32);

  sumvector1_im(6) <= resize(product_pipeline_phase0_12_im, 32) + resize(product_pipeline_phase0_13_im, 32);

  sumvector1_re(7) <= resize(product_pipeline_phase0_14_re, 32) + resize(product_pipeline_phase0_15_re, 32);

  sumvector1_im(7) <= resize(product_pipeline_phase0_14_im, 32) + resize(product_pipeline_phase0_15_im, 32);

  sumvector1_re(8) <= resize(product_pipeline_phase0_16_re, 32) + resize(product_pipeline_phase0_17_re, 32);

  sumvector1_im(8) <= resize(product_pipeline_phase0_16_im, 32) + resize(product_pipeline_phase0_17_im, 32);

  sumvector1_re(9) <= resize(product_pipeline_phase0_18_re, 32) + resize(product_pipeline_phase0_19_re, 32);

  sumvector1_im(9) <= resize(product_pipeline_phase0_18_im, 32) + resize(product_pipeline_phase0_19_im, 32);

  sumvector1_re(10) <= resize(product_pipeline_phase0_20_re, 32) + resize(product_pipeline_phase0_21_re, 32);

  sumvector1_im(10) <= resize(product_pipeline_phase0_20_im, 32) + resize(product_pipeline_phase0_21_im, 32);

  sumvector1_re(11) <= resize(product_pipeline_phase0_22_re, 32) + resize(product_pipeline_phase0_23_re, 32);

  sumvector1_im(11) <= resize(product_pipeline_phase0_22_im, 32) + resize(product_pipeline_phase0_23_im, 32);

  sumvector1_re(12) <= resize(product_pipeline_phase0_24_re, 32) + resize(product_pipeline_phase0_25_re, 32);

  sumvector1_im(12) <= resize(product_pipeline_phase0_24_im, 32) + resize(product_pipeline_phase0_25_im, 32);

  sumvector1_re(13) <= resize(product_pipeline_phase0_26_re, 32) + resize(product_pipeline_phase0_27_re, 32);

  sumvector1_im(13) <= resize(product_pipeline_phase0_26_im, 32) + resize(product_pipeline_phase0_27_im, 32);

  sumvector1_re(14) <= resize(product_pipeline_phase0_28_re, 32);
  sumvector1_im(14) <= resize(product_pipeline_phase0_28_im, 32);

  sumdelay_pipeline_process1 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
          sumdelay_pipeline1_re <= (OTHERS => (OTHERS => '0'));
          sumdelay_pipeline1_im <= (OTHERS => (OTHERS => '0'));
      ELSIF phase_0 = '1' THEN
        sumdelay_pipeline1_re(0 TO 14) <= sumvector1_re(0 TO 14);
        sumdelay_pipeline1_im(0 TO 14) <= sumvector1_im(0 TO 14);
      END IF;
    END IF; 
  END PROCESS sumdelay_pipeline_process1;

  add_temp_2 <= resize(sumdelay_pipeline1_re(0), 33) + resize(sumdelay_pipeline1_re(1), 33);
  sumvector2_re(0) <= add_temp_2(31 DOWNTO 0);

  add_temp_3 <= resize(sumdelay_pipeline1_im(0), 33) + resize(sumdelay_pipeline1_im(1), 33);
  sumvector2_im(0) <= add_temp_3(31 DOWNTO 0);

  add_temp_4 <= resize(sumdelay_pipeline1_re(2), 33) + resize(sumdelay_pipeline1_re(3), 33);
  sumvector2_re(1) <= add_temp_4(31 DOWNTO 0);

  add_temp_5 <= resize(sumdelay_pipeline1_im(2), 33) + resize(sumdelay_pipeline1_im(3), 33);
  sumvector2_im(1) <= add_temp_5(31 DOWNTO 0);

  add_temp_6 <= resize(sumdelay_pipeline1_re(4), 33) + resize(sumdelay_pipeline1_re(5), 33);
  sumvector2_re(2) <= add_temp_6(31 DOWNTO 0);

  add_temp_7 <= resize(sumdelay_pipeline1_im(4), 33) + resize(sumdelay_pipeline1_im(5), 33);
  sumvector2_im(2) <= add_temp_7(31 DOWNTO 0);

  add_temp_8 <= resize(sumdelay_pipeline1_re(6), 33) + resize(sumdelay_pipeline1_re(7), 33);
  sumvector2_re(3) <= add_temp_8(31 DOWNTO 0);

  add_temp_9 <= resize(sumdelay_pipeline1_im(6), 33) + resize(sumdelay_pipeline1_im(7), 33);
  sumvector2_im(3) <= add_temp_9(31 DOWNTO 0);

  add_temp_10 <= resize(sumdelay_pipeline1_re(8), 33) + resize(sumdelay_pipeline1_re(9), 33);
  sumvector2_re(4) <= add_temp_10(31 DOWNTO 0);

  add_temp_11 <= resize(sumdelay_pipeline1_im(8), 33) + resize(sumdelay_pipeline1_im(9), 33);
  sumvector2_im(4) <= add_temp_11(31 DOWNTO 0);

  add_temp_12 <= resize(sumdelay_pipeline1_re(10), 33) + resize(sumdelay_pipeline1_re(11), 33);
  sumvector2_re(5) <= add_temp_12(31 DOWNTO 0);

  add_temp_13 <= resize(sumdelay_pipeline1_im(10), 33) + resize(sumdelay_pipeline1_im(11), 33);
  sumvector2_im(5) <= add_temp_13(31 DOWNTO 0);

  add_temp_14 <= resize(sumdelay_pipeline1_re(12), 33) + resize(sumdelay_pipeline1_re(13), 33);
  sumvector2_re(6) <= add_temp_14(31 DOWNTO 0);

  add_temp_15 <= resize(sumdelay_pipeline1_im(12), 33) + resize(sumdelay_pipeline1_im(13), 33);
  sumvector2_im(6) <= add_temp_15(31 DOWNTO 0);

  sumvector2_re(7) <= sumdelay_pipeline1_re(14);
  sumvector2_im(7) <= sumdelay_pipeline1_im(14);

  sumdelay_pipeline_process2 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
          sumdelay_pipeline2_re <= (OTHERS => (OTHERS => '0'));
          sumdelay_pipeline2_im <= (OTHERS => (OTHERS => '0'));
      ELSIF phase_0 = '1' THEN
        sumdelay_pipeline2_re(0 TO 7) <= sumvector2_re(0 TO 7);
        sumdelay_pipeline2_im(0 TO 7) <= sumvector2_im(0 TO 7);
      END IF;
    END IF; 
  END PROCESS sumdelay_pipeline_process2;

  add_temp_16 <= resize(sumdelay_pipeline2_re(0), 33) + resize(sumdelay_pipeline2_re(1), 33);
  sumvector3_re(0) <= add_temp_16(31 DOWNTO 0);

  add_temp_17 <= resize(sumdelay_pipeline2_im(0), 33) + resize(sumdelay_pipeline2_im(1), 33);
  sumvector3_im(0) <= add_temp_17(31 DOWNTO 0);

  add_temp_18 <= resize(sumdelay_pipeline2_re(2), 33) + resize(sumdelay_pipeline2_re(3), 33);
  sumvector3_re(1) <= add_temp_18(31 DOWNTO 0);

  add_temp_19 <= resize(sumdelay_pipeline2_im(2), 33) + resize(sumdelay_pipeline2_im(3), 33);
  sumvector3_im(1) <= add_temp_19(31 DOWNTO 0);

  add_temp_20 <= resize(sumdelay_pipeline2_re(4), 33) + resize(sumdelay_pipeline2_re(5), 33);
  sumvector3_re(2) <= add_temp_20(31 DOWNTO 0);

  add_temp_21 <= resize(sumdelay_pipeline2_im(4), 33) + resize(sumdelay_pipeline2_im(5), 33);
  sumvector3_im(2) <= add_temp_21(31 DOWNTO 0);

  add_temp_22 <= resize(sumdelay_pipeline2_re(6), 33) + resize(sumdelay_pipeline2_re(7), 33);
  sumvector3_re(3) <= add_temp_22(31 DOWNTO 0);

  add_temp_23 <= resize(sumdelay_pipeline2_im(6), 33) + resize(sumdelay_pipeline2_im(7), 33);
  sumvector3_im(3) <= add_temp_23(31 DOWNTO 0);

  sumdelay_pipeline_process3 : PROCESS (clk, reset)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
          sumdelay_pipeline3_re <= (OTHERS => (OTHERS => '0'));
          sumdelay_pipeline3_im <= (OTHERS => (OTHERS => '0'));
      ELSIF phase_0 = '1' THEN
        sumdelay_pipeline3_re(0 TO 3) <= sumvector3_re(0 TO 3);
        sumdelay_pipeline3_im(0 TO 3) <= sumvector3_im(0 TO 3);
      END IF;
    END IF; 
  END PROCESS sumdelay_pipeline_process3;

  add_temp_24 <= resize(sumdelay_pipeline3_re(0), 33) + resize(sumdelay_pipeline3_re(1), 33);
  sumvector4_re(0) <= add_temp_24(31 DOWNTO 0);

  add_temp_25 <= resize(sumdelay_pipeline3_im(0), 33) + resize(sumdelay_pipeline3_im(1), 33);
  sumvector4_im(0) <= add_temp_25(31 DOWNTO 0);

  add_temp_26 <= resize(sumdelay_pipeline3_re(2), 33) + resize(sumdelay_pipeline3_re(3), 33);
  sumvector4_re(1) <= add_temp_26(31 DOWNTO 0);

  add_temp_27 <= resize(sumdelay_pipeline3_im(2), 33) + resize(sumdelay_pipeline3_im(3), 33);
  sumvector4_im(1) <= add_temp_27(31 DOWNTO 0);

  sumdelay_pipeline_process4 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
          sumdelay_pipeline4_re <= (OTHERS => (OTHERS => '0'));
          sumdelay_pipeline4_im <= (OTHERS => (OTHERS => '0'));
      ELSIF phase_0 = '1' THEN
        sumdelay_pipeline4_re(0 TO 1) <= sumvector4_re(0 TO 1);
        sumdelay_pipeline4_im(0 TO 1) <= sumvector4_im(0 TO 1);
      END IF;
    END IF; 
  END PROCESS sumdelay_pipeline_process4;

  add_temp_28 <= resize(sumdelay_pipeline4_re(0), 33) + resize(sumdelay_pipeline4_re(1), 33);
  sum5_re <= add_temp_28(31 DOWNTO 0);

  add_temp_29 <= resize(sumdelay_pipeline4_im(0), 33) + resize(sumdelay_pipeline4_im(1), 33);
  sum5_im <= add_temp_29(31 DOWNTO 0);

  output_typeconvert_re <= resize(shift_right(sum5_re(30 DOWNTO 0) + ( "0" & (sum5_re(15) & NOT sum5_re(15) & NOT sum5_re(15) & NOT sum5_re(15) & NOT sum5_re(15) & NOT sum5_re(15) & NOT sum5_re(15) & NOT sum5_re(15) & NOT sum5_re(15) & NOT sum5_re(15) & NOT sum5_re(15) & NOT sum5_re(15) & NOT sum5_re(15) & NOT sum5_re(15) & NOT sum5_re(15))), 15), 16);
  output_typeconvert_im <= resize(shift_right(sum5_im(30 DOWNTO 0) + ( "0" & (sum5_im(15) & NOT sum5_im(15) & NOT sum5_im(15) & NOT sum5_im(15) & NOT sum5_im(15) & NOT sum5_im(15) & NOT sum5_im(15) & NOT sum5_im(15) & NOT sum5_im(15) & NOT sum5_im(15) & NOT sum5_im(15) & NOT sum5_im(15) & NOT sum5_im(15) & NOT sum5_im(15) & NOT sum5_im(15))), 15), 16);

  ce_delay : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
          ce_delayline1 <= '0';
          ce_delayline2 <= '0';
          ce_delayline3 <= '0';
          ce_delayline4 <= '0';
          ce_delayline5 <= '0';
          ce_delayline6 <= '0';
          ce_delayline7 <= '0';
          ce_delayline8 <= '0';
          ce_delayline9 <= '0';
          ce_delayline10 <= '0';
          ce_delayline11 <= '0';
          ce_delayline12 <= '0';
          ce_delayline13 <= '0';
          ce_delayline14 <= '0';
          ce_delayline15 <= '0';
          ce_delayline16 <= '0';
          ce_delayline17 <= '0';
          ce_delayline18 <= '0';
          ce_delayline19 <= '0';
      ELSIF clk_enable_stage5 = '1' THEN
        ce_delayline1 <= clk_enable_stage5;
        ce_delayline2 <= ce_delayline1;
        ce_delayline3 <= ce_delayline2;
        ce_delayline4 <= ce_delayline3;
        ce_delayline5 <= ce_delayline4;
        ce_delayline6 <= ce_delayline5;
        ce_delayline7 <= ce_delayline6;
        ce_delayline8 <= ce_delayline7;
        ce_delayline9 <= ce_delayline8;
        ce_delayline10 <= ce_delayline9;
        ce_delayline11 <= ce_delayline10;
        ce_delayline12 <= ce_delayline11;
        ce_delayline13 <= ce_delayline12;
        ce_delayline14 <= ce_delayline13;
        ce_delayline15 <= ce_delayline14;
        ce_delayline16 <= ce_delayline15;
        ce_delayline17 <= ce_delayline16;
        ce_delayline18 <= ce_delayline17;
        ce_delayline19 <= ce_delayline18;
      END IF;
    END IF; 
  END PROCESS ce_delay;

  ce_gated <=  ce_delayline19 AND ce_out_reg;

  output_register_process : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
          output_register_re <= (OTHERS => '0');
          output_register_im <= (OTHERS => '0');
      ELSIF phase_0 = '1' THEN
        output_register_re <= output_typeconvert_re;
        output_register_im <= output_typeconvert_im;
      END IF;
    END IF; 
  END PROCESS output_register_process;

  -- Assignment Statements
  ce_out_stage5 <= ce_gated;
  filter_out_stage5_re <= std_logic_vector(output_register_re);
  filter_out_stage5_im <= std_logic_vector(output_register_im);
END rtl;
