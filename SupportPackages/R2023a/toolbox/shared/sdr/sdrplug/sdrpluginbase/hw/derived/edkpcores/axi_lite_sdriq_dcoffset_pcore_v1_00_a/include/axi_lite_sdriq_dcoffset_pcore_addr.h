/*
 * File Name:         hdl_prj\ipcore\axi_lite_sdriq_dcoffset_pcore_v1_00_a\include\axi_lite_sdriq_dcoffset_pcore_addr.h
 * Description:       C Header File
 * Created:           2013-08-28 18:09:31
 */

#ifndef AXI_LITE_SDRIQ_DCOFFSET_PCORE_H_
#define AXI_LITE_SDRIQ_DCOFFSET_PCORE_H_

#define  IPCore_Reset_axi_lite_sdriq_dcoffset_pcore                0x0  //write 0x1 to bit 0 to reset IP core
#define  IPCore_Enable_axi_lite_sdriq_dcoffset_pcore               0x4  //enabled (by default) when bit 0 is 0x1
#define  wr_IQbal_Data_axi_lite_sdriq_dcoffset_pcore               0x100  //data register for port wr_IQbal
#define  wr_iqbal_dcoffbypass_Data_axi_lite_sdriq_dcoffset_pcore   0x104  //data register for port wr_iqbal_dcoffbypass
#define  wr_dcoffset_Data_axi_lite_sdriq_dcoffset_pcore            0x108  //data register for port wr_dcoffset
#define  rd_IQbal_Data_axi_lite_sdriq_dcoffset_pcore               0x10C  //data register for port rd_IQbal
#define  rd_iqbal_dcoffbypass_Data_axi_lite_sdriq_dcoffset_pcore   0x110  //data register for port rd_iqbal_dcoffbypass
#define  rd_dcoffset_Data_axi_lite_sdriq_dcoffset_pcore            0x114  //data register for port rd_dcoffset

#endif /* AXI_LITE_SDRIQ_DCOFFSET_PCORE_H_ */
