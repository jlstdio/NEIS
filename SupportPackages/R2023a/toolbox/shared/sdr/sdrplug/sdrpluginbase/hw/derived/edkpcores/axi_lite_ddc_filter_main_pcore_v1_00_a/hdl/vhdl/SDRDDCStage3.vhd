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
-- Sampling Frequency     : N/A (normalized frequency)
-- Response               : CIC Compensator
-- Specification          : Fp,Fst,Ap,Ast
-- Number of Sections     : 5
-- Differential Delay     : 1
-- CIC Rate Change Factor : 4
-- Passband Edge          : 0.35
-- Stopband Edge          : 0.75
-- Passband Ripple        : 1 dB
-- Stopband Atten.        : 70 dB
-- -------------------------------------------------------------

-- -------------------------------------------------------------
-- HDL Implementation    : Fully parallel
-- Multipliers           : 7
-- Folding Factor        : 1
-- -------------------------------------------------------------
-- Filter Settings:
--
-- Discrete-Time FIR Filter (real)
-- -------------------------------
-- Filter Structure  : Direct-Form Symmetric FIR
-- Filter Length     : 13
-- Stable            : Yes
-- Linear Phase      : Yes (Type 1)
-- Arithmetic        : fixed
-- Numerator         : s16,15 -> [-1 1)
-- Input             : s16,0 -> [-32768 32768)
-- Filter Internals  : Specify Precision
--   Output          : s16,0 -> [-32768 32768)
--   Tap Sum         : s17,0 -> [-65536 65536)
--   Product         : s32,15 -> [-65536 65536)
--   Accumulator     : s32,15 -> [-65536 65536)
--   Round Mode      : convergent
--   Overflow Mode   : wrap
-- -------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;
ENTITY SDRDDCStage3 IS
   PORT( clk                             :   IN    std_logic; 
         clk_enable_stage3               :   IN    std_logic; 
         reset                           :   IN    std_logic; 
         filter_in_stage3_re             :   IN    std_logic_vector(15 DOWNTO 0); -- sfix16
         filter_in_stage3_im             :   IN    std_logic_vector(15 DOWNTO 0); -- sfix16
         filter_out_stage3_re            :   OUT   std_logic_vector(15 DOWNTO 0); -- sfix16
         filter_out_stage3_im            :   OUT   std_logic_vector(15 DOWNTO 0)  -- sfix16
         );

END SDRDDCStage3;


