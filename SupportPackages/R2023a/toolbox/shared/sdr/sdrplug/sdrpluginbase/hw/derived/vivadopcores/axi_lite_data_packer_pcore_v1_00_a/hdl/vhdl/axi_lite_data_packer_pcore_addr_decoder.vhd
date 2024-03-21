-- -------------------------------------------------------------
-- 
-- File Name: hdl_prj/hdlsrc/axi_lite_data_packer/axi_lite_data_packer_pcore_addr_decoder.vhd
-- Created: 2015-01-15 09:20:40
-- 
-- Generated by MATLAB 8.5 and HDL Coder 3.6
-- 
-- -------------------------------------------------------------


-- -------------------------------------------------------------
-- 
-- Module: axi_lite_data_packer_pcore_addr_decoder
-- Source Path: axi_lite_data_packer_pcore/axi_lite_data_packer_pcore_axi_lite/axi_lite_data_packer_pcore_addr_decoder
-- Hierarchy Level: 2
-- 
-- -------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY axi_lite_data_packer_pcore_addr_decoder IS
  PORT( clk_in                            :   IN    std_logic;
        reset                             :   IN    std_logic;
        data_write                        :   IN    std_logic_vector(31 DOWNTO 0);  -- ufix32
        addr_sel                          :   IN    std_logic_vector(13 DOWNTO 0);  -- ufix14
        wr_enb                            :   IN    std_logic;  -- ufix1
        rd_enb                            :   IN    std_logic;  -- ufix1
        read_rd_sel                       :   IN    std_logic_vector(3 DOWNTO 0);  -- ufix2
        data_read                         :   OUT   std_logic_vector(31 DOWNTO 0);  -- ufix32
        write_wr_sel                      :   OUT   std_logic_vector(3 DOWNTO 0)  -- ufix2
        );
END axi_lite_data_packer_pcore_addr_decoder;


ARCHITECTURE rtl OF axi_lite_data_packer_pcore_addr_decoder IS

  -- Signals
  SIGNAL enb                              : std_logic;
  SIGNAL addr_sel_unsigned                : unsigned(13 DOWNTO 0);  -- ufix14
  SIGNAL decode_sel_rd_sel                : std_logic;  -- ufix1
  SIGNAL read_rd_sel_unsigned             : unsigned(3 DOWNTO 0);  -- ufix2
  SIGNAL const_1                          : std_logic;  -- ufix1
  SIGNAL const_0                          : unsigned(31 DOWNTO 0);  -- ufix32
  SIGNAL read_reg_rd_sel                  : unsigned(3 DOWNTO 0);  -- ufix2
  SIGNAL data_in_rd_sel                   : unsigned(31 DOWNTO 0);  -- ufix32
  SIGNAL decode_rd_rd_sel                 : unsigned(31 DOWNTO 0);  -- ufix32
  SIGNAL data_write_unsigned              : unsigned(31 DOWNTO 0);  -- ufix32
  SIGNAL data_in_wr_sel                   : unsigned(3 DOWNTO 0);  -- ufix2
  SIGNAL decode_sel_wr_sel                : std_logic;  -- ufix1
  SIGNAL reg_enb_wr_sel                   : std_logic;  -- ufix1
  SIGNAL write_reg_wr_sel                 : unsigned(3 DOWNTO 0);  -- ufix2

BEGIN
  addr_sel_unsigned <= unsigned(addr_sel);

  
  decode_sel_rd_sel <= '1' WHEN addr_sel_unsigned = to_unsigned(16#0041#, 14) ELSE
      '0';

  read_rd_sel_unsigned <= unsigned(read_rd_sel);

  const_1 <= '1';

  enb <= const_1;

  const_0 <= to_unsigned(0, 32);

  reg_rd_sel_process : PROCESS (clk_in, reset)
  BEGIN
    IF reset = '1' THEN
      read_reg_rd_sel <= to_unsigned(16#0#, 4);
    ELSIF clk_in'EVENT AND clk_in = '1' THEN
      IF enb = '1' THEN
        read_reg_rd_sel <= read_rd_sel_unsigned;
      END IF;
    END IF;
  END PROCESS reg_rd_sel_process;


  data_in_rd_sel <= resize(read_reg_rd_sel, 32);

  
  decode_rd_rd_sel <= const_0 WHEN decode_sel_rd_sel = '0' ELSE
      data_in_rd_sel;

  data_read <= std_logic_vector(decode_rd_rd_sel);

  data_write_unsigned <= unsigned(data_write);

  data_in_wr_sel <= data_write_unsigned(3 DOWNTO 0);

  
  decode_sel_wr_sel <= '1' WHEN addr_sel_unsigned = to_unsigned(16#0040#, 14) ELSE
      '0';

  reg_enb_wr_sel <= decode_sel_wr_sel AND wr_enb;

  reg_wr_sel_process : PROCESS (clk_in, reset)
  BEGIN
    IF reset = '1' THEN
      write_reg_wr_sel <= to_unsigned(16#0#, 4);
    ELSIF clk_in'EVENT AND clk_in = '1' THEN
      IF enb = '1' AND reg_enb_wr_sel = '1' THEN
        write_reg_wr_sel <= data_in_wr_sel;
      END IF;
    END IF;
  END PROCESS reg_wr_sel_process;


  write_wr_sel <= std_logic_vector(write_reg_wr_sel);

END rtl;

