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
-- Discrete-Time Gain
-- ------------------
-- Filter Structure  : Scalar
-- Filter Length     : 1
-- Stable            : Yes
-- Linear Phase      : Yes (Type 1)
-- Arithmetic        : fixed
-- Gain              : s16,14 -> [-2 2)
-- Input             : s16,0 -> [-32768 32768)
-- Output            : s16,0 -> [-32768 32768)
-- Round Mode        : floor
-- Overflow Mode     : wrap
-- -------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;
ENTITY SDRDDCStage2 IS
   PORT( clk                             :   IN    std_logic; 
         clk_enable_stage2               :   IN    std_logic; 
         reset                           :   IN    std_logic; 
         cicfinegain                     :   IN    std_logic_vector(15 DOWNTO 0); -- sfix16_En14                                 
         filter_in_stage2_re             :   IN    std_logic_vector(15 DOWNTO 0); -- sfix16
         filter_in_stage2_im             :   IN    std_logic_vector(15 DOWNTO 0); -- sfix16
         filter_out_stage2_re            :   OUT   std_logic_vector(15 DOWNTO 0); -- sfix16
         filter_out_stage2_im            :   OUT   std_logic_vector(15 DOWNTO 0)  -- sfix16
         );

END SDRDDCStage2;


----------------------------------------------------------------
--Module Architecture: ddc_filters_stage2
----------------------------------------------------------------
ARCHITECTURE rtl OF SDRDDCStage2 IS
  -- Local Functions
  -- Type Definitions
  -- Constants
  --CONSTANT scaleconst                     : signed(15 DOWNTO 0) := to_signed(15552, 16); -- sfix16_En14
  -- Signals

  SIGNAL gain_typeconvert                 : signed(15 DOWNTO 0); -- sfix16

  SIGNAL input_typeconvert_re             : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_typeconvert_im             : signed(15 DOWNTO 0); -- sfix16
  SIGNAL scaleout_re                      : signed(15 DOWNTO 0); -- sfix16
  SIGNAL scaleout_im                      : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_typeconvert_re_pipe_re     : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_typeconvert_re_pipe_im     : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_typeconvert_re_pipe_1_re   : signed(15 DOWNTO 0); -- sfix16
  SIGNAL input_typeconvert_re_pipe_1_im   : signed(15 DOWNTO 0); -- sfix16
  SIGNAL scaleconst_pipe                  : signed(15 DOWNTO 0); -- sfix16_En14
  SIGNAL scaleconst_pipe_1                : signed(15 DOWNTO 0); -- sfix16_En14
  SIGNAL scaleout_re_pipe_re              : signed(31 DOWNTO 0); -- sfix32_En14
  SIGNAL scaleout_re_pipe_im              : signed(31 DOWNTO 0); -- sfix32_En14
  SIGNAL scaleout_re_pipe_1_re            : signed(31 DOWNTO 0); -- sfix32_En14
  SIGNAL scaleout_re_pipe_1_im            : signed(31 DOWNTO 0); -- sfix32_En14
  SIGNAL output_register_re               : signed(15 DOWNTO 0); -- sfix16
  SIGNAL output_register_im               : signed(15 DOWNTO 0); -- sfix16


BEGIN

  -- Block Statements
  input_typeconvert_re <= signed(filter_in_stage2_re);
  input_typeconvert_im <= signed(filter_in_stage2_im);

  gain_typeconvert <= signed(cicfinegain);

  temp_process1 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
        input_typeconvert_re_pipe_re <= (OTHERS => '0');
        input_typeconvert_re_pipe_im <= (OTHERS => '0');
        input_typeconvert_re_pipe_1_re <= (OTHERS => '0');
        input_typeconvert_re_pipe_1_im <= (OTHERS => '0');
        scaleconst_pipe <= (OTHERS => '0');
        scaleconst_pipe_1 <= (OTHERS => '0');
        scaleout_re_pipe_re <= (OTHERS => '0');
        scaleout_re_pipe_im <= (OTHERS => '0');
        scaleout_re_pipe_1_re <= (OTHERS => '0');
        scaleout_re_pipe_1_im <= (OTHERS => '0');
      ELSIF clk_enable_stage2 = '1' THEN
        input_typeconvert_re_pipe_re <= input_typeconvert_re;
        input_typeconvert_re_pipe_im <= input_typeconvert_im;
        input_typeconvert_re_pipe_1_re <= input_typeconvert_re_pipe_re;
        input_typeconvert_re_pipe_1_im <= input_typeconvert_re_pipe_im;
        scaleconst_pipe <= gain_typeconvert;
        scaleconst_pipe_1 <= scaleconst_pipe;

        scaleout_re_pipe_re <= input_typeconvert_re_pipe_1_re * scaleconst_pipe_1;
        scaleout_re_pipe_im <= input_typeconvert_re_pipe_1_im * scaleconst_pipe_1;

        scaleout_re_pipe_1_re <= scaleout_re_pipe_re;
        scaleout_re_pipe_1_im <= scaleout_re_pipe_im;
      END IF;
    END IF;
  END PROCESS temp_process1;

  scaleout_re <= scaleout_re_pipe_1_re(29 DOWNTO 14);
  scaleout_im <= scaleout_re_pipe_1_im(29 DOWNTO 14);

  Output_Register_process : PROCESS (clk, reset)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
        output_register_re <= (OTHERS => '0');
        output_register_im <= (OTHERS => '0');
      ELSIF clk_enable_stage2 = '1' THEN
        output_register_re <= scaleout_re;
        output_register_im <= scaleout_im;
      END IF;
    END IF; 
  END PROCESS Output_Register_process;

  -- Assignment Statements
  filter_out_stage2_re <= std_logic_vector(output_register_re);
  filter_out_stage2_im <= std_logic_vector(output_register_im);
END rtl;
