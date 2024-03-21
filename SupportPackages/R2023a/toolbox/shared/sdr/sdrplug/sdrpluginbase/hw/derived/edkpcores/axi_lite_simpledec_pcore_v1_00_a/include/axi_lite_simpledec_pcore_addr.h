/*
 * File Name:         hdl_prj\ipcore\axi_lite_simpledec_pcore_v1_00_a\include\axi_lite_simpledec_pcore_addr.h
 * Description:       C Header File
 * Created:           2013-07-31 16:42:14
 */

#ifndef AXI_LITE_SIMPLEDEC_PCORE_H_
#define AXI_LITE_SIMPLEDEC_PCORE_H_

#define  IPCore_Reset_axi_lite_simpledec_pcore        0x0  //write 0x1 to bit 0 to reset IP core
#define  IPCore_Enable_axi_lite_simpledec_pcore       0x4  //enabled (by default) when bit 0 is 0x1
#define  wr_decFactor_Data_axi_lite_simpledec_pcore   0x100  //data register for port wr_decFactor
#define  rd_decFactor_Data_axi_lite_simpledec_pcore   0x104  //data register for port rd_decFactor

#endif /* AXI_LITE_SIMPLEDEC_PCORE_H_ */
