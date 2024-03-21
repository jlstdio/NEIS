
################################################################
# This is a generated script based on design: system
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2019.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   puts "ERROR: This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source system_script.tcl





# CHANGE DESIGN NAME HERE
set design_name $BlockDesignName

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# CHECKING IF PROJECT EXISTS
if { [get_projects -quiet] eq "" } {
   puts "ERROR: Please open or create a project!"
   return 1
}

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "ERROR: Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      puts "INFO: Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   puts "INFO: Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   puts "INFO: Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   puts "INFO: Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

puts "INFO: Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   puts $errMsg
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell Target Range rxDUTIPCoreName txDUTIPCoreName} {

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]
  set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]
  set iic_rtl [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 iic_rtl ]

  # Create ports
  set LED [ create_bd_port -dir O LED ]
  set spi_csn [ create_bd_port -dir O spi_csn ]
  set spi_miso [ create_bd_port -dir I spi_miso ]
  set spi_mosi [ create_bd_port -dir O spi_mosi ]
  set spi_clk [ create_bd_port -dir O spi_clk ]

  # CMOS/LVDS tx/rx ports depends on Target platform 
  if {[string equal $Target "E310"]} {
      # CMOS flag
      set CMOS_FLAG 1
      # input/output ports
      set ONSWITCH_DB [ create_bd_port -dir I ONSWITCH_DB ]
      set TCXO_DAC_SCLK [ create_bd_port -dir O TCXO_DAC_SCLK ]
      set TCXO_DAC_SDIN [ create_bd_port -dir O TCXO_DAC_SDIN ]
      set TCXO_DAC_SYNCn [ create_bd_port -dir O TCXO_DAC_SYNCn ]
      set rx_clk_in [ create_bd_port -dir I rx_clk_in ]
      set rx_data_in [ create_bd_port -dir I -from 11 -to 0 rx_data_in ]
      set tx_clk_out [ create_bd_port -dir O tx_clk_out ]
      set tx_data_out [ create_bd_port -dir O -from 11 -to 0 tx_data_out ]
      set tx_frame_out [ create_bd_port -dir O tx_frame_out ]
      set rx_frame_in [ create_bd_port -dir I rx_frame_in ]
      set RX1B_BANDSEL [ create_bd_port -dir O -from 1 -to 0 RX1B_BANDSEL ]
      set RX1C_BANDSEL [ create_bd_port -dir O -from 1 -to 0 RX1C_BANDSEL ]
      set RX1_BANDSEL [ create_bd_port -dir O -from 2 -to 0 RX1_BANDSEL ]
      set RX2B_BANDSEL [ create_bd_port -dir O -from 1 -to 0 RX2B_BANDSEL ]
      set RX2C_BANDSEL [ create_bd_port -dir O -from 1 -to 0 RX2C_BANDSEL ]
      set RX2_BANDSEL [ create_bd_port -dir O -from 2 -to 0 RX2_BANDSEL ]
      set TX_BANDSEL [ create_bd_port -dir O -from 2 -to 0 TX_BANDSEL ]
      set TX_ENABLE1A [ create_bd_port -dir O TX_ENABLE1A ]
      set TX_ENABLE1B [ create_bd_port -dir O TX_ENABLE1B ]
      set TX_ENABLE2A [ create_bd_port -dir O TX_ENABLE2A ]
      set TX_ENABLE2B [ create_bd_port -dir O TX_ENABLE2B ]
      set VCRX1_V1 [ create_bd_port -dir O VCRX1_V1 ]
      set VCRX1_V2 [ create_bd_port -dir O VCRX1_V2 ]
      set VCRX2_V1 [ create_bd_port -dir O VCRX2_V1 ]
      set VCRX2_V2 [ create_bd_port -dir O VCRX2_V2 ]
      set VCTXRX1_V1 [ create_bd_port -dir O VCTXRX1_V1 ]
      set VCTXRX1_V2 [ create_bd_port -dir O VCTXRX1_V2 ]
      set VCTXRX2_V1 [ create_bd_port -dir O VCTXRX2_V1 ]
      set VCTXRX2_V2 [ create_bd_port -dir O VCTXRX2_V2 ]
      set AVR_IRQ [create_bd_port -dir O AVR_IRQ ]
  } else {
      # CMOS flag
      set CMOS_FLAG 0
      # input/output ports
      set rx_clk_in_n [ create_bd_port -dir I rx_clk_in_n ]
      set rx_clk_in_p [ create_bd_port -dir I rx_clk_in_p ]
      set rx_data_in_n [ create_bd_port -dir I -from 5 -to 0 rx_data_in_n ]
      set rx_data_in_p [ create_bd_port -dir I -from 5 -to 0 rx_data_in_p ]
      set rx_frame_in_n [ create_bd_port -dir I rx_frame_in_n ]
      set rx_frame_in_p [ create_bd_port -dir I rx_frame_in_p ]
      set tx_clk_out_n [ create_bd_port -dir O tx_clk_out_n ]
      set tx_clk_out_p [ create_bd_port -dir O tx_clk_out_p ]
      set tx_data_out_n [ create_bd_port -dir O -from 5 -to 0 tx_data_out_n ]
      set tx_data_out_p [ create_bd_port -dir O -from 5 -to 0 tx_data_out_p ]
      set tx_frame_out_n [ create_bd_port -dir O tx_frame_out_n ]
      set tx_frame_out_p [ create_bd_port -dir O tx_frame_out_p ]
  }
  
  # Number of GPIO pins on port depends on Target platform 
  if {[string equal $Target "ZC706"] || [string equal $Target "ZedBoard"]|| [string equal $Target "E310"]} {
      set gpio_io [ create_bd_port -dir IO -from 16 -to 0 gpio_io ]
  } elseif {[string equal $Target "ADIRFSOM"]} {
      set gpio_io [ create_bd_port -dir IO -from 18 -to 0 gpio_io ]
  }

  # Create instance: DMA_rstn, and set properties
  set DMA_rstn [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 DMA_rstn ]
  set_property -dict [ list CONFIG.C_OPERATION {not} CONFIG.C_SIZE {1}  ] $DMA_rstn

  # Create instance: axi_ad9361, and set properties
  set axi_ad9361 [ create_bd_cell -type ip -vlnv analog.com:user:axi_ad9361:1.0 axi_ad9361 ]
  if {[string equal $Target "E310"]} {
      set_property -dict [ list CONFIG.CMOS_OR_LVDS_N {1} CONFIG.DAC_IODELAY_ENABLE {0} ] $axi_ad9361
  } else {
      set_property -dict [ list CONFIG.CMOS_OR_LVDS_N {0} CONFIG.DAC_IODELAY_ENABLE {0} ] $axi_ad9361 
  }

  # Create instance: axi_dma_rx, and set properties
  set axi_dma_rx [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_rx ]
  set_property -dict [ list CONFIG.c_include_mm2s {0} CONFIG.c_include_s2mm_dre {1} CONFIG.c_m_axi_s2mm_data_width {64} CONFIG.c_sg_include_stscntrl_strm {0} CONFIG.c_sg_length_width {18}  ] $axi_dma_rx

  # Create instance: axi_dma_tx, and set properties
  set axi_dma_tx [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_tx ]
  set_property -dict [ list CONFIG.c_include_mm2s {1} CONFIG.c_include_mm2s_dre {1} CONFIG.c_include_s2mm {0} CONFIG.c_m_axi_mm2s_data_width {64} CONFIG.c_m_axis_mm2s_tdata_width {64} CONFIG.c_sg_include_stscntrl_strm {0} CONFIG.c_sg_length_width {18}  ] $axi_dma_tx

  # Create instance: axi_iic_0, and set properties
  set axi_iic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_iic:2.0 axi_iic_0 ]

  # Create instance: axi_interconnect_0, and set properties
  set axi_interconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0 ]
  set_property -dict [ list CONFIG.ENABLE_ADVANCED_OPTIONS {0} CONFIG.NUM_MI {1}  ] $axi_interconnect_0

  # Create instance: axi_interconnect_1, and set properties
  set axi_interconnect_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_1 ]
  set_property -dict [ list CONFIG.ENABLE_ADVANCED_OPTIONS {0} CONFIG.NUM_MI {1}  ] $axi_interconnect_1

  # Create instance: axi_lite_data_packer_pcore_0, and set properties
  set axi_lite_data_packer_pcore_0 [ create_bd_cell -type ip -vlnv MATHWORKS:ip:axi_lite_data_packer_pcore:1.0 axi_lite_data_packer_pcore_0 ]
  set_property -dict [list CONFIG.bit_width {64}] $axi_lite_data_packer_pcore_0

  # Create instance: axi_lite_data_unpacker_pcore_0, and set properties
  set axi_lite_data_unpacker_pcore_0 [ create_bd_cell -type ip -vlnv MATHWORKS:ip:axi_lite_data_unpacker_pcore:1.0 axi_lite_data_unpacker_pcore_0 ]
  set_property -dict [list CONFIG.bit_width {64}] $axi_lite_data_unpacker_pcore_0

  # Create instance: axi_lite_data_verifier_if_pcore_0, and set properties
  set axi_lite_data_verifier_if_pcore_0 [ create_bd_cell -type ip -vlnv mathworks.com:ip:axi_lite_data_verifier_if_pcore:1.0 axi_lite_data_verifier_if_pcore_0 ]
  
  if {[string equal $Target "E310"]} {
    # Create instance: axi_lite_filterbank_antselect_ip_0, and set properties
    set axi_lite_filterbank_antselect_ip_0 [ create_bd_cell -type ip -vlnv mathworks.com:ip:axi_lite_filterbank_antselect_ip:1.0 axi_lite_filterbank_antselect_ip_0 ]
  }

  # Create instance: axi_lite_sample_counter_pcore_0, and set properties
  set axi_lite_sample_counter_pcore_0 [ create_bd_cell -type ip -vlnv mathworks.com:ip:axi_lite_sample_counter_pcore:1.0 axi_lite_sample_counter_pcore_0 ]

  # Create instance: axi_lite_sdrramp_src_pcore_0, and set properties
  set axi_lite_sdrramp_src_pcore_0 [ create_bd_cell -type ip -vlnv MATHWORKS:ip:axi_lite_sdrramp_src_pcore:1.0 axi_lite_sdrramp_src_pcore_0 ]
  set_property -dict [list CONFIG.bit_width {64}] $axi_lite_sdrramp_src_pcore_0

  # Create instance: axi_lite_system_config_pcore_0, and set properties
  set axi_lite_system_config_pcore_0 [ create_bd_cell -type ip -vlnv mathworks.com:user:axi_lite_system_config_pcore:1.0 axi_lite_system_config_pcore_0 ]

  # Create instance: axi_mem_intercon, and set properties
  set axi_mem_intercon [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_mem_intercon ]
  set_property -dict [ list CONFIG.ENABLE_ADVANCED_OPTIONS {1} CONFIG.NUM_MI {1} CONFIG.NUM_SI {2} CONFIG.XBAR_DATA_WIDTH {64}  ] $axi_mem_intercon

  # Create instance: clk_domain_xing_rst_0, and set properties
  set clk_domain_xing_rst_0 [ create_bd_cell -type ip -vlnv mathworks.com:user:clk_domain_xing_rst:1.0 clk_domain_xing_rst_0 ]

  # Create instance: clk_domain_xing_rst_1, and set properties
  set clk_domain_xing_rst_1 [ create_bd_cell -type ip -vlnv mathworks.com:user:clk_domain_xing_rst:1.0 clk_domain_xing_rst_1 ]

  # Create instance: clk_domain_xing_rst_2, and set properties
  set clk_domain_xing_rst_2 [ create_bd_cell -type ip -vlnv mathworks.com:user:clk_domain_xing_rst:1.0 clk_domain_xing_rst_2 ]

  # Create instance: clockGen_0, and set properties
  set clockGen_0 [ create_bd_cell -type ip -vlnv mathworks.com:user:clockGen:1.0 clockGen_0 ]
  if {[string equal $Target "E310"]} {
    set_property -dict [list CONFIG.clk_div {2}] $clockGen_0
  }

  # Create instance: dac_unpack_0, and set properties
  set dac_unpack_0 [ create_bd_cell -type ip -vlnv mathworks.com:user:dac_unpack:1.0 dac_unpack_0 ]
  set_property -dict [ list CONFIG.bus_width {64}  ] $dac_unpack_0


  # Create instance: data_fifo_generator_rx, and set properties
  set data_fifo_generator_rx [ create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.2 data_fifo_generator_rx ]
  set_property -dict [ list CONFIG.Clock_Type_AXI {Independent_Clock} CONFIG.FIFO_Implementation_axis {Independent_Clocks_Block_RAM} CONFIG.FIFO_Implementation_rach {Independent_Clocks_Distributed_RAM} CONFIG.FIFO_Implementation_rdch {Independent_Clocks_Block_RAM} CONFIG.FIFO_Implementation_wach {Independent_Clocks_Distributed_RAM} CONFIG.FIFO_Implementation_wdch {Independent_Clocks_Block_RAM} CONFIG.FIFO_Implementation_wrch {Independent_Clocks_Distributed_RAM} CONFIG.INTERFACE_TYPE {AXI_STREAM} CONFIG.Input_Depth_axis {16384} CONFIG.TDATA_NUM_BYTES {8} CONFIG.TUSER_WIDTH {0}  ] $data_fifo_generator_rx

  # Create instance: data_fifo_generator_tx, and set properties
  set data_fifo_generator_tx [ create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.2 data_fifo_generator_tx ]
  set_property -dict [ list CONFIG.Clock_Type_AXI {Independent_Clock} CONFIG.FIFO_Implementation_axis {Independent_Clocks_Block_RAM} CONFIG.FIFO_Implementation_rach {Independent_Clocks_Distributed_RAM} CONFIG.FIFO_Implementation_rdch {Independent_Clocks_Block_RAM} CONFIG.FIFO_Implementation_wach {Independent_Clocks_Distributed_RAM} CONFIG.FIFO_Implementation_wdch {Independent_Clocks_Block_RAM} CONFIG.FIFO_Implementation_wrch {Independent_Clocks_Distributed_RAM} CONFIG.INTERFACE_TYPE {AXI_STREAM} CONFIG.Input_Depth_axis {4096} CONFIG.TDATA_NUM_BYTES {8} CONFIG.TUSER_WIDTH {0}  ] $data_fifo_generator_tx

  # Create instance: detection_fifo_rx, and set properties
  set detection_fifo_rx [ create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.2 detection_fifo_rx ]
  set_property -dict [ list CONFIG.Enable_Data_Counts_axis {true} CONFIG.FIFO_Implementation_rach {Common_Clock_Distributed_RAM} CONFIG.FIFO_Implementation_wach {Common_Clock_Distributed_RAM} CONFIG.FIFO_Implementation_wrch {Common_Clock_Distributed_RAM} CONFIG.INTERFACE_TYPE {AXI_STREAM} CONFIG.Input_Depth_axis {16} CONFIG.Overflow_Flag_AXI {true} CONFIG.TDATA_NUM_BYTES {8} CONFIG.TUSER_WIDTH {0} CONFIG.Underflow_Flag_AXI {true}  ] $detection_fifo_rx

  # Create instance: detection_fifo_tx, and set properties
  set detection_fifo_tx [ create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.2 detection_fifo_tx ]
  set_property -dict [ list CONFIG.Enable_Data_Counts_axis {true} CONFIG.FIFO_Implementation_rach {Common_Clock_Distributed_RAM} CONFIG.FIFO_Implementation_wach {Common_Clock_Distributed_RAM} CONFIG.FIFO_Implementation_wrch {Common_Clock_Distributed_RAM} CONFIG.INTERFACE_TYPE {AXI_STREAM} CONFIG.Input_Depth_axis {16} CONFIG.Overflow_Flag_AXI {true} CONFIG.TDATA_NUM_BYTES {8} CONFIG.TUSER_WIDTH {0} CONFIG.Underflow_Flag_AXI {true}  ] $detection_fifo_tx
  # Create instance: fclk2_reset, and set properties
  set fclk2_reset [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 fclk2_reset ]
  set_property -dict [ list CONFIG.C_OPERATION {not} CONFIG.C_SIZE {1}  ] $fclk2_reset

  # Create instance: fifo_generator_clkgen_rx, and set properties
  set fifo_generator_clkgen_rx [ create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.2 fifo_generator_clkgen_rx ]
  set_property -dict [ list CONFIG.Clock_Type_AXI {Independent_Clock} CONFIG.FIFO_Implementation_axis {Independent_Clocks_Block_RAM} CONFIG.FIFO_Implementation_rach {Independent_Clocks_Distributed_RAM} CONFIG.FIFO_Implementation_rdch {Independent_Clocks_Block_RAM} CONFIG.FIFO_Implementation_wach {Independent_Clocks_Distributed_RAM} CONFIG.FIFO_Implementation_wdch {Independent_Clocks_Block_RAM} CONFIG.FIFO_Implementation_wrch {Independent_Clocks_Distributed_RAM} CONFIG.INTERFACE_TYPE {AXI_STREAM} CONFIG.Input_Depth_axis {16} CONFIG.TDATA_NUM_BYTES {8} CONFIG.TUSER_WIDTH {0} CONFIG.axis_type {FIFO}  ] $fifo_generator_clkgen_rx

  # Create instance: fifo_generator_clkgen_tx, and set properties
  set fifo_generator_clkgen_tx [ create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.2 fifo_generator_clkgen_tx ]
  set_property -dict [ list CONFIG.Clock_Type_AXI {Independent_Clock} CONFIG.FIFO_Implementation_axis {Independent_Clocks_Block_RAM} CONFIG.FIFO_Implementation_rach {Independent_Clocks_Distributed_RAM} CONFIG.FIFO_Implementation_rdch {Independent_Clocks_Block_RAM} CONFIG.FIFO_Implementation_wach {Independent_Clocks_Distributed_RAM} CONFIG.FIFO_Implementation_wdch {Independent_Clocks_Block_RAM} CONFIG.FIFO_Implementation_wrch {Independent_Clocks_Distributed_RAM} CONFIG.INTERFACE_TYPE {AXI_STREAM} CONFIG.Input_Depth_axis {16} CONFIG.TDATA_NUM_BYTES {8} CONFIG.TUSER_WIDTH {0} CONFIG.axis_type {FIFO}  ] $fifo_generator_clkgen_tx

  # Create instance: fifo_irq_ctrl_pcore_rx, and set properties
  set fifo_irq_ctrl_pcore_rx [ create_bd_cell -type ip -vlnv mathworks.com:ip:axi_lite_fifo_irq_ctrl_pcore:1.0 fifo_irq_ctrl_pcore_rx ]
  set_property -dict [ list CONFIG.base_addr {1137049600}  ] $fifo_irq_ctrl_pcore_rx

  # Create instance: fifo_irq_ctrl_pcore_tx, and set properties
  set fifo_irq_ctrl_pcore_tx [ create_bd_cell -type ip -vlnv mathworks.com:ip:axi_lite_fifo_irq_ctrl_pcore:1.0 fifo_irq_ctrl_pcore_tx ]
  set_property -dict [ list CONFIG.base_addr {1137115136}  ] $fifo_irq_ctrl_pcore_tx
  # Create instance: gpio_tribus_slice_0, and set properties
  set gpio_tribus_slice_0 [ create_bd_cell -type ip -vlnv mw:user:gpio_tribus_slice:1.0 gpio_tribus_slice_0 ]
  if {[string equal $Target "ZC706"] || [string equal $Target "ZedBoard"]} {
      set_property -dict [list CONFIG.bit_width {49} CONFIG.out_width {17}] $gpio_tribus_slice_0
  } elseif {[string equal $Target "ADIRFSOM"]} {
      set_property -dict [list CONFIG.bit_width {51} CONFIG.out_width {19}] $gpio_tribus_slice_0
  }
    
  # Create instance: interrupt_concat, and set properties
  set interrupt_concat [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 interrupt_concat ]
  set_property -dict [ list CONFIG.NUM_PORTS {4}  ] $interrupt_concat

  # Create instance: led_driver_0, and set properties
  set led_driver_0 [ create_bd_cell -type ip -vlnv mathworks.com:user:led_driver:2.0 led_driver_0 ]
  set_property -dict [ list CONFIG.CNTWIDTH {32} CONFIG.cnt_significant_bit {26}  ] $led_driver_0
  
 # Create instance: tx_tready_tieoff, and set properties
  set tx_tready_tieoff [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 tx_tready_tieoff ]

  # Create instance: processing_system7_1
  set processing_system7_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_1 ]

  ## Set processing_system properties.
  ## Common properties shared between all boards:
  
  # When using '\' to split command over multiple lines, 
  # ensure there is no trailing white space after the character
  # i.e. '\ ', as this will cause the build to fail! 

  ## ZC706 and ZedBoard share a base processing system setup, with individual board specific presets
  if {[string equal $Target "ZC706"] || [string equal $Target "ZedBoard"]} {
        ## Set board specific Vivado preset
        if {[string equal $Target "ZC706"]} {  
            set_property -dict [ list CONFIG.preset {ZC706*} ]  $processing_system7_1
        } elseif {[string equal $Target "ZedBoard"]} {
            set_property -dict [ list CONFIG.preset {ZedBoard*} ] $processing_system7_1
        }
        ## Set shared base processing system properties
        set_property -dict [ list CONFIG.PCW_ENET0_PERIPHERAL_FREQMHZ {1000 Mbps} \
            CONFIG.PCW_EN_CLK2_PORT {1} CONFIG.PCW_EN_CLK3_PORT {1} \
            CONFIG.PCW_EN_RST2_PORT {1} CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {100} \
            CONFIG.PCW_FPGA2_PERIPHERAL_FREQMHZ {100} CONFIG.PCW_FPGA3_PERIPHERAL_FREQMHZ {200} \
            CONFIG.PCW_GPIO_EMIO_GPIO_ENABLE {1} CONFIG.PCW_GPIO_EMIO_GPIO_IO {49} \
            CONFIG.PCW_I2C0_I2C0_IO {MIO 50 .. 51} CONFIG.PCW_I2C0_PERIPHERAL_ENABLE {1} \
            CONFIG.PCW_IRQ_F2P_INTR {1} CONFIG.PCW_SPI0_PERIPHERAL_ENABLE {1} \
            CONFIG.PCW_UIPARAM_DDR_CWL {5.0000000} CONFIG.PCW_UIPARAM_DDR_T_FAW {25} \
            CONFIG.PCW_USE_DEFAULT_ACP_USER_VAL {1} CONFIG.PCW_USE_FABRIC_INTERRUPT {1} \
            CONFIG.PCW_USE_S_AXI_ACP {1} CONFIG.PCW_USE_S_AXI_HP0 {1} \
            CONFIG.PCW_USE_S_AXI_HP1 {1} ] $processing_system7_1
  } elseif {[string equal $Target "ADIRFSOM"]} { 
	    # There is currently no Vivado board preset for ADIRFSOM, 
	    # which is why there are far more properties to set here.
        set_property -dict [ list CONFIG.PCW_ENET0_PERIPHERAL_FREQMHZ {1000 Mbps} \
            CONFIG.PCW_EN_CLK2_PORT {1} CONFIG.PCW_EN_CLK3_PORT {1} \
            CONFIG.PCW_EN_RST2_PORT {1} CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {100} \
            CONFIG.PCW_FPGA2_PERIPHERAL_FREQMHZ {100} CONFIG.PCW_FPGA3_PERIPHERAL_FREQMHZ {200} \
            CONFIG.PCW_GPIO_EMIO_GPIO_ENABLE {1} CONFIG.PCW_GPIO_EMIO_GPIO_IO {51} \
            CONFIG.PCW_IRQ_F2P_INTR {1} CONFIG.PCW_SPI0_PERIPHERAL_ENABLE {1} \
            CONFIG.PCW_USE_FABRIC_INTERRUPT {1} CONFIG.PCW_USE_S_AXI_ACP {1} \
            CONFIG.PCW_USE_S_AXI_HP0 {1} CONFIG.PCW_USE_S_AXI_HP1 {1} \
            CONFIG.PCW_ENET0_ENET0_IO {MIO 16 .. 27} CONFIG.PCW_ENET0_GRP_MDIO_ENABLE {1} CONFIG.PCW_ENET0_GRP_MDIO_IO {MIO 52 .. 53} \
            CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {1} CONFIG.PCW_ENET0_RESET_ENABLE {1} \
            CONFIG.PCW_ENET0_RESET_IO {MIO 8} CONFIG.PCW_ENET_RESET_SELECT {Separate reset pins} \
            CONFIG.PCW_GPIO_MIO_GPIO_ENABLE {1} CONFIG.PCW_PACKAGE_NAME {fbg676} \
            CONFIG.PCW_PRESET_BANK0_VOLTAGE {LVCMOS 1.8V} CONFIG.PCW_PRESET_BANK1_VOLTAGE {LVCMOS 1.8V} \
            CONFIG.PCW_QSPI_PERIPHERAL_ENABLE {1} CONFIG.PCW_SD0_GRP_CD_ENABLE {1} \
            CONFIG.PCW_SD0_GRP_CD_IO {MIO 50} CONFIG.PCW_SD0_PERIPHERAL_ENABLE {1} \
            CONFIG.PCW_SDIO_PERIPHERAL_FREQMHZ {50} CONFIG.PCW_SPI0_SPI0_IO {EMIO} \
            CONFIG.PCW_TTC0_PERIPHERAL_ENABLE {0} CONFIG.PCW_UART1_PERIPHERAL_ENABLE {1} \
            CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY0 {0.264} CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY1 {0.265} \
            CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY2 {0.330} CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY3 {0.330} \
            CONFIG.PCW_UIPARAM_DDR_BUS_WIDTH {32 Bit} CONFIG.PCW_UIPARAM_DDR_CLOCK_0_LENGTH_MM {34} \
            CONFIG.PCW_UIPARAM_DDR_CLOCK_1_LENGTH_MM {34} CONFIG.PCW_UIPARAM_DDR_CLOCK_2_LENGTH_MM {54} \
            CONFIG.PCW_UIPARAM_DDR_CLOCK_3_LENGTH_MM {54} CONFIG.PCW_UIPARAM_DDR_DQS_0_LENGTH_MM {43.4} \
            CONFIG.PCW_UIPARAM_DDR_DQS_1_LENGTH_MM {43.8} CONFIG.PCW_UIPARAM_DDR_DQS_2_LENGTH_MM {44.2} \
            CONFIG.PCW_UIPARAM_DDR_DQS_3_LENGTH_MM {43.5} CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_0 {-0.053} \
            CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_1 {-0.059} CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_2 {0.065} \
            CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_3 {0.066} CONFIG.PCW_UIPARAM_DDR_DQ_0_LENGTH_MM {43.6} \
            CONFIG.PCW_UIPARAM_DDR_DQ_1_LENGTH_MM {43.75} CONFIG.PCW_UIPARAM_DDR_DQ_2_LENGTH_MM {44.2} \
            CONFIG.PCW_UIPARAM_DDR_DQ_3_LENGTH_MM {43.5} CONFIG.PCW_UIPARAM_DDR_PARTNO {MT41K256M16 RE-125} \
            CONFIG.PCW_UIPARAM_DDR_TRAIN_DATA_EYE {1} CONFIG.PCW_UIPARAM_DDR_TRAIN_READ_GATE {1} \
            CONFIG.PCW_UIPARAM_DDR_TRAIN_WRITE_LEVEL {1} CONFIG.PCW_UIPARAM_DDR_USE_INTERNAL_VREF {0} \
        ] $processing_system7_1
  } elseif {[string equal $Target "E310"]} {
        set_property -dict [ list \
            CONFIG.PCW_ACT_APU_PERIPHERAL_FREQMHZ {666.666687} CONFIG.PCW_ACT_CAN0_PERIPHERAL_FREQMHZ {23.8095} \
            CONFIG.PCW_ACT_CAN1_PERIPHERAL_FREQMHZ {23.8095} CONFIG.PCW_ACT_CAN_PERIPHERAL_FREQMHZ {10.000000} \
            CONFIG.PCW_ACT_DCI_PERIPHERAL_FREQMHZ {10.158731} CONFIG.PCW_ACT_ENET0_PERIPHERAL_FREQMHZ {125.000000} \
            CONFIG.PCW_ACT_ENET1_PERIPHERAL_FREQMHZ {10.000000} CONFIG.PCW_ACT_FPGA0_PERIPHERAL_FREQMHZ {100.000000} \
            CONFIG.PCW_ACT_FPGA1_PERIPHERAL_FREQMHZ {100.000000} CONFIG.PCW_ACT_FPGA2_PERIPHERAL_FREQMHZ {125.000000} \
            CONFIG.PCW_ACT_FPGA3_PERIPHERAL_FREQMHZ {200.000000} CONFIG.PCW_ACT_I2C_PERIPHERAL_FREQMHZ {50} \
            CONFIG.PCW_ACT_PCAP_PERIPHERAL_FREQMHZ {200.000000} CONFIG.PCW_ACT_QSPI_PERIPHERAL_FREQMHZ {10.000000} \
            CONFIG.PCW_ACT_SDIO_PERIPHERAL_FREQMHZ {125.000000} CONFIG.PCW_ACT_SMC_PERIPHERAL_FREQMHZ {10.000000} \
            CONFIG.PCW_ACT_SPI_PERIPHERAL_FREQMHZ {166.666672} CONFIG.PCW_ACT_TPIU_PERIPHERAL_FREQMHZ {200.000000} \
            CONFIG.PCW_ACT_TTC0_CLK0_PERIPHERAL_FREQMHZ {111.111115} CONFIG.PCW_ACT_TTC0_CLK1_PERIPHERAL_FREQMHZ {111.111115} \
            CONFIG.PCW_ACT_TTC0_CLK2_PERIPHERAL_FREQMHZ {111.111115} CONFIG.PCW_ACT_TTC1_CLK0_PERIPHERAL_FREQMHZ {111.111115} \
            CONFIG.PCW_ACT_TTC1_CLK1_PERIPHERAL_FREQMHZ {111.111115} CONFIG.PCW_ACT_TTC1_CLK2_PERIPHERAL_FREQMHZ {111.111115} \
            CONFIG.PCW_ACT_TTC_PERIPHERAL_FREQMHZ {50} CONFIG.PCW_ACT_UART_PERIPHERAL_FREQMHZ {100.000000} \
            CONFIG.PCW_ACT_USB0_PERIPHERAL_FREQMHZ {60} CONFIG.PCW_ACT_USB1_PERIPHERAL_FREQMHZ {60} \
            CONFIG.PCW_ACT_WDT_PERIPHERAL_FREQMHZ {111.111115} CONFIG.PCW_APU_CLK_RATIO_ENABLE {6:2:1} \
            CONFIG.PCW_APU_PERIPHERAL_FREQMHZ {666.666666} CONFIG.PCW_ARMPLL_CTRL_FBDIV {40} \
            CONFIG.PCW_CAN0_BASEADDR {0xE0008000} CONFIG.PCW_CAN0_GRP_CLK_ENABLE {0} \
            CONFIG.PCW_CAN0_HIGHADDR {0xE0008FFF} CONFIG.PCW_CAN0_PERIPHERAL_CLKSRC {External} \
            CONFIG.PCW_CAN0_PERIPHERAL_ENABLE {0} CONFIG.PCW_CAN0_PERIPHERAL_FREQMHZ {-1} \
            CONFIG.PCW_CAN1_BASEADDR {0xE0009000} CONFIG.PCW_CAN1_GRP_CLK_ENABLE {0} \
            CONFIG.PCW_CAN1_HIGHADDR {0xE0009FFF} CONFIG.PCW_CAN1_PERIPHERAL_CLKSRC {External} \
            CONFIG.PCW_CAN1_PERIPHERAL_ENABLE {0} CONFIG.PCW_CAN1_PERIPHERAL_FREQMHZ {-1} \
            CONFIG.PCW_CAN_PERIPHERAL_CLKSRC {IO PLL} CONFIG.PCW_CAN_PERIPHERAL_DIVISOR0 {1} \
            CONFIG.PCW_CAN_PERIPHERAL_DIVISOR1 {1} CONFIG.PCW_CAN_PERIPHERAL_FREQMHZ {100} \
            CONFIG.PCW_CAN_PERIPHERAL_VALID {0} CONFIG.PCW_CLK0_FREQ {100000000} \
            CONFIG.PCW_CLK1_FREQ {100000000} CONFIG.PCW_CLK2_FREQ {125000000} \
            CONFIG.PCW_CLK3_FREQ {200000000} CONFIG.PCW_CORE0_FIQ_INTR {0} \
            CONFIG.PCW_CORE0_IRQ_INTR {0} CONFIG.PCW_CORE1_FIQ_INTR {0} \
            CONFIG.PCW_CORE1_IRQ_INTR {0} CONFIG.PCW_CPU_CPU_6X4X_MAX_RANGE {667} \
            CONFIG.PCW_CPU_CPU_PLL_FREQMHZ {1333.333} CONFIG.PCW_CPU_PERIPHERAL_CLKSRC {ARM PLL} \
            CONFIG.PCW_CPU_PERIPHERAL_DIVISOR0 {2} CONFIG.PCW_CRYSTAL_PERIPHERAL_FREQMHZ {33.333333} \
            CONFIG.PCW_DCI_PERIPHERAL_CLKSRC {DDR PLL} CONFIG.PCW_DCI_PERIPHERAL_DIVISOR0 {35} \
            CONFIG.PCW_DCI_PERIPHERAL_DIVISOR1 {3} CONFIG.PCW_DCI_PERIPHERAL_FREQMHZ {10.159} \
            CONFIG.PCW_DDRPLL_CTRL_FBDIV {32} CONFIG.PCW_DDR_DDR_PLL_FREQMHZ {1066.667} \
            CONFIG.PCW_DDR_HPRLPR_QUEUE_PARTITION {HPR(0)/LPR(32)} CONFIG.PCW_DDR_HPR_TO_CRITICAL_PRIORITY_LEVEL {15} \
            CONFIG.PCW_DDR_LPR_TO_CRITICAL_PRIORITY_LEVEL {2} CONFIG.PCW_DDR_PERIPHERAL_CLKSRC {DDR PLL} \
            CONFIG.PCW_DDR_PERIPHERAL_DIVISOR0 {2} CONFIG.PCW_DDR_PORT0_HPR_ENABLE {0} \
            CONFIG.PCW_DDR_PORT1_HPR_ENABLE {0} CONFIG.PCW_DDR_PORT2_HPR_ENABLE {0} \
            CONFIG.PCW_DDR_PORT3_HPR_ENABLE {0} CONFIG.PCW_DDR_RAM_BASEADDR {0x00100000} \
            CONFIG.PCW_DDR_RAM_HIGHADDR {0x3FFFFFFF} CONFIG.PCW_DDR_WRITE_TO_CRITICAL_PRIORITY_LEVEL {2} \
            CONFIG.PCW_DM_WIDTH {4} CONFIG.PCW_DQS_WIDTH {4} CONFIG.PCW_DQ_WIDTH {32} CONFIG.PCW_ENET0_BASEADDR {0xE000B000} \
            CONFIG.PCW_ENET0_ENET0_IO {MIO 16 .. 27} CONFIG.PCW_ENET0_GRP_MDIO_ENABLE {1} \
            CONFIG.PCW_ENET0_GRP_MDIO_IO {MIO 52 .. 53} CONFIG.PCW_ENET0_HIGHADDR {0xE000BFFF} \
            CONFIG.PCW_ENET0_PERIPHERAL_CLKSRC {IO PLL} CONFIG.PCW_ENET0_PERIPHERAL_DIVISOR0 {8} \
            CONFIG.PCW_ENET0_PERIPHERAL_DIVISOR1 {1} CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {1} \
            CONFIG.PCW_ENET0_PERIPHERAL_FREQMHZ {1000 Mbps} CONFIG.PCW_ENET0_RESET_ENABLE {1} \
            CONFIG.PCW_ENET0_RESET_IO {MIO 11} CONFIG.PCW_ENET1_BASEADDR {0xE000C000} \
            CONFIG.PCW_ENET1_GRP_MDIO_ENABLE {0} CONFIG.PCW_ENET1_HIGHADDR {0xE000CFFF} \
            CONFIG.PCW_ENET1_PERIPHERAL_CLKSRC {IO PLL} CONFIG.PCW_ENET1_PERIPHERAL_DIVISOR0 {1} \
            CONFIG.PCW_ENET1_PERIPHERAL_DIVISOR1 {1} CONFIG.PCW_ENET1_PERIPHERAL_ENABLE {0} \
            CONFIG.PCW_ENET1_PERIPHERAL_FREQMHZ {1000 Mbps} CONFIG.PCW_ENET1_RESET_ENABLE {0} \
            CONFIG.PCW_ENET_RESET_ENABLE {1} CONFIG.PCW_ENET_RESET_POLARITY {Active Low} \
            CONFIG.PCW_ENET_RESET_SELECT {Share reset pin} CONFIG.PCW_EN_4K_TIMER {0} \
            CONFIG.PCW_EN_CAN0 {0} CONFIG.PCW_EN_CAN1 {0} CONFIG.PCW_EN_CLK0_PORT {1} \
            CONFIG.PCW_EN_CLK1_PORT {0} CONFIG.PCW_EN_CLK2_PORT {0} CONFIG.PCW_EN_CLK3_PORT {1} \
            CONFIG.PCW_EN_CLKTRIG0_PORT {0} CONFIG.PCW_EN_CLKTRIG1_PORT {0} CONFIG.PCW_EN_CLKTRIG2_PORT {0} \
            CONFIG.PCW_EN_CLKTRIG3_PORT {0} CONFIG.PCW_EN_DDR {1} CONFIG.PCW_EN_EMIO_CAN0 {0} \
            CONFIG.PCW_EN_EMIO_CAN1 {0} CONFIG.PCW_EN_EMIO_CD_SDIO0 {0} CONFIG.PCW_EN_EMIO_CD_SDIO1 {0} \
            CONFIG.PCW_EN_EMIO_ENET0 {0} CONFIG.PCW_EN_EMIO_ENET1 {0} CONFIG.PCW_EN_EMIO_GPIO {1} \
            CONFIG.PCW_EN_EMIO_I2C0 {0} CONFIG.PCW_EN_EMIO_I2C1 {0} CONFIG.PCW_EN_EMIO_MODEM_UART0 {0} \
            CONFIG.PCW_EN_EMIO_MODEM_UART1 {0} CONFIG.PCW_EN_EMIO_PJTAG {0} CONFIG.PCW_EN_EMIO_SDIO0 {0} \
            CONFIG.PCW_EN_EMIO_SDIO1 {0} CONFIG.PCW_EN_EMIO_SPI0 {1} CONFIG.PCW_EN_EMIO_SPI1 {1} \
            CONFIG.PCW_EN_EMIO_SRAM_INT {0} CONFIG.PCW_EN_EMIO_TRACE {0} \
            CONFIG.PCW_EN_EMIO_TTC0 {0} CONFIG.PCW_EN_EMIO_TTC1 {0} \
            CONFIG.PCW_EN_EMIO_UART0 {0} CONFIG.PCW_EN_EMIO_UART1 {0} \
            CONFIG.PCW_EN_EMIO_WDT {0} CONFIG.PCW_EN_EMIO_WP_SDIO0 {0} \
            CONFIG.PCW_EN_EMIO_WP_SDIO1 {0} CONFIG.PCW_EN_ENET0 {1} \
            CONFIG.PCW_EN_ENET1 {0} CONFIG.PCW_EN_GPIO {1} \
            CONFIG.PCW_EN_I2C0 {1} CONFIG.PCW_EN_I2C1 {0} \
            CONFIG.PCW_EN_MODEM_UART0 {0} CONFIG.PCW_EN_MODEM_UART1 {0} \
            CONFIG.PCW_EN_PJTAG {0} CONFIG.PCW_EN_QSPI {0} \
            CONFIG.PCW_EN_RST0_PORT {1} CONFIG.PCW_EN_RST1_PORT {1} CONFIG.PCW_EN_RST2_PORT {1} \
            CONFIG.PCW_EN_RST3_PORT {1} CONFIG.PCW_EN_SDIO0 {1} CONFIG.PCW_EN_SDIO1 {0} \
            CONFIG.PCW_EN_SMC {0} CONFIG.PCW_EN_SPI0 {1} CONFIG.PCW_EN_SPI1 {1} \
            CONFIG.PCW_EN_TRACE {0} CONFIG.PCW_EN_TTC0 {0} CONFIG.PCW_EN_TTC1 {0} \
            CONFIG.PCW_EN_UART0 {1} CONFIG.PCW_EN_UART1 {1} CONFIG.PCW_EN_USB0 {1} \
            CONFIG.PCW_EN_USB1 {0} CONFIG.PCW_EN_WDT {0} CONFIG.PCW_FCLK0_PERIPHERAL_CLKSRC {IO PLL} \
            CONFIG.PCW_FCLK0_PERIPHERAL_DIVISOR0 {10} CONFIG.PCW_FCLK0_PERIPHERAL_DIVISOR1 {1} \
            CONFIG.PCW_FCLK1_PERIPHERAL_CLKSRC {IO PLL} CONFIG.PCW_FCLK1_PERIPHERAL_DIVISOR0 {10} \
            CONFIG.PCW_FCLK1_PERIPHERAL_DIVISOR1 {1} CONFIG.PCW_FCLK2_PERIPHERAL_CLKSRC {IO PLL} \
            CONFIG.PCW_FCLK2_PERIPHERAL_DIVISOR0 {8} CONFIG.PCW_FCLK2_PERIPHERAL_DIVISOR1 {1} \
            CONFIG.PCW_FCLK3_PERIPHERAL_CLKSRC {IO PLL} CONFIG.PCW_FCLK3_PERIPHERAL_DIVISOR0 {5} \
            CONFIG.PCW_FCLK3_PERIPHERAL_DIVISOR1 {1} CONFIG.PCW_FCLK_CLK0_BUF {true} \
            CONFIG.PCW_FCLK_CLK1_BUF {false} CONFIG.PCW_FCLK_CLK2_BUF {false} \
            CONFIG.PCW_FCLK_CLK3_BUF {true} CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {100} \
            CONFIG.PCW_FPGA1_PERIPHERAL_FREQMHZ {100.000000} CONFIG.PCW_FPGA2_PERIPHERAL_FREQMHZ {125.000000} \
            CONFIG.PCW_FPGA3_PERIPHERAL_FREQMHZ {200} CONFIG.PCW_FPGA_FCLK0_ENABLE {1} \
            CONFIG.PCW_FPGA_FCLK1_ENABLE {0} CONFIG.PCW_FPGA_FCLK2_ENABLE {0} \
            CONFIG.PCW_FPGA_FCLK3_ENABLE {1} CONFIG.PCW_GPIO_BASEADDR {0xE000A000} \
            CONFIG.PCW_GPIO_EMIO_GPIO_ENABLE {1} CONFIG.PCW_GPIO_EMIO_GPIO_IO {64} \
            CONFIG.PCW_GPIO_EMIO_GPIO_WIDTH {64} CONFIG.PCW_GPIO_HIGHADDR {0xE000AFFF} \
            CONFIG.PCW_GPIO_MIO_GPIO_ENABLE {1} CONFIG.PCW_GPIO_MIO_GPIO_IO {MIO} \
            CONFIG.PCW_GPIO_PERIPHERAL_ENABLE {1} CONFIG.PCW_I2C0_BASEADDR {0xE0004000} \
            CONFIG.PCW_I2C0_GRP_INT_ENABLE {0} CONFIG.PCW_I2C0_HIGHADDR {0xE0004FFF} \
            CONFIG.PCW_I2C0_I2C0_IO {MIO 46 .. 47} CONFIG.PCW_I2C0_PERIPHERAL_ENABLE {1} \
            CONFIG.PCW_I2C0_RESET_ENABLE {0} CONFIG.PCW_I2C1_BASEADDR {0xE0005000} \
            CONFIG.PCW_I2C1_GRP_INT_ENABLE {0} CONFIG.PCW_I2C1_HIGHADDR {0xE0005FFF} \
            CONFIG.PCW_I2C1_PERIPHERAL_ENABLE {0} CONFIG.PCW_I2C1_RESET_ENABLE {0} \
            CONFIG.PCW_I2C_PERIPHERAL_FREQMHZ {111.111115} CONFIG.PCW_I2C_RESET_ENABLE {1} \
            CONFIG.PCW_I2C_RESET_POLARITY {Active Low} CONFIG.PCW_I2C_RESET_SELECT {Share reset pin} \
            CONFIG.PCW_IMPORT_BOARD_PRESET {None} CONFIG.PCW_INCLUDE_ACP_TRANS_CHECK {0} \
            CONFIG.PCW_INCLUDE_TRACE_BUFFER {0} CONFIG.PCW_IOPLL_CTRL_FBDIV {30} \
            CONFIG.PCW_IO_IO_PLL_FREQMHZ {1000.000} CONFIG.PCW_IRQ_F2P_INTR {1} \
            CONFIG.PCW_IRQ_F2P_MODE {DIRECT} CONFIG.PCW_MIO_0_DIRECTION {in} \
            CONFIG.PCW_MIO_0_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_0_PULLUP {enabled} \
            CONFIG.PCW_MIO_0_SLEW {slow} CONFIG.PCW_MIO_10_DIRECTION {inout} \
            CONFIG.PCW_MIO_10_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_10_PULLUP {enabled} \
            CONFIG.PCW_MIO_10_SLEW {slow} CONFIG.PCW_MIO_11_DIRECTION {out} \
            CONFIG.PCW_MIO_11_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_11_PULLUP {enabled} \
            CONFIG.PCW_MIO_11_SLEW {slow} CONFIG.PCW_MIO_12_DIRECTION {inout} \
            CONFIG.PCW_MIO_12_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_12_PULLUP {enabled} \
            CONFIG.PCW_MIO_12_SLEW {slow} CONFIG.PCW_MIO_13_DIRECTION {inout} \
            CONFIG.PCW_MIO_13_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_13_PULLUP {enabled} \
            CONFIG.PCW_MIO_13_SLEW {slow} CONFIG.PCW_MIO_14_DIRECTION {in} \
            CONFIG.PCW_MIO_14_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_14_PULLUP {enabled} \
            CONFIG.PCW_MIO_14_SLEW {slow} CONFIG.PCW_MIO_15_DIRECTION {out} \
            CONFIG.PCW_MIO_15_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_15_PULLUP {enabled} \
            CONFIG.PCW_MIO_15_SLEW {slow} CONFIG.PCW_MIO_16_DIRECTION {out} \
            CONFIG.PCW_MIO_16_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_16_PULLUP {enabled} \
            CONFIG.PCW_MIO_16_SLEW {slow} CONFIG.PCW_MIO_17_DIRECTION {out} \
            CONFIG.PCW_MIO_17_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_17_PULLUP {enabled} \
            CONFIG.PCW_MIO_17_SLEW {slow} CONFIG.PCW_MIO_18_DIRECTION {out} \
            CONFIG.PCW_MIO_18_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_18_PULLUP {enabled} \
            CONFIG.PCW_MIO_18_SLEW {slow} CONFIG.PCW_MIO_19_DIRECTION {out} \
            CONFIG.PCW_MIO_19_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_19_PULLUP {enabled} \
            CONFIG.PCW_MIO_19_SLEW {slow} CONFIG.PCW_MIO_1_DIRECTION {inout} \
            CONFIG.PCW_MIO_1_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_1_PULLUP {enabled} \
            CONFIG.PCW_MIO_1_SLEW {slow} CONFIG.PCW_MIO_20_DIRECTION {out} \
            CONFIG.PCW_MIO_20_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_20_PULLUP {enabled} \
            CONFIG.PCW_MIO_20_SLEW {slow} CONFIG.PCW_MIO_21_DIRECTION {out} \
            CONFIG.PCW_MIO_21_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_21_PULLUP {enabled} \
            CONFIG.PCW_MIO_21_SLEW {slow} CONFIG.PCW_MIO_22_DIRECTION {in} \
            CONFIG.PCW_MIO_22_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_22_PULLUP {enabled} \
            CONFIG.PCW_MIO_22_SLEW {slow} CONFIG.PCW_MIO_23_DIRECTION {in} \
            CONFIG.PCW_MIO_23_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_23_PULLUP {enabled} \
            CONFIG.PCW_MIO_23_SLEW {slow} CONFIG.PCW_MIO_24_DIRECTION {in} \
            CONFIG.PCW_MIO_24_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_24_PULLUP {enabled} CONFIG.PCW_MIO_24_SLEW {slow} \
            CONFIG.PCW_MIO_25_DIRECTION {in} CONFIG.PCW_MIO_25_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_25_PULLUP {enabled} \
            CONFIG.PCW_MIO_25_SLEW {slow} CONFIG.PCW_MIO_26_DIRECTION {in} CONFIG.PCW_MIO_26_IOTYPE {LVCMOS 1.8V} \
            CONFIG.PCW_MIO_26_PULLUP {enabled} CONFIG.PCW_MIO_26_SLEW {slow} CONFIG.PCW_MIO_27_DIRECTION {in} \
            CONFIG.PCW_MIO_27_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_27_PULLUP {enabled} CONFIG.PCW_MIO_27_SLEW {slow} \
            CONFIG.PCW_MIO_28_DIRECTION {inout} CONFIG.PCW_MIO_28_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_28_PULLUP {enabled} \
            CONFIG.PCW_MIO_28_SLEW {slow} CONFIG.PCW_MIO_29_DIRECTION {in} CONFIG.PCW_MIO_29_IOTYPE {LVCMOS 1.8V} \
            CONFIG.PCW_MIO_29_PULLUP {enabled} CONFIG.PCW_MIO_29_SLEW {slow} CONFIG.PCW_MIO_2_DIRECTION {inout} \
            CONFIG.PCW_MIO_2_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_2_PULLUP {disabled} CONFIG.PCW_MIO_2_SLEW {slow} \
            CONFIG.PCW_MIO_30_DIRECTION {out} CONFIG.PCW_MIO_30_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_30_PULLUP {enabled} \
            CONFIG.PCW_MIO_30_SLEW {slow} CONFIG.PCW_MIO_31_DIRECTION {in} CONFIG.PCW_MIO_31_IOTYPE {LVCMOS 1.8V} \
            CONFIG.PCW_MIO_31_PULLUP {enabled} CONFIG.PCW_MIO_31_SLEW {slow} CONFIG.PCW_MIO_32_DIRECTION {inout} \
            CONFIG.PCW_MIO_32_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_32_PULLUP {enabled} CONFIG.PCW_MIO_32_SLEW {slow} \
            CONFIG.PCW_MIO_33_DIRECTION {inout} CONFIG.PCW_MIO_33_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_33_PULLUP {enabled} \
            CONFIG.PCW_MIO_33_SLEW {slow} CONFIG.PCW_MIO_34_DIRECTION {inout} CONFIG.PCW_MIO_34_IOTYPE {LVCMOS 1.8V} \
            CONFIG.PCW_MIO_34_PULLUP {enabled} CONFIG.PCW_MIO_34_SLEW {slow} CONFIG.PCW_MIO_35_DIRECTION {inout} \
            CONFIG.PCW_MIO_35_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_35_PULLUP {enabled} CONFIG.PCW_MIO_35_SLEW {slow} \
            CONFIG.PCW_MIO_36_DIRECTION {in} CONFIG.PCW_MIO_36_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_36_PULLUP {enabled} \
            CONFIG.PCW_MIO_36_SLEW {slow} CONFIG.PCW_MIO_37_DIRECTION {inout} CONFIG.PCW_MIO_37_IOTYPE {LVCMOS 1.8V} \
            CONFIG.PCW_MIO_37_PULLUP {enabled} CONFIG.PCW_MIO_37_SLEW {slow} CONFIG.PCW_MIO_38_DIRECTION {inout} \
            CONFIG.PCW_MIO_38_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_38_PULLUP {enabled} CONFIG.PCW_MIO_38_SLEW {slow} \
            CONFIG.PCW_MIO_39_DIRECTION {inout} CONFIG.PCW_MIO_39_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_39_PULLUP {enabled} \
            CONFIG.PCW_MIO_39_SLEW {slow} CONFIG.PCW_MIO_3_DIRECTION {inout} CONFIG.PCW_MIO_3_IOTYPE {LVCMOS 1.8V} \
            CONFIG.PCW_MIO_3_PULLUP {disabled} CONFIG.PCW_MIO_3_SLEW {slow} CONFIG.PCW_MIO_40_DIRECTION {inout} \
            CONFIG.PCW_MIO_40_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_40_PULLUP {enabled} CONFIG.PCW_MIO_40_SLEW {slow} \
            CONFIG.PCW_MIO_41_DIRECTION {inout} CONFIG.PCW_MIO_41_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_41_PULLUP {enabled} \
            CONFIG.PCW_MIO_41_SLEW {slow} CONFIG.PCW_MIO_42_DIRECTION {inout} CONFIG.PCW_MIO_42_IOTYPE {LVCMOS 1.8V} \
            CONFIG.PCW_MIO_42_PULLUP {enabled} CONFIG.PCW_MIO_42_SLEW {slow} CONFIG.PCW_MIO_43_DIRECTION {inout} \
            CONFIG.PCW_MIO_43_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_43_PULLUP {enabled} CONFIG.PCW_MIO_43_SLEW {slow} \
            CONFIG.PCW_MIO_44_DIRECTION {inout} CONFIG.PCW_MIO_44_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_44_PULLUP {enabled} \
            CONFIG.PCW_MIO_44_SLEW {slow} CONFIG.PCW_MIO_45_DIRECTION {inout} CONFIG.PCW_MIO_45_IOTYPE {LVCMOS 1.8V} \
            CONFIG.PCW_MIO_45_PULLUP {enabled} CONFIG.PCW_MIO_45_SLEW {slow} CONFIG.PCW_MIO_46_DIRECTION {inout} \
            CONFIG.PCW_MIO_46_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_46_PULLUP {enabled} CONFIG.PCW_MIO_46_SLEW {slow} \
            CONFIG.PCW_MIO_47_DIRECTION {inout} CONFIG.PCW_MIO_47_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_47_PULLUP {enabled} \
            CONFIG.PCW_MIO_47_SLEW {slow} CONFIG.PCW_MIO_48_DIRECTION {out} CONFIG.PCW_MIO_48_IOTYPE {LVCMOS 1.8V} \
            CONFIG.PCW_MIO_48_PULLUP {enabled} CONFIG.PCW_MIO_48_SLEW {slow} CONFIG.PCW_MIO_49_DIRECTION {in} \
            CONFIG.PCW_MIO_49_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_49_PULLUP {enabled} CONFIG.PCW_MIO_49_SLEW {slow} \
            CONFIG.PCW_MIO_4_DIRECTION {inout} CONFIG.PCW_MIO_4_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_4_PULLUP {disabled} \
            CONFIG.PCW_MIO_4_SLEW {slow} CONFIG.PCW_MIO_50_DIRECTION {inout} CONFIG.PCW_MIO_50_IOTYPE {LVCMOS 1.8V} \
            CONFIG.PCW_MIO_50_PULLUP {enabled} CONFIG.PCW_MIO_50_SLEW {slow} CONFIG.PCW_MIO_51_DIRECTION {inout} \
            CONFIG.PCW_MIO_51_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_51_PULLUP {enabled} CONFIG.PCW_MIO_51_SLEW {slow} \
            CONFIG.PCW_MIO_52_DIRECTION {out} CONFIG.PCW_MIO_52_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_52_PULLUP {enabled} \
            CONFIG.PCW_MIO_52_SLEW {slow} CONFIG.PCW_MIO_53_DIRECTION {inout} CONFIG.PCW_MIO_53_IOTYPE {LVCMOS 1.8V} \
            CONFIG.PCW_MIO_53_PULLUP {enabled} CONFIG.PCW_MIO_53_SLEW {slow} CONFIG.PCW_MIO_5_DIRECTION {inout} \
            CONFIG.PCW_MIO_5_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_5_PULLUP {disabled} CONFIG.PCW_MIO_5_SLEW {slow} \
            CONFIG.PCW_MIO_6_DIRECTION {inout} CONFIG.PCW_MIO_6_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_6_PULLUP {disabled} \
            CONFIG.PCW_MIO_6_SLEW {slow} CONFIG.PCW_MIO_7_DIRECTION {out} CONFIG.PCW_MIO_7_IOTYPE {LVCMOS 1.8V} \
            CONFIG.PCW_MIO_7_PULLUP {disabled} CONFIG.PCW_MIO_7_SLEW {slow} CONFIG.PCW_MIO_8_DIRECTION {out} \
            CONFIG.PCW_MIO_8_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_8_PULLUP {disabled} CONFIG.PCW_MIO_8_SLEW {slow} \
            CONFIG.PCW_MIO_9_DIRECTION {out} CONFIG.PCW_MIO_9_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_9_PULLUP {enabled} \
            CONFIG.PCW_MIO_9_SLEW {slow} CONFIG.PCW_MIO_PRIMITIVE {54} \
            CONFIG.PCW_MIO_TREE_PERIPHERALS {SD 0#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#USB Reset#GPIO#ENET Reset#GPIO#GPIO#UART 0#UART 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#SD 0#SD 0#SD 0#SD 0#SD 0#SD 0#I2C 0#I2C 0#UART 1#UART 1#GPIO#GPIO#Enet 0#Enet 0} \
            CONFIG.PCW_MIO_TREE_SIGNALS {cd#gpio[1]#gpio[2]#gpio[3]#gpio[4]#gpio[5]#gpio[6]#gpio[7]#gpio[8]#reset#gpio[10]#reset#gpio[12]#gpio[13]#rx#tx#tx_clk#txd[0]#txd[1]#txd[2]#txd[3]#tx_ctl#rx_clk#rxd[0]#rxd[1]#rxd[2]#rxd[3]#rx_ctl#data[4]#dir#stp#nxt#data[0]#data[1]#data[2]#data[3]#clk#data[5]#data[6]#data[7]#clk#cmd#data[0]#data[1]#data[2]#data[3]#scl#sda#tx#rx#gpio[50]#gpio[51]#mdc#mdio} \
            CONFIG.PCW_M_AXI_GP0_ENABLE_STATIC_REMAP {0} CONFIG.PCW_M_AXI_GP0_FREQMHZ {50} CONFIG.PCW_M_AXI_GP0_ID_WIDTH {12} \
            CONFIG.PCW_M_AXI_GP0_SUPPORT_NARROW_BURST {0} CONFIG.PCW_M_AXI_GP0_THREAD_ID_WIDTH {12} CONFIG.PCW_M_AXI_GP1_ENABLE_STATIC_REMAP {0} \
            CONFIG.PCW_M_AXI_GP1_FREQMHZ {10} CONFIG.PCW_M_AXI_GP1_ID_WIDTH {12} CONFIG.PCW_M_AXI_GP1_SUPPORT_NARROW_BURST {0} \
            CONFIG.PCW_M_AXI_GP1_THREAD_ID_WIDTH {12} CONFIG.PCW_NAND_CYCLES_T_AR {0} CONFIG.PCW_NAND_CYCLES_T_CLR {0} \
            CONFIG.PCW_NAND_CYCLES_T_RC {2} CONFIG.PCW_NAND_CYCLES_T_REA {1} CONFIG.PCW_NAND_CYCLES_T_RR {0} \
            CONFIG.PCW_NAND_CYCLES_T_WC {2} CONFIG.PCW_NAND_CYCLES_T_WP {1} CONFIG.PCW_NAND_GRP_D8_ENABLE {0} \
            CONFIG.PCW_NAND_PERIPHERAL_ENABLE {0} CONFIG.PCW_NOR_CS0_T_CEOE {1} CONFIG.PCW_NOR_CS0_T_PC {1} \
            CONFIG.PCW_NOR_CS0_T_RC {2} CONFIG.PCW_NOR_CS0_T_TR {1} CONFIG.PCW_NOR_CS0_T_WC {2} \
            CONFIG.PCW_NOR_CS0_T_WP {1} CONFIG.PCW_NOR_CS0_WE_TIME {2} CONFIG.PCW_NOR_CS1_T_CEOE {1} \
            CONFIG.PCW_NOR_CS1_T_PC {1} CONFIG.PCW_NOR_CS1_T_RC {2} CONFIG.PCW_NOR_CS1_T_TR {1} \
            CONFIG.PCW_NOR_CS1_T_WC {2} CONFIG.PCW_NOR_CS1_T_WP {1} CONFIG.PCW_NOR_CS1_WE_TIME {2} \
            CONFIG.PCW_NOR_GRP_A25_ENABLE {0} CONFIG.PCW_NOR_GRP_CS0_ENABLE {0} CONFIG.PCW_NOR_GRP_CS1_ENABLE {0} \
            CONFIG.PCW_NOR_GRP_SRAM_CS0_ENABLE {0} CONFIG.PCW_NOR_GRP_SRAM_CS1_ENABLE {0} CONFIG.PCW_NOR_GRP_SRAM_INT_ENABLE {0} \
            CONFIG.PCW_NOR_PERIPHERAL_ENABLE {0} CONFIG.PCW_NOR_SRAM_CS0_T_CEOE {1} CONFIG.PCW_NOR_SRAM_CS0_T_PC {1} \
            CONFIG.PCW_NOR_SRAM_CS0_T_RC {2} CONFIG.PCW_NOR_SRAM_CS0_T_TR {1} CONFIG.PCW_NOR_SRAM_CS0_T_WC {2} \
            CONFIG.PCW_NOR_SRAM_CS0_T_WP {1} CONFIG.PCW_NOR_SRAM_CS0_WE_TIME {2} CONFIG.PCW_NOR_SRAM_CS1_T_CEOE {1} \
            CONFIG.PCW_NOR_SRAM_CS1_T_PC {1} CONFIG.PCW_NOR_SRAM_CS1_T_RC {2} CONFIG.PCW_NOR_SRAM_CS1_T_TR {1} \
            CONFIG.PCW_NOR_SRAM_CS1_T_WC {2} CONFIG.PCW_NOR_SRAM_CS1_T_WP {1} CONFIG.PCW_NOR_SRAM_CS1_WE_TIME {2} \
            CONFIG.PCW_OVERRIDE_BASIC_CLOCK {0} CONFIG.PCW_P2F_CAN0_INTR {0} CONFIG.PCW_P2F_CAN1_INTR {0} \
            CONFIG.PCW_P2F_CTI_INTR {0} CONFIG.PCW_P2F_DMAC0_INTR {0} CONFIG.PCW_P2F_DMAC1_INTR {0} \
            CONFIG.PCW_P2F_DMAC2_INTR {0} CONFIG.PCW_P2F_DMAC3_INTR {0} CONFIG.PCW_P2F_DMAC4_INTR {0} \
            CONFIG.PCW_P2F_DMAC5_INTR {0} CONFIG.PCW_P2F_DMAC6_INTR {0} CONFIG.PCW_P2F_DMAC7_INTR {0} \
            CONFIG.PCW_P2F_DMAC_ABORT_INTR {0} CONFIG.PCW_P2F_ENET0_INTR {0} CONFIG.PCW_P2F_ENET1_INTR {0} \
            CONFIG.PCW_P2F_GPIO_INTR {0} CONFIG.PCW_P2F_I2C0_INTR {0} CONFIG.PCW_P2F_I2C1_INTR {0} \
            CONFIG.PCW_P2F_QSPI_INTR {0} CONFIG.PCW_P2F_SDIO0_INTR {0} CONFIG.PCW_P2F_SDIO1_INTR {0} \
            CONFIG.PCW_P2F_SMC_INTR {0} CONFIG.PCW_P2F_SPI0_INTR {0} CONFIG.PCW_P2F_SPI1_INTR {0} \
            CONFIG.PCW_P2F_UART0_INTR {0} CONFIG.PCW_P2F_UART1_INTR {0} CONFIG.PCW_P2F_USB0_INTR {0} \
            CONFIG.PCW_P2F_USB1_INTR {0} CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY0 {0.063} CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY1 {0.062} \
            CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY2 {0.065} CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY3 {0.083} \
            CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_0 {-0.007} CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_1 {-0.010} \
            CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_2 {-0.006} CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_3 {-0.048} \
            CONFIG.PCW_PACKAGE_NAME {clg484} CONFIG.PCW_PCAP_PERIPHERAL_CLKSRC {IO PLL} \
            CONFIG.PCW_PCAP_PERIPHERAL_DIVISOR0 {5} CONFIG.PCW_PCAP_PERIPHERAL_FREQMHZ {200} \
            CONFIG.PCW_PERIPHERAL_BOARD_PRESET {None} CONFIG.PCW_PJTAG_PERIPHERAL_ENABLE {0} \
            CONFIG.PCW_PRESET_BANK0_VOLTAGE {LVCMOS 1.8V} CONFIG.PCW_PRESET_BANK1_VOLTAGE {LVCMOS 1.8V} \
            CONFIG.PCW_PS7_SI_REV {PRODUCTION} CONFIG.PCW_QSPI_GRP_FBCLK_ENABLE {0} \
            CONFIG.PCW_QSPI_GRP_IO1_ENABLE {0} CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {0} \
            CONFIG.PCW_QSPI_GRP_SS1_ENABLE {0} CONFIG.PCW_QSPI_INTERNAL_HIGHADDRESS {0xFCFFFFFF} \
            CONFIG.PCW_QSPI_PERIPHERAL_CLKSRC {IO PLL} CONFIG.PCW_QSPI_PERIPHERAL_DIVISOR0 {1} \
            CONFIG.PCW_QSPI_PERIPHERAL_ENABLE {0} CONFIG.PCW_QSPI_PERIPHERAL_FREQMHZ {200} \
            CONFIG.PCW_SD0_GRP_CD_ENABLE {1} CONFIG.PCW_SD0_GRP_CD_IO {MIO 0} \
            CONFIG.PCW_SD0_GRP_POW_ENABLE {0} CONFIG.PCW_SD0_GRP_WP_ENABLE {0} \
            CONFIG.PCW_SD0_PERIPHERAL_ENABLE {1} CONFIG.PCW_SD0_SD0_IO {MIO 40 .. 45} \
            CONFIG.PCW_SD1_GRP_CD_ENABLE {0} CONFIG.PCW_SD1_GRP_POW_ENABLE {0} \
            CONFIG.PCW_SD1_GRP_WP_ENABLE {0} CONFIG.PCW_SD1_PERIPHERAL_ENABLE {0} \
            CONFIG.PCW_SDIO0_BASEADDR {0xE0100000} CONFIG.PCW_SDIO0_HIGHADDR {0xE0100FFF} \
            CONFIG.PCW_SDIO1_BASEADDR {0xE0101000} CONFIG.PCW_SDIO1_HIGHADDR {0xE0101FFF} \
            CONFIG.PCW_SDIO_PERIPHERAL_CLKSRC {IO PLL} CONFIG.PCW_SDIO_PERIPHERAL_DIVISOR0 {8} \
            CONFIG.PCW_SDIO_PERIPHERAL_FREQMHZ {125} CONFIG.PCW_SDIO_PERIPHERAL_VALID {1} \
            CONFIG.PCW_SMC_CYCLE_T0 {NA} CONFIG.PCW_SMC_CYCLE_T1 {NA} CONFIG.PCW_SMC_CYCLE_T2 {NA} \
            CONFIG.PCW_SMC_CYCLE_T3 {NA} CONFIG.PCW_SMC_CYCLE_T4 {NA} CONFIG.PCW_SMC_CYCLE_T5 {NA} \
            CONFIG.PCW_SMC_CYCLE_T6 {NA} CONFIG.PCW_SMC_PERIPHERAL_CLKSRC {IO PLL} \
            CONFIG.PCW_SMC_PERIPHERAL_DIVISOR0 {1} CONFIG.PCW_SMC_PERIPHERAL_FREQMHZ {100} \
            CONFIG.PCW_SMC_PERIPHERAL_VALID {0} CONFIG.PCW_SPI0_BASEADDR {0xE0006000} \
            CONFIG.PCW_SPI0_GRP_SS0_ENABLE {1} CONFIG.PCW_SPI0_GRP_SS0_IO {EMIO} \
            CONFIG.PCW_SPI0_GRP_SS1_ENABLE {1} CONFIG.PCW_SPI0_GRP_SS1_IO {EMIO} \
            CONFIG.PCW_SPI0_GRP_SS2_ENABLE {1} CONFIG.PCW_SPI0_GRP_SS2_IO {EMIO} CONFIG.PCW_SPI0_HIGHADDR {0xE0006FFF} \
            CONFIG.PCW_SPI0_PERIPHERAL_ENABLE {1} CONFIG.PCW_SPI0_SPI0_IO {EMIO} CONFIG.PCW_SPI1_BASEADDR {0xE0007000} \
            CONFIG.PCW_SPI1_GRP_SS0_ENABLE {1} CONFIG.PCW_SPI1_GRP_SS0_IO {EMIO} CONFIG.PCW_SPI1_GRP_SS1_ENABLE {1} \
            CONFIG.PCW_SPI1_GRP_SS1_IO {EMIO} CONFIG.PCW_SPI1_GRP_SS2_ENABLE {1} CONFIG.PCW_SPI1_GRP_SS2_IO {EMIO} \
            CONFIG.PCW_SPI1_HIGHADDR {0xE0007FFF} CONFIG.PCW_SPI1_PERIPHERAL_ENABLE {1} CONFIG.PCW_SPI1_SPI1_IO {EMIO} \
            CONFIG.PCW_SPI_PERIPHERAL_CLKSRC {IO PLL} CONFIG.PCW_SPI_PERIPHERAL_DIVISOR0 {6} CONFIG.PCW_SPI_PERIPHERAL_FREQMHZ {166.666666} \
            CONFIG.PCW_SPI_PERIPHERAL_VALID {1} CONFIG.PCW_S_AXI_ACP_ARUSER_VAL {31} CONFIG.PCW_S_AXI_ACP_AWUSER_VAL {31} \
            CONFIG.PCW_S_AXI_ACP_FREQMHZ {10} CONFIG.PCW_S_AXI_ACP_ID_WIDTH {3} CONFIG.PCW_S_AXI_GP0_FREQMHZ {10} \
            CONFIG.PCW_S_AXI_GP0_ID_WIDTH {6} CONFIG.PCW_S_AXI_GP1_FREQMHZ {10} CONFIG.PCW_S_AXI_GP1_ID_WIDTH {6} \
            CONFIG.PCW_S_AXI_HP0_DATA_WIDTH {64} CONFIG.PCW_S_AXI_HP0_FREQMHZ {50} CONFIG.PCW_S_AXI_HP0_ID_WIDTH {6} \
            CONFIG.PCW_S_AXI_HP1_DATA_WIDTH {64} CONFIG.PCW_S_AXI_HP1_FREQMHZ {10} CONFIG.PCW_S_AXI_HP1_ID_WIDTH {6} \
            CONFIG.PCW_S_AXI_HP2_DATA_WIDTH {64} CONFIG.PCW_S_AXI_HP2_FREQMHZ {10} CONFIG.PCW_S_AXI_HP2_ID_WIDTH {6} \
            CONFIG.PCW_S_AXI_HP3_DATA_WIDTH {64} CONFIG.PCW_S_AXI_HP3_FREQMHZ {10} CONFIG.PCW_S_AXI_HP3_ID_WIDTH {6} \
            CONFIG.PCW_TPIU_PERIPHERAL_CLKSRC {External} CONFIG.PCW_TPIU_PERIPHERAL_DIVISOR0 {1} CONFIG.PCW_TPIU_PERIPHERAL_FREQMHZ {200} \
            CONFIG.PCW_TRACE_BUFFER_CLOCK_DELAY {12} CONFIG.PCW_TRACE_BUFFER_FIFO_SIZE {128} CONFIG.PCW_TRACE_GRP_16BIT_ENABLE {0} \
            CONFIG.PCW_TRACE_GRP_2BIT_ENABLE {0} CONFIG.PCW_TRACE_GRP_32BIT_ENABLE {0} CONFIG.PCW_TRACE_GRP_4BIT_ENABLE {0} \
            CONFIG.PCW_TRACE_GRP_8BIT_ENABLE {0} CONFIG.PCW_TRACE_INTERNAL_WIDTH {2} CONFIG.PCW_TRACE_PERIPHERAL_ENABLE {0} \
            CONFIG.PCW_TRACE_PIPELINE_WIDTH {8} CONFIG.PCW_TTC0_BASEADDR {0xE0104000} CONFIG.PCW_TTC0_CLK0_PERIPHERAL_CLKSRC {CPU_1X} \
            CONFIG.PCW_TTC0_CLK0_PERIPHERAL_DIVISOR0 {1} CONFIG.PCW_TTC0_CLK0_PERIPHERAL_FREQMHZ {133.333333} \
            CONFIG.PCW_TTC0_CLK1_PERIPHERAL_CLKSRC {CPU_1X} CONFIG.PCW_TTC0_CLK1_PERIPHERAL_DIVISOR0 {1} \
            CONFIG.PCW_TTC0_CLK1_PERIPHERAL_FREQMHZ {133.333333} CONFIG.PCW_TTC0_CLK2_PERIPHERAL_CLKSRC {CPU_1X} \
            CONFIG.PCW_TTC0_CLK2_PERIPHERAL_DIVISOR0 {1} CONFIG.PCW_TTC0_CLK2_PERIPHERAL_FREQMHZ {133.333333} \
            CONFIG.PCW_TTC0_HIGHADDR {0xE0104fff} CONFIG.PCW_TTC0_PERIPHERAL_ENABLE {0} CONFIG.PCW_TTC1_BASEADDR {0xE0105000} \
            CONFIG.PCW_TTC1_CLK0_PERIPHERAL_CLKSRC {CPU_1X} CONFIG.PCW_TTC1_CLK0_PERIPHERAL_DIVISOR0 {1} CONFIG.PCW_TTC1_CLK0_PERIPHERAL_FREQMHZ {133.333333} \
            CONFIG.PCW_TTC1_CLK1_PERIPHERAL_CLKSRC {CPU_1X} CONFIG.PCW_TTC1_CLK1_PERIPHERAL_DIVISOR0 {1} CONFIG.PCW_TTC1_CLK1_PERIPHERAL_FREQMHZ {133.333333} \
            CONFIG.PCW_TTC1_CLK2_PERIPHERAL_CLKSRC {CPU_1X} CONFIG.PCW_TTC1_CLK2_PERIPHERAL_DIVISOR0 {1} CONFIG.PCW_TTC1_CLK2_PERIPHERAL_FREQMHZ {133.333333} \
            CONFIG.PCW_TTC1_HIGHADDR {0xE0105fff} CONFIG.PCW_TTC1_PERIPHERAL_ENABLE {0} CONFIG.PCW_TTC_PERIPHERAL_FREQMHZ {50} \
            CONFIG.PCW_UART0_BASEADDR {0xE0000000} CONFIG.PCW_UART0_BAUD_RATE {115200} CONFIG.PCW_UART0_GRP_FULL_ENABLE {0} \
            CONFIG.PCW_UART0_HIGHADDR {0xE0000FFF} CONFIG.PCW_UART0_PERIPHERAL_ENABLE {1} CONFIG.PCW_UART0_UART0_IO {MIO 14 .. 15} \
            CONFIG.PCW_UART1_BASEADDR {0xE0001000} CONFIG.PCW_UART1_BAUD_RATE {115200} CONFIG.PCW_UART1_GRP_FULL_ENABLE {0} \
            CONFIG.PCW_UART1_HIGHADDR {0xE0001FFF} CONFIG.PCW_UART1_PERIPHERAL_ENABLE {1} CONFIG.PCW_UART1_UART1_IO {MIO 48 .. 49} \
            CONFIG.PCW_UART_PERIPHERAL_CLKSRC {IO PLL} CONFIG.PCW_UART_PERIPHERAL_DIVISOR0 {10} CONFIG.PCW_UART_PERIPHERAL_FREQMHZ {100} \
            CONFIG.PCW_UART_PERIPHERAL_VALID {1} CONFIG.PCW_UIPARAM_ACT_DDR_FREQ_MHZ {533.333374} CONFIG.PCW_UIPARAM_DDR_ADV_ENABLE {0} \
            CONFIG.PCW_UIPARAM_DDR_AL {0} CONFIG.PCW_UIPARAM_DDR_BANK_ADDR_COUNT {3} CONFIG.PCW_UIPARAM_DDR_BL {8} CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY0 {0.0} \
            CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY1 {0.0} CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY2 {0.0} CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY3 {0.0} \
            CONFIG.PCW_UIPARAM_DDR_BUS_WIDTH {32 Bit} CONFIG.PCW_UIPARAM_DDR_CL {7} CONFIG.PCW_UIPARAM_DDR_CLOCK_0_LENGTH_MM {0} \
            CONFIG.PCW_UIPARAM_DDR_CLOCK_0_PACKAGE_LENGTH {61.0905} CONFIG.PCW_UIPARAM_DDR_CLOCK_0_PROPOGATION_DELAY {160} \
            CONFIG.PCW_UIPARAM_DDR_CLOCK_1_LENGTH_MM {0} CONFIG.PCW_UIPARAM_DDR_CLOCK_1_PACKAGE_LENGTH {61.0905} \
            CONFIG.PCW_UIPARAM_DDR_CLOCK_1_PROPOGATION_DELAY {160} CONFIG.PCW_UIPARAM_DDR_CLOCK_2_LENGTH_MM {0} \
            CONFIG.PCW_UIPARAM_DDR_CLOCK_2_PACKAGE_LENGTH {61.0905} CONFIG.PCW_UIPARAM_DDR_CLOCK_2_PROPOGATION_DELAY {160} \
            CONFIG.PCW_UIPARAM_DDR_CLOCK_3_LENGTH_MM {0} CONFIG.PCW_UIPARAM_DDR_CLOCK_3_PACKAGE_LENGTH {61.0905} \
            CONFIG.PCW_UIPARAM_DDR_CLOCK_3_PROPOGATION_DELAY {160} CONFIG.PCW_UIPARAM_DDR_CLOCK_STOP_EN {0} \
            CONFIG.PCW_UIPARAM_DDR_COL_ADDR_COUNT {10} CONFIG.PCW_UIPARAM_DDR_CWL {6} \
            CONFIG.PCW_UIPARAM_DDR_DEVICE_CAPACITY {4096 MBits} CONFIG.PCW_UIPARAM_DDR_DQS_0_LENGTH_MM {0} \
            CONFIG.PCW_UIPARAM_DDR_DQS_0_PACKAGE_LENGTH {68.4725} CONFIG.PCW_UIPARAM_DDR_DQS_0_PROPOGATION_DELAY {160} \
            CONFIG.PCW_UIPARAM_DDR_DQS_1_LENGTH_MM {0} CONFIG.PCW_UIPARAM_DDR_DQS_1_PACKAGE_LENGTH {71.086} CONFIG.PCW_UIPARAM_DDR_DQS_1_PROPOGATION_DELAY {160} \
            CONFIG.PCW_UIPARAM_DDR_DQS_2_LENGTH_MM {0} CONFIG.PCW_UIPARAM_DDR_DQS_2_PACKAGE_LENGTH {66.794} CONFIG.PCW_UIPARAM_DDR_DQS_2_PROPOGATION_DELAY {160} \
            CONFIG.PCW_UIPARAM_DDR_DQS_3_LENGTH_MM {0} CONFIG.PCW_UIPARAM_DDR_DQS_3_PACKAGE_LENGTH {108.7385} CONFIG.PCW_UIPARAM_DDR_DQS_3_PROPOGATION_DELAY {160} \
            CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_0 {0.0} CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_1 {0.0} CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_2 {0.0} \
            CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_3 {0.0} CONFIG.PCW_UIPARAM_DDR_DQ_0_LENGTH_MM {0} CONFIG.PCW_UIPARAM_DDR_DQ_0_PACKAGE_LENGTH {64.1705} \
            CONFIG.PCW_UIPARAM_DDR_DQ_0_PROPOGATION_DELAY {160} CONFIG.PCW_UIPARAM_DDR_DQ_1_LENGTH_MM {0} CONFIG.PCW_UIPARAM_DDR_DQ_1_PACKAGE_LENGTH {63.686} \
            CONFIG.PCW_UIPARAM_DDR_DQ_1_PROPOGATION_DELAY {160} CONFIG.PCW_UIPARAM_DDR_DQ_2_LENGTH_MM {0} CONFIG.PCW_UIPARAM_DDR_DQ_2_PACKAGE_LENGTH {68.46} \
            CONFIG.PCW_UIPARAM_DDR_DQ_2_PROPOGATION_DELAY {160} CONFIG.PCW_UIPARAM_DDR_DQ_3_LENGTH_MM {0} CONFIG.PCW_UIPARAM_DDR_DQ_3_PACKAGE_LENGTH {105.4895} \
            CONFIG.PCW_UIPARAM_DDR_DQ_3_PROPOGATION_DELAY {160} CONFIG.PCW_UIPARAM_DDR_DRAM_WIDTH {16 Bits} CONFIG.PCW_UIPARAM_DDR_ECC {Disabled} \
            CONFIG.PCW_UIPARAM_DDR_ENABLE {1} CONFIG.PCW_UIPARAM_DDR_FREQ_MHZ {533.333333} CONFIG.PCW_UIPARAM_DDR_HIGH_TEMP {Normal (0-85)} \
            CONFIG.PCW_UIPARAM_DDR_MEMORY_TYPE {DDR 3 (Low Voltage)} CONFIG.PCW_UIPARAM_DDR_PARTNO {Custom} \
            CONFIG.PCW_UIPARAM_DDR_ROW_ADDR_COUNT {15} CONFIG.PCW_UIPARAM_DDR_SPEED_BIN {DDR3_1066F} CONFIG.PCW_UIPARAM_DDR_TRAIN_DATA_EYE {1} \
            CONFIG.PCW_UIPARAM_DDR_TRAIN_READ_GATE {1} CONFIG.PCW_UIPARAM_DDR_TRAIN_WRITE_LEVEL {1} CONFIG.PCW_UIPARAM_DDR_T_FAW {40.0} \
            CONFIG.PCW_UIPARAM_DDR_T_RAS_MIN {35.0} CONFIG.PCW_UIPARAM_DDR_T_RC {48.75} CONFIG.PCW_UIPARAM_DDR_T_RCD {7} \
            CONFIG.PCW_UIPARAM_DDR_T_RP {7} CONFIG.PCW_UIPARAM_DDR_USE_INTERNAL_VREF {0} CONFIG.PCW_UIPARAM_GENERATE_SUMMARY {NA} \
            CONFIG.PCW_USB0_BASEADDR {0xE0102000} CONFIG.PCW_USB0_HIGHADDR {0xE0102fff} CONFIG.PCW_USB0_PERIPHERAL_ENABLE {1} \
            CONFIG.PCW_USB0_PERIPHERAL_FREQMHZ {60} CONFIG.PCW_USB0_RESET_ENABLE {1} CONFIG.PCW_USB0_RESET_IO {MIO 9} \
            CONFIG.PCW_USB0_USB0_IO {MIO 28 .. 39} CONFIG.PCW_USB1_BASEADDR {0xE0103000} CONFIG.PCW_USB1_HIGHADDR {0xE0103fff} \
            CONFIG.PCW_USB1_PERIPHERAL_ENABLE {0} CONFIG.PCW_USB1_PERIPHERAL_FREQMHZ {60} CONFIG.PCW_USB1_RESET_ENABLE {0} \
            CONFIG.PCW_USB_RESET_ENABLE {1} CONFIG.PCW_USB_RESET_POLARITY {Active Low} CONFIG.PCW_USB_RESET_SELECT {Share reset pin} \
            CONFIG.PCW_USE_AXI_FABRIC_IDLE {0} CONFIG.PCW_USE_AXI_NONSECURE {0} CONFIG.PCW_USE_CORESIGHT {0} \
            CONFIG.PCW_USE_CROSS_TRIGGER {0} CONFIG.PCW_USE_CR_FABRIC {1} CONFIG.PCW_USE_DDR_BYPASS {0} CONFIG.PCW_USE_DEBUG {0} \
            CONFIG.PCW_USE_DEFAULT_ACP_USER_VAL {1} CONFIG.PCW_USE_DMA0 {0} CONFIG.PCW_USE_DMA1 {0} CONFIG.PCW_USE_DMA2 {0} \
            CONFIG.PCW_USE_DMA3 {0} CONFIG.PCW_USE_EXPANDED_IOP {0} CONFIG.PCW_USE_EXPANDED_PS_SLCR_REGISTERS {0} \
            CONFIG.PCW_USE_FABRIC_INTERRUPT {1} CONFIG.PCW_USE_HIGH_OCM {0} CONFIG.PCW_USE_M_AXI_GP0 {1} \
            CONFIG.PCW_USE_M_AXI_GP1 {0} CONFIG.PCW_USE_PROC_EVENT_BUS {0} CONFIG.PCW_USE_PS_SLCR_REGISTERS {0} \
            CONFIG.PCW_USE_S_AXI_ACP {1} CONFIG.PCW_USE_S_AXI_GP0 {0} CONFIG.PCW_USE_S_AXI_GP1 {0} CONFIG.PCW_USE_S_AXI_HP0 {1} \
            CONFIG.PCW_USE_S_AXI_HP1 {1} CONFIG.PCW_USE_S_AXI_HP2 {0} CONFIG.PCW_USE_S_AXI_HP3 {0} CONFIG.PCW_USE_TRACE {0} \
            CONFIG.PCW_USE_TRACE_DATA_EDGE_DETECTOR {0} CONFIG.PCW_VALUE_SILVERSION {3} CONFIG.PCW_WDT_PERIPHERAL_CLKSRC {CPU_1X} \
            CONFIG.PCW_WDT_PERIPHERAL_DIVISOR0 {1} CONFIG.PCW_WDT_PERIPHERAL_ENABLE {0} CONFIG.PCW_WDT_PERIPHERAL_FREQMHZ {133.333333} \
          ] $processing_system7_1
  }

  # Create instance: processing_system7_1_axi_periph, and set properties
  set processing_system7_1_axi_periph [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 processing_system7_1_axi_periph ]
  if {[string equal $Target "E310"]} {
    set_property -dict [ list CONFIG.NUM_MI {13}  ] $processing_system7_1_axi_periph
  } else {
    set_property -dict [ list CONFIG.NUM_MI {12}  ] $processing_system7_1_axi_periph
  }

  # Create instance: rst_processing_system7_1_166M, and set properties
  set rst_processing_system7_1_166M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_processing_system7_1_166M ]
  set_property -dict [ list CONFIG.C_AUX_RESET_HIGH {0} CONFIG.USE_BOARD_FLOW {false}  ] $rst_processing_system7_1_166M

  # Create instance: rxdut_data_mux, and set properties
  set rxdut_data_mux [ create_bd_cell -type ip -vlnv mathworks.com:user:basic_mux:1.0 rxdut_data_mux ]
  set_property -dict [ list CONFIG.bit_width {64}  ] $rxdut_data_mux

  # Create instance: rxdut_strobe_mux, and set properties
  set rxdut_strobe_mux [ create_bd_cell -type ip -vlnv mathworks.com:user:basic_mux:1.0 rxdut_strobe_mux ]

  # Create instance: rxdut_wrapper_0, and set properties
  set rxdut_wrapper_0 [ create_bd_cell -type ip -vlnv mathworks.com:user:$rxDUTIPCoreName:1.0 rxdut_wrapper_0 ]
  set_property -dict [list CONFIG.bit_width {64}] $rxdut_wrapper_0

  # Create instance: spi_slave_tie_offs, and set properties
  set spi_slave_tie_offs [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 spi_slave_tie_offs ]

  # Create instance: spi_tie_not_gate, and set properties
  set spi_tie_not_gate [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 spi_tie_not_gate ]
  set_property -dict [ list CONFIG.C_OPERATION {not} CONFIG.C_SIZE {1}  ] $spi_tie_not_gate
  # Create instance: tx_data_path_rst_n, and set properties
  set tx_data_path_rst_n [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 tx_data_path_rst_n ]
  set_property -dict [ list CONFIG.C_OPERATION {not} CONFIG.C_SIZE {1}  ] $tx_data_path_rst_n


  # Create instance: txdut_data_mux, and set properties
  set txdut_data_mux [ create_bd_cell -type ip -vlnv mathworks.com:user:basic_mux:1.0 txdut_data_mux ]
  set_property -dict [ list CONFIG.bit_width {64}  ] $txdut_data_mux

  # Create instance: txdut_strobe_mux, and set properties
  set txdut_strobe_mux [ create_bd_cell -type ip -vlnv mathworks.com:user:basic_mux:1.0 txdut_strobe_mux ]

  # Create instance: txdut_wrapper_0, and set properties
  set txdut_wrapper_0 [ create_bd_cell -type ip -vlnv mathworks.com:user:$txDUTIPCoreName:1.0 txdut_wrapper_0 ]
  set_property -dict [list CONFIG.bit_width {64}] $txdut_wrapper_0

  # Create instance: util_vector_logic_0, and set properties
  set util_vector_logic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_0 ]
  set_property -dict [ list CONFIG.C_OPERATION {not} CONFIG.C_SIZE {1}  ] $util_vector_logic_0
  
  # Create instance: led_reset_util_vector_logic, and set properties
  set led_reset_util_vector_logic [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 led_reset_util_vector_logic ]
  set_property -dict [ list CONFIG.C_OPERATION {or} CONFIG.C_SIZE {1}  ] $led_reset_util_vector_logic

  # Create instance: xlconcat_adc, and set properties
  set xlconcat_adc [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_adc ]
  set_property -dict [ list CONFIG.IN0_WIDTH {16} CONFIG.IN1_WIDTH {16} CONFIG.IN2_WIDTH {16} CONFIG.IN3_WIDTH {16} CONFIG.NUM_PORTS {4}  ] $xlconcat_adc
  
  # CMOS/LVDS depends on Target platform 
  if {[string equal $Target "E310"]} {      
       # Create instance: xlconstant_1, and set properties
      set xlconstant_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_3 ]
      set_property -dict [ list CONFIG.CONST_VAL {0} CONFIG.CONST_WIDTH {1} ] $xlconstant_3
  } 


 # Create interface connections
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_S2MM [get_bd_intf_pins axi_dma_rx/M_AXI_S2MM] [get_bd_intf_pins axi_interconnect_1/S00_AXI]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_SG [get_bd_intf_pins axi_dma_rx/M_AXI_SG] [get_bd_intf_pins axi_mem_intercon/S00_AXI]
  connect_bd_intf_net -intf_net axi_dma_1_M_AXI_MM2S [get_bd_intf_pins axi_dma_tx/M_AXI_MM2S] [get_bd_intf_pins axi_interconnect_0/S00_AXI]
  connect_bd_intf_net -intf_net axi_dma_1_M_AXI_SG [get_bd_intf_pins axi_dma_tx/M_AXI_SG] [get_bd_intf_pins axi_mem_intercon/S01_AXI]
  connect_bd_intf_net -intf_net axi_dma_tx_M_AXIS_MM2S [get_bd_intf_pins axi_dma_tx/M_AXIS_MM2S] [get_bd_intf_pins data_fifo_generator_tx/S_AXIS]
  connect_bd_intf_net -intf_net axi_iic_0_IIC [get_bd_intf_ports iic_rtl] [get_bd_intf_pins axi_iic_0/IIC]
  connect_bd_intf_net -intf_net axi_interconnect_0_M00_AXI [get_bd_intf_pins axi_interconnect_0/M00_AXI] [get_bd_intf_pins processing_system7_1/S_AXI_HP0]
  connect_bd_intf_net -intf_net axi_interconnect_1_M00_AXI [get_bd_intf_pins axi_interconnect_1/M00_AXI] [get_bd_intf_pins processing_system7_1/S_AXI_HP1]
  connect_bd_intf_net -intf_net axi_lite_data_packer_pcore_0_m_axis [get_bd_intf_pins axi_lite_data_packer_pcore_0/m_axis] [get_bd_intf_pins detection_fifo_rx/S_AXIS]
  connect_bd_intf_net -intf_net axi_lite_sample_counter_pcore_0_m_axis [get_bd_intf_pins axi_dma_rx/S_AXIS_S2MM] [get_bd_intf_pins axi_lite_sample_counter_pcore_0/m_axis]
  connect_bd_intf_net -intf_net axi_mem_intercon_M00_AXI [get_bd_intf_pins axi_mem_intercon/M00_AXI] [get_bd_intf_pins processing_system7_1/S_AXI_ACP]
  connect_bd_intf_net -intf_net data_fifo_generator_rx_M_AXIS [get_bd_intf_pins axi_lite_sample_counter_pcore_0/s_axis] [get_bd_intf_pins data_fifo_generator_rx/M_AXIS]
  connect_bd_intf_net -intf_net data_fifo_generator_tx_M_AXIS [get_bd_intf_pins data_fifo_generator_tx/M_AXIS] [get_bd_intf_pins detection_fifo_tx/S_AXIS]
  connect_bd_intf_net -intf_net detection_fifo_tx_M_AXIS [get_bd_intf_pins axi_lite_data_unpacker_pcore_0/s_axis] [get_bd_intf_pins detection_fifo_tx/M_AXIS]
  connect_bd_intf_net -intf_net processing_system7_1_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins processing_system7_1/DDR]
  connect_bd_intf_net -intf_net processing_system7_1_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins processing_system7_1/FIXED_IO]
  connect_bd_intf_net -intf_net processing_system7_1_M_AXI_GP0 [get_bd_intf_pins processing_system7_1/M_AXI_GP0] [get_bd_intf_pins processing_system7_1_axi_periph/S00_AXI]
  connect_bd_intf_net -intf_net processing_system7_1_axi_periph_M00_AXI [get_bd_intf_pins axi_dma_rx/S_AXI_LITE] [get_bd_intf_pins processing_system7_1_axi_periph/M00_AXI]
  connect_bd_intf_net -intf_net processing_system7_1_axi_periph_M01_AXI [get_bd_intf_pins axi_ad9361/s_axi] [get_bd_intf_pins processing_system7_1_axi_periph/M01_AXI]
  connect_bd_intf_net -intf_net processing_system7_1_axi_periph_M02_AXI [get_bd_intf_pins axi_lite_system_config_pcore_0/AXI_Lite] [get_bd_intf_pins processing_system7_1_axi_periph/M02_AXI]
  connect_bd_intf_net -intf_net processing_system7_1_axi_periph_M03_AXI [get_bd_intf_pins axi_lite_sdrramp_src_pcore_0/AXI4_Lite] [get_bd_intf_pins processing_system7_1_axi_periph/M03_AXI]
  connect_bd_intf_net -intf_net processing_system7_1_axi_periph_M04_AXI [get_bd_intf_pins axi_lite_sample_counter_pcore_0/AXI4_Lite] [get_bd_intf_pins processing_system7_1_axi_periph/M04_AXI]
  connect_bd_intf_net -intf_net processing_system7_1_axi_periph_M05_AXI [get_bd_intf_pins axi_lite_data_verifier_if_pcore_0/AXI4_Lite] [get_bd_intf_pins processing_system7_1_axi_periph/M05_AXI]
  connect_bd_intf_net -intf_net processing_system7_1_axi_periph_M06_AXI [get_bd_intf_pins axi_lite_data_packer_pcore_0/AXI4_Lite] [get_bd_intf_pins processing_system7_1_axi_periph/M06_AXI]
  connect_bd_intf_net -intf_net processing_system7_1_axi_periph_M07_AXI [get_bd_intf_pins axi_lite_data_unpacker_pcore_0/AXI4_Lite] [get_bd_intf_pins processing_system7_1_axi_periph/M07_AXI]
  connect_bd_intf_net -intf_net processing_system7_1_axi_periph_M08_AXI [get_bd_intf_pins axi_iic_0/S_AXI] [get_bd_intf_pins processing_system7_1_axi_periph/M08_AXI]
  connect_bd_intf_net -intf_net processing_system7_1_axi_periph_M09_AXI [get_bd_intf_pins axi_dma_tx/S_AXI_LITE] [get_bd_intf_pins processing_system7_1_axi_periph/M09_AXI]
  connect_bd_intf_net -intf_net processing_system7_1_axi_periph_M10_AXI [get_bd_intf_pins fifo_irq_ctrl_pcore_rx/AXI4_Lite] [get_bd_intf_pins processing_system7_1_axi_periph/M10_AXI]
  connect_bd_intf_net -intf_net processing_system7_1_axi_periph_M11_AXI [get_bd_intf_pins fifo_irq_ctrl_pcore_tx/AXI4_Lite] [get_bd_intf_pins processing_system7_1_axi_periph/M11_AXI]

  # Create port connections
  connect_bd_net -net DMA_rstn_Res [get_bd_pins DMA_rstn/Res] [get_bd_pins axi_dma_rx/axi_resetn]
  connect_bd_net -net axi_ad9361_0_l_clk [get_bd_pins axi_ad9361/clk] [get_bd_pins axi_ad9361/l_clk] [get_bd_pins clk_domain_xing_rst_2/clk_b] [get_bd_pins clockGen_0/clkIn] [get_bd_pins dac_unpack_0/clk] [get_bd_pins fifo_generator_clkgen_rx/s_aclk] [get_bd_pins fifo_generator_clkgen_tx/m_aclk]
  connect_bd_net -net axi_ad9361_adc_valid_i0 [get_bd_pins axi_ad9361/adc_valid_i0] [get_bd_pins fifo_generator_clkgen_rx/s_axis_tvalid]
  if {[string equal $Target "E310"]} {
       connect_bd_net -net axi_ad9361_tx_clk_out [get_bd_ports tx_clk_out] [get_bd_pins axi_ad9361/tx_clk_out]
       connect_bd_net -net axi_ad9361_tx_data_out [get_bd_ports tx_data_out] [get_bd_pins axi_ad9361/tx_data_out]
       connect_bd_net -net axi_ad9361_tx_frame_out [get_bd_ports tx_frame_out] [get_bd_pins axi_ad9361/tx_frame_out]  
       connect_bd_net -net rx_clk_in_p_1 [get_bd_ports rx_clk_in] [get_bd_pins axi_ad9361/rx_clk_in]
       connect_bd_net -net rx_data_in_1 [get_bd_ports rx_data_in] [get_bd_pins axi_ad9361/rx_data_in]
       connect_bd_net -net rx_frame_in_p_1 [get_bd_ports rx_frame_in] [get_bd_pins axi_ad9361/rx_frame_in]
       connect_bd_net -net axi_lite_filterbank_antselect_ip_0_RX1B_BANDSEL [get_bd_ports RX1B_BANDSEL] [get_bd_pins axi_lite_filterbank_antselect_ip_0/RX1B_BANDSEL]
       connect_bd_net -net axi_lite_filterbank_antselect_ip_0_RX1C_BANDSEL [get_bd_ports RX1C_BANDSEL] [get_bd_pins axi_lite_filterbank_antselect_ip_0/RX1C_BANDSEL]
       connect_bd_net -net axi_lite_filterbank_antselect_ip_0_RX1_BANDSEL [get_bd_ports RX1_BANDSEL] [get_bd_pins axi_lite_filterbank_antselect_ip_0/RX1_BANDSEL]
       connect_bd_net -net axi_lite_filterbank_antselect_ip_0_RX2B_BANDSEL [get_bd_ports RX2B_BANDSEL] [get_bd_pins axi_lite_filterbank_antselect_ip_0/RX2B_BANDSEL]
       connect_bd_net -net axi_lite_filterbank_antselect_ip_0_RX2C_BANDSEL [get_bd_ports RX2C_BANDSEL] [get_bd_pins axi_lite_filterbank_antselect_ip_0/RX2C_BANDSEL]
       connect_bd_net -net axi_lite_filterbank_antselect_ip_0_RX2_BANDSEL [get_bd_ports RX2_BANDSEL] [get_bd_pins axi_lite_filterbank_antselect_ip_0/RX2_BANDSEL]
       connect_bd_net -net axi_lite_filterbank_antselect_ip_0_TX_BANDSEL [get_bd_ports TX_BANDSEL] [get_bd_pins axi_lite_filterbank_antselect_ip_0/TX_BANDSEL]
       connect_bd_net -net axi_lite_filterbank_antselect_ip_0_TX_ENABLE1A [get_bd_ports TX_ENABLE1A] [get_bd_pins axi_lite_filterbank_antselect_ip_0/TX_ENABLE1A]
       connect_bd_net -net axi_lite_filterbank_antselect_ip_0_TX_ENABLE1B [get_bd_ports TX_ENABLE1B] [get_bd_pins axi_lite_filterbank_antselect_ip_0/TX_ENABLE1B]
       connect_bd_net -net axi_lite_filterbank_antselect_ip_0_TX_ENABLE2A [get_bd_ports TX_ENABLE2A] [get_bd_pins axi_lite_filterbank_antselect_ip_0/TX_ENABLE2A]
       connect_bd_net -net axi_lite_filterbank_antselect_ip_0_TX_ENABLE2B [get_bd_ports TX_ENABLE2B] [get_bd_pins axi_lite_filterbank_antselect_ip_0/TX_ENABLE2B]
       connect_bd_net -net axi_lite_filterbank_antselect_ip_0_VCRX1_V1 [get_bd_ports VCRX1_V1] [get_bd_pins axi_lite_filterbank_antselect_ip_0/VCRX1_V1]
       connect_bd_net -net axi_lite_filterbank_antselect_ip_0_VCRX1_V2 [get_bd_ports VCRX1_V2] [get_bd_pins axi_lite_filterbank_antselect_ip_0/VCRX1_V2]
       connect_bd_net -net axi_lite_filterbank_antselect_ip_0_VCRX2_V1 [get_bd_ports VCRX2_V1] [get_bd_pins axi_lite_filterbank_antselect_ip_0/VCRX2_V1]
       connect_bd_net -net axi_lite_filterbank_antselect_ip_0_VCRX2_V2 [get_bd_ports VCRX2_V2] [get_bd_pins axi_lite_filterbank_antselect_ip_0/VCRX2_V2]
       connect_bd_net -net axi_lite_filterbank_antselect_ip_0_VCTXRX1_V1 [get_bd_ports VCTXRX1_V1] [get_bd_pins axi_lite_filterbank_antselect_ip_0/VCTXRX1_V1]
       connect_bd_net -net axi_lite_filterbank_antselect_ip_0_VCTXRX1_V2 [get_bd_ports VCTXRX1_V2] [get_bd_pins axi_lite_filterbank_antselect_ip_0/VCTXRX1_V2]
       connect_bd_net -net axi_lite_filterbank_antselect_ip_0_VCTXRX2_V1 [get_bd_ports VCTXRX2_V1] [get_bd_pins axi_lite_filterbank_antselect_ip_0/VCTXRX2_V1]
       connect_bd_net -net axi_lite_filterbank_antselect_ip_0_VCTXRX2_V2 [get_bd_ports VCTXRX2_V2] [get_bd_pins axi_lite_filterbank_antselect_ip_0/VCTXRX2_V2]
       connect_bd_intf_net -intf_net processing_system7_1_axi_periph_M12_AXI [get_bd_intf_pins axi_lite_filterbank_antselect_ip_0/AXI4_Lite] [get_bd_intf_pins processing_system7_1_axi_periph/M12_AXI]       
       connect_bd_net -net processing_system7_1_FCLK_CLK0 [get_bd_pins axi_lite_filterbank_antselect_ip_0/AXI4_Lite_ACLK] [get_bd_pins axi_lite_filterbank_antselect_ip_0/IPCORE_CLK] [get_bd_pins processing_system7_1_axi_periph/M12_ACLK]
       connect_bd_net -net rst_processing_system7_1_166M_peripheral_aresetn [get_bd_pins axi_lite_filterbank_antselect_ip_0/AXI4_Lite_ARESETN] [get_bd_pins axi_lite_filterbank_antselect_ip_0/IPCORE_RESETN]
       create_bd_addr_seg -range 0x10000 -offset 0x43C30000 [get_bd_addr_spaces processing_system7_1/Data] [get_bd_addr_segs axi_lite_filterbank_antselect_ip_0/AXI4_Lite/reg0] SEG_axi_lite_filterbank_antselect_ip_0_reg0
       connect_bd_net -net avr_irq_net [get_bd_ports AVR_IRQ] [get_bd_pins xlconstant_3/dout]
	   
	   connect_bd_net -net axi_ad9361_adc_data_i0 [get_bd_pins axi_ad9361/adc_data_i0] [get_bd_pins xlconcat_adc/In2]
       connect_bd_net -net axi_ad9361_adc_data_i1 [get_bd_pins axi_ad9361/adc_data_i1] [get_bd_pins xlconcat_adc/In0]
       connect_bd_net -net axi_ad9361_adc_data_q0 [get_bd_pins axi_ad9361/adc_data_q0] [get_bd_pins xlconcat_adc/In3]
       connect_bd_net -net axi_ad9361_adc_data_q1 [get_bd_pins axi_ad9361/adc_data_q1] [get_bd_pins xlconcat_adc/In1]
	    
	   connect_bd_net -net dac_unpack_0_data_out_i0 [get_bd_pins axi_ad9361/dac_data_i0] [get_bd_pins dac_unpack_0/data_out_i1]
	   connect_bd_net -net dac_unpack_0_data_out_i1 [get_bd_pins axi_ad9361/dac_data_i1] [get_bd_pins dac_unpack_0/data_out_i0]
	   connect_bd_net -net dac_unpack_0_data_out_q0 [get_bd_pins axi_ad9361/dac_data_q0] [get_bd_pins dac_unpack_0/data_out_q1]
	   connect_bd_net -net dac_unpack_0_data_out_q1 [get_bd_pins axi_ad9361/dac_data_q1] [get_bd_pins dac_unpack_0/data_out_q0]
  } else {
       connect_bd_net -net axi_ad9361_tx_clk_out_n [get_bd_ports tx_clk_out_n] [get_bd_pins axi_ad9361/tx_clk_out_n]
       connect_bd_net -net axi_ad9361_tx_clk_out_p [get_bd_ports tx_clk_out_p] [get_bd_pins axi_ad9361/tx_clk_out_p]
       connect_bd_net -net axi_ad9361_tx_data_out_n [get_bd_ports tx_data_out_n] [get_bd_pins axi_ad9361/tx_data_out_n]
       connect_bd_net -net axi_ad9361_tx_data_out_p [get_bd_ports tx_data_out_p] [get_bd_pins axi_ad9361/tx_data_out_p]
       connect_bd_net -net axi_ad9361_tx_frame_out_n [get_bd_ports tx_frame_out_n] [get_bd_pins axi_ad9361/tx_frame_out_n]
       connect_bd_net -net axi_ad9361_tx_frame_out_p [get_bd_ports tx_frame_out_p] [get_bd_pins axi_ad9361/tx_frame_out_p]
       connect_bd_net -net rx_clk_in_n_1 [get_bd_ports rx_clk_in_n] [get_bd_pins axi_ad9361/rx_clk_in_n]
       connect_bd_net -net rx_clk_in_p_1 [get_bd_ports rx_clk_in_p] [get_bd_pins axi_ad9361/rx_clk_in_p]
       connect_bd_net -net rx_data_in_n_1 [get_bd_ports rx_data_in_n] [get_bd_pins axi_ad9361/rx_data_in_n]
       connect_bd_net -net rx_data_in_p_1 [get_bd_ports rx_data_in_p] [get_bd_pins axi_ad9361/rx_data_in_p]
       connect_bd_net -net rx_frame_in_n_1 [get_bd_ports rx_frame_in_n] [get_bd_pins axi_ad9361/rx_frame_in_n]
       connect_bd_net -net rx_frame_in_p_1 [get_bd_ports rx_frame_in_p] [get_bd_pins axi_ad9361/rx_frame_in_p]
	   
	   connect_bd_net -net axi_ad9361_adc_data_i0 [get_bd_pins axi_ad9361/adc_data_i0] [get_bd_pins xlconcat_adc/In0]
       connect_bd_net -net axi_ad9361_adc_data_i1 [get_bd_pins axi_ad9361/adc_data_i1] [get_bd_pins xlconcat_adc/In2]
       connect_bd_net -net axi_ad9361_adc_data_q0 [get_bd_pins axi_ad9361/adc_data_q0] [get_bd_pins xlconcat_adc/In1]
       connect_bd_net -net axi_ad9361_adc_data_q1 [get_bd_pins axi_ad9361/adc_data_q1] [get_bd_pins xlconcat_adc/In3]
	    
	   connect_bd_net -net dac_unpack_0_data_out_i0 [get_bd_pins axi_ad9361/dac_data_i0] [get_bd_pins dac_unpack_0/data_out_i0]
	   connect_bd_net -net dac_unpack_0_data_out_i1 [get_bd_pins axi_ad9361/dac_data_i1] [get_bd_pins dac_unpack_0/data_out_i1]
	   connect_bd_net -net dac_unpack_0_data_out_q0 [get_bd_pins axi_ad9361/dac_data_q0] [get_bd_pins dac_unpack_0/data_out_q0]
	   connect_bd_net -net dac_unpack_0_data_out_q1 [get_bd_pins axi_ad9361/dac_data_q1] [get_bd_pins dac_unpack_0/data_out_q1]
  }
  
  
  connect_bd_net -net axi_dma_0_s2mm_introut [get_bd_pins axi_dma_rx/s2mm_introut] [get_bd_pins interrupt_concat/In0]
  connect_bd_net -net axi_dma_1_mm2s_introut [get_bd_pins axi_dma_tx/mm2s_introut] [get_bd_pins interrupt_concat/In1]
  connect_bd_net -net axi_lite_data_unpacker_pcore_0_ch_sel [get_bd_pins axi_lite_data_unpacker_pcore_0/ch_sel] [get_bd_pins axi_lite_data_verifier_if_pcore_0/ch_sel]
  connect_bd_net -net axi_lite_data_unpacker_pcore_0_m_axis_tdata [get_bd_pins axi_lite_data_unpacker_pcore_0/m_axis_tdata] [get_bd_pins txdut_data_mux/In_1] [get_bd_pins txdut_wrapper_0/s_axis_tdata]
  connect_bd_net -net axi_lite_data_unpacker_pcore_0_m_axis_tvalid [get_bd_pins axi_lite_data_unpacker_pcore_0/m_axis_tvalid] [get_bd_pins txdut_strobe_mux/In_1] [get_bd_pins txdut_wrapper_0/s_axis_tvalid]
  connect_bd_net -net axi_lite_data_unpacker_pcore_0_s_axis_tready [get_bd_pins axi_lite_data_unpacker_pcore_0/s_axis_tready] [get_bd_pins detection_fifo_tx/m_axis_tready]
  connect_bd_net -net axi_lite_sample_counter_pcore_0_rst_out [get_bd_pins DMA_rstn/Op1] [get_bd_pins axi_lite_sample_counter_pcore_0/rst_out]
  connect_bd_net -net axi_lite_sdrramp_src_pcore_0_src_out1 [get_bd_pins axi_lite_sdrramp_src_pcore_0/src_out] [get_bd_pins rxdut_data_mux/In_1] [get_bd_pins rxdut_wrapper_0/s_axis_tdata]
  connect_bd_net -net axi_lite_sdrramp_src_pcore_0_src_strobe [get_bd_pins axi_lite_sdrramp_src_pcore_0/src_strobe] [get_bd_pins rxdut_strobe_mux/In_1] [get_bd_pins rxdut_wrapper_0/s_axis_tvalid]
  connect_bd_net -net axi_lite_system_config_pcore_0_dut_rx_by_pass [get_bd_pins axi_lite_system_config_pcore_0/dut_rx_by_pass] [get_bd_pins rxdut_data_mux/Sel] [get_bd_pins rxdut_strobe_mux/Sel]
  connect_bd_net -net axi_lite_system_config_pcore_0_dut_tx_by_pass [get_bd_pins axi_lite_system_config_pcore_0/dut_tx_by_pass] [get_bd_pins txdut_data_mux/Sel] [get_bd_pins txdut_strobe_mux/Sel]
  connect_bd_net -net axi_lite_system_config_pcore_0_rx_data_path_rst [get_bd_pins axi_lite_data_packer_pcore_0/rst] [get_bd_pins axi_lite_sdrramp_src_pcore_0/reset] [get_bd_pins axi_lite_system_config_pcore_0/rx_data_path_rst] [get_bd_pins fifo_irq_ctrl_pcore_rx/DATA_PATH_RST] [get_bd_pins led_reset_util_vector_logic/Op1] [get_bd_pins rxdut_wrapper_0/reset] [get_bd_pins util_vector_logic_0/Op1]
  connect_bd_net -net axi_lite_system_config_pcore_0_stream_enable_rx [get_bd_pins axi_lite_sdrramp_src_pcore_0/stream_en] [get_bd_pins axi_lite_system_config_pcore_0/stream_enable_rx] [get_bd_pins fifo_irq_ctrl_pcore_rx/ENABLE]
  connect_bd_net -net axi_lite_system_config_pcore_0_stream_enable_tx [get_bd_pins axi_lite_data_unpacker_pcore_0/stream_en] [get_bd_pins axi_lite_system_config_pcore_0/stream_enable_tx] [get_bd_pins dac_unpack_0/stream_enb] [get_bd_pins fifo_irq_ctrl_pcore_tx/ENABLE]
  connect_bd_net -net axi_lite_system_config_pcore_0_tx_data_path_rst [get_bd_pins axi_lite_data_unpacker_pcore_0/rst] [get_bd_pins axi_lite_system_config_pcore_0/tx_data_path_rst] [get_bd_pins fifo_irq_ctrl_pcore_tx/DATA_PATH_RST] [get_bd_pins led_reset_util_vector_logic/Op2] [get_bd_pins tx_data_path_rst_n/Op1] [get_bd_pins txdut_wrapper_0/reset]
  connect_bd_net -net basic_mux_0_Output [get_bd_pins axi_lite_data_verifier_if_pcore_0/data] [get_bd_pins fifo_generator_clkgen_tx/s_axis_tdata] [get_bd_pins txdut_data_mux/Out_1]
  connect_bd_net -net clk_domain_xing_rst_0_reset_b [get_bd_pins axi_lite_sample_counter_pcore_0/data_path_rst_n] [get_bd_pins clk_domain_xing_rst_0/reset_b]
  connect_bd_net -net clk_domain_xing_rst_1_reset_b [get_bd_pins clk_domain_xing_rst_1/reset_b] [get_bd_pins data_fifo_generator_tx/s_aresetn]
  connect_bd_net -net clk_domain_xing_rst_2_reset_b [get_bd_pins clk_domain_xing_rst_2/reset_b] [get_bd_pins dac_unpack_0/aresetn]
  connect_bd_net -net clockGen_0_clkOut [get_bd_pins axi_lite_data_packer_pcore_0/clk] [get_bd_pins axi_lite_data_unpacker_pcore_0/clk] [get_bd_pins axi_lite_data_verifier_if_pcore_0/clk] [get_bd_pins axi_lite_sdrramp_src_pcore_0/clk] [get_bd_pins axi_lite_system_config_pcore_0/rx_clk] [get_bd_pins axi_lite_system_config_pcore_0/tx_clk] [get_bd_pins clockGen_0/clkOut] [get_bd_pins data_fifo_generator_rx/s_aclk] [get_bd_pins data_fifo_generator_tx/m_aclk] [get_bd_pins detection_fifo_rx/s_aclk] [get_bd_pins detection_fifo_tx/s_aclk] [get_bd_pins fifo_generator_clkgen_rx/m_aclk] [get_bd_pins fifo_generator_clkgen_tx/s_aclk] [get_bd_pins fifo_irq_ctrl_pcore_rx/DATA_CLK] [get_bd_pins fifo_irq_ctrl_pcore_tx/DATA_CLK] [get_bd_pins led_driver_0/clk_rf] [get_bd_pins rxdut_wrapper_0/clk] [get_bd_pins txdut_wrapper_0/clk]
  connect_bd_net -net data_fifo_generator_rx_s_axis_tready [get_bd_pins data_fifo_generator_rx/s_axis_tready] [get_bd_pins detection_fifo_rx/m_axis_tready]
  connect_bd_net -net detection_fifo_rx_axis_data_count [get_bd_pins detection_fifo_rx/axis_data_count] [get_bd_pins fifo_irq_ctrl_pcore_rx/FIFO_DATA_OCC_CNT]
  connect_bd_net -net detection_fifo_rx_axis_overflow [get_bd_pins detection_fifo_rx/axis_overflow] [get_bd_pins fifo_irq_ctrl_pcore_rx/FIFO_OF]
  connect_bd_net -net detection_fifo_rx_axis_underflow [get_bd_pins detection_fifo_rx/axis_underflow] [get_bd_pins fifo_irq_ctrl_pcore_rx/FIFO_UF]
  connect_bd_net -net detection_fifo_rx_m_axis_tdata [get_bd_pins data_fifo_generator_rx/s_axis_tdata] [get_bd_pins detection_fifo_rx/m_axis_tdata]
  connect_bd_net -net detection_fifo_rx_m_axis_tvalid [get_bd_pins data_fifo_generator_rx/s_axis_tvalid] [get_bd_pins detection_fifo_rx/m_axis_tvalid] [get_bd_pins fifo_irq_ctrl_pcore_rx/AXIS_TVALID]
  connect_bd_net -net detection_fifo_tx_axis_data_count [get_bd_pins detection_fifo_tx/axis_data_count] [get_bd_pins fifo_irq_ctrl_pcore_tx/FIFO_DATA_OCC_CNT]
  connect_bd_net -net detection_fifo_tx_axis_overflow [get_bd_pins detection_fifo_tx/axis_overflow] [get_bd_pins fifo_irq_ctrl_pcore_tx/FIFO_OF]
  connect_bd_net -net detection_fifo_tx_axis_underflow [get_bd_pins detection_fifo_tx/axis_underflow] [get_bd_pins fifo_irq_ctrl_pcore_tx/FIFO_UF]
  connect_bd_net -net detection_fifo_tx_m_axis_tdata [get_bd_pins axi_lite_data_unpacker_pcore_0/s_axis_tdata] [get_bd_pins detection_fifo_tx/m_axis_tdata]
  connect_bd_net -net detection_fifo_tx_m_axis_tvalid [get_bd_pins axi_lite_data_unpacker_pcore_0/s_axis_tvalid] [get_bd_pins detection_fifo_tx/m_axis_tvalid] [get_bd_pins fifo_irq_ctrl_pcore_tx/AXIS_TVALID]
  connect_bd_net -net fifo_generator_clkgen_rx_m_axis_tdata [get_bd_pins axi_lite_sdrramp_src_pcore_0/data_in] [get_bd_pins fifo_generator_clkgen_rx/m_axis_tdata]
  connect_bd_net -net fifo_generator_clkgen_rx_m_axis_tvalid [get_bd_pins axi_lite_sdrramp_src_pcore_0/data_vld] [get_bd_pins fifo_generator_clkgen_rx/m_axis_tvalid]
  connect_bd_net -net fifo_generator_clkgen_tx_m_axis_tdata [get_bd_pins dac_unpack_0/data_in] [get_bd_pins fifo_generator_clkgen_tx/m_axis_tdata]
  connect_bd_net -net fifo_irq_ctrl_pcore_rx_EXT_IRQ [get_bd_pins fifo_irq_ctrl_pcore_rx/EXT_IRQ] [get_bd_pins interrupt_concat/In2]
  connect_bd_net -net fifo_irq_ctrl_pcore_tx_EXT_IRQ [get_bd_pins fifo_irq_ctrl_pcore_tx/EXT_IRQ] [get_bd_pins interrupt_concat/In3]
  connect_bd_net -net gpio_tribus_slice_0_GPIO_0_tri_i [get_bd_pins gpio_tribus_slice_0/GPIO_0_tri_i] [get_bd_pins processing_system7_1/GPIO_I]
  connect_bd_net -net gpio_tribus_slice_0_gpio_io [get_bd_ports gpio_io] [get_bd_pins gpio_tribus_slice_0/gpio_io]
  connect_bd_net -net interrupt_concat_out [get_bd_pins interrupt_concat/dout] [get_bd_pins processing_system7_1/IRQ_F2P]
  connect_bd_net -net led_driver_0_LED [get_bd_ports LED] [get_bd_pins led_driver_0/LED]
  connect_bd_net -net tx_tready_tieoff_const [get_bd_pins fifo_generator_clkgen_rx/m_axis_tready] [get_bd_pins fifo_generator_clkgen_tx/m_axis_tready] [get_bd_pins tx_tready_tieoff/dout]
  connect_bd_net -net led_reset_util_vector_logic_Res [get_bd_pins led_driver_0/rst] [get_bd_pins led_reset_util_vector_logic/Res]
  connect_bd_net -net processing_system7_1_FCLK_CLK0 [get_bd_pins led_driver_0/clk_ps7] [get_bd_pins axi_ad9361/s_axi_aclk] [get_bd_pins axi_dma_rx/m_axi_s2mm_aclk] [get_bd_pins axi_dma_rx/m_axi_sg_aclk] [get_bd_pins axi_dma_rx/s_axi_lite_aclk] [get_bd_pins axi_dma_tx/m_axi_mm2s_aclk] [get_bd_pins axi_dma_tx/m_axi_sg_aclk] [get_bd_pins axi_dma_tx/s_axi_lite_aclk] [get_bd_pins axi_iic_0/s_axi_aclk] [get_bd_pins axi_interconnect_0/ACLK] [get_bd_pins axi_interconnect_0/M00_ACLK] [get_bd_pins axi_interconnect_0/S00_ACLK] [get_bd_pins axi_interconnect_1/ACLK] [get_bd_pins axi_interconnect_1/M00_ACLK] [get_bd_pins axi_interconnect_1/S00_ACLK] [get_bd_pins axi_lite_data_packer_pcore_0/AXI4_Lite_ACLK] [get_bd_pins axi_lite_data_packer_pcore_0/IPCORE_CLK] [get_bd_pins axi_lite_data_unpacker_pcore_0/AXI4_Lite_ACLK] [get_bd_pins axi_lite_data_unpacker_pcore_0/IPCORE_CLK] [get_bd_pins axi_lite_data_verifier_if_pcore_0/AXI4_Lite_ACLK] [get_bd_pins axi_lite_data_verifier_if_pcore_0/IPCORE_CLK] [get_bd_pins axi_lite_sample_counter_pcore_0/AXI4_Lite_ACLK] [get_bd_pins axi_lite_sample_counter_pcore_0/IPCORE_CLK] [get_bd_pins axi_lite_sample_counter_pcore_0/ps7_fclk0] [get_bd_pins axi_lite_sdrramp_src_pcore_0/AXI4_Lite_ACLK] [get_bd_pins axi_lite_sdrramp_src_pcore_0/IPCORE_CLK] [get_bd_pins axi_lite_system_config_pcore_0/AXI_Lite_ACLK] [get_bd_pins axi_lite_system_config_pcore_0/IPCORE_CLK] [get_bd_pins axi_mem_intercon/ACLK] [get_bd_pins axi_mem_intercon/M00_ACLK] [get_bd_pins axi_mem_intercon/S00_ACLK] [get_bd_pins axi_mem_intercon/S01_ACLK] [get_bd_pins clk_domain_xing_rst_0/clk_b] [get_bd_pins clk_domain_xing_rst_1/clk_b] [get_bd_pins data_fifo_generator_rx/m_aclk] [get_bd_pins data_fifo_generator_tx/s_aclk] [get_bd_pins fifo_irq_ctrl_pcore_rx/AXI4_Lite_ACLK] [get_bd_pins fifo_irq_ctrl_pcore_rx/IPCORE_CLK] [get_bd_pins fifo_irq_ctrl_pcore_tx/AXI4_Lite_ACLK] [get_bd_pins fifo_irq_ctrl_pcore_tx/IPCORE_CLK] [get_bd_pins processing_system7_1/FCLK_CLK0] [get_bd_pins processing_system7_1/M_AXI_GP0_ACLK] [get_bd_pins processing_system7_1/S_AXI_ACP_ACLK] [get_bd_pins processing_system7_1/S_AXI_HP0_ACLK] [get_bd_pins processing_system7_1/S_AXI_HP1_ACLK] [get_bd_pins processing_system7_1_axi_periph/ACLK] [get_bd_pins processing_system7_1_axi_periph/M00_ACLK] [get_bd_pins processing_system7_1_axi_periph/M01_ACLK] [get_bd_pins processing_system7_1_axi_periph/M02_ACLK] [get_bd_pins processing_system7_1_axi_periph/M03_ACLK] [get_bd_pins processing_system7_1_axi_periph/M04_ACLK] [get_bd_pins processing_system7_1_axi_periph/M05_ACLK] [get_bd_pins processing_system7_1_axi_periph/M06_ACLK] [get_bd_pins processing_system7_1_axi_periph/M07_ACLK] [get_bd_pins processing_system7_1_axi_periph/M08_ACLK] [get_bd_pins processing_system7_1_axi_periph/M09_ACLK] [get_bd_pins processing_system7_1_axi_periph/M10_ACLK] [get_bd_pins processing_system7_1_axi_periph/M11_ACLK] [get_bd_pins processing_system7_1_axi_periph/S00_ACLK] [get_bd_pins rst_processing_system7_1_166M/slowest_sync_clk] 
  connect_bd_net -net processing_system7_1_FCLK_CLK3 [get_bd_pins axi_ad9361/delay_clk] [get_bd_pins processing_system7_1/FCLK_CLK3]
  connect_bd_net -net processing_system7_1_FCLK_RESET0_N [get_bd_pins processing_system7_1/FCLK_RESET0_N] [get_bd_pins rst_processing_system7_1_166M/ext_reset_in]
  connect_bd_net -net processing_system7_1_GPIO_O [get_bd_pins gpio_tribus_slice_0/GPIO_0_tri_o] [get_bd_pins processing_system7_1/GPIO_O]
  connect_bd_net -net processing_system7_1_GPIO_T [get_bd_pins gpio_tribus_slice_0/GPIO_0_tri_t] [get_bd_pins processing_system7_1/GPIO_T]
  connect_bd_net -net processing_system7_1_SPI0_MOSI_O [get_bd_ports spi_mosi] [get_bd_ports TCXO_DAC_SDIN] [get_bd_pins processing_system7_1/SPI0_MOSI_O]
  connect_bd_net -net processing_system7_1_SPI0_SCLK_O [get_bd_ports spi_clk] [get_bd_ports TCXO_DAC_SCLK] [get_bd_pins processing_system7_1/SPI0_SCLK_O]
  connect_bd_net -net processing_system7_1_SPI0_SS_O [get_bd_ports spi_csn] [get_bd_pins processing_system7_1/SPI0_SS_O]
  connect_bd_net -net processing_system7_1_SPI0_SS_1 [get_bd_ports TCXO_DAC_SYNCn] [get_bd_pins processing_system7_1/SPI0_SS1_O]
  connect_bd_net -net rst_processing_system7_1_166M_interconnect_aresetn [get_bd_pins processing_system7_1_axi_periph/ARESETN] [get_bd_pins rst_processing_system7_1_166M/interconnect_aresetn]
  connect_bd_net -net rst_processing_system7_1_166M_peripheral_aresetn [get_bd_pins axi_ad9361/s_axi_aresetn] [get_bd_pins axi_dma_tx/axi_resetn] [get_bd_pins axi_iic_0/s_axi_aresetn] [get_bd_pins axi_interconnect_0/ARESETN] [get_bd_pins axi_interconnect_0/M00_ARESETN] [get_bd_pins axi_interconnect_0/S00_ARESETN] [get_bd_pins axi_interconnect_1/ARESETN] [get_bd_pins axi_interconnect_1/M00_ARESETN] [get_bd_pins axi_interconnect_1/S00_ARESETN] [get_bd_pins axi_lite_data_packer_pcore_0/AXI4_Lite_ARESETN] [get_bd_pins axi_lite_data_packer_pcore_0/IPCORE_RESETN] [get_bd_pins axi_lite_data_unpacker_pcore_0/AXI4_Lite_ARESETN] [get_bd_pins axi_lite_data_unpacker_pcore_0/IPCORE_RESETN] [get_bd_pins axi_lite_data_verifier_if_pcore_0/AXI4_Lite_ARESETN] [get_bd_pins axi_lite_data_verifier_if_pcore_0/IPCORE_RESETN] [get_bd_pins axi_lite_sample_counter_pcore_0/AXI4_Lite_ARESETN] [get_bd_pins axi_lite_sample_counter_pcore_0/IPCORE_RESETN] [get_bd_pins axi_lite_sdrramp_src_pcore_0/AXI4_Lite_ARESETN] [get_bd_pins axi_lite_sdrramp_src_pcore_0/IPCORE_RESETN] [get_bd_pins axi_lite_system_config_pcore_0/AXI_Lite_ARESETN] [get_bd_pins axi_lite_system_config_pcore_0/IPCORE_RESETN] [get_bd_pins axi_mem_intercon/ARESETN] [get_bd_pins axi_mem_intercon/M00_ARESETN] [get_bd_pins axi_mem_intercon/S00_ARESETN] [get_bd_pins axi_mem_intercon/S01_ARESETN] [get_bd_pins fclk2_reset/Op1] [get_bd_pins fifo_irq_ctrl_pcore_rx/AXI4_Lite_ARESETN] [get_bd_pins fifo_irq_ctrl_pcore_rx/IPCORE_RESETN] [get_bd_pins fifo_irq_ctrl_pcore_tx/AXI4_Lite_ARESETN] [get_bd_pins fifo_irq_ctrl_pcore_tx/IPCORE_RESETN] [get_bd_pins processing_system7_1_axi_periph/M00_ARESETN] [get_bd_pins processing_system7_1_axi_periph/M01_ARESETN] [get_bd_pins processing_system7_1_axi_periph/M02_ARESETN] [get_bd_pins processing_system7_1_axi_periph/M03_ARESETN] [get_bd_pins processing_system7_1_axi_periph/M04_ARESETN] [get_bd_pins processing_system7_1_axi_periph/M05_ARESETN] [get_bd_pins processing_system7_1_axi_periph/M06_ARESETN] [get_bd_pins processing_system7_1_axi_periph/M07_ARESETN] [get_bd_pins processing_system7_1_axi_periph/M08_ARESETN] [get_bd_pins processing_system7_1_axi_periph/M09_ARESETN] [get_bd_pins processing_system7_1_axi_periph/M10_ARESETN] [get_bd_pins processing_system7_1_axi_periph/M11_ARESETN] [get_bd_pins processing_system7_1_axi_periph/S00_ARESETN] [get_bd_pins rst_processing_system7_1_166M/peripheral_aresetn]

  connect_bd_net -net rxdut_data_mux_Output [get_bd_pins axi_lite_data_packer_pcore_0/s_axis_tdata] [get_bd_pins rxdut_data_mux/Out_1]
  connect_bd_net -net rxdut_strobe_mux_Output [get_bd_pins axi_lite_data_packer_pcore_0/s_axis_tvalid] [get_bd_pins rxdut_strobe_mux/Out_1]
  connect_bd_net -net rxdut_wrapper_0_m_axis_tdata [get_bd_pins rxdut_data_mux/In_0] [get_bd_pins rxdut_wrapper_0/m_axis_tdata]
  connect_bd_net -net rxdut_wrapper_0_m_axis_tvalid [get_bd_pins rxdut_strobe_mux/In_0] [get_bd_pins rxdut_wrapper_0/m_axis_tvalid]
  connect_bd_net -net spi_miso_i_1 [get_bd_ports spi_miso] [get_bd_pins processing_system7_1/SPI0_MISO_I]
  connect_bd_net -net spi_slave_tie_offs_dout [get_bd_pins processing_system7_1/SPI0_SS_I] [get_bd_pins spi_slave_tie_offs/dout] [get_bd_pins spi_tie_not_gate/Op1]
  connect_bd_net -net spi_tie_not_gate_Res [get_bd_pins processing_system7_1/SPI0_MOSI_I] [get_bd_pins processing_system7_1/SPI0_SCLK_I] [get_bd_pins spi_tie_not_gate/Res]
  connect_bd_net -net tx_data_path_rst_n_Res [get_bd_pins clk_domain_xing_rst_1/reset_a] [get_bd_pins clk_domain_xing_rst_2/reset_a] [get_bd_pins detection_fifo_tx/s_aresetn] [get_bd_pins fifo_generator_clkgen_tx/s_aresetn] [get_bd_pins tx_data_path_rst_n/Res]
  connect_bd_net -net txdut_strobe_mux_Output [get_bd_pins axi_lite_data_verifier_if_pcore_0/dvld] [get_bd_pins fifo_generator_clkgen_tx/s_axis_tvalid] [get_bd_pins txdut_strobe_mux/Out_1]
  connect_bd_net -net txdut_wrapper_0_m_axis_tdata [get_bd_pins txdut_data_mux/In_0] [get_bd_pins txdut_wrapper_0/m_axis_tdata]
  connect_bd_net -net txdut_wrapper_0_m_axis_tvalid [get_bd_pins txdut_strobe_mux/In_0] [get_bd_pins txdut_wrapper_0/m_axis_tvalid]
  connect_bd_net -net util_vector_logic_0_Res [get_bd_pins clk_domain_xing_rst_0/reset_a] [get_bd_pins data_fifo_generator_rx/s_aresetn] [get_bd_pins detection_fifo_rx/s_aresetn] [get_bd_pins fifo_generator_clkgen_rx/s_aresetn] [get_bd_pins util_vector_logic_0/Res]
  connect_bd_net -net util_vector_logic_1_Res [get_bd_pins axi_lite_system_config_pcore_0/g_reset] [get_bd_pins fclk2_reset/Res]
  connect_bd_net -net xlconcat_adc_dout [get_bd_pins fifo_generator_clkgen_rx/s_axis_tdata] [get_bd_pins xlconcat_adc/dout]

  # Create address segments
  create_bd_addr_seg -range $Range -offset 0x0 [get_bd_addr_spaces axi_dma_rx/Data_SG] [get_bd_addr_segs processing_system7_1/S_AXI_ACP/ACP_DDR_LOWOCM] SEG_processing_system7_1_ACP_DDR_LOWOCM
  create_bd_addr_seg -range 0x400000 -offset 0xE0000000 [get_bd_addr_spaces axi_dma_rx/Data_SG] [get_bd_addr_segs processing_system7_1/S_AXI_ACP/ACP_IOP] SEG_processing_system7_1_ACP_IOP
  create_bd_addr_seg -range $Range -offset 0x0 [get_bd_addr_spaces axi_dma_rx/Data_S2MM] [get_bd_addr_segs processing_system7_1/S_AXI_HP1/HP1_DDR_LOWOCM] SEG_processing_system7_1_HP1_DDR_LOWOCM
  create_bd_addr_seg -range $Range -offset 0x0 [get_bd_addr_spaces axi_dma_tx/Data_SG] [get_bd_addr_segs processing_system7_1/S_AXI_ACP/ACP_DDR_LOWOCM] SEG_processing_system7_1_ACP_DDR_LOWOCM
  if {[string equal $Target "ZC706"] || [string equal $Target "ZedBoard"] || [string equal $Target "ADIRFSOM"]} {
    create_bd_addr_seg -range 0x1000000 -offset 0xFC000000 [get_bd_addr_spaces axi_dma_rx/Data_SG] [get_bd_addr_segs processing_system7_1/S_AXI_ACP/ACP_QSPI_LINEAR] SEG_processing_system7_1_ACP_QSPI_LINEAR
    create_bd_addr_seg -range 0x1000000 -offset 0xFC000000 [get_bd_addr_spaces axi_dma_tx/Data_SG] [get_bd_addr_segs processing_system7_1/S_AXI_ACP/ACP_QSPI_LINEAR] SEG_processing_system7_1_ACP_QSPI_LINEAR
  }
  create_bd_addr_seg -range $Range -offset 0x0 [get_bd_addr_spaces axi_dma_tx/Data_MM2S] [get_bd_addr_segs processing_system7_1/S_AXI_HP0/HP0_DDR_LOWOCM] SEG_processing_system7_1_HP0_DDR_LOWOCM
  create_bd_addr_seg -range 0x10000 -offset 0x43C00000 [get_bd_addr_spaces processing_system7_1/Data] [get_bd_addr_segs axi_ad9361/s_axi/axi_lite] SEG_axi_ad9361_axi_lite
  create_bd_addr_seg -range 0x10000 -offset 0x40400000 [get_bd_addr_spaces processing_system7_1/Data] [get_bd_addr_segs axi_dma_rx/S_AXI_LITE/Reg] SEG_axi_dma_0_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x40410000 [get_bd_addr_spaces processing_system7_1/Data] [get_bd_addr_segs axi_dma_tx/S_AXI_LITE/Reg] SEG_axi_dma_1_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x41620000 [get_bd_addr_spaces processing_system7_1/Data] [get_bd_addr_segs axi_iic_0/S_AXI/Reg] SEG_axi_iic_0_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x43C10000 [get_bd_addr_spaces processing_system7_1/Data] [get_bd_addr_segs axi_lite_data_packer_pcore_0/AXI4_Lite/reg0] SEG_axi_lite_data_packer_pcore_0_reg0
  create_bd_addr_seg -range 0x10000 -offset 0x43C20000 [get_bd_addr_spaces processing_system7_1/Data] [get_bd_addr_segs axi_lite_data_unpacker_pcore_0/AXI4_Lite/reg0] SEG_axi_lite_data_unpacker_pcore_0_reg0
  create_bd_addr_seg -range 0x10000 -offset 0x43C50000 [get_bd_addr_spaces processing_system7_1/Data] [get_bd_addr_segs axi_lite_data_verifier_if_pcore_0/AXI4_Lite/reg0] SEG_axi_lite_data_verifier_if_pcore_0_reg0
  create_bd_addr_seg -range 0x10000 -offset 0x43C60000 [get_bd_addr_spaces processing_system7_1/Data] [get_bd_addr_segs fifo_irq_ctrl_pcore_rx/AXI4_Lite/reg0] SEG_fifo_irq_ctrl_pcore_rx_reg0
  create_bd_addr_seg -range 0x10000 -offset 0x43C70000 [get_bd_addr_spaces processing_system7_1/Data] [get_bd_addr_segs fifo_irq_ctrl_pcore_tx/AXI4_Lite/reg0] SEG_fifo_irq_ctrl_pcore_tx_reg0
  create_bd_addr_seg -range 0x10000 -offset 0x50000000 [get_bd_addr_spaces processing_system7_1/Data] [get_bd_addr_segs axi_lite_sample_counter_pcore_0/AXI4_Lite/reg0] SEG_axi_lite_sample_counter_pcore_0_reg0
  create_bd_addr_seg -range 0x10000 -offset 0x7D600000 [get_bd_addr_spaces processing_system7_1/Data] [get_bd_addr_segs axi_lite_sdrramp_src_pcore_0/AXI4_Lite/reg0] SEG_axi_lite_sdrramp_src_pcore_0_reg0
  create_bd_addr_seg -range 0x10000 -offset 0x72200000 [get_bd_addr_spaces processing_system7_1/Data] [get_bd_addr_segs axi_lite_system_config_pcore_0/AXI_Lite/reg0] SEG_axi_lite_system_config_pcore_0_reg0eg0
  


  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design "" $Target $Range $rxDUTIPCoreName $txDUTIPCoreName


