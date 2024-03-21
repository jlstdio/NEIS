
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
-- Stage 1               : Cascaded Integrator-Comb Decimator
-- HDL Implementation    : Fully parallel

--
-- Stage 2               : Scalar
-- HDL Implementation    : Fully parallel

--
-- Stage 3               : Direct-Form Symmetric FIR
-- HDL Implementation    : Fully parallel
-- Multipliers           : 7
-- Folding Factor        : 1

--
-- Stage 4               : Direct-Form FIR Polyphase Decimator
-- HDL Implementation    : Fully parallel
-- Multipliers           : 7
-- Folding Factor        : 1

--
-- Stage 5               : Direct-Form FIR Polyphase Decimator
-- HDL Implementation    : Fully parallel
-- Multipliers           : 13
-- Folding Factor        : 1

--
-- -------------------------------------------------------------
-- Filter Settings:
--
-- Discrete-Time FIR Filter (real)
-- -------------------------------
-- Filter Structure  : Cascade
-- Number of Stages  : 5
-- Stable            : Yes
-- Linear Phase      : Yes (Type 4)
-- -------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;

ENTITY SDRDDCMain IS
   PORT( clk                             :   IN    std_logic; 
         clk_enable                      :   IN    std_logic; 
         reset                           :   IN    std_logic; 
         filter_in_re                    :   IN    std_logic_vector(13 DOWNTO 0); -- sfix14
         filter_in_im                    :   IN    std_logic_vector(13 DOWNTO 0); -- sfix14         
         cic_enable                      :   IN    std_logic;
         hb1_enable                      :   IN    std_logic;
         hb2_enable                      :   IN    std_logic;
         rate                            :   IN    std_logic_vector(7 DOWNTO 0); -- ufix8
        -- load_rate                       :   IN    std_logic; 
         cicfinegain                     :   IN    std_logic_vector(15 DOWNTO 0);
         filter_out_re                   :   OUT   std_logic_vector(15 DOWNTO 0); -- sfix16
         filter_out_im                   :   OUT   std_logic_vector(15 DOWNTO 0); -- sfix16
         ce_out                          :   OUT   std_logic  
         );

END SDRDDCMain;


