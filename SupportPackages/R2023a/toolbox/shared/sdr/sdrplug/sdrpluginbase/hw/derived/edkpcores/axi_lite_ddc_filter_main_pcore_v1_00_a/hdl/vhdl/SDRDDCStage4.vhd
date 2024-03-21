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
-- Transition Width   : 0.4
-- Stopband Atten.    : 90 dB
-- -------------------------------------------------------------

-- -------------------------------------------------------------
-- HDL Implementation    : Fully parallel
-- Multipliers           : 7
-- Folding Factor        : 1
-- -------------------------------------------------------------
-- Filter Settings:
--
-- Discrete-Time FIR Multirate Filter (real)
-- -----------------------------------------
-- Filter Structure   : Direct-Form FIR Polyphase Decimator
-- Decimation Factor  : 2
-- Polyphase Length   : 14
-- Filter Length      : 27
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
ENTITY SDRDDCStage4 IS
   PORT( clk                             :   IN    std_logic; 
         clk_enable_stage4               :   IN    std_logic; 
         reset                           :   IN    std_logic; 
         filter_in_stage4_re             :   IN    std_logic_vector(15 DOWNTO 0); -- sfix16
         filter_in_stage4_im             :   IN    std_logic_vector(15 DOWNTO 0); -- sfix16
         filter_out_stage4_re            :   OUT   std_logic_vector(15 DOWNTO 0); -- sfix16
         filter_out_stage4_im            :   OUT   std_logic_vector(15 DOWNTO 0); -- sfix16
         ce_out_stage4                   :   OUT   std_logic  
         );

END SDRDDCStage4;


