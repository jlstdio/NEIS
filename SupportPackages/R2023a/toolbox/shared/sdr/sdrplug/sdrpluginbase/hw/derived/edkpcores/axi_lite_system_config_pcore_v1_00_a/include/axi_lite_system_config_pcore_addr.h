/*
 * File Name:         hdl_prj\ipcore\axi_lite_system_config_pcore_v1_00_a\include\axi_lite_system_config_pcore_addr.h
 * Description:       C Header File
 * Created:           2014-01-29 22:33:38
*/

#ifndef AXI_LITE_SYSTEM_CONFIG_PCORE_H_
#define AXI_LITE_SYSTEM_CONFIG_PCORE_H_

#define  IPCore_Reset_axi_lite_system_config_pcore               0x0  //write 0x1 to bit 0 to reset IP core
#define  IPCore_Enable_axi_lite_system_config_pcore              0x4  //enabled (by default) when bit 0 is 0x1
#define  rd_ver_reg_Data_axi_lite_system_config_pcore            0x100  //data register for port rd_ver_reg
#define  rd_hwinfo1_reg_Data_axi_lite_system_config_pcore        0x104  //data register for port rd_hwinfo1_reg
#define  rd_hwinfo2_reg_Data_axi_lite_system_config_pcore        0x108  //data register for port rd_hwinfo2_reg
#define  rd_hwinfo3_reg_Data_axi_lite_system_config_pcore        0x10C  //data register for port rd_hwinfo3_reg
#define  rd_hwinfo4_reg_Data_axi_lite_system_config_pcore        0x110  //data register for port rd_hwinfo4_reg
#define  rd_hwinfo5_reg_Data_axi_lite_system_config_pcore        0x114  //data register for port rd_hwinfo5_reg
#define  rd_hwinfo6_reg_Data_axi_lite_system_config_pcore        0x118  //data register for port rd_hwinfo6_reg
#define  rd_hwinfo7_reg_Data_axi_lite_system_config_pcore        0x11C  //data register for port rd_hwinfo7_reg
#define  rd_hwinfo8_reg_Data_axi_lite_system_config_pcore        0x120  //data register for port rd_hwinfo8_reg
#define  wr_sysrst_reg_Data_axi_lite_system_config_pcore         0x124  //data register for port wr_sysrst_reg
#define  wr_rxstrmenb_reg_Data_axi_lite_system_config_pcore      0x128  //data register for port wr_rxstrmenb_reg
#define  rd_rxstrmenb_reg_Data_axi_lite_system_config_pcore      0x12C  //data register for port rd_rxstrmenb_reg
#define  wr_rst_reg_Data_axi_lite_system_config_pcore            0x130  //data register for port wr_rst_reg
#define  wr_rx_data_src_path_Data_axi_lite_system_config_pcore   0x134  //data register for port wr_rx_data_src_path
#define  rd_rx_data_src_path_Data_axi_lite_system_config_pcore   0x138  //data register for port rd_rx_data_src_path
#define  wr_txstrmenb_reg_Data_axi_lite_system_config_pcore      0x13C  //data register for port wr_txstrmenb_reg
#define  rd_txstrmenb_reg_Data_axi_lite_system_config_pcore      0x140  //data register for port rd_txstrmenb_reg
#define  wr_tx_data_src_path_Data_axi_lite_system_config_pcore   0x144  //data register for port wr_tx_data_src_path
#define  rd_tx_data_src_path_Data_axi_lite_system_config_pcore   0x148  //data register for port rd_tx_data_src_path

#endif /* AXI_LITE_SYSTEM_CONFIG_PCORE_H_ */
