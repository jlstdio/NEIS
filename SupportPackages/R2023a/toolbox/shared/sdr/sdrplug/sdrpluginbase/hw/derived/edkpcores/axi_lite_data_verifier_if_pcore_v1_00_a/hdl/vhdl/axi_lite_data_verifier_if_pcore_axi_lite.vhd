-- -------------------------------------------------------------
-- 
-- File Name: hdl_prj/hdlsrc/axi_lite_data_verifier_if/axi_lite_data_verifier_if_pcore_axi_lite.vhd
-- Created: 2015-02-10 12:42:51
-- 
-- Generated by MATLAB 8.5 and HDL Coder 3.6
-- 
-- -------------------------------------------------------------


-- -------------------------------------------------------------
-- 
-- Module: axi_lite_data_verifier_if_pcore_axi_lite
-- Source Path: axi_lite_data_verifier_if_pcore/axi_lite_data_verifier_if_pcore_axi_lite
-- Hierarchy Level: 1
-- 
-- -------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY axi_lite_data_verifier_if_pcore_axi_lite IS
  PORT( axi_rst                           :   IN    std_logic;
        AXI4_Lite_ACLK                    :   IN    std_logic;  -- ufix1
        AXI4_Lite_ARESETN                 :   IN    std_logic;  -- ufix1
        AXI4_Lite_AWADDR                  :   IN    std_logic_vector(15 DOWNTO 0);  -- ufix16
        AXI4_Lite_AWVALID                 :   IN    std_logic;  -- ufix1
        AXI4_Lite_WDATA                   :   IN    std_logic_vector(31 DOWNTO 0);  -- ufix32
        AXI4_Lite_WSTRB                   :   IN    std_logic_vector(3 DOWNTO 0);  -- ufix4
        AXI4_Lite_WVALID                  :   IN    std_logic;  -- ufix1
        AXI4_Lite_BREADY                  :   IN    std_logic;  -- ufix1
        AXI4_Lite_ARADDR                  :   IN    std_logic_vector(15 DOWNTO 0);  -- ufix16
        AXI4_Lite_ARVALID                 :   IN    std_logic;  -- ufix1
        AXI4_Lite_RREADY                  :   IN    std_logic;  -- ufix1
        read_rd_count_reg                 :   IN    std_logic_vector(31 DOWNTO 0);  -- ufix32
        read_rd_status_reg                :   IN    std_logic_vector(31 DOWNTO 0);  -- ufix32
        read_ch1_0                        :   IN    std_logic_vector(31 DOWNTO 0);  -- ufix32
        read_ch1_1                        :   IN    std_logic_vector(31 DOWNTO 0);  -- ufix32
        read_ch1_2                        :   IN    std_logic_vector(31 DOWNTO 0);  -- ufix32
        read_ch1_3                        :   IN    std_logic_vector(31 DOWNTO 0);  -- ufix32
        read_ch1_4                        :   IN    std_logic_vector(31 DOWNTO 0);  -- ufix32
        read_ch2_0                        :   IN    std_logic_vector(31 DOWNTO 0);  -- ufix32
        read_ch2_1                        :   IN    std_logic_vector(31 DOWNTO 0);  -- ufix32
        read_ch2_2                        :   IN    std_logic_vector(31 DOWNTO 0);  -- ufix32
        read_ch2_3                        :   IN    std_logic_vector(31 DOWNTO 0);  -- ufix32
        read_ch2_4                        :   IN    std_logic_vector(31 DOWNTO 0);  -- ufix32
        read_rd_cntmax                    :   IN    std_logic_vector(15 DOWNTO 0);  -- ufix16
        AXI4_Lite_AWREADY                 :   OUT   std_logic;  -- ufix1
        AXI4_Lite_WREADY                  :   OUT   std_logic;  -- ufix1
        AXI4_Lite_BRESP                   :   OUT   std_logic_vector(1 DOWNTO 0);  -- ufix2
        AXI4_Lite_BVALID                  :   OUT   std_logic;  -- ufix1
        AXI4_Lite_ARREADY                 :   OUT   std_logic;  -- ufix1
        AXI4_Lite_RDATA                   :   OUT   std_logic_vector(31 DOWNTO 0);  -- ufix32
        AXI4_Lite_RRESP                   :   OUT   std_logic_vector(1 DOWNTO 0);  -- ufix2
        AXI4_Lite_RVALID                  :   OUT   std_logic;  -- ufix1
        write_wr_rst_reg                  :   OUT   std_logic_vector(31 DOWNTO 0);  -- ufix32
        write_wr_cntmax                   :   OUT   std_logic_vector(15 DOWNTO 0);  -- ufix16
        reset_internal                    :   OUT   std_logic  -- ufix1
        );
