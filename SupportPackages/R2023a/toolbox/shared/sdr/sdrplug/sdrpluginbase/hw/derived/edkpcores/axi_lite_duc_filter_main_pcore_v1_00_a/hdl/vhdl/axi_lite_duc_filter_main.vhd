-- -------------------------------------------------------------
-- 
-- File Name: hdl_prj\hdlsrc\axi_lite_duc_filter_main\axi_lite_duc_filter_main.vhd
-- Created: 2013-09-23 15:11:42
-- 
-- Generated by MATLAB 8.2 and HDL Coder 3.3
-- 
-- 
-- -------------------------------------------------------------
-- Rate and Clocking Details
-- -------------------------------------------------------------
-- Model base rate: 0.2
-- Target subsystem base rate: 0.2
-- 
-- -------------------------------------------------------------


-- -------------------------------------------------------------
-- 
-- Module: axi_lite_duc_filter_main
-- Source Path: axi_lite_duc_filter_main
-- Hierarchy Level: 0
-- 
-- -------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY axi_lite_duc_filter_main IS
  PORT( wr_control_reg  : IN  std_logic_vector(31 DOWNTO 0);  -- uint32
        x_in            : IN  std_logic_vector(15 DOWNTO 0);  -- uint16
        y_in            : IN  std_logic_vector(15 DOWNTO 0);  -- uint16
        clk             : IN  std_logic;  -- ufix1
        reset           : IN  std_logic;  -- ufix1
        clock_enable    : IN  std_logic; 
        rd_control_reg  : OUT std_logic_vector(31 DOWNTO 0);  -- uint32
        intFactor       : OUT std_logic_vector(31 DOWNTO 0);  -- exposed value of intfactor register for use in axis demapper
        x_out           : OUT std_logic_vector(15 DOWNTO 0);  -- uint16
        y_out           : OUT std_logic_vector(15 DOWNTO 0);  -- uint16
        ce_out          : OUT std_logic  -- ufix1
        );
END axi_lite_duc_filter_main;


ARCHITECTURE rtl OF axi_lite_duc_filter_main IS

  -- Component Declarations
  COMPONENT SDRDUCMain
      PORT( clk                             :   IN    std_logic; 
              clk_enable                      :   IN    std_logic; 
              reset                           :   IN    std_logic; 
              filter_in_re                    :   IN    std_logic_vector(15 DOWNTO 0); -- sfix14
              filter_in_im                    :   IN    std_logic_vector(15 DOWNTO 0); -- sfix14
              rate                            :   IN    std_logic_vector(7 DOWNTO 0); -- ufix8
              cic_enable                      :   IN    std_logic;
              hb1_enable                      :   IN    std_logic;
              hb2_enable                      :   IN    std_logic;         
              cicfinegain                     :   IN    std_logic_vector(15 DOWNTO 0);         
              filter_out_re                   :   OUT   std_logic_vector(15 DOWNTO 0); -- sfix16
              filter_out_im                   :   OUT   std_logic_vector(15 DOWNTO 0); -- sfix16
              ce_out                          :   OUT   std_logic  
              );
  END COMPONENT;


  FOR ALL : SDRDUCMain
    USE ENTITY work.SDRDUCMain(rtl);

        
  -- Local Functions
  -- Type Definitions
  -- Constants
  -- Signals
  SIGNAL cic_enable                       : std_logic; -- ufix1
  SIGNAL hb1_enable                       : std_logic; -- ufix1
  SIGNAL hb2_enable                       : std_logic; -- ufix1
  SIGNAL rate                             : std_logic_vector(7 DOWNTO 0); -- sfix16
  SIGNAL cicfinegain                      : std_logic_vector(15 DOWNTO 0); -- sfix16
  SIGNAL data_final                       : std_logic_vector(31 DOWNTO 0); -- sfix16
  SIGNAL OUTPUT_REG                       : std_logic_vector(31 DOWNTO 0); -- sfix16
  SIGNAL OUTPUT_REG_sync1                 : std_logic_vector(31 DOWNTO 0); -- sfix16
  SIGNAL OUTPUT_REG_sync2                 : std_logic_vector(31 DOWNTO 0); -- sfix16
  SIGNAL OUTPUT_REG_sync3                 : std_logic_vector(31 DOWNTO 0); -- sfix16
  
  signal clk_enable_duc  : std_logic;  
  signal x_in_duc        : std_logic_vector(15 DOWNTO 0); 
  signal y_in_duc        : std_logic_vector(15 DOWNTO 0); 
  signal clk_enable_temp : std_logic;
  signal int_factor      : unsigned(9 downto 0);
  signal cnt             : unsigned(9 downto 0);  
  signal int_factor_mult1: unsigned(1 downto 0);
  signal int_factor_mult2: unsigned(1 downto 0);
  
  signal int_factor_pad  : std_logic_vector(21 downto 0);