----------------------------------------------------------------
--Module Architecture: SDRDDCStage4
----------------------------------------------------------------
ARCHITECTURE rtl OF SDRDDCStage4 IS
  -- Local Functions
  -- Type Definitions
  TYPE input_pipeline_type IS ARRAY (NATURAL range <>) OF signed(15 DOWNTO 0); -- sfix16
  TYPE vector_of_signed16               IS ARRAY (NATURAL RANGE <>) OF signed(15 DOWNTO 0);
  TYPE vector_of_signed31               IS ARRAY (NATURAL RANGE <>) OF signed(30 DOWNTO 0);
  TYPE sumdelay_pipeline_type IS ARRAY (NATURAL range <>) OF signed(31 DOWNTO 0); -- sfix32_En15
  -- Constants
  CONSTANT coeffphase1_1                  : signed(15 DOWNTO 0) := to_signed(9, 16); -- sfix16_En15
  CONSTANT coeffphase1_2                  : signed(15 DOWNTO 0) := to_signed(-55, 16); -- sfix16_En15
  CONSTANT coeffphase1_3                  : signed(15 DOWNTO 0) := to_signed(195, 16); -- sfix16_En15
  CONSTANT coeffphase1_4                  : signed(15 DOWNTO 0) := to_signed(-532, 16); -- sfix16_En15
  CONSTANT coeffphase1_5                  : signed(15 DOWNTO 0) := to_signed(1252, 16); -- sfix16_En15
  CONSTANT coeffphase1_6                  : signed(15 DOWNTO 0) := to_signed(-2903, 16); -- sfix16_En15
  CONSTANT coeffphase1_7                  : signed(15 DOWNTO 0) := to_signed(10225, 16); -- sfix16_En15
  CONSTANT coeffphase1_8                  : signed(15 DOWNTO 0) := to_signed(10225, 16); -- sfix16_En15
  CONSTANT coeffphase1_9                  : signed(15 DOWNTO 0) := to_signed(-2903, 16); -- sfix16_En15
  CONSTANT coeffphase1_10                 : signed(15 DOWNTO 0) := to_signed(1252, 16); -- sfix16_En15
  CONSTANT coeffphase1_11                 : signed(15 DOWNTO 0) := to_signed(-532, 16); -- sfix16_En15
  CONSTANT coeffphase1_12                 : signed(15 DOWNTO 0) := to_signed(195, 16); -- sfix16_En15
  CONSTANT coeffphase1_13                 : signed(15 DOWNTO 0) := to_signed(-55, 16); -- sfix16_En15
  CONSTANT coeffphase1_14                 : signed(15 DOWNTO 0) := to_signed(9, 16); -- sfix16_En15
  CONSTANT coeffphase2_1                  : signed(15 DOWNTO 0) := to_signed(0, 16); -- sfix16_En15
  CONSTANT coeffphase2_2                  : signed(15 DOWNTO 0) := to_signed(0, 16); -- sfix16_En15
  CONSTANT coeffphase2_3                  : signed(15 DOWNTO 0) := to_signed(0, 16); -- sfix16_En15
  CONSTANT coeffphase2_4                  : signed(15 DOWNTO 0) := to_signed(0, 16); -- sfix16_En15
  CONSTANT coeffphase2_5                  : signed(15 DOWNTO 0) := to_signed(0, 16); -- sfix16_En15
  CONSTANT coeffphase2_6                  : signed(15 DOWNTO 0) := to_signed(0, 16); -- sfix16_En15
  CONSTANT coeffphase2_7                  : signed(15 DOWNTO 0) := to_signed(16384, 16); -- sfix16_En15
  CONSTANT coeffphase2_8                  : signed(15 DOWNTO 0) := to_signed(0, 16); -- sfix16_En15
  CONSTANT coeffphase2_9                  : signed(15 DOWNTO 0) := to_signed(0, 16); -- sfix16_En15
  CONSTANT coeffphase2_10                 : signed(15 DOWNTO 0) := to_signed(0, 16); -- sfix16_En15
  CONSTANT coeffphase2_11                 : signed(15 DOWNTO 0) := to_signed(0, 16); -- sfix16_En15
  CONSTANT coeffphase2_12                 : signed(15 DOWNTO 0) := to_signed(0, 16); -- sfix16_En15
  CONSTANT coeffphase2_13                 : signed(15 DOWNTO 0) := to_signed(0, 16); -- sfix16_En15
  CONSTANT coeffphase2_14                 : signed(15 DOWNTO 0) := to_signed(0, 16); -- sfix16_En15

  -- Signals
  SIGNAL ring_count                       : unsigned(1 DOWNTO 0); -- ufix2
  SIGNAL phase_0                          : std_logic; -- boolean
  SIGNAL phase_1                          : std_logic; -- boolean
  SIGNAL ce_out_reg                       : std_logic; -- boolean
  SIGNAL input_typeconvert_re             : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_typeconvert_im             : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase0_re         : input_pipeline_type(0 TO 12); -- sfix16
  SIGNAL input_pipeline_phase0_im         : input_pipeline_type(0 TO 12); -- sfix16
  SIGNAL input_pipeline_phase1_re         : input_pipeline_type(0 TO 6); -- sfix16
  SIGNAL input_pipeline_phase1_im         : input_pipeline_type(0 TO 6); -- sfix16
  SIGNAL product_phase0_1_re              : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_phase0_1_im              : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL input_typeconvert_re_pipe_re     : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_typeconvert_re_pipe_im     : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_typeconvert_re_pipe_1_re   : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_typeconvert_re_pipe_1_im   : signed(15 DOWNTO 0); -- sfix16
  SIGNAL coeffphase1_1_pipe               : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL coeffphase1_1_pipe_1             : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL product_phase0_1_re_pipe_re      : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_1_re_pipe_im      : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_1_re_pipe_1_re    : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product_phase0_1_re_pipe_1_im    : signed(31 DOWNTO 0); -- sfix32_En15
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
  SIGNAL product_phase1_7_re              : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_phase1_7_im              : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL input_pipeline_phase1_re_6_pipe_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_pipeline_phase1_re_6_pipe_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL int_delay_pipe_re                : vector_of_signed16(0 TO 1); -- sfix16
  SIGNAL int_delay_pipe_im                : vector_of_signed16(0 TO 1); -- sfix16
  SIGNAL product_phase1_7_re_pipe_re      : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_phase1_7_re_pipe_im      : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL int_delay_pipe_1_re              : vector_of_signed31(0 TO 1); -- sfix31_En15
  SIGNAL int_delay_pipe_1_im              : vector_of_signed31(0 TO 1); -- sfix31_En15
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
  SIGNAL product_pipeline_phase1_7_re     : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL product_pipeline_phase1_7_im     : signed(30 DOWNTO 0); -- sfix31_En15
  SIGNAL quantized_sum_re                 : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL quantized_sum_im                 : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL sumvector1_re                    : sumdelay_pipeline_type(0 TO 7); -- sfix32_En15
  SIGNAL sumvector1_im                    : sumdelay_pipeline_type(0 TO 7); -- sfix32_En15
  SIGNAL add_temp                         : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL add_temp_1                       : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL sumdelay_pipeline1_re            : sumdelay_pipeline_type(0 TO 7); -- sfix32_En15
  SIGNAL sumdelay_pipeline1_im            : sumdelay_pipeline_type(0 TO 7); -- sfix32_En15
  SIGNAL sumvector2_re                    : sumdelay_pipeline_type(0 TO 3); -- sfix32_En15
  SIGNAL sumvector2_im                    : sumdelay_pipeline_type(0 TO 3); -- sfix32_En15
  SIGNAL add_temp_2                       : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL add_temp_3                       : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL add_temp_4                       : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL add_temp_5                       : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL add_temp_6                       : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL add_temp_7                       : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL add_temp_8                       : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL add_temp_9                       : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL sumdelay_pipeline2_re            : sumdelay_pipeline_type(0 TO 3); -- sfix32_En15
  SIGNAL sumdelay_pipeline2_im            : sumdelay_pipeline_type(0 TO 3); -- sfix32_En15
  SIGNAL sumvector3_re                    : sumdelay_pipeline_type(0 TO 1); -- sfix32_En15
  SIGNAL sumvector3_im                    : sumdelay_pipeline_type(0 TO 1); -- sfix32_En15
  SIGNAL add_temp_10                      : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL add_temp_11                      : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL add_temp_12                      : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL add_temp_13                      : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL sumdelay_pipeline3_re            : sumdelay_pipeline_type(0 TO 1); -- sfix32_En15
  SIGNAL sumdelay_pipeline3_im            : sumdelay_pipeline_type(0 TO 1); -- sfix32_En15
  SIGNAL sum4_re                          : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL sum4_im                          : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL add_temp_14                      : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL add_temp_15                      : signed(32 DOWNTO 0); -- sfix33_En15
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
      ELSIF clk_enable_stage4 = '1' THEN
        ring_count <= ring_count(0) & ring_count(1);
      END IF;
    END IF; 
  END PROCESS ce_output;

  phase_0 <= ring_count(0)  AND clk_enable_stage4;

  phase_1 <= ring_count(1)  AND clk_enable_stage4;

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

  input_typeconvert_re <= signed(filter_in_stage4_re);
  input_typeconvert_im <= signed(filter_in_stage4_im);

  Delay_Pipeline_Phase0_process : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
        input_pipeline_phase0_re(0 TO 12) <= (OTHERS => (OTHERS => '0'));
        input_pipeline_phase0_im(0 TO 12) <= (OTHERS => (OTHERS => '0'));
      ELSIF phase_0 = '1' THEN
        input_pipeline_phase0_re(0) <= input_typeconvert_re;
        input_pipeline_phase0_re(1 TO 12) <= input_pipeline_phase0_re(0 TO 11);
        input_pipeline_phase0_im(0) <= input_typeconvert_im;
        input_pipeline_phase0_im(1 TO 12) <= input_pipeline_phase0_im(0 TO 11);
      END IF;
    END IF; 
  END PROCESS Delay_Pipeline_Phase0_process;


  Delay_Pipeline_Phase1_process : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
        input_pipeline_phase1_re(0 TO 6) <= (OTHERS => (OTHERS => '0'));
        input_pipeline_phase1_im(0 TO 6) <= (OTHERS => (OTHERS => '0'));
      ELSIF phase_1 = '1' THEN
        input_pipeline_phase1_re(0) <= input_typeconvert_re;
        input_pipeline_phase1_re(1 TO 6) <= input_pipeline_phase1_re(0 TO 5);
        input_pipeline_phase1_im(0) <= input_typeconvert_im;
        input_pipeline_phase1_im(1 TO 6) <= input_pipeline_phase1_im(0 TO 5);
      END IF;
    END IF; 
  END PROCESS Delay_Pipeline_Phase1_process;


  temp_process1 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
        input_typeconvert_re_pipe_re <= (OTHERS => '0');
        input_typeconvert_re_pipe_im <= (OTHERS => '0');
        input_typeconvert_re_pipe_1_re <= (OTHERS => '0');
        input_typeconvert_re_pipe_1_im <= (OTHERS => '0');
        coeffphase1_1_pipe <= (OTHERS => '0');
        coeffphase1_1_pipe_1 <= (OTHERS => '0');
        product_phase0_1_re_pipe_re <= (OTHERS => '0');
        product_phase0_1_re_pipe_im <= (OTHERS => '0');
        product_phase0_1_re_pipe_1_re <= (OTHERS => '0');
        product_phase0_1_re_pipe_1_im <= (OTHERS => '0');
      ELSIF phase_0 = '1' THEN
        input_typeconvert_re_pipe_re <= input_typeconvert_re;
        input_typeconvert_re_pipe_im <= input_typeconvert_im;
        input_typeconvert_re_pipe_1_re <= input_typeconvert_re_pipe_re;
        input_typeconvert_re_pipe_1_im <= input_typeconvert_re_pipe_im;
        coeffphase1_1_pipe <= coeffphase1_1;
        coeffphase1_1_pipe_1 <= coeffphase1_1_pipe;

        product_phase0_1_re_pipe_re <= input_typeconvert_re_pipe_1_re * coeffphase1_1_pipe_1;
        product_phase0_1_re_pipe_im <= input_typeconvert_re_pipe_1_im * coeffphase1_1_pipe_1;

        product_phase0_1_re_pipe_1_re <= product_phase0_1_re_pipe_re;
        product_phase0_1_re_pipe_1_im <= product_phase0_1_re_pipe_im;
      END IF;
    END IF;
  END PROCESS temp_process1;

  product_phase0_1_re <= product_phase0_1_re_pipe_1_re(30 DOWNTO 0);
  product_phase0_1_im <= product_phase0_1_re_pipe_1_im(30 DOWNTO 0);

  temp_process2 : PROCESS (clk)
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
  END PROCESS temp_process2;

  product_phase0_2_re <= product_phase0_2_re_pipe_1_re(30 DOWNTO 0);
  product_phase0_2_im <= product_phase0_2_re_pipe_1_im(30 DOWNTO 0);

  temp_process3 : PROCESS (clk)
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
  END PROCESS temp_process3;

  product_phase0_3_re <= product_phase0_3_re_pipe_1_re(30 DOWNTO 0);
  product_phase0_3_im <= product_phase0_3_re_pipe_1_im(30 DOWNTO 0);

  temp_process4 : PROCESS (clk)
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
  END PROCESS temp_process4;

  product_phase0_4_re <= product_phase0_4_re_pipe_1_re(30 DOWNTO 0);
  product_phase0_4_im <= product_phase0_4_re_pipe_1_im(30 DOWNTO 0);

  temp_process5 : PROCESS (clk)
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
  END PROCESS temp_process5;

  product_phase0_5_re <= product_phase0_5_re_pipe_1_re(30 DOWNTO 0);
  product_phase0_5_im <= product_phase0_5_re_pipe_1_im(30 DOWNTO 0);

  temp_process6 : PROCESS (clk)
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
  END PROCESS temp_process6;

  product_phase0_6_re <= product_phase0_6_re_pipe_1_re(30 DOWNTO 0);
  product_phase0_6_im <= product_phase0_6_re_pipe_1_im(30 DOWNTO 0);

  temp_process7 : PROCESS (clk)
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
  END PROCESS temp_process7;

  product_phase0_7_re <= product_phase0_7_re_pipe_1_re(30 DOWNTO 0);
  product_phase0_7_im <= product_phase0_7_re_pipe_1_im(30 DOWNTO 0);

  temp_process8 : PROCESS (clk)
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
  END PROCESS temp_process8;

  product_phase0_8_re <= product_phase0_8_re_pipe_1_re(30 DOWNTO 0);
  product_phase0_8_im <= product_phase0_8_re_pipe_1_im(30 DOWNTO 0);

  temp_process9 : PROCESS (clk)
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
  END PROCESS temp_process9;

  product_phase0_9_re <= product_phase0_9_re_pipe_1_re(30 DOWNTO 0);
  product_phase0_9_im <= product_phase0_9_re_pipe_1_im(30 DOWNTO 0);

  temp_process10 : PROCESS (clk)
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
  END PROCESS temp_process10;

  product_phase0_10_re <= product_phase0_10_re_pipe_1_re(30 DOWNTO 0);
  product_phase0_10_im <= product_phase0_10_re_pipe_1_im(30 DOWNTO 0);

  temp_process11 : PROCESS (clk)
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
  END PROCESS temp_process11;

  product_phase0_11_re <= product_phase0_11_re_pipe_1_re(30 DOWNTO 0);
  product_phase0_11_im <= product_phase0_11_re_pipe_1_im(30 DOWNTO 0);

  temp_process12 : PROCESS (clk)
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
  END PROCESS temp_process12;

  product_phase0_12_re <= product_phase0_12_re_pipe_1_re(30 DOWNTO 0);
  product_phase0_12_im <= product_phase0_12_re_pipe_1_im(30 DOWNTO 0);

  temp_process13 : PROCESS (clk)
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
  END PROCESS temp_process13;

  product_phase0_13_re <= product_phase0_13_re_pipe_1_re(30 DOWNTO 0);
  product_phase0_13_im <= product_phase0_13_re_pipe_1_im(30 DOWNTO 0);

  temp_process14 : PROCESS (clk)
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
  END PROCESS temp_process14;

  product_phase0_14_re <= product_phase0_14_re_pipe_1_re(30 DOWNTO 0);
  product_phase0_14_im <= product_phase0_14_re_pipe_1_im(30 DOWNTO 0);

  temp_process15 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
        int_delay_pipe_re <= (OTHERS => (OTHERS => '0'));
        int_delay_pipe_im <= (OTHERS => (OTHERS => '0'));
      ELSIF phase_0 = '1' THEN
        int_delay_pipe_re(1) <= int_delay_pipe_re(0);
        int_delay_pipe_im(1) <= int_delay_pipe_im(0);
        int_delay_pipe_re(0) <= input_pipeline_phase1_re(6);
        int_delay_pipe_im(0) <= input_pipeline_phase1_im(6);
      END IF;
    END IF;
  END PROCESS temp_process15;
  input_pipeline_phase1_re_6_pipe_re <= int_delay_pipe_re(1);
  input_pipeline_phase1_re_6_pipe_im <= int_delay_pipe_im(1);

  temp_process16 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
        int_delay_pipe_1_re <= (OTHERS => (OTHERS => '0'));
        int_delay_pipe_1_im <= (OTHERS => (OTHERS => '0'));
      ELSIF phase_0 = '1' THEN
        int_delay_pipe_1_re(1) <= int_delay_pipe_1_re(0);
        int_delay_pipe_1_im(1) <= int_delay_pipe_1_im(0);
        int_delay_pipe_1_re(0) <= product_phase1_7_re_pipe_re;
        int_delay_pipe_1_im(0) <= product_phase1_7_re_pipe_im;
      END IF;
    END IF;
  END PROCESS temp_process16;
  product_phase1_7_re <= int_delay_pipe_1_re(1);
  product_phase1_7_im <= int_delay_pipe_1_im(1);

  product_phase1_7_re_pipe_re <= resize(input_pipeline_phase1_re_6_pipe_re(15 DOWNTO 0) & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 31);

  product_phase1_7_re_pipe_im <= resize(input_pipeline_phase1_re_6_pipe_im(15 DOWNTO 0) & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 31);

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
          product_pipeline_phase1_7_re <= (OTHERS => '0');
          product_pipeline_phase1_7_im <= (OTHERS => '0');
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
        product_pipeline_phase1_7_re <= product_phase1_7_re;
        product_pipeline_phase1_7_im <= product_phase1_7_im;
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
      END IF;
    END IF; 
  END PROCESS product_pipeline_process1;

  quantized_sum_re <= resize(product_pipeline_phase1_7_re, 32);
  quantized_sum_im <= resize(product_pipeline_phase1_7_im, 32);

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

  sumvector1_re(7) <= resize(product_pipeline_phase0_14_re, 32);
  sumvector1_im(7) <= resize(product_pipeline_phase0_14_im, 32);

  sumdelay_pipeline_process1 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
        sumdelay_pipeline1_re <= (OTHERS => (OTHERS => '0'));
        sumdelay_pipeline1_im <= (OTHERS => (OTHERS => '0'));
      ELSIF phase_0 = '1' THEN
        sumdelay_pipeline1_re(0 TO 7) <= sumvector1_re(0 TO 7);
        sumdelay_pipeline1_im(0 TO 7) <= sumvector1_im(0 TO 7);
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

  sumdelay_pipeline_process2 : PROCESS (clk, reset)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
        sumdelay_pipeline2_re <= (OTHERS => (OTHERS => '0'));
        sumdelay_pipeline2_im <= (OTHERS => (OTHERS => '0'));
      ELSIF phase_0 = '1' THEN
        sumdelay_pipeline2_re(0 TO 3) <= sumvector2_re(0 TO 3);
        sumdelay_pipeline2_im(0 TO 3) <= sumvector2_im(0 TO 3);
      END IF;
    END IF; 
  END PROCESS sumdelay_pipeline_process2;

  add_temp_10 <= resize(sumdelay_pipeline2_re(0), 33) + resize(sumdelay_pipeline2_re(1), 33);
  sumvector3_re(0) <= add_temp_10(31 DOWNTO 0);

  add_temp_11 <= resize(sumdelay_pipeline2_im(0), 33) + resize(sumdelay_pipeline2_im(1), 33);
  sumvector3_im(0) <= add_temp_11(31 DOWNTO 0);

  add_temp_12 <= resize(sumdelay_pipeline2_re(2), 33) + resize(sumdelay_pipeline2_re(3), 33);
  sumvector3_re(1) <= add_temp_12(31 DOWNTO 0);

  add_temp_13 <= resize(sumdelay_pipeline2_im(2), 33) + resize(sumdelay_pipeline2_im(3), 33);
  sumvector3_im(1) <= add_temp_13(31 DOWNTO 0);

  sumdelay_pipeline_process3 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
        sumdelay_pipeline3_re <= (OTHERS => (OTHERS => '0'));
        sumdelay_pipeline3_im <= (OTHERS => (OTHERS => '0'));
      ELSIF phase_0 = '1' THEN
        sumdelay_pipeline3_re(0 TO 1) <= sumvector3_re(0 TO 1);
        sumdelay_pipeline3_im(0 TO 1) <= sumvector3_im(0 TO 1);
      END IF;
    END IF; 
  END PROCESS sumdelay_pipeline_process3;

  add_temp_14 <= resize(sumdelay_pipeline3_re(0), 33) + resize(sumdelay_pipeline3_re(1), 33);
  sum4_re <= add_temp_14(31 DOWNTO 0);

  add_temp_15 <= resize(sumdelay_pipeline3_im(0), 33) + resize(sumdelay_pipeline3_im(1), 33);
  sum4_im <= add_temp_15(31 DOWNTO 0);

  output_typeconvert_re <= resize(shift_right(sum4_re(30 DOWNTO 0) + ( "0" & (sum4_re(15) & NOT sum4_re(15) & NOT sum4_re(15) & NOT sum4_re(15) & NOT sum4_re(15) & NOT sum4_re(15) & NOT sum4_re(15) & NOT sum4_re(15) & NOT sum4_re(15) & NOT sum4_re(15) & NOT sum4_re(15) & NOT sum4_re(15) & NOT sum4_re(15) & NOT sum4_re(15) & NOT sum4_re(15))), 15), 16);
  output_typeconvert_im <= resize(shift_right(sum4_im(30 DOWNTO 0) + ( "0" & (sum4_im(15) & NOT sum4_im(15) & NOT sum4_im(15) & NOT sum4_im(15) & NOT sum4_im(15) & NOT sum4_im(15) & NOT sum4_im(15) & NOT sum4_im(15) & NOT sum4_im(15) & NOT sum4_im(15) & NOT sum4_im(15) & NOT sum4_im(15) & NOT sum4_im(15) & NOT sum4_im(15) & NOT sum4_im(15))), 15), 16);

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
      ELSIF clk_enable_stage4 = '1' THEN
        ce_delayline1 <= clk_enable_stage4;
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
      END IF;
    END IF; 
  END PROCESS ce_delay;

  ce_gated <=  ce_delayline17 AND ce_out_reg;

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
  ce_out_stage4 <= ce_gated;
  filter_out_stage4_re <= std_logic_vector(output_register_re);
  filter_out_stage4_im <= std_logic_vector(output_register_im);
END rtl;
