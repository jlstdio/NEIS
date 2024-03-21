/*
 * File Name:         hdl_prj\ipcore\fifo_irq_ctrl_pcore_v1_0\include\axi_lite_fifo_irq_ctrl_pcore_addr.h
 * Description:       C Header File
 * Created:           2015-05-14 08:08:22
*/

#ifndef  AXI_LITE_FIFO_IRQ_CTRL_PCORE_H_
#define  AXI_LITE_FIFO_IRQ_CTRL_PCORE_H_

#define  IPCore_Reset_axi_lite_fifo_irq_ctrl_pcore           0x0  //write 0x1 to bit 0 to reset IP core
#define  IPCore_Enable_axi_lite_fifo_irq_ctrl_pcore          0x4  //enabled (by default) when bit 0 is 0x1
#define  wr_CTRL_Data_axi_lite_fifo_irq_ctrl_pcore           0x100  //data register for port wr_CTRL
#define  rd_STATUS_Data_axi_lite_fifo_irq_ctrl_pcore         0x104  //data register for port rd_STATUS
#define  wr_ISR_Data_axi_lite_fifo_irq_ctrl_pcore            0x108  //data register for port wr_ISR
#define  rd_ISR_Data_axi_lite_fifo_irq_ctrl_pcore            0x10C  //data register for port rd_ISR
#define  wr_IER_Data_axi_lite_fifo_irq_ctrl_pcore            0x110  //data register for port wr_ISRE
#define  rd_IER_Data_axi_lite_fifo_irq_ctrl_pcore            0x114  //data register for port rd_ISRE
#define  rd_OFCNT_Data_axi_lite_fifo_irq_ctrl_pcore          0x118  //data register for port rd_OFCNT
#define  rd_UFCNT_Data_axi_lite_fifo_irq_ctrl_pcore          0x11C  //data register for port rd_UFCNT
#define  rd_FIFO_OCC_CNT_Data_axi_lite_fifo_irq_ctrl_pcore   0x120  //data register for port rd_FIFO_OCC_CNT
#define  rd_FIFO_SAMP_CNT_Data_axi_lite_fifo_irq_ctrl_pcore  0x124  //data register for port rd_FIFO_SAMP_CNT

#endif /*  AXI_LITE_FIFO_IRQ_CTRL_PCORE_H_ */
