/*
 * File Name:         hdl_prj\ipcore\axi_lite_nco_pcore_v1_00_a\include\axi_lite_nco_pcore_addr.h
 * Description:       C Header File
 * Created:           2014-01-21 14:11:11
*/

#ifndef AXI_LITE_NCO_PCORE_H_
#define AXI_LITE_NCO_PCORE_H_

#define  IPCore_Reset_axi_lite_nco_pcore       0x0  //write 0x1 to bit 0 to reset IP core
#define  IPCore_Enable_axi_lite_nco_pcore      0x4  //enabled (by default) when bit 0 is 0x1
#define  wr_NCOinc_Data_axi_lite_nco_pcore     0x100  //data register for port wr_NCOinc
#define  rd_NCOinc_Data_axi_lite_nco_pcore     0x104  //data register for port rd_NCOinc
#define  wr_debugNCO_Data_axi_lite_nco_pcore   0x108  //data register for port wr_debugNCO
#define  rd_debugNCO_Data_axi_lite_nco_pcore   0x10C  //data register for port rd_debugNCO

#endif /* AXI_LITE_NCO_PCORE_H_ */