BEGIN

  -- pre-process input data and data valid signal(data hold stable for a specified number of clks)
  -- calculate interpolation factor
  int_factor_mult1 <= to_unsigned(2,2) when hb1_enable = '1' else to_unsigned(1,2);
  int_factor_mult2 <= to_unsigned(2,2) when hb2_enable = '1' else to_unsigned(1,2);
  int_factor <= resize(int_factor_mult1 * int_factor_mult2,10) when cic_enable = '0' else
                resize(int_factor_mult1 * int_factor_mult2 * unsigned(rate),10);

  cnt_proc: process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        cnt        <= to_unsigned(1, 10);
      elsif clk_enable_temp = '1' then
        if cnt = int_factor then
          cnt        <= to_unsigned(1, 10);
        else
          cnt        <= cnt + to_unsigned(1, 10);
        end if;
      end if;
    end if;
  end process;

  data_proc: process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        x_in_duc     <= (others => '0');
        y_in_duc     <= (others => '0');
      else
        if clock_enable = '1' then
          x_in_duc     <= x_in;
          y_in_duc     <= y_in;    
        else       
          x_in_duc     <= x_in_duc;
          y_in_duc     <= y_in_duc;
        end if;
      end if;
    end if;
  end process;

  dvld_proc: process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        clk_enable_temp <= '0';
      else      
        if (clk_enable_temp = '0' and cnt =  to_unsigned(1, 10)) or (clk_enable_temp = '1' and cnt = int_factor) then
            clk_enable_temp <= clock_enable;
        end if;
      end if;
    end if;
  end process;

 clk_enable_duc <=  clk_enable_temp;

 ce_out <= clk_enable_temp; -- bypass clk_enable_duc, don't use ce_out of SDRDUCMain

  -- pre-process DONE, send x_in_duc, y_in_duc, clk_enable_duc to duc
  
  u_SDRDUCMain: SDRDUCMain
    PORT MAP (
              clk                              => clk,
              clk_enable                       => clk_enable_duc,
              reset                            => reset,
              filter_in_re                     => x_in_duc,
              filter_in_im                     => y_in_duc,
              cic_enable                       => cic_enable,
              hb1_enable                       => hb1_enable,
              hb2_enable                       => hb2_enable,              
              rate                             => rate,
              cicfinegain                      => cicfinegain,              
              filter_out_re                    => x_out,
              filter_out_im                    => y_out,
              ce_out                           => OPEN      );

              
  Sync_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      OUTPUT_REG_sync1 <= wr_control_reg;
      OUTPUT_REG_sync2 <= OUTPUT_REG_sync1;
      OUTPUT_REG_sync3 <= OUTPUT_REG_sync2;
    END IF;
  END PROCESS Sync_process;

  data_final_proc : PROCESS (clk)
   BEGIN
     IF clk'EVENT AND clk = '1' THEN
       IF reset = '1' THEN
         data_final <= (others => '0');
       ELSIF OUTPUT_REG_sync3 = OUTPUT_REG_sync2 THEN
         data_final <= OUTPUT_REG_sync3;
       END IF;
     END IF;
   END PROCESS data_final_proc;

  -- Block Statements

   cicfinegain <= data_final(15 DOWNTO 0);
   rate <= data_final(23 DOWNTO 16);
   cic_enable <= data_final(24);
   hb2_enable <= data_final(25);
   hb1_enable <= data_final(26);

   rd_control_reg <= wr_control_reg;
   int_factor_pad <= (others => '0');
   intFactor <= int_factor_pad & std_logic_vector(int_factor);

END rtl;