----------------------------------------------------------------
--Module Architecture: SDRDDCStage3
----------------------------------------------------------------
ARCHITECTURE rtl OF SDRDDCStage3 IS
  -- Local Functions
  -- Type Definitions
  TYPE delay_pipeline_type IS ARRAY (NATURAL range <>) OF signed(15 DOWNTO 0); -- sfix16
  -- Constants
  CONSTANT coeff1                         : signed(15 DOWNTO 0) := to_signed(492, 16); -- sfix16_En15
  CONSTANT coeff2                         : signed(15 DOWNTO 0) := to_signed(1345, 16); -- sfix16_En15
  CONSTANT coeff3                         : signed(15 DOWNTO 0) := to_signed(-127, 16); -- sfix16_En15
  CONSTANT coeff4                         : signed(15 DOWNTO 0) := to_signed(-3749, 16); -- sfix16_En15
  CONSTANT coeff5                         : signed(15 DOWNTO 0) := to_signed(-1141, 16); -- sfix16_En15
  CONSTANT coeff6                         : signed(15 DOWNTO 0) := to_signed(10940, 16); -- sfix16_En15
  CONSTANT coeff7                         : signed(15 DOWNTO 0) := to_signed(18625, 16); -- sfix16_En15

  -- Signals
  SIGNAL delay_pipeline_re                : delay_pipeline_type(0 TO 11); -- sfix16
  SIGNAL delay_pipeline_im                : delay_pipeline_type(0 TO 11); -- sfix16
  SIGNAL filter_in_stage3_re_regtype_re   : signed(15 DOWNTO 0); -- sfix16
  SIGNAL filter_in_stage3_re_regtype_im   : signed(15 DOWNTO 0); -- sfix16
  SIGNAL tapsum1_re                       : signed(16 DOWNTO 0); -- sfix17
  SIGNAL tapsum1_im                       : signed(16 DOWNTO 0); -- sfix17
  SIGNAL tapsum_mcand_re                  : signed(16 DOWNTO 0); -- sfix17
  SIGNAL tapsum_mcand_im                  : signed(16 DOWNTO 0); -- sfix17
  SIGNAL tapsum2_re                       : signed(16 DOWNTO 0); -- sfix17
  SIGNAL tapsum2_im                       : signed(16 DOWNTO 0); -- sfix17
  SIGNAL tapsum_mcand_1_re                : signed(16 DOWNTO 0); -- sfix17
  SIGNAL tapsum_mcand_1_im                : signed(16 DOWNTO 0); -- sfix17
  SIGNAL tapsum3_re                       : signed(16 DOWNTO 0); -- sfix17
  SIGNAL tapsum3_im                       : signed(16 DOWNTO 0); -- sfix17
  SIGNAL tapsum_mcand_2_re                : signed(16 DOWNTO 0); -- sfix17
  SIGNAL tapsum_mcand_2_im                : signed(16 DOWNTO 0); -- sfix17
  SIGNAL tapsum4_re                       : signed(16 DOWNTO 0); -- sfix17
  SIGNAL tapsum4_im                       : signed(16 DOWNTO 0); -- sfix17
  SIGNAL tapsum_mcand_3_re                : signed(16 DOWNTO 0); -- sfix17
  SIGNAL tapsum_mcand_3_im                : signed(16 DOWNTO 0); -- sfix17
  SIGNAL tapsum5_re                       : signed(16 DOWNTO 0); -- sfix17
  SIGNAL tapsum5_im                       : signed(16 DOWNTO 0); -- sfix17
  SIGNAL tapsum_mcand_4_re                : signed(16 DOWNTO 0); -- sfix17
  SIGNAL tapsum_mcand_4_im                : signed(16 DOWNTO 0); -- sfix17
  SIGNAL tapsum6_re                       : signed(16 DOWNTO 0); -- sfix17
  SIGNAL tapsum6_im                       : signed(16 DOWNTO 0); -- sfix17
  SIGNAL tapsum_mcand_5_re                : signed(16 DOWNTO 0); -- sfix17
  SIGNAL tapsum_mcand_5_im                : signed(16 DOWNTO 0); -- sfix17
  SIGNAL product7_re                      : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product7_im                      : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL delay_pipeline_re_5_under_pipe_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL delay_pipeline_re_5_under_pipe_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL delay_pipeline_re_5_under_pipe_1_re : signed(15 DOWNTO 0); -- sfix16
  SIGNAL delay_pipeline_re_5_under_pipe_1_im : signed(15 DOWNTO 0); -- sfix16
  SIGNAL coeff7_pipe                      : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL coeff7_pipe_1                    : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL product7_re_pipe_re              : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product7_re_pipe_im              : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product7_re_pipe_1_re            : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product7_re_pipe_1_im            : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product6_re                      : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product6_im                      : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL tapsum_mcand_5_re_pipe_re        : signed(16 DOWNTO 0); -- sfix17
  SIGNAL tapsum_mcand_5_re_pipe_im        : signed(16 DOWNTO 0); -- sfix17
  SIGNAL tapsum_mcand_5_re_pipe_1_re      : signed(16 DOWNTO 0); -- sfix17
  SIGNAL tapsum_mcand_5_re_pipe_1_im      : signed(16 DOWNTO 0); -- sfix17
  SIGNAL coeff6_pipe                      : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL coeff6_pipe_1                    : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL product6_re_pipe_re              : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL product6_re_pipe_im              : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL product6_re_pipe_1_re            : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL product6_re_pipe_1_im            : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL product5_re                      : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product5_im                      : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL tapsum_mcand_4_re_pipe_re        : signed(16 DOWNTO 0); -- sfix17
  SIGNAL tapsum_mcand_4_re_pipe_im        : signed(16 DOWNTO 0); -- sfix17
  SIGNAL tapsum_mcand_4_re_pipe_1_re      : signed(16 DOWNTO 0); -- sfix17
  SIGNAL tapsum_mcand_4_re_pipe_1_im      : signed(16 DOWNTO 0); -- sfix17
  SIGNAL coeff5_pipe                      : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL coeff5_pipe_1                    : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL product5_re_pipe_re              : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL product5_re_pipe_im              : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL product5_re_pipe_1_re            : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL product5_re_pipe_1_im            : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL product4_re                      : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product4_im                      : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL tapsum_mcand_3_re_pipe_re        : signed(16 DOWNTO 0); -- sfix17
  SIGNAL tapsum_mcand_3_re_pipe_im        : signed(16 DOWNTO 0); -- sfix17
  SIGNAL tapsum_mcand_3_re_pipe_1_re      : signed(16 DOWNTO 0); -- sfix17
  SIGNAL tapsum_mcand_3_re_pipe_1_im      : signed(16 DOWNTO 0); -- sfix17
  SIGNAL coeff4_pipe                      : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL coeff4_pipe_1                    : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL product4_re_pipe_re              : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL product4_re_pipe_im              : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL product4_re_pipe_1_re            : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL product4_re_pipe_1_im            : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL product3_re                      : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product3_im                      : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL tapsum_mcand_2_re_pipe_re        : signed(16 DOWNTO 0); -- sfix17
  SIGNAL tapsum_mcand_2_re_pipe_im        : signed(16 DOWNTO 0); -- sfix17
  SIGNAL tapsum_mcand_2_re_pipe_1_re      : signed(16 DOWNTO 0); -- sfix17
  SIGNAL tapsum_mcand_2_re_pipe_1_im      : signed(16 DOWNTO 0); -- sfix17
  SIGNAL coeff3_pipe                      : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL coeff3_pipe_1                    : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL product3_re_pipe_re              : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL product3_re_pipe_im              : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL product3_re_pipe_1_re            : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL product3_re_pipe_1_im            : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL product2_re                      : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product2_im                      : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL tapsum_mcand_1_re_pipe_re        : signed(16 DOWNTO 0); -- sfix17
  SIGNAL tapsum_mcand_1_re_pipe_im        : signed(16 DOWNTO 0); -- sfix17
  SIGNAL tapsum_mcand_1_re_pipe_1_re      : signed(16 DOWNTO 0); -- sfix17
  SIGNAL tapsum_mcand_1_re_pipe_1_im      : signed(16 DOWNTO 0); -- sfix17
  SIGNAL coeff2_pipe                      : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL coeff2_pipe_1                    : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL product2_re_pipe_re              : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL product2_re_pipe_im              : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL product2_re_pipe_1_re            : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL product2_re_pipe_1_im            : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL product1_re                      : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL product1_im                      : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL tapsum_mcand_re_pipe_re          : signed(16 DOWNTO 0); -- sfix17
  SIGNAL tapsum_mcand_re_pipe_im          : signed(16 DOWNTO 0); -- sfix17
  SIGNAL tapsum_mcand_re_pipe_1_re        : signed(16 DOWNTO 0); -- sfix17
  SIGNAL tapsum_mcand_re_pipe_1_im        : signed(16 DOWNTO 0); -- sfix17
  SIGNAL coeff1_pipe                      : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL coeff1_pipe_1                    : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL product1_re_pipe_re              : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL product1_re_pipe_im              : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL product1_re_pipe_1_re            : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL product1_re_pipe_1_im            : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL sum_final_re                     : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL sum_final_im                     : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL sum1_1_re                        : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL sum1_1_im                        : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL add_temp                         : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL add_temp_1                       : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL sumpipe1_1_re                    : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL sumpipe1_1_im                    : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL sum1_2_re                        : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL sum1_2_im                        : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL add_temp_2                       : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL add_temp_3                       : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL sumpipe1_2_re                    : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL sumpipe1_2_im                    : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL sum1_3_re                        : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL sum1_3_im                        : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL add_temp_4                       : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL add_temp_5                       : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL sumpipe1_3_re                    : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL sumpipe1_3_im                    : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL sumpipe1_4_re                    : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL sumpipe1_4_im                    : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL sum2_1_re                        : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL sum2_1_im                        : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL add_temp_6                       : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL add_temp_7                       : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL sumpipe2_1_re                    : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL sumpipe2_1_im                    : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL sum2_2_re                        : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL sum2_2_im                        : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL add_temp_8                       : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL add_temp_9                       : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL sumpipe2_2_re                    : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL sumpipe2_2_im                    : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL sum3_1_re                        : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL sum3_1_im                        : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL add_temp_10                      : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL add_temp_11                      : signed(32 DOWNTO 0); -- sfix33_En15
  SIGNAL sumpipe3_1_re                    : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL sumpipe3_1_im                    : signed(31 DOWNTO 0); -- sfix32_En15
  SIGNAL output_typeconvert_re            : signed(15 DOWNTO 0); -- sfix16
  SIGNAL output_typeconvert_im            : signed(15 DOWNTO 0); -- sfix16
  SIGNAL output_register_re               : signed(15 DOWNTO 0); -- sfix16
  SIGNAL output_register_im               : signed(15 DOWNTO 0); -- sfix16


