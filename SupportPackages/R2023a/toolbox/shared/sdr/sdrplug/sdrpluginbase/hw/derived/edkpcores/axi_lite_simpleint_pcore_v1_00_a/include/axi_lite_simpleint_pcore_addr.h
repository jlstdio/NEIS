/*
 * File Name:         hdl_prj\ipcore\axi_lite_simpleint_pcore_v1_00_a\include\axi_lite_simpleint_pcore_addr.h
 * Description:       C Header File
 * Created:           2013-09-23 14:44:28
*/

#ifndef AXI_LITE_SIMPLEINT_PCORE_H_
#define AXI_LITE_SIMPLEINT_PCORE_H_

#define  IPCore_Reset_axi_lite_simpleint_pcore        0x0  //write 0x1 to bit 0 to reset IP core
#define  IPCore_Enable_axi_lite_simpleint_pcore       0x4  //enabled (by default) when bit 0 is 0x1
#define  wr_intFactor_Data_axi_lite_simpleint_pcore   0x100  //data register for port wr_intFactor
#define  rd_intFactor_Data_axi_lite_simpleint_pcore   0x104  //data register for port rd_intFactor

#endif /* AXI_LITE_SIMPLEINT_PCORE_H_ */