END axi_lite_data_verifier_if_pcore_axi_lite;


ARCHITECTURE rtl OF axi_lite_data_verifier_if_pcore_axi_lite IS

  -- Component Declarations
  COMPONENT axi_lite_data_verifier_if_pcore_addr_decoder
    PORT( axi_clk                         :   IN    std_logic;  -- ufix1
          axi_rst                         :   IN    std_logic;
          data_write                      :   IN    std_logic_vector(31 DOWNTO 0);  -- ufix32
          addr_sel                        :   IN    std_logic_vector(13 DOWNTO 0);  -- ufix14
          wr_enb                          :   IN    std_logic;  -- ufix1
          rd_enb                          :   IN    std_logic;  -- ufix1
          read_rd_count_reg               :   IN    std_logic_vector(31 DOWNTO 0);  -- ufix32
          read_rd_status_reg              :   IN    std_logic_vector(31 DOWNTO 0);  -- ufix32
          read_ch1_0                      :   IN    std_logic_vector(31 DOWNTO 0);  -- ufix32
          read_ch1_1                      :   IN    std_logic_vector(31 DOWNTO 0);  -- ufix32
          read_ch1_2                      :   IN    std_logic_vector(31 DOWNTO 0);  -- ufix32
          read_ch1_3                      :   IN    std_logic_vector(31 DOWNTO 0);  -- ufix32
          read_ch1_4                      :   IN    std_logic_vector(31 DOWNTO 0);  -- ufix32
          read_ch2_0                      :   IN    std_logic_vector(31 DOWNTO 0);  -- ufix32
          read_ch2_1                      :   IN    std_logic_vector(31 DOWNTO 0);  -- ufix32
          read_ch2_2                      :   IN    std_logic_vector(31 DOWNTO 0);  -- ufix32
          read_ch2_3                      :   IN    std_logic_vector(31 DOWNTO 0);  -- ufix32
          read_ch2_4                      :   IN    std_logic_vector(31 DOWNTO 0);  -- ufix32
          read_rd_cntmax                  :   IN    std_logic_vector(15 DOWNTO 0);  -- ufix16
          data_read                       :   OUT   std_logic_vector(31 DOWNTO 0);  -- ufix32
          write_wr_rst_reg                :   OUT   std_logic_vector(31 DOWNTO 0);  -- ufix32
          write_wr_cntmax                 :   OUT   std_logic_vector(15 DOWNTO 0)  -- ufix16
          );
  END COMPONENT;

  COMPONENT axi_lite_data_verifier_if_pcore_axi_lite_module
    PORT( axi_clk                         :   IN    std_logic;  -- ufix1
          AXI4_Lite_ARESETN               :   IN    std_logic;  -- ufix1
          AXI4_Lite_AWADDR                :   IN    std_logic_vector(15 DOWNTO 0);  -- ufix16
          AXI4_Lite_AWVALID               :   IN    std_logic;  -- ufix1
          AXI4_Lite_WDATA                 :   IN    std_logic_vector(31 DOWNTO 0);  -- ufix32
          AXI4_Lite_WSTRB                 :   IN    std_logic_vector(3 DOWNTO 0);  -- ufix4
          AXI4_Lite_WVALID                :   IN    std_logic;  -- ufix1
          AXI4_Lite_BREADY                :   IN    std_logic;  -- ufix1
          AXI4_Lite_ARADDR                :   IN    std_logic_vector(15 DOWNTO 0);  -- ufix16
          AXI4_Lite_ARVALID               :   IN    std_logic;  -- ufix1
          AXI4_Lite_RREADY                :   IN    std_logic;  -- ufix1
          data_read                       :   IN    std_logic_vector(31 DOWNTO 0);  -- ufix32
          AXI4_Lite_AWREADY               :   OUT   std_logic;  -- ufix1
          AXI4_Lite_WREADY                :   OUT   std_logic;  -- ufix1
          AXI4_Lite_BRESP                 :   OUT   std_logic_vector(1 DOWNTO 0);  -- ufix2
          AXI4_Lite_BVALID                :   OUT   std_logic;  -- ufix1
          AXI4_Lite_ARREADY               :   OUT   std_logic;  -- ufix1
          AXI4_Lite_RDATA                 :   OUT   std_logic_vector(31 DOWNTO 0);  -- ufix32
          AXI4_Lite_RRESP                 :   OUT   std_logic_vector(1 DOWNTO 0);  -- ufix2
          AXI4_Lite_RVALID                :   OUT   std_logic;  -- ufix1
          data_write                      :   OUT   std_logic_vector(31 DOWNTO 0);  -- ufix32
          addr_sel                        :   OUT   std_logic_vector(13 DOWNTO 0);  -- ufix14
          wr_enb                          :   OUT   std_logic;  -- ufix1
          rd_enb                          :   OUT   std_logic;  -- ufix1
          reset_internal                  :   OUT   std_logic  -- ufix1
          );
  END COMPONENT;

  -- Component Configuration Statements
  FOR ALL : axi_lite_data_verifier_if_pcore_addr_decoder
    USE ENTITY work.axi_lite_data_verifier_if_pcore_addr_decoder(rtl);

  FOR ALL : axi_lite_data_verifier_if_pcore_axi_lite_module
    USE ENTITY work.axi_lite_data_verifier_if_pcore_axi_lite_module(rtl);

  -- Signals
  SIGNAL top_data_write                   : std_logic_vector(31 DOWNTO 0);  -- ufix32
  SIGNAL top_addr_sel                     : std_logic_vector(13 DOWNTO 0);  -- ufix14
  SIGNAL top_wr_enb                       : std_logic;  -- ufix1
  SIGNAL top_rd_enb                       : std_logic;  -- ufix1
  SIGNAL top_data_read                    : std_logic_vector(31 DOWNTO 0);  -- ufix32
  SIGNAL write_wr_rst_reg_tmp             : std_logic_vector(31 DOWNTO 0);  -- ufix32
  SIGNAL write_wr_cntmax_tmp              : std_logic_vector(15 DOWNTO 0);  -- ufix16
  SIGNAL AXI4_Lite_BRESP_tmp              : std_logic_vector(1 DOWNTO 0);  -- ufix2
  SIGNAL AXI4_Lite_RDATA_tmp              : std_logic_vector(31 DOWNTO 0);  -- ufix32
  SIGNAL AXI4_Lite_RRESP_tmp              : std_logic_vector(1 DOWNTO 0);  -- ufix2
  SIGNAL top_reset_internal               : std_logic;  -- ufix1

