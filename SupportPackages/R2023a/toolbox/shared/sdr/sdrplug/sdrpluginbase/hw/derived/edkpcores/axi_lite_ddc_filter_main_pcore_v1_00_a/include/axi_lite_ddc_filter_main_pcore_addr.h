/*
 * File Name:         hdl_prj\ipcore\axi_lite_ddc_filter_main_pcore_v1_00_a\include\axi_lite_ddc_filter_main_pcore_addr.h
 * Description:       C Header File
 * Created:           2013-07-31 17:17:07
 */

#ifndef AXI_LITE_DDC_FILTER_MAIN_PCORE_H_
#define AXI_LITE_DDC_FILTER_MAIN_PCORE_H_

#define  IPCore_Reset_axi_lite_ddc_filter_main_pcore          0x0  //write 0x1 to bit 0 to reset IP core
#define  IPCore_Enable_axi_lite_ddc_filter_main_pcore         0x4  //enabled (by default) when bit 0 is 0x1
#define  wr_control_reg_Data_axi_lite_ddc_filter_main_pcore   0x100  //data register for port wr_control_reg
#define  rd_control_reg_Data_axi_lite_ddc_filter_main_pcore   0x104  //data register for port rd_control_reg

#endif /* AXI_LITE_DDC_FILTER_MAIN_PCORE_H_ */
