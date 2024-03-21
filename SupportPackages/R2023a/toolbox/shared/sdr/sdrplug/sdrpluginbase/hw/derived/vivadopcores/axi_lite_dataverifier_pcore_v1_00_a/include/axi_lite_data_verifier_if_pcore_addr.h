/*
 * File Name:         hdl_prj/ipcore/axi_lite_data_verifier_if_pcore_v1_0/include/axi_lite_data_verifier_if_pcore_addr.h
 * Description:       C Header File
 * Created:           2015-02-10 12:42:51
*/

#ifndef AXI_LITE_DATA_VERIFIER_IF_PCORE_H_
#define AXI_LITE_DATA_VERIFIER_IF_PCORE_H_

#define  IPCore_Reset_axi_lite_data_verifier_if_pcore         0x0  //write 0x1 to bit 0 to reset IP core
#define  IPCore_Enable_axi_lite_data_verifier_if_pcore        0x4  //enabled (by default) when bit 0 is 0x1
#define  wr_rst_reg_Data_axi_lite_data_verifier_if_pcore      0x100  //data register for port wr_rst_reg
#define  rd_count_reg_Data_axi_lite_data_verifier_if_pcore    0x104  //data register for port rd_count_reg
#define  rd_status_reg_Data_axi_lite_data_verifier_if_pcore   0x108  //data register for port rd_status_reg
#define  ch1_0_Data_axi_lite_data_verifier_if_pcore           0x10C  //data register for port ch1_0
#define  ch1_1_Data_axi_lite_data_verifier_if_pcore           0x110  //data register for port ch1_1
#define  ch1_2_Data_axi_lite_data_verifier_if_pcore           0x114  //data register for port ch1_2
#define  ch1_3_Data_axi_lite_data_verifier_if_pcore           0x118  //data register for port ch1_3
#define  ch1_4_Data_axi_lite_data_verifier_if_pcore           0x11C  //data register for port ch1_4
#define  ch2_0_Data_axi_lite_data_verifier_if_pcore           0x120  //data register for port ch2_0
#define  ch2_1_Data_axi_lite_data_verifier_if_pcore           0x124  //data register for port ch2_1
#define  ch2_2_Data_axi_lite_data_verifier_if_pcore           0x128  //data register for port ch2_2
#define  ch2_3_Data_axi_lite_data_verifier_if_pcore           0x12C  //data register for port ch2_3
#define  ch2_4_Data_axi_lite_data_verifier_if_pcore           0x130  //data register for port ch2_4
#define  wr_cntmax_Data_axi_lite_data_verifier_if_pcore       0x134  //data register for port wr_cntmax
#define  rd_cntmax_Data_axi_lite_data_verifier_if_pcore       0x138  //data register for port rd_cntmax

#endif /* AXI_LITE_DATA_VERIFIER_IF_PCORE_H_ */