BEGIN
  u_axi_lite_data_verifier_if_pcore_addr_decoder_inst : axi_lite_data_verifier_if_pcore_addr_decoder
    PORT MAP( axi_clk => AXI4_Lite_ACLK,  -- ufix1
              axi_rst => axi_rst,
              data_write => top_data_write,  -- ufix32
              addr_sel => top_addr_sel,  -- ufix14
              wr_enb => top_wr_enb,  -- ufix1
              rd_enb => top_rd_enb,  -- ufix1
              read_rd_count_reg => read_rd_count_reg,  -- ufix32
              read_rd_status_reg => read_rd_status_reg,  -- ufix32
              read_ch1_0 => read_ch1_0,  -- ufix32
              read_ch1_1 => read_ch1_1,  -- ufix32
              read_ch1_2 => read_ch1_2,  -- ufix32
              read_ch1_3 => read_ch1_3,  -- ufix32
              read_ch1_4 => read_ch1_4,  -- ufix32
              read_ch2_0 => read_ch2_0,  -- ufix32
              read_ch2_1 => read_ch2_1,  -- ufix32
              read_ch2_2 => read_ch2_2,  -- ufix32
              read_ch2_3 => read_ch2_3,  -- ufix32
              read_ch2_4 => read_ch2_4,  -- ufix32
              read_rd_cntmax => read_rd_cntmax,  -- ufix16
              data_read => top_data_read,  -- ufix32
              write_wr_rst_reg => write_wr_rst_reg_tmp,  -- ufix32
              write_wr_cntmax => write_wr_cntmax_tmp  -- ufix16
              );

  u_axi_lite_data_verifier_if_pcore_axi_lite_module_inst : axi_lite_data_verifier_if_pcore_axi_lite_module
    PORT MAP( axi_clk => AXI4_Lite_ACLK,  -- ufix1
              AXI4_Lite_ARESETN => AXI4_Lite_ARESETN,  -- ufix1
              AXI4_Lite_AWADDR => AXI4_Lite_AWADDR,  -- ufix16
              AXI4_Lite_AWVALID => AXI4_Lite_AWVALID,  -- ufix1
              AXI4_Lite_WDATA => AXI4_Lite_WDATA,  -- ufix32
              AXI4_Lite_WSTRB => AXI4_Lite_WSTRB,  -- ufix4
              AXI4_Lite_WVALID => AXI4_Lite_WVALID,  -- ufix1
              AXI4_Lite_BREADY => AXI4_Lite_BREADY,  -- ufix1
              AXI4_Lite_ARADDR => AXI4_Lite_ARADDR,  -- ufix16
              AXI4_Lite_ARVALID => AXI4_Lite_ARVALID,  -- ufix1
              AXI4_Lite_RREADY => AXI4_Lite_RREADY,  -- ufix1
              data_read => top_data_read,  -- ufix32
              AXI4_Lite_AWREADY => AXI4_Lite_AWREADY,  -- ufix1
              AXI4_Lite_WREADY => AXI4_Lite_WREADY,  -- ufix1
              AXI4_Lite_BRESP => AXI4_Lite_BRESP_tmp,  -- ufix2
              AXI4_Lite_BVALID => AXI4_Lite_BVALID,  -- ufix1
              AXI4_Lite_ARREADY => AXI4_Lite_ARREADY,  -- ufix1
              AXI4_Lite_RDATA => AXI4_Lite_RDATA_tmp,  -- ufix32
              AXI4_Lite_RRESP => AXI4_Lite_RRESP_tmp,  -- ufix2
              AXI4_Lite_RVALID => AXI4_Lite_RVALID,  -- ufix1
              data_write => top_data_write,  -- ufix32
              addr_sel => top_addr_sel,  -- ufix14
              wr_enb => top_wr_enb,  -- ufix1
              rd_enb => top_rd_enb,  -- ufix1
              reset_internal => top_reset_internal  -- ufix1
              );

  reset_internal <= top_reset_internal;

  AXI4_Lite_BRESP <= AXI4_Lite_BRESP_tmp;

  AXI4_Lite_RDATA <= AXI4_Lite_RDATA_tmp;

  AXI4_Lite_RRESP <= AXI4_Lite_RRESP_tmp;

  write_wr_rst_reg <= write_wr_rst_reg_tmp;

  write_wr_cntmax <= write_wr_cntmax_tmp;

END rtl;
