-- -------------------------------------------------------------
-- 
-- File Name: hdl_prj/hdlsrc/axi_lite_data_packer/axi_lite_data_packer_pcore_dut.vhd
-- Created: 2015-01-15 09:20:40
-- 
-- Generated by MATLAB 8.5 and HDL Coder 3.6
-- 
-- -------------------------------------------------------------


-- -------------------------------------------------------------
-- 
-- Module: axi_lite_data_packer_pcore_dut
-- Source Path: axi_lite_data_packer_pcore/axi_lite_data_packer_pcore_dut
-- Hierarchy Level: 1
-- 
-- -------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY axi_lite_data_packer_pcore_dut IS
    GENERIC(
        bit_width : integer := 64
    );
    PORT( 
        clk                               :   IN    std_logic;  -- ufix1
        rst                               :   IN    std_logic;  -- ufix1
        s_axis_tvalid                     :   IN    std_logic;  -- ufix1
        s_axis_tdata                      :   IN    std_logic_vector(bit_width - 1 DOWNTO 0);  -- ufix64
        wr_sel                            :   IN    std_logic_vector(3 DOWNTO 0);  -- ufix2
        m_axis_tvalid                     :   OUT   std_logic;  -- ufix1
        m_axis_tdata                      :   OUT   std_logic_vector(bit_width - 1 DOWNTO 0);  -- ufix64
        ch_sel                            :   OUT   std_logic_vector(3 DOWNTO 0);  -- ufix2
        rd_sel                            :   OUT   std_logic_vector(3 DOWNTO 0)  -- ufix2
        );
END axi_lite_data_packer_pcore_dut;


ARCHITECTURE rtl OF axi_lite_data_packer_pcore_dut IS

  -- Component Declarations
  COMPONENT dataPacker
    GENERIC(
        bit_width : integer := 64
    );
    PORT( clk                             :   IN    std_logic;  -- ufix1
          rst                             :   IN    std_logic;  -- ufix1
          s_axis_tvalid                   :   IN    std_logic;  -- ufix1
          s_axis_tdata                    :   IN    std_logic_vector(bit_width - 1 DOWNTO 0);  -- ufix64
          wr_sel                          :   IN    std_logic_vector(3 DOWNTO 0);  -- ufix2
          m_axis_tvalid                   :   OUT   std_logic;  -- ufix1
          m_axis_tdata                    :   OUT   std_logic_vector(bit_width - 1 DOWNTO 0);  -- ufix64
          ch_sel                          :   OUT   std_logic_vector(3 DOWNTO 0);  -- ufix2
          rd_sel                          :   OUT   std_logic_vector(3 DOWNTO 0)  -- ufix2
          );
  END COMPONENT;

  -- Component Configuration Statements
  FOR ALL : dataPacker
    USE ENTITY work.dataPacker(rtl);

  -- Signals
  SIGNAL clk_sig                          : std_logic;  -- ufix1
  SIGNAL rst_sig                          : std_logic;  -- ufix1
  SIGNAL s_axis_tvalid_sig                : std_logic;  -- ufix1
  SIGNAL m_axis_tvalid_sig                : std_logic;  -- ufix1
  SIGNAL m_axis_tdata_sig                 : std_logic_vector(bit_width - 1 DOWNTO 0);  -- ufix64
  SIGNAL ch_sel_sig                       : std_logic_vector(3 DOWNTO 0);  -- ufix2
  SIGNAL rd_sel_sig                       : std_logic_vector(3 DOWNTO 0);  -- ufix2

BEGIN
  u_dataPacker : dataPacker
    GENERIC MAP(
        bit_width => bit_width
    )
    PORT MAP( clk => clk_sig,  -- ufix1
              rst => rst_sig,  -- ufix1
              s_axis_tvalid => s_axis_tvalid_sig,  -- ufix1
              s_axis_tdata => s_axis_tdata,  -- ufix64
              wr_sel => wr_sel,  -- ufix2
              m_axis_tvalid => m_axis_tvalid_sig,  -- ufix1
              m_axis_tdata => m_axis_tdata_sig,  -- ufix64
              ch_sel => ch_sel_sig,  -- ufix2
              rd_sel => rd_sel_sig  -- ufix2
              );

  clk_sig <= clk;

  rst_sig <= rst;

  s_axis_tvalid_sig <= s_axis_tvalid;

  m_axis_tvalid <= m_axis_tvalid_sig;

  m_axis_tdata <= m_axis_tdata_sig;

  ch_sel <= ch_sel_sig;

  rd_sel <= rd_sel_sig;

END rtl;

