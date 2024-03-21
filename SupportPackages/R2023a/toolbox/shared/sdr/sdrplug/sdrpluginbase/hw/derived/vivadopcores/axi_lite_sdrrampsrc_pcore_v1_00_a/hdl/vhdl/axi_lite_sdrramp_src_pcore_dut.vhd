-- -------------------------------------------------------------
-- 
-- File Name: hdl_prj/hdlsrc/axi_lite_sdrramp_src/axi_lite_sdrramp_src_pcore_dut.vhd
-- Created: 2014-07-16 08:51:28
-- 
-- Generated by MATLAB 8.4 and HDL Coder 3.5
-- 
-- -------------------------------------------------------------


-- -------------------------------------------------------------
-- 
-- Module: axi_lite_sdrramp_src_pcore_dut
-- Source Path: axi_lite_sdrramp_src__pcore/axi_lite_sdrramp_src__pcore_dut
-- Hierarchy Level: 1
-- 
-- -------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY axi_lite_sdrramp_src_pcore_dut IS
    GENERIC (
        bit_width : integer := 64
    );
    PORT( clk                               :   IN    std_logic;  -- ufix1
        reset                             :   IN    std_logic;  -- ufix1
        stream_en                         :   IN    std_logic;  -- ufix1
        wr_src_sel                        :   IN    std_logic_vector(1 DOWNTO 0);  -- ufix2
        wr_cnt_max                        :   IN    std_logic_vector(15 DOWNTO 0);  -- ufix16
        data_in                           :   IN    std_logic_vector(bit_width - 1 DOWNTO 0);  -- ufix64
        data_vld                          :   IN    std_logic;  -- ufix1
        src_strobe                        :   OUT   std_logic;  -- ufix1
        src_out                           :   OUT   std_logic_vector(bit_width - 1 DOWNTO 0);  -- ufix64
        rd_src_sel                        :   OUT   std_logic_vector(1 DOWNTO 0);  -- ufix2
        rd_cnt_max                        :   OUT   std_logic_vector(15 DOWNTO 0)  -- ufix16
        );
END axi_lite_sdrramp_src_pcore_dut;


ARCHITECTURE rtl OF axi_lite_sdrramp_src_pcore_dut IS

  -- Component Declarations
  COMPONENT axi_lite_sdrramp_src
    GENERIC (
        bit_width : integer := 64
    );
    PORT( clk                             :   IN    std_logic;  -- ufix1
          reset                           :   IN    std_logic;  -- ufix1
          stream_en                       :   IN    std_logic;  -- ufix1
          wr_src_sel                      :   IN    std_logic_vector(1 DOWNTO 0);  -- ufix2
          wr_cnt_max                      :   IN    std_logic_vector(15 DOWNTO 0);  -- ufix16
          data_in                         :   IN    std_logic_vector(bit_width - 1 DOWNTO 0);  -- ufix64
          data_vld                        :   IN    std_logic;  -- ufix1
          src_strobe                      :   OUT   std_logic;  -- ufix1
          src_out                         :   OUT   std_logic_vector(bit_width - 1 DOWNTO 0);  -- ufix64
          rd_src_sel                      :   OUT   std_logic_vector(1 DOWNTO 0);  -- ufix2
          rd_cnt_max                      :   OUT   std_logic_vector(15 DOWNTO 0)  -- ufix16
          );
  END COMPONENT;

  -- Component Configuration Statements
  FOR ALL : axi_lite_sdrramp_src
    USE ENTITY work.axi_lite_sdrramp_src(rtl);

  -- Signals
  SIGNAL clk_sig                          : std_logic;  -- ufix1
  SIGNAL reset_sig                        : std_logic;  -- ufix1
  SIGNAL stream_en_sig                    : std_logic;  -- ufix1
  SIGNAL data_vld_sig                     : std_logic;  -- ufix1
  SIGNAL src_strobe_sig                   : std_logic;  -- ufix1
  SIGNAL src_out_sig                      : std_logic_vector(bit_width - 1 DOWNTO 0);  -- ufix64
  SIGNAL rd_src_sel_sig                   : std_logic_vector(1 DOWNTO 0);  -- ufix2
  SIGNAL rd_cnt_max_sig                   : std_logic_vector(15 DOWNTO 0);  -- ufix16

BEGIN
  u_axi_lite_sdrramp_src : axi_lite_sdrramp_src
    GENERIC MAP(
        bit_width => bit_width
    )
    PORT MAP( clk => clk_sig,  -- ufix1
              reset => reset_sig,  -- ufix1
              stream_en => stream_en_sig,  -- ufix1
              wr_src_sel => wr_src_sel,  -- ufix2
              wr_cnt_max => wr_cnt_max,  -- ufix16
              data_in => data_in,  -- ufix64
              data_vld => data_vld_sig,  -- ufix1
              src_strobe => src_strobe_sig,  -- ufix1
              src_out => src_out_sig,  -- ufix64
              rd_src_sel => rd_src_sel_sig,  -- ufix2
              rd_cnt_max => rd_cnt_max_sig  -- ufix16
              );

  clk_sig <= clk;

  reset_sig <= reset;

  stream_en_sig <= stream_en;

  data_vld_sig <= data_vld;

  src_strobe <= src_strobe_sig;

  src_out <= src_out_sig;

  rd_src_sel <= rd_src_sel_sig;

  rd_cnt_max <= rd_cnt_max_sig;

END rtl;

