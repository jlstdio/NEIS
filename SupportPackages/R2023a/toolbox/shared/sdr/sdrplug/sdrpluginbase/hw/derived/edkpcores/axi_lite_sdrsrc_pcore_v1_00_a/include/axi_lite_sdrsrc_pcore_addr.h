/*
 * File Name:         hdl_prj\ipcore\axi_lite_sdrsrc_pcore_v1_00_a\include\axi_lite_sdrsrc_pcore_addr.h
 * Description:       C Header File
 * Created:           2014-02-27 10:13:04
*/

#ifndef AXI_LITE_SDRSRC_PCORE_H_
#define AXI_LITE_SDRSRC_PCORE_H_

#define  IPCore_Reset_axi_lite_sdrsrc_pcore       0x0  //write 0x1 to bit 0 to reset IP core
#define  IPCore_Enable_axi_lite_sdrsrc_pcore      0x4  //enabled (by default) when bit 0 is 0x1
#define  wr_src_sel_Data_axi_lite_sdrsrc_pcore    0x100  //data register for port wr_src_sel
#define  wr_src_amp_Data_axi_lite_sdrsrc_pcore    0x104  //data register for port wr_src_amp
#define  wr_src_freq_Data_axi_lite_sdrsrc_pcore   0x108  //data register for port wr_src_freq
#define  rd_src_sel_Data_axi_lite_sdrsrc_pcore    0x10C  //data register for port rd_src_sel
#define  rd_src_amp_Data_axi_lite_sdrsrc_pcore    0x110  //data register for port rd_src_amp
#define  rd_src_freq_Data_axi_lite_sdrsrc_pcore   0x114  //data register for port rd_src_freq

#endif /* AXI_LITE_SDRSRC_PCORE_H_ */