BEGIN

  -- Block Statements
  Delay_Pipeline_process : PROCESS (clk, reset)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
        delay_pipeline_re(0 TO 11) <= (OTHERS => (OTHERS => '0'));
        delay_pipeline_im(0 TO 11) <= (OTHERS => (OTHERS => '0'));
      ELSIF clk_enable_stage3 = '1' THEN
        delay_pipeline_re(0) <= signed(filter_in_stage3_re);
        delay_pipeline_re(1 TO 11) <= delay_pipeline_re(0 TO 10);
        delay_pipeline_im(0) <= signed(filter_in_stage3_im);
        delay_pipeline_im(1 TO 11) <= delay_pipeline_im(0 TO 10);
      END IF;
    END IF; 
  END PROCESS Delay_Pipeline_process;


  filter_in_stage3_re_regtype_re <= signed(filter_in_stage3_re);
  filter_in_stage3_re_regtype_im <= signed(filter_in_stage3_im);

  tapsum1_re <= resize(filter_in_stage3_re_regtype_re, 17) + resize(delay_pipeline_re(11), 17);

  tapsum1_im <= resize(filter_in_stage3_re_regtype_im, 17) + resize(delay_pipeline_im(11), 17);

  tapsum_mcand_re <= tapsum1_re;
  tapsum_mcand_im <= tapsum1_im;

  tapsum2_re <= resize(delay_pipeline_re(0), 17) + resize(delay_pipeline_re(10), 17);

  tapsum2_im <= resize(delay_pipeline_im(0), 17) + resize(delay_pipeline_im(10), 17);

  tapsum_mcand_1_re <= tapsum2_re;
  tapsum_mcand_1_im <= tapsum2_im;

  tapsum3_re <= resize(delay_pipeline_re(1), 17) + resize(delay_pipeline_re(9), 17);

  tapsum3_im <= resize(delay_pipeline_im(1), 17) + resize(delay_pipeline_im(9), 17);

  tapsum_mcand_2_re <= tapsum3_re;
  tapsum_mcand_2_im <= tapsum3_im;

  tapsum4_re <= resize(delay_pipeline_re(2), 17) + resize(delay_pipeline_re(8), 17);

  tapsum4_im <= resize(delay_pipeline_im(2), 17) + resize(delay_pipeline_im(8), 17);

  tapsum_mcand_3_re <= tapsum4_re;
  tapsum_mcand_3_im <= tapsum4_im;

  tapsum5_re <= resize(delay_pipeline_re(3), 17) + resize(delay_pipeline_re(7), 17);

  tapsum5_im <= resize(delay_pipeline_im(3), 17) + resize(delay_pipeline_im(7), 17);

  tapsum_mcand_4_re <= tapsum5_re;
  tapsum_mcand_4_im <= tapsum5_im;

  tapsum6_re <= resize(delay_pipeline_re(4), 17) + resize(delay_pipeline_re(6), 17);

  tapsum6_im <= resize(delay_pipeline_im(4), 17) + resize(delay_pipeline_im(6), 17);

  tapsum_mcand_5_re <= tapsum6_re;
  tapsum_mcand_5_im <= tapsum6_im;

  temp_process1 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
        delay_pipeline_re_5_under_pipe_re <= (OTHERS => '0');
        delay_pipeline_re_5_under_pipe_im <= (OTHERS => '0');
        delay_pipeline_re_5_under_pipe_1_re <= (OTHERS => '0');
        delay_pipeline_re_5_under_pipe_1_im <= (OTHERS => '0');
        coeff7_pipe <= (OTHERS => '0');
        coeff7_pipe_1 <= (OTHERS => '0');
        product7_re_pipe_re <= (OTHERS => '0');
        product7_re_pipe_im <= (OTHERS => '0');
        product7_re_pipe_1_re <= (OTHERS => '0');
        product7_re_pipe_1_im <= (OTHERS => '0');
      ELSIF clk_enable_stage3 = '1' THEN
        delay_pipeline_re_5_under_pipe_re <= delay_pipeline_re(5);
        delay_pipeline_re_5_under_pipe_im <= delay_pipeline_im(5);
        delay_pipeline_re_5_under_pipe_1_re <= delay_pipeline_re_5_under_pipe_re;
        delay_pipeline_re_5_under_pipe_1_im <= delay_pipeline_re_5_under_pipe_im;
        coeff7_pipe <= coeff7;
        coeff7_pipe_1 <= coeff7_pipe;

        product7_re_pipe_re <= delay_pipeline_re_5_under_pipe_1_re * coeff7_pipe_1;
        product7_re_pipe_im <= delay_pipeline_re_5_under_pipe_1_im * coeff7_pipe_1;

        product7_re_pipe_1_re <= product7_re_pipe_re;
        product7_re_pipe_1_im <= product7_re_pipe_im;
      END IF;
    END IF;
  END PROCESS temp_process1;

  product7_re <= product7_re_pipe_1_re;
  product7_im <= product7_re_pipe_1_im;

  temp_process2 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
        tapsum_mcand_5_re_pipe_re <= (OTHERS => '0');
        tapsum_mcand_5_re_pipe_im <= (OTHERS => '0');
        tapsum_mcand_5_re_pipe_1_re <= (OTHERS => '0');
        tapsum_mcand_5_re_pipe_1_im <= (OTHERS => '0');
        coeff6_pipe <= (OTHERS => '0');
        coeff6_pipe_1 <= (OTHERS => '0');
        product6_re_pipe_re <= (OTHERS => '0');
        product6_re_pipe_im <= (OTHERS => '0');
        product6_re_pipe_1_re <= (OTHERS => '0');
        product6_re_pipe_1_im <= (OTHERS => '0');
      ELSIF clk_enable_stage3 = '1' THEN
        tapsum_mcand_5_re_pipe_re <= tapsum_mcand_5_re;
        tapsum_mcand_5_re_pipe_im <= tapsum_mcand_5_im;
        tapsum_mcand_5_re_pipe_1_re <= tapsum_mcand_5_re_pipe_re;
        tapsum_mcand_5_re_pipe_1_im <= tapsum_mcand_5_re_pipe_im;
        coeff6_pipe <= coeff6;
        coeff6_pipe_1 <= coeff6_pipe;

        product6_re_pipe_re <= tapsum_mcand_5_re_pipe_1_re * coeff6_pipe_1;
        product6_re_pipe_im <= tapsum_mcand_5_re_pipe_1_im * coeff6_pipe_1;

        product6_re_pipe_1_re <= product6_re_pipe_re;
        product6_re_pipe_1_im <= product6_re_pipe_im;
      END IF;
    END IF;
  END PROCESS temp_process2;

  product6_re <= product6_re_pipe_1_re(31 DOWNTO 0);
  product6_im <= product6_re_pipe_1_im(31 DOWNTO 0);

  temp_process3 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
        tapsum_mcand_4_re_pipe_re <= (OTHERS => '0');
        tapsum_mcand_4_re_pipe_im <= (OTHERS => '0');
        tapsum_mcand_4_re_pipe_1_re <= (OTHERS => '0');
        tapsum_mcand_4_re_pipe_1_im <= (OTHERS => '0');
        coeff5_pipe <= (OTHERS => '0');
        coeff5_pipe_1 <= (OTHERS => '0');
        product5_re_pipe_re <= (OTHERS => '0');
        product5_re_pipe_im <= (OTHERS => '0');
        product5_re_pipe_1_re <= (OTHERS => '0');
        product5_re_pipe_1_im <= (OTHERS => '0');
      ELSIF clk_enable_stage3 = '1' THEN
        tapsum_mcand_4_re_pipe_re <= tapsum_mcand_4_re;
        tapsum_mcand_4_re_pipe_im <= tapsum_mcand_4_im;
        tapsum_mcand_4_re_pipe_1_re <= tapsum_mcand_4_re_pipe_re;
        tapsum_mcand_4_re_pipe_1_im <= tapsum_mcand_4_re_pipe_im;
        coeff5_pipe <= coeff5;
        coeff5_pipe_1 <= coeff5_pipe;

        product5_re_pipe_re <= tapsum_mcand_4_re_pipe_1_re * coeff5_pipe_1;
        product5_re_pipe_im <= tapsum_mcand_4_re_pipe_1_im * coeff5_pipe_1;

        product5_re_pipe_1_re <= product5_re_pipe_re;
        product5_re_pipe_1_im <= product5_re_pipe_im;
      END IF;
    END IF;
  END PROCESS temp_process3;

  product5_re <= product5_re_pipe_1_re(31 DOWNTO 0);
  product5_im <= product5_re_pipe_1_im(31 DOWNTO 0);

  temp_process4 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
        tapsum_mcand_3_re_pipe_re <= (OTHERS => '0');
        tapsum_mcand_3_re_pipe_im <= (OTHERS => '0');
        tapsum_mcand_3_re_pipe_1_re <= (OTHERS => '0');
        tapsum_mcand_3_re_pipe_1_im <= (OTHERS => '0');
        coeff4_pipe <= (OTHERS => '0');
        coeff4_pipe_1 <= (OTHERS => '0');
        product4_re_pipe_re <= (OTHERS => '0');
        product4_re_pipe_im <= (OTHERS => '0');
        product4_re_pipe_1_re <= (OTHERS => '0');
        product4_re_pipe_1_im <= (OTHERS => '0');
      ELSIF clk_enable_stage3 = '1' THEN
        tapsum_mcand_3_re_pipe_re <= tapsum_mcand_3_re;
        tapsum_mcand_3_re_pipe_im <= tapsum_mcand_3_im;
        tapsum_mcand_3_re_pipe_1_re <= tapsum_mcand_3_re_pipe_re;
        tapsum_mcand_3_re_pipe_1_im <= tapsum_mcand_3_re_pipe_im;
        coeff4_pipe <= coeff4;
        coeff4_pipe_1 <= coeff4_pipe;

        product4_re_pipe_re <= tapsum_mcand_3_re_pipe_1_re * coeff4_pipe_1;
        product4_re_pipe_im <= tapsum_mcand_3_re_pipe_1_im * coeff4_pipe_1;

        product4_re_pipe_1_re <= product4_re_pipe_re;
        product4_re_pipe_1_im <= product4_re_pipe_im;
      END IF;
    END IF;
  END PROCESS temp_process4;

  product4_re <= product4_re_pipe_1_re(31 DOWNTO 0);
  product4_im <= product4_re_pipe_1_im(31 DOWNTO 0);

  temp_process5 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
        tapsum_mcand_2_re_pipe_re <= (OTHERS => '0');
        tapsum_mcand_2_re_pipe_im <= (OTHERS => '0');
        tapsum_mcand_2_re_pipe_1_re <= (OTHERS => '0');
        tapsum_mcand_2_re_pipe_1_im <= (OTHERS => '0');
        coeff3_pipe <= (OTHERS => '0');
        coeff3_pipe_1 <= (OTHERS => '0');
        product3_re_pipe_re <= (OTHERS => '0');
        product3_re_pipe_im <= (OTHERS => '0');
        product3_re_pipe_1_re <= (OTHERS => '0');
        product3_re_pipe_1_im <= (OTHERS => '0');
      ELSIF clk_enable_stage3 = '1' THEN
        tapsum_mcand_2_re_pipe_re <= tapsum_mcand_2_re;
        tapsum_mcand_2_re_pipe_im <= tapsum_mcand_2_im;
        tapsum_mcand_2_re_pipe_1_re <= tapsum_mcand_2_re_pipe_re;
        tapsum_mcand_2_re_pipe_1_im <= tapsum_mcand_2_re_pipe_im;
        coeff3_pipe <= coeff3;
        coeff3_pipe_1 <= coeff3_pipe;

        product3_re_pipe_re <= tapsum_mcand_2_re_pipe_1_re * coeff3_pipe_1;
        product3_re_pipe_im <= tapsum_mcand_2_re_pipe_1_im * coeff3_pipe_1;

        product3_re_pipe_1_re <= product3_re_pipe_re;
        product3_re_pipe_1_im <= product3_re_pipe_im;
      END IF;
    END IF;
  END PROCESS temp_process5;

  product3_re <= product3_re_pipe_1_re(31 DOWNTO 0);
  product3_im <= product3_re_pipe_1_im(31 DOWNTO 0);

  temp_process6 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
        tapsum_mcand_1_re_pipe_re <= (OTHERS => '0');
        tapsum_mcand_1_re_pipe_im <= (OTHERS => '0');
        tapsum_mcand_1_re_pipe_1_re <= (OTHERS => '0');
        tapsum_mcand_1_re_pipe_1_im <= (OTHERS => '0');
        coeff2_pipe <= (OTHERS => '0');
        coeff2_pipe_1 <= (OTHERS => '0');
        product2_re_pipe_re <= (OTHERS => '0');
        product2_re_pipe_im <= (OTHERS => '0');
        product2_re_pipe_1_re <= (OTHERS => '0');
        product2_re_pipe_1_im <= (OTHERS => '0');
      ELSIF clk_enable_stage3 = '1' THEN
        tapsum_mcand_1_re_pipe_re <= tapsum_mcand_1_re;
        tapsum_mcand_1_re_pipe_im <= tapsum_mcand_1_im;
        tapsum_mcand_1_re_pipe_1_re <= tapsum_mcand_1_re_pipe_re;
        tapsum_mcand_1_re_pipe_1_im <= tapsum_mcand_1_re_pipe_im;
        coeff2_pipe <= coeff2;
        coeff2_pipe_1 <= coeff2_pipe;

        product2_re_pipe_re <= tapsum_mcand_1_re_pipe_1_re * coeff2_pipe_1;
        product2_re_pipe_im <= tapsum_mcand_1_re_pipe_1_im * coeff2_pipe_1;

        product2_re_pipe_1_re <= product2_re_pipe_re;
        product2_re_pipe_1_im <= product2_re_pipe_im;
      END IF;
    END IF;
  END PROCESS temp_process6;

  product2_re <= product2_re_pipe_1_re(31 DOWNTO 0);
  product2_im <= product2_re_pipe_1_im(31 DOWNTO 0);

  temp_process7 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
        tapsum_mcand_re_pipe_re <= (OTHERS => '0');
        tapsum_mcand_re_pipe_im <= (OTHERS => '0');
        tapsum_mcand_re_pipe_1_re <= (OTHERS => '0');
        tapsum_mcand_re_pipe_1_im <= (OTHERS => '0');
        coeff1_pipe <= (OTHERS => '0');
        coeff1_pipe_1 <= (OTHERS => '0');
        product1_re_pipe_re <= (OTHERS => '0');
        product1_re_pipe_im <= (OTHERS => '0');
        product1_re_pipe_1_re <= (OTHERS => '0');
        product1_re_pipe_1_im <= (OTHERS => '0');
      ELSIF clk_enable_stage3 = '1' THEN
        tapsum_mcand_re_pipe_re <= tapsum_mcand_re;
        tapsum_mcand_re_pipe_im <= tapsum_mcand_im;
        tapsum_mcand_re_pipe_1_re <= tapsum_mcand_re_pipe_re;
        tapsum_mcand_re_pipe_1_im <= tapsum_mcand_re_pipe_im;
        coeff1_pipe <= coeff1;
        coeff1_pipe_1 <= coeff1_pipe;

        product1_re_pipe_re <= tapsum_mcand_re_pipe_1_re * coeff1_pipe_1;
        product1_re_pipe_im <= tapsum_mcand_re_pipe_1_im * coeff1_pipe_1;

        product1_re_pipe_1_re <= product1_re_pipe_re;
        product1_re_pipe_1_im <= product1_re_pipe_im;
      END IF;
    END IF;
  END PROCESS temp_process7;

  product1_re <= product1_re_pipe_1_re(31 DOWNTO 0);
  product1_im <= product1_re_pipe_1_im(31 DOWNTO 0);

  add_temp <= resize(product7_re, 33) + resize(product6_re, 33);
  sum1_1_re <= add_temp(31 DOWNTO 0);

  add_temp_1 <= resize(product7_im, 33) + resize(product6_im, 33);
  sum1_1_im <= add_temp_1(31 DOWNTO 0);

  add_temp_2 <= resize(product5_re, 33) + resize(product4_re, 33);
  sum1_2_re <= add_temp_2(31 DOWNTO 0);

  add_temp_3 <= resize(product5_im, 33) + resize(product4_im, 33);
  sum1_2_im <= add_temp_3(31 DOWNTO 0);

  add_temp_4 <= resize(product3_re, 33) + resize(product2_re, 33);
  sum1_3_re <= add_temp_4(31 DOWNTO 0);

  add_temp_5 <= resize(product3_im, 33) + resize(product2_im, 33);
  sum1_3_im <= add_temp_5(31 DOWNTO 0);

  temp_process8 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
        sumpipe1_1_re <= (OTHERS => '0');
        sumpipe1_1_im <= (OTHERS => '0');
        sumpipe1_2_re <= (OTHERS => '0');
        sumpipe1_2_im <= (OTHERS => '0');
        sumpipe1_3_re <= (OTHERS => '0');
        sumpipe1_3_im <= (OTHERS => '0');
        sumpipe1_4_re <= (OTHERS => '0');
        sumpipe1_4_im <= (OTHERS => '0');
      ELSIF clk_enable_stage3 = '1' THEN
        sumpipe1_1_re <= sum1_1_re;
        sumpipe1_1_im <= sum1_1_im;
        sumpipe1_2_re <= sum1_2_re;
        sumpipe1_2_im <= sum1_2_im;
        sumpipe1_3_re <= sum1_3_re;
        sumpipe1_3_im <= sum1_3_im;
        sumpipe1_4_re <= product1_re;
        sumpipe1_4_im <= product1_im;
      END IF;
    END IF; 
  END PROCESS temp_process8;

  add_temp_6 <= resize(sumpipe1_1_re, 33) + resize(sumpipe1_2_re, 33);
  sum2_1_re <= add_temp_6(31 DOWNTO 0);

  add_temp_7 <= resize(sumpipe1_1_im, 33) + resize(sumpipe1_2_im, 33);
  sum2_1_im <= add_temp_7(31 DOWNTO 0);

  add_temp_8 <= resize(sumpipe1_3_re, 33) + resize(sumpipe1_4_re, 33);
  sum2_2_re <= add_temp_8(31 DOWNTO 0);

  add_temp_9 <= resize(sumpipe1_3_im, 33) + resize(sumpipe1_4_im, 33);
  sum2_2_im <= add_temp_9(31 DOWNTO 0);

  temp_process9 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
        sumpipe2_1_re <= (OTHERS => '0');
        sumpipe2_1_im <= (OTHERS => '0');
        sumpipe2_2_re <= (OTHERS => '0');
        sumpipe2_2_im <= (OTHERS => '0');
      ELSIF clk_enable_stage3 = '1' THEN
        sumpipe2_1_re <= sum2_1_re;
        sumpipe2_1_im <= sum2_1_im;
        sumpipe2_2_re <= sum2_2_re;
        sumpipe2_2_im <= sum2_2_im;
      END IF;
    END IF; 
  END PROCESS temp_process9;

  add_temp_10 <= resize(sumpipe2_1_re, 33) + resize(sumpipe2_2_re, 33);
  sum3_1_re <= add_temp_10(31 DOWNTO 0);

  add_temp_11 <= resize(sumpipe2_1_im, 33) + resize(sumpipe2_2_im, 33);
  sum3_1_im <= add_temp_11(31 DOWNTO 0);

  temp_process10 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
        sumpipe3_1_re <= (OTHERS => '0');
        sumpipe3_1_im <= (OTHERS => '0');
      ELSIF clk_enable_stage3 = '1' THEN
        sumpipe3_1_re <= sum3_1_re;
        sumpipe3_1_im <= sum3_1_im;
      END IF;
    END IF; 
  END PROCESS temp_process10;

  sum_final_re <= sumpipe3_1_re;
  sum_final_im <= sumpipe3_1_im;

  output_typeconvert_re <= resize(shift_right(sum_final_re(30 DOWNTO 0) + ( "0" & (sum_final_re(15) & NOT sum_final_re(15) & NOT sum_final_re(15) & NOT sum_final_re(15) & NOT sum_final_re(15) & NOT sum_final_re(15) & NOT sum_final_re(15) & NOT sum_final_re(15) & NOT sum_final_re(15) & NOT sum_final_re(15) & NOT sum_final_re(15) & NOT sum_final_re(15) & NOT sum_final_re(15) & NOT sum_final_re(15) & NOT sum_final_re(15))), 15), 16);
  output_typeconvert_im <= resize(shift_right(sum_final_im(30 DOWNTO 0) + ( "0" & (sum_final_im(15) & NOT sum_final_im(15) & NOT sum_final_im(15) & NOT sum_final_im(15) & NOT sum_final_im(15) & NOT sum_final_im(15) & NOT sum_final_im(15) & NOT sum_final_im(15) & NOT sum_final_im(15) & NOT sum_final_im(15) & NOT sum_final_im(15) & NOT sum_final_im(15) & NOT sum_final_im(15) & NOT sum_final_im(15) & NOT sum_final_im(15))), 15), 16);

  Output_Register_process : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
        output_register_re <= (OTHERS => '0');
        output_register_im <= (OTHERS => '0');
      ELSIF clk_enable_stage3 = '1' THEN
        output_register_re <= output_typeconvert_re;
        output_register_im <= output_typeconvert_im;
      END IF;
    END IF; 
  END PROCESS Output_Register_process;

  -- Assignment Statements
  filter_out_stage3_re <= std_logic_vector(output_register_re);
  filter_out_stage3_im <= std_logic_vector(output_register_im);
END rtl;