----------------------------------------------------------------
--Module Architecture: ddc_filters
----------------------------------------------------------------
ARCHITECTURE rtl OF SDRDDCMain IS
  COMPONENT SDRDDCStage1
   PORT( clk                             :   IN    std_logic; 
         clk_enable_stage1               :   IN    std_logic; 
         reset                           :   IN    std_logic; 
         filter_in_stage1_re             :   IN    std_logic_vector(13 DOWNTO 0); -- sfix14
         filter_in_stage1_im             :   IN    std_logic_vector(13 DOWNTO 0); -- sfix14
         rate                            :   IN    std_logic_vector(7 DOWNTO 0); -- ufix8
         --load_rate                       :   IN    std_logic; 
         filter_out_stage1_re            :   OUT   std_logic_vector(15 DOWNTO 0); -- sfix16
         filter_out_stage1_im            :   OUT   std_logic_vector(15 DOWNTO 0); -- sfix16
         ce_out_stage1                   :   OUT   std_logic  
         );
    END COMPONENT;

  COMPONENT SDRDDCStage2
   PORT( clk                             :   IN    std_logic; 
         clk_enable_stage2               :   IN    std_logic; 
         reset                           :   IN    std_logic; 
         cicfinegain                     :   IN    std_logic_vector(15 DOWNTO 0); -- sfix16_En14                                 
         filter_in_stage2_re             :   IN    std_logic_vector(15 DOWNTO 0); -- sfix16
         filter_in_stage2_im             :   IN    std_logic_vector(15 DOWNTO 0); -- sfix16
         filter_out_stage2_re            :   OUT   std_logic_vector(15 DOWNTO 0); -- sfix16
         filter_out_stage2_im            :   OUT   std_logic_vector(15 DOWNTO 0)  -- sfix16
         );
    END COMPONENT;

  COMPONENT SDRDDCStage3
   PORT( clk                             :   IN    std_logic; 
         clk_enable_stage3               :   IN    std_logic; 
         reset                           :   IN    std_logic; 
         filter_in_stage3_re             :   IN    std_logic_vector(15 DOWNTO 0); -- sfix16
         filter_in_stage3_im             :   IN    std_logic_vector(15 DOWNTO 0); -- sfix16
         filter_out_stage3_re            :   OUT   std_logic_vector(15 DOWNTO 0); -- sfix16
         filter_out_stage3_im            :   OUT   std_logic_vector(15 DOWNTO 0)  -- sfix16
         );
    END COMPONENT;

  COMPONENT SDRDDCStage4
   PORT( clk                             :   IN    std_logic; 
         clk_enable_stage4               :   IN    std_logic; 
         reset                           :   IN    std_logic; 
         filter_in_stage4_re             :   IN    std_logic_vector(15 DOWNTO 0); -- sfix16
         filter_in_stage4_im             :   IN    std_logic_vector(15 DOWNTO 0); -- sfix16
         filter_out_stage4_re            :   OUT   std_logic_vector(15 DOWNTO 0); -- sfix16
         filter_out_stage4_im            :   OUT   std_logic_vector(15 DOWNTO 0); -- sfix16
         ce_out_stage4                   :   OUT   std_logic  
         );
    END COMPONENT;

  COMPONENT SDRDDCStage5
   PORT( clk                             :   IN    std_logic; 
         clk_enable_stage5               :   IN    std_logic; 
         reset                           :   IN    std_logic; 
         filter_in_stage5_re             :   IN    std_logic_vector(15 DOWNTO 0); -- sfix16
         filter_in_stage5_im             :   IN    std_logic_vector(15 DOWNTO 0); -- sfix16
         filter_out_stage5_re            :   OUT   std_logic_vector(15 DOWNTO 0); -- sfix16
         filter_out_stage5_im            :   OUT   std_logic_vector(15 DOWNTO 0); -- sfix16
         ce_out_stage5                   :   OUT   std_logic  
         );
    END COMPONENT;

  FOR ALL : SDRDDCStage1
    USE ENTITY work.SDRDDCStage1(rtl);

  FOR ALL : SDRDDCStage2
    USE ENTITY work.SDRDDCStage2(rtl);

  FOR ALL : SDRDDCStage3
    USE ENTITY work.SDRDDCStage3(rtl);

  FOR ALL : SDRDDCStage4
    USE ENTITY work.SDRDDCStage4(rtl);

  FOR ALL : SDRDDCStage5
    USE ENTITY work.SDRDDCStage5(rtl);

  -- Local Functions
  -- Type Definitions
  -- Constants
  CONSTANT logical_one                    : std_logic := '1'; -- boolean
  -- Signals
  SIGNAL filter_in_stage1_re              : std_logic_vector(13 DOWNTO 0); -- sfix14
  SIGNAL filter_in_stage1_im              : std_logic_vector(13 DOWNTO 0); -- sfix14
  SIGNAL filter_out_stage1_re             : std_logic_vector(15 DOWNTO 0); -- sfix16
  SIGNAL filter_out_stage1_im             : std_logic_vector(15 DOWNTO 0); -- sfix16
  SIGNAL clk_enable_stage1                : std_logic; -- boolean
  SIGNAL ce_out_stage1                    : std_logic; -- boolean
  SIGNAL filter_in_stage2_re              : std_logic_vector(15 DOWNTO 0); -- sfix16
  SIGNAL filter_in_stage2_im              : std_logic_vector(15 DOWNTO 0); -- sfix16
  SIGNAL filter_out_stage2_re             : std_logic_vector(15 DOWNTO 0); -- sfix16
  SIGNAL filter_out_stage2_im             : std_logic_vector(15 DOWNTO 0); -- sfix16
  SIGNAL clk_enable_stage2                : std_logic; -- boolean
  SIGNAL ce_out_stage2                    : std_logic; -- boolean
  SIGNAL filter_in_stage3_re              : std_logic_vector(15 DOWNTO 0); -- sfix16
  SIGNAL filter_in_stage3_im              : std_logic_vector(15 DOWNTO 0); -- sfix16
  SIGNAL filter_out_stage3_re             : std_logic_vector(15 DOWNTO 0); -- sfix16
  SIGNAL filter_out_stage3_im             : std_logic_vector(15 DOWNTO 0); -- sfix16
  SIGNAL clk_enable_stage3                : std_logic; -- boolean
  SIGNAL ce_out_stage3                    : std_logic; -- boolean
  SIGNAL filter_in_stage4_re              : std_logic_vector(15 DOWNTO 0); -- sfix16
  SIGNAL filter_in_stage4_im              : std_logic_vector(15 DOWNTO 0); -- sfix16
  SIGNAL filter_out_stage4_re             : std_logic_vector(15 DOWNTO 0); -- sfix16
  SIGNAL filter_out_stage4_im             : std_logic_vector(15 DOWNTO 0); -- sfix16
  SIGNAL clk_enable_stage4                : std_logic; -- boolean
  SIGNAL ce_out_stage4                    : std_logic; -- boolean
  SIGNAL filter_in_stage5_re              : std_logic_vector(15 DOWNTO 0); -- sfix16
  SIGNAL filter_in_stage5_im              : std_logic_vector(15 DOWNTO 0); -- sfix16
  SIGNAL filter_out_stage5_re             : std_logic_vector(15 DOWNTO 0); -- sfix16
  SIGNAL filter_out_stage5_im             : std_logic_vector(15 DOWNTO 0); -- sfix16
  SIGNAL clk_enable_stage5                : std_logic; -- boolean
  SIGNAL ce_out_stage5                    : std_logic; -- boolean
  SIGNAL filter_in_stage2_tmp_re          : signed(15 DOWNTO 0); -- sfix16
  SIGNAL filter_in_stage2_tmp_im          : signed(15 DOWNTO 0); -- sfix16
  SIGNAL filter_in_stage3_tmp_re          : signed(15 DOWNTO 0); -- sfix16
  SIGNAL filter_in_stage3_tmp_im          : signed(15 DOWNTO 0); -- sfix16
  SIGNAL filter_in_stage4_tmp_re          : signed(15 DOWNTO 0); -- sfix16
  SIGNAL filter_in_stage4_tmp_im          : signed(15 DOWNTO 0); -- sfix16
  SIGNAL filter_in_stage5_tmp_re          : signed(15 DOWNTO 0); -- sfix16
  SIGNAL filter_in_stage5_tmp_im          : signed(15 DOWNTO 0); -- sfix16
  SIGNAL cedelay1_stage2                  : std_logic; -- boolean
  SIGNAL cedelay2_stage2                  : std_logic; -- boolean
  SIGNAL cedelay3_stage2                  : std_logic; -- boolean
  SIGNAL cedelay4_stage2                  : std_logic; -- boolean
  SIGNAL cedelay5_stage2                  : std_logic; -- boolean
  SIGNAL cedelay1_stage3                  : std_logic; -- boolean
  SIGNAL cedelay2_stage3                  : std_logic; -- boolean
  SIGNAL cedelay3_stage3                  : std_logic; -- boolean
  SIGNAL cedelay4_stage3                  : std_logic; -- boolean
  SIGNAL cedelay5_stage3                  : std_logic; -- boolean
  SIGNAL cedelay6_stage3                  : std_logic; -- boolean
  SIGNAL cedelay7_stage3                  : std_logic; -- boolean
  SIGNAL cedelay8_stage3                  : std_logic; -- boolean


