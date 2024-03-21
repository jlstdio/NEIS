/*
 * File Name:         hdl_prj\ipcore\axi_lite_sample_counter_pcore_v1_0\include\axi_lite_sample_counter_pcore_addr.h
 * Description:       C Header File
 * Created:           2014-07-29 08:51:09
*/

#ifndef AXI_LITE_SAMPLE_COUNTER_PCORE_H_
#define AXI_LITE_SAMPLE_COUNTER_PCORE_H_

#define  IPCore_Reset_axi_lite_sample_counter_pcore               0x0  //write 0x1 to bit 0 to reset IP core
#define  IPCore_Enable_axi_lite_sample_counter_pcore              0x4  //enabled (by default) when bit 0 is 0x1
#define  wr_samples_per_ring_Data_axi_lite_sample_counter_pcore   0x100  //data register for port wr_samples_per_ring
#define  wr_rst_reg_Data_axi_lite_sample_counter_pcore            0x104  //data register for port wr_rst_reg
#define  rd_samples_per_ring_Data_axi_lite_sample_counter_pcore   0x108  //data register for port rd_samples_per_ring
#define  rd_rst_reg_Data_axi_lite_sample_counter_pcore            0x10C  //data register for port rd_rst_reg

#endif /* AXI_LITE_SAMPLE_COUNTER_PCORE_H_ */
