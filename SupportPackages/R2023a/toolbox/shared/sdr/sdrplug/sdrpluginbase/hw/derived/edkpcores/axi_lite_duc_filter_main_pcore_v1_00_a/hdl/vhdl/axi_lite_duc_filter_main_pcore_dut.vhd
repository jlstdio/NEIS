-- -------------------------------------------------------------
-- 
-- File Name: hdl_prj\hdlsrc\axi_lite_duc_filter_main\axi_lite_duc_filter_main_pcore_dut.vhd
-- Created: 2014-03-09 13:20:37
-- 
-- Generated by MATLAB 8.3 and HDL Coder 3.4
-- 
-- -------------------------------------------------------------


-- -------------------------------------------------------------
-- 
-- Module: axi_lite_duc_filter_main_pcore_dut
-- Source Path: axi_lite_duc_filter_main_pcore/axi_lite_duc_filter_main_pcore_dut
-- Hierarchy Level: 1
-- 
-- -------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY axi_lite_duc_filter_main_pcore_dut IS
  PORT( wr_control_reg                    :   IN    std_logic_vector(31 DOWNTO 0);  -- ufix32
        x_in                              :   IN    std_logic_vector(15 DOWNTO 0);  -- ufix16
        y_in                              :   IN    std_logic_vector(15 DOWNTO 0);  -- ufix16
        clk                               :   IN    std_logic;  -- ufix1
        reset                             :   IN    std_logic;  -- ufix1
        clock_enable                      :   IN    std_logic;  -- ufix1
        rd_control_reg                    :   OUT   std_logic_vector(31 DOWNTO 0);  -- ufix32
        x_out                             :   OUT   std_logic_vector(15 DOWNTO 0);  -- ufix16
        y_out                             :   OUT   std_logic_vector(15 DOWNTO 0);  -- ufix16
        ce_out                            :   OUT   std_logic;  -- ufix1
        intFactor                         :   OUT   std_logic_vector(31 DOWNTO 0)  -- ufix32
        );
END axi_lite_duc_filter_main_pcore_dut;


ARCHITECTURE rtl OF axi_lite_duc_filter_main_pcore_dut IS

  -- Component Declarations
  COMPONENT axi_lite_duc_filter_main
    PORT( wr_control_reg                  :   IN    std_logic_vector(31 DOWNTO 0);  -- ufix32
          x_in                            :   IN    std_logic_vector(15 DOWNTO 0);  -- ufix16
          y_in                            :   IN    std_logic_vector(15 DOWNTO 0);  -- ufix16
          clk                             :   IN    std_logic;  -- ufix1
          reset                           :   IN    std_logic;  -- ufix1
          clock_enable                    :   IN    std_logic;  -- ufix1
          rd_control_reg                  :   OUT   std_logic_vector(31 DOWNTO 0);  -- ufix32
          x_out                           :   OUT   std_logic_vector(15 DOWNTO 0);  -- ufix16
          y_out                           :   OUT   std_logic_vector(15 DOWNTO 0);  -- ufix16
          ce_out                          :   OUT   std_logic;  -- ufix1
          intFactor                       :   OUT   std_logic_vector(31 DOWNTO 0)  -- ufix32
          );
  END COMPONENT;

  -- Component Configuration Statements
  FOR ALL : axi_lite_duc_filter_main
    USE ENTITY work.axi_lite_duc_filter_main(rtl);

  -- Signals
  SIGNAL clk_sig                          : std_logic;  -- ufix1
  SIGNAL reset_sig                        : std_logic;  -- ufix1
  SIGNAL clock_enable_sig                 : std_logic;  -- ufix1
  SIGNAL rd_control_reg_sig               : std_logic_vector(31 DOWNTO 0);  -- ufix32
  SIGNAL x_out_sig                        : std_logic_vector(15 DOWNTO 0);  -- ufix16
  SIGNAL y_out_sig                        : std_logic_vector(15 DOWNTO 0);  -- ufix16
  SIGNAL ce_out_sig                       : std_logic;  -- ufix1
  SIGNAL intFactor_sig                    : std_logic_vector(31 DOWNTO 0);  -- ufix32

BEGIN
  u_axi_lite_duc_filter_main : axi_lite_duc_filter_main
    PORT MAP( wr_control_reg => wr_control_reg,  -- ufix32
              x_in => x_in,  -- ufix16
              y_in => y_in,  -- ufix16
              clk => clk_sig,  -- ufix1
              reset => reset_sig,  -- ufix1
              clock_enable => clock_enable_sig,  -- ufix1
              rd_control_reg => rd_control_reg_sig,  -- ufix32
              x_out => x_out_sig,  -- ufix16
              y_out => y_out_sig,  -- ufix16
              ce_out => ce_out_sig,  -- ufix1
              intFactor => intFactor_sig  -- ufix32
              );

  clk_sig <= clk;

  reset_sig <= reset;

  clock_enable_sig <= clock_enable;

  rd_control_reg <= rd_control_reg_sig;

  x_out <= x_out_sig;

  y_out <= y_out_sig;

  ce_out <= ce_out_sig;

  intFactor <= intFactor_sig;

END rtl;