BEGIN
  u_ddc_filters_stage1: SDRDDCStage1
    PORT MAP (
              clk                              => clk,
              clk_enable_stage1                => clk_enable_stage1,
              reset                            => reset,
              filter_in_stage1_re              => filter_in_stage1_re,
              filter_in_stage1_im              => filter_in_stage1_im,
              rate                             => rate,
              --load_rate                        => load_rate,
              filter_out_stage1_re             => filter_out_stage1_re,
              filter_out_stage1_im             => filter_out_stage1_im,
              ce_out_stage1                    => ce_out_stage1      );

  u_ddc_filters_stage2: SDRDDCStage2
    PORT MAP (
              clk                              => clk,
              clk_enable_stage2                => clk_enable_stage2,
              reset                            => reset,
              cicfinegain                      => cicfinegain,                                
              filter_in_stage2_re              => filter_in_stage2_re,
              filter_in_stage2_im              => filter_in_stage2_im,
              filter_out_stage2_re             => filter_out_stage2_re,
              filter_out_stage2_im             => filter_out_stage2_im      );

  u_ddc_filters_stage3: SDRDDCStage3
    PORT MAP (
              clk                              => clk,
              clk_enable_stage3                => clk_enable_stage3,
              reset                            => reset,
              filter_in_stage3_re              => filter_in_stage3_re,
              filter_in_stage3_im              => filter_in_stage3_im,
              filter_out_stage3_re             => filter_out_stage3_re,
              filter_out_stage3_im             => filter_out_stage3_im      );

  u_ddc_filters_stage4: SDRDDCStage4
    PORT MAP (
              clk                              => clk,
              clk_enable_stage4                => clk_enable_stage4,
              reset                            => reset,
              filter_in_stage4_re              => filter_in_stage4_re,
              filter_in_stage4_im              => filter_in_stage4_im,
              filter_out_stage4_re             => filter_out_stage4_re,
              filter_out_stage4_im             => filter_out_stage4_im,
              ce_out_stage4                    => ce_out_stage4      );

  u_ddc_filters_stage5: SDRDDCStage5
    PORT MAP (
              clk                              => clk,
              clk_enable_stage5                => clk_enable_stage5,
              reset                            => reset,
              filter_in_stage5_re              => filter_in_stage5_re,
              filter_in_stage5_im              => filter_in_stage5_im,
              filter_out_stage5_re             => filter_out_stage5_re,
              filter_out_stage5_im             => filter_out_stage5_im,
              ce_out_stage5                    => ce_out_stage5      );


  -- Block Statements
  filter_in_stage1_re <= std_logic_vector(filter_in_re);
  filter_in_stage1_im <= std_logic_vector(filter_in_im);
  filter_in_stage2_tmp_re <= signed(filter_out_stage1_re);
  filter_in_stage2_tmp_im <= signed(filter_out_stage1_im);

  filter_in_stage2_re <= std_logic_vector(filter_in_stage2_tmp_re);
  filter_in_stage2_im <= std_logic_vector(filter_in_stage2_tmp_im);
  filter_in_stage3_tmp_re <= signed(filter_out_stage2_re);
  filter_in_stage3_tmp_im <= signed(filter_out_stage2_im);

  filter_in_stage3_re <= std_logic_vector(filter_in_stage3_tmp_re);
  filter_in_stage3_im <= std_logic_vector(filter_in_stage3_tmp_im);
  filter_in_stage4_tmp_re <= signed(filter_out_stage3_re);
  filter_in_stage4_tmp_im <= signed(filter_out_stage3_im);
  -- stage3output (filter_out_stage3) is cic output (with gain and droop correction)
  filter_in_stage4_re <= filter_out_stage3_re WHEN (cic_enable = '1') ELSE
                             filter_in_stage1_re & "00";

  filter_in_stage4_im <= filter_out_stage3_im WHEN (cic_enable = '1') ELSE
                             filter_in_stage1_im & "00";

  clk_enable_stage4 <= ce_out_stage3 WHEN (cic_enable = '1') ELSE
                             clk_enable_stage1;

  --filter_in_stage4_re <= std_logic_vector(filter_in_stage4_tmp_re);
  --filter_in_stage4_im <= std_logic_vector(filter_in_stage4_tmp_im);
  filter_in_stage5_tmp_re <= signed(filter_out_stage4_re);
  filter_in_stage5_tmp_im <= signed(filter_out_stage4_im);

  filter_in_stage5_re <= filter_out_stage4_re WHEN (hb1_enable = '1') ELSE
                             filter_in_stage4_re;
  filter_in_stage5_im <= filter_out_stage4_im WHEN (hb1_enable = '1') ELSE
                             filter_in_stage4_im;

  clk_enable_stage5 <= ce_out_stage4 WHEN (hb1_enable = '1') ELSE
                             clk_enable_stage4;

