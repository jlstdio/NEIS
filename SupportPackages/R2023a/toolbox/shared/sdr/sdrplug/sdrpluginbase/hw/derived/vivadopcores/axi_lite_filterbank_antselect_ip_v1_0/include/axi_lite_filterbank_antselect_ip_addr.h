/*
 * File Name:         hdl_prj\ipcore\axi_lite_filterbank_antselect_ip_v1_0\include\axi_lite_filterbank_antselect_ip_addr.h
 * Description:       C Header File
 * Created:           2016-05-02 18:40:52
*/

#ifndef AXI_LITE_FILTERBANK_ANTSELECT_IP_H_
#define AXI_LITE_FILTERBANK_ANTSELECT_IP_H_

#define  IPCore_Reset_axi_lite_filterbank_antselect_ip           0x0  //write 0x1 to bit 0 to reset IP core
#define  IPCore_Enable_axi_lite_filterbank_antselect_ip          0x4  //enabled (by default) when bit 0 is 0x1
#define  wr_TX_BANDSEL_Data_axi_lite_filterbank_antselect_ip     0x100  //data register for port wr_TX_BANDSEL
#define  wr_RX1_BANDSEL_Data_axi_lite_filterbank_antselect_ip    0x104  //data register for port wr_RX1_BANDSEL
#define  wr_RX2_BANDSEL_Data_axi_lite_filterbank_antselect_ip    0x108  //data register for port wr_RX2_BANDSEL
#define  wr_RX1B_BANDSEL_Data_axi_lite_filterbank_antselect_ip   0x10C  //data register for port wr_RX1B_BANDSEL
#define  wr_RX1C_BANDSEL_Data_axi_lite_filterbank_antselect_ip   0x110  //data register for port wr_RX1C_BANDSEL
#define  wr_RX2B_BANDSEL_Data_axi_lite_filterbank_antselect_ip   0x114  //data register for port wr_RX2B_BANDSEL
#define  wr_RX2C_BANDSEL_Data_axi_lite_filterbank_antselect_ip   0x118  //data register for port wr_RX2C_BANDSEL
#define  wr_TX_ENABLE1A_Data_axi_lite_filterbank_antselect_ip    0x11C  //data register for port wr_TX_ENABLE1A
#define  wr_TX_ENABLE2A_Data_axi_lite_filterbank_antselect_ip    0x120  //data register for port wr_TX_ENABLE2A
#define  wr_TX_ENABLE1B_Data_axi_lite_filterbank_antselect_ip    0x124  //data register for port wr_TX_ENABLE1B
#define  wr_TX_ENABLE2B_Data_axi_lite_filterbank_antselect_ip    0x128  //data register for port wr_TX_ENABLE2B
#define  wr_VCTXRX1_V1_Data_axi_lite_filterbank_antselect_ip     0x12C  //data register for port wr_VCTXRX1_V1
#define  wr_VCTXRX1_V2_Data_axi_lite_filterbank_antselect_ip     0x130  //data register for port wr_VCTXRX1_V2
#define  wr_VCTXRX2_V1_Data_axi_lite_filterbank_antselect_ip     0x134  //data register for port wr_VCTXRX2_V1
#define  wr_VCTXRX2_V2_Data_axi_lite_filterbank_antselect_ip     0x138  //data register for port wr_VCTXRX2_V2
#define  wr_VCRX1_V1_Data_axi_lite_filterbank_antselect_ip       0x13C  //data register for port wr_VCRX1_V1
#define  wr_VCRX1_V2_Data_axi_lite_filterbank_antselect_ip       0x140  //data register for port wr_VCRX1_V2
#define  wr_VCRX2_V1_Data_axi_lite_filterbank_antselect_ip       0x144  //data register for port wr_VCRX2_V1
#define  wr_VCRX2_V2_Data_axi_lite_filterbank_antselect_ip       0x148  //data register for port wr_VCRX2_V2
#define  rd_TX_BANDSEL_Data_axi_lite_filterbank_antselect_ip     0x14C  //data register for port rd_TX_BANDSEL
#define  rd_RX1_BANDSEL_Data_axi_lite_filterbank_antselect_ip    0x150  //data register for port rd_RX1_BANDSEL
#define  rd_RX2_BANDSEL_Data_axi_lite_filterbank_antselect_ip    0x154  //data register for port rd_RX2_BANDSEL
#define  rd_RX1B_BANDSEL_Data_axi_lite_filterbank_antselect_ip   0x158  //data register for port rd_RX1B_BANDSEL
#define  rd_RX1C_BANDSEL_Data_axi_lite_filterbank_antselect_ip   0x15C  //data register for port rd_RX1C_BANDSEL
#define  rd_RX2B_BANDSEL_Data_axi_lite_filterbank_antselect_ip   0x160  //data register for port rd_RX2B_BANDSEL
#define  rd_RX2C_BANDSEL_Data_axi_lite_filterbank_antselect_ip   0x164  //data register for port rd_RX2C_BANDSEL
#define  rd_TX_ENABLE1A_Data_axi_lite_filterbank_antselect_ip    0x168  //data register for port rd_TX_ENABLE1A
#define  rd_TX_ENABLE2A_Data_axi_lite_filterbank_antselect_ip    0x16C  //data register for port rd_TX_ENABLE2A
#define  rd_TX_ENABLE1B_Data_axi_lite_filterbank_antselect_ip    0x170  //data register for port rd_TX_ENABLE1B
#define  rd_TX_ENABLE2B_Data_axi_lite_filterbank_antselect_ip    0x174  //data register for port rd_TX_ENABLE2B
#define  rd_VCTXRX1_V1_Data_axi_lite_filterbank_antselect_ip     0x178  //data register for port rd_VCTXRX1_V1
#define  rd_VCTXRX1_V2_Data_axi_lite_filterbank_antselect_ip     0x17C  //data register for port rd_VCTXRX1_V2
#define  rd_VCTXRX2_V1_Data_axi_lite_filterbank_antselect_ip     0x180  //data register for port rd_VCTXRX2_V1
#define  rd_VCTXRX2_V2_Data_axi_lite_filterbank_antselect_ip     0x184  //data register for port rd_VCTXRX2_V2
#define  rd_VCRX1_V1_Data_axi_lite_filterbank_antselect_ip       0x188  //data register for port rd_VCRX1_V1
#define  rd_VCRX1_V2_Data_axi_lite_filterbank_antselect_ip       0x18C  //data register for port rd_VCRX1_V2
#define  rd_VCRX2_V1_Data_axi_lite_filterbank_antselect_ip       0x190  //data register for port rd_VCRX2_V1
#define  rd_VCRX2_V2_Data_axi_lite_filterbank_antselect_ip       0x194  //data register for port rd_VCRX2_V2

#endif /* AXI_LITE_FILTERBANK_ANTSELECT_IP_H_ */
