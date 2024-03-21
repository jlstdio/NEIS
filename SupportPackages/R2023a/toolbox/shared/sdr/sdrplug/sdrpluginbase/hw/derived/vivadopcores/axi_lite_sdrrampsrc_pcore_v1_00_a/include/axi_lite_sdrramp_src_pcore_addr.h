/*
 * File Name:         hdl_prj/ipcore/axi_lite_sdrramp_src__pcore_v1_0/include/axi_lite_sdrramp_src__pcore_addr.h
 * Description:       C Header File
 * Created:           2014-07-16 08:51:28
*/

#ifndef AXI_LITE_SDRRAMP_SRC__PCORE_H_
#define AXI_LITE_SDRRAMP_SRC__PCORE_H_

#define  IPCore_Reset_axi_lite_sdrramp_src__pcore      0x0  //write 0x1 to bit 0 to reset IP core
#define  IPCore_Enable_axi_lite_sdrramp_src__pcore     0x4  //enabled (by default) when bit 0 is 0x1
#define  wr_src_sel_Data_axi_lite_sdrramp_src__pcore   0x100  //data register for port wr_src_sel
#define  wr_cnt_max_Data_axi_lite_sdrramp_src__pcore   0x104  //data register for port wr_cnt_max
#define  rd_src_sel_Data_axi_lite_sdrramp_src__pcore   0x10C  //data register for port rd_src_sel
#define  rd_cnt_max_Data_axi_lite_sdrramp_src__pcore   0x110  //data register for port rd_cnt_max

#endif /* AXI_LITE_SDRRAMP_SRC__PCORE_H_ */