--  filter_in_stage5_re <= std_logic_vector(filter_in_stage5_tmp_re);
 -- filter_in_stage5_im <= std_logic_vector(filter_in_stage5_tmp_im);
  clk_enable_stage1 <= clk_enable;
  clk_enable_stage2 <= ce_out_stage1;
  cedelay_stage2_process : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
        cedelay1_stage2 <= '0';
        cedelay2_stage2 <= '0';
        cedelay3_stage2 <= '0';
        cedelay4_stage2 <= '0';
        cedelay5_stage2 <= '0';
      ELSIF clk_enable_stage2 = '1' THEN
        cedelay1_stage2 <= logical_one;
        cedelay2_stage2 <= cedelay1_stage2;
        cedelay3_stage2 <= cedelay2_stage2;
        cedelay4_stage2 <= cedelay3_stage2;
        cedelay5_stage2 <= cedelay4_stage2;
      END IF;
    END IF; 
  END PROCESS cedelay_stage2_process;

  ce_out_stage2 <=  clk_enable_stage2 AND cedelay5_stage2;

  clk_enable_stage3 <= ce_out_stage2;
  cedelay_stage3_process : PROCESS (clk, reset)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
        cedelay1_stage3 <= '0';
        cedelay2_stage3 <= '0';
        cedelay3_stage3 <= '0';
        cedelay4_stage3 <= '0';
        cedelay5_stage3 <= '0';
        cedelay6_stage3 <= '0';
        cedelay7_stage3 <= '0';
        cedelay8_stage3 <= '0';
      ELSIF clk_enable_stage3 = '1' THEN
        cedelay1_stage3 <= logical_one;
        cedelay2_stage3 <= cedelay1_stage3;
        cedelay3_stage3 <= cedelay2_stage3;
        cedelay4_stage3 <= cedelay3_stage3;
        cedelay5_stage3 <= cedelay4_stage3;
        cedelay6_stage3 <= cedelay5_stage3;
        cedelay7_stage3 <= cedelay6_stage3;
        cedelay8_stage3 <= cedelay7_stage3;
      END IF;
    END IF; 
  END PROCESS cedelay_stage3_process;

  ce_out_stage3 <=  clk_enable_stage3 AND cedelay8_stage3;
  -- ce_out_stage3 is the CIC combined stage Output valid when CIC is in
  --clk_enable_stage4 <= ce_out_stage3;
  --clk_enable_stage5 <= ce_out_stage4;
  --ce_out <= ce_out_stage5;
  -- Assignment Statements
  filter_out_re <= filter_out_stage5_re WHEN (hb2_enable = '1') ELSE
                             filter_in_stage5_re;
                             
  filter_out_im <= filter_out_stage5_im WHEN (hb2_enable = '1') ELSE
                             filter_in_stage5_im; 

 -- filter_out_re <= std_logic_vector(filter_out_stage5_re);
  --filter_out_im <= std_logic_vector(filter_out_stage5_im);

  ce_out <= ce_out_stage5 WHEN (hb2_enable = '1') ELSE
                             clk_enable_stage5;
END rtl;
