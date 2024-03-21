/*
 * File Name:         hdl_prj/ipcore/axi_lite_data_packer_pcore_v1_0/include/axi_lite_data_packer_pcore_addr.h
 * Description:       C Header File
 * Created:           2015-01-15 09:20:41
*/

#ifndef AXI_LITE_DATA_PACKER_PCORE_H_
#define AXI_LITE_DATA_PACKER_PCORE_H_

#define  IPCore_Reset_axi_lite_data_packer_pcore    0x0  //write 0x1 to bit 0 to reset IP core
#define  IPCore_Enable_axi_lite_data_packer_pcore   0x4  //enabled (by default) when bit 0 is 0x1
#define  wr_sel_Data_axi_lite_data_packer_pcore     0x100  //data register for port wr_sel
#define  rd_sel_Data_axi_lite_data_packer_pcore     0x104  //data register for port rd_sel

#endif /* AXI_LITE_DATA_PACKER_PCORE_H_ */
