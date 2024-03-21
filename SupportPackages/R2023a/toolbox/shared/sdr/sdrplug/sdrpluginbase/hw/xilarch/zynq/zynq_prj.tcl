# Build variables
# Set which TCL script to use for building the Block Design
set ProjectName             [lindex $argv 0]
set Target                  [lindex $argv 1]
set Language                [lindex $argv 2]
set BlockDesignTCLScript    [lindex $argv 3]
set BlockDesignName         [lindex $argv 4]
set ConstraintFile          [lindex $argv 5]
set DataPath                [lindex $argv 6]
set IsHDLWA                 [lindex $argv 7]
set rxDUTIPCoreName         [lindex $argv 8]
set txDUTIPCoreName         [lindex $argv 9]
# ---------------------------------------------------------------------
# Initialise
# ---------------------------------------------------------------------
# Variables used to switch in user DUT logic
if {[string equal $DataPath {Receive path}]} {
     set rx 1
     set tx 1
} elseif {[string equal $DataPath {Transmit path}]} {
     set tx 1
     set rx 1
}

if {[string equal $Target "ZC706"]} {
  set Board xilinx.com:zc706:part0:1.3
  set Device xc7z045ffg900-2
  set Range "0x40000000"
} elseif {[string equal $Target "ZedBoard"]} {
	set Board em.avnet.com:zed:part0:1.0
	set Device xc7z020clg484-1
    set Range "0x20000000"
} elseif {[string equal $Target "ADIRFSOM"]} {
    set Device xc7z035ifbg676-2L
    set Board not-applicable
    set Range "0x40000000"
} elseif {[string equal $Target "E310"]} {
    set Device xc7z020clg484-1
    set Board not-applicable
    set Range "0x20000000"
}

proc ProjectGeneration {} {
global ProjectName
global Target
global Range
global Device 
global Board 
global Language 
global BlockDesignTCLScript 
global BlockDesignName
global rxDUTIPCoreName
global txDUTIPCoreName
# ---------------------------------------------------------------------
# Create project and import source files
# ---------------------------------------------------------------------
# Catch path length issues during project generation
set_msg_config -id "ProjectBase 1-489" -new_severity "ERROR"

# Create project
create_project -part $Device -force $ProjectName 
set proj_dir [get_property directory [current_project]]
set obj [get_projects $ProjectName ]
if {[string equal $Target "ZC706"] || [string equal $Target "ZedBoard"]} {
	set_property "board_part" $Board $obj
}
# Set project properties
set obj [get_projects system]
set_property "default_lib" "xil_defaultlib" $obj
set_property "ip_cache_permissions" "read write" $obj
set_property "sim.ip.auto_export_scripts" "1" $obj
set_property "simulator_language" "Mixed" $obj
set_property "target_language" $Language $obj
set_property "xpm_libraries" "XPM_CDC XPM_MEMORY" $obj
set_property "xsim.array_display_limit" "64" $obj
set_property "xsim.trace_limit" "65536" $obj

set_property  ip_repo_paths "../sdrsrc/ipcores" [current_project]
update_ip_catalog

add_files -fileset constrs_1 -norecurse "../sdrsrc/system_constr.xdc"

source $BlockDesignTCLScript

# Disable OOC synthesis
set_property GENERATE_SYNTH_CHECKPOINT 0  [get_files "./$ProjectName.srcs/sources_1/bd/$BlockDesignName/$BlockDesignName.bd"]

validate_bd_design
save_bd_design
}

proc OpenProject {} {
global ProjectName
open_project $ProjectName 
}

proc Synthesis {} {
global ProjectName 
global BlockDesignName 
global ConstraintFile
# ---------------------------------------------------------------------
# Compile project
# ---------------------------------------------------------------------

generate_target all [get_files  ./$ProjectName.srcs/sources_1/bd/$BlockDesignName/$BlockDesignName.bd]

make_wrapper -files [get_files "./$ProjectName.srcs/sources_1/bd/$BlockDesignName/$BlockDesignName.bd"] -top
import_files -force -norecurse "./$ProjectName.srcs/sources_1/bd/$BlockDesignName/hdl/$BlockDesignName\_wrapper.vhd"
update_compile_order -fileset sources_1


# Create 'synth_1' run (if not found)
if {[string equal [get_runs synth_1] ""]} {
 create_run -name synth_1 -part $Device -flow {Vivado Synthesis 2016} -strategy "Vivado Synthesis Defaults" -constrset constrs_1
}
set obj [get_runs synth_1]
# Create 'impl_1' run (if not found)
if {[string equal [get_runs impl_1] ""]} {
 create_run -name impl_1 -part $Device -flow {Vivado Implementation 2016} -strategy "Vivado Implementation Defaults" -constrset constrs_1 -parent_run synth_1
}
set obj [get_runs impl_1]


# ---------------------------------------------------------------------
# Run synthesis
# ---------------------------------------------------------------------
# launch synthesis
launch_runs synth_1
wait_on_run synth_1
open_run synth_1
write_checkpoint post_synthesis -force
}
proc BitGeneration {} {
global BlockDesignName 
global IsHDLWA
# ---------------------------------------------------------------------
# Run implementation and bit stream generation
# ---------------------------------------------------------------------
# launch implementation 
launch_runs impl_1
wait_on_run impl_1

# # open implementation 
open_run impl_1
# open_bd_design [get_property directory [current_project]]/[current_project].srcs/sources_1/bd/$BlockDesignName/$BlockDesignName.bd

# generate bitstream using name of IP Integrator Canvas
write_bitstream -bin_file $BlockDesignName

 if {$IsHDLWA == 0} {
# # export software specific files
# # export_hardware [get_files [get_property directory [current_project]]/[current_project].srcs/sources_1/bd/$BlockDesignName/$BlockDesignName.bd] [get_runs impl_1]
write_hwdef -file $BlockDesignName.hwdef
write_sysdef -hwdef $BlockDesignName.hwdef -bitfile $BlockDesignName.bit -file $BlockDesignName.hdf
# write_hwdef -file $BlockDesignName.hdf
}

if {$IsHDLWA == 1} {
set par_str [report_timing_summary -return_string]
set timing_err ""
set result [regexp {Timing constraints are not met} $par_str match]
if {$result > 0} {
	set timing_err "Warning: Design does not meet all timing constraints."
}
set log ""
lappend log "\n\n---------------------------------------------------"
lappend log "   SDR for Zynq Development Boards build summary"
lappend log "---------------------------------------------------\n"
if [catch {file copy -force "$BlockDesignName\.bit" ../sdcard_image/}] {
   file delete ../sdcard_image
   lappend log "Expected programming file not generated."
   lappend log "Zynq-based SDR Targeting build failed.\n"
} else {
   if {[string length $timing_err] > 0} {
      lappend log "$timing_err\n"
      set warn_str " with warning"
   } else {
      set warn_str ""
   }
   lappend log "Programming file generated."
   lappend log "You may close this shell."
}
foreach j $log {puts $j}
}
}

proc RunCheckpoint {} {
global ProjectName
global Device 
global Language 
global BlockDesignName
global ConstraintFile
global DataPath

set IPProject ${ProjectName}/../IP_Project
set HW_Reg_IP axi_lite_system_config_pcore

# Create a managed IP project
create_project managed_ip_project $IPProject -part $Device -ip

# Set basic project properties
set_property target_language $Language [current_project]
set_property target_simulator XSim [current_project]

# Update IP catalog, so that the DUT can actually be used
# set_property ip_repo_paths  $ProjectName/../sdrsrc/ipcores [current_project]
# update_ip_catalog

set_property ip_repo_paths  "../sdrsrc/ipcores" [current_fileset]
update_ip_catalog

if {[string equal $DataPath {Receive path}]} {
	 set DUTName rxdut_wrapper
} elseif {[string equal $DataPath {Transmit path}]} {
	 set DUTName txdut_wrapper
}

set IPProject [get_property directory [current_project]]

# ------------------------------------------------------------ #
# -------------------------- DUT IP -------------------------- #
# ------------------------------------------------------------ #

# Create DUT IP for OOC synthesis
create_ip -name $DUTName -vendor mathworks.com -library user -version 1.0 -module_name ${DUTName}_0 -dir $IPProject

# Generate synthesis target (i.e. the wrapper)
generate_target {instantiation_template} [get_files $IPProject/${DUTName}_0/${DUTName}_0.xci]
generate_target all [get_files  $IPProject/${DUTName}_0/${DUTName}_0.xci]

# Create a project managed run
create_ip_run [get_files -of_objects [get_fileset sources_1] $IPProject/${DUTName}_0/${DUTName}_0.xci]

# Launch synthesis and wait for it to finish
launch_run  ${DUTName}_0_synth_1
wait_on_run ${DUTName}_0_synth_1

# ------------------------------------------------------------ #
# ------------------------- HW Reg IP ------------------------ #
# ------------------------------------------------------------ #

# Create System Config IP for OOC synthesis
create_ip -name $HW_Reg_IP -vendor mathworks.com -library user -version 1.0 -module_name ${HW_Reg_IP}_0 -dir $IPProject

# Generate synthesis target (i.e. the wrapper)
generate_target {instantiation_template} [get_files $IPProject/${HW_Reg_IP}_0/${HW_Reg_IP}_0.xci]
generate_target all [get_files  $IPProject/${HW_Reg_IP}_0/${HW_Reg_IP}_0.xci]

# Create a project managed run
create_ip_run [get_files -of_objects [get_fileset sources_1] $IPProject/${HW_Reg_IP}_0/${HW_Reg_IP}_0.xci]

# Launch synthesis and wait for it to finish
launch_run  ${HW_Reg_IP}_0_synth_1
wait_on_run ${HW_Reg_IP}_0_synth_1

# The IPs finished synthesizing, this project is no longer needed
close_project

# ------------------------------------------------------------ #
# --------------------- Non-project flow --------------------- #
# ------------------------------------------------------------ #

# Open base design post-synthesis checkpoint
open_checkpoint ./post_synthesis.dcp

# Empty out the DUT and System Config IP core netlist cells
update_design -black_box -cell [ get_cells system_i/${DUTName}_0 ]
update_design -black_box -cell [ get_cells system_i/${HW_Reg_IP}_0 ]

# Insert the OOC synthesized IP cores into the black boxes
read_checkpoint -cell [ get_cells system_i/${DUTName}_0 ] $IPProject/${DUTName}_0/${DUTName}_0.dcp
read_checkpoint -cell [ get_cells system_i/${HW_Reg_IP}_0 ] $IPProject/${HW_Reg_IP}_0/${HW_Reg_IP}_0.dcp

# Read the constraints - this includes the user target frequency
read_xdc ../sdrsrc/${ConstraintFile}

# Write a new checkpoint that includes the the new netlist
write_checkpoint ${ProjectName}_post_synth -force

# Implementation - checkpoints written after each major step for review later
opt_design
write_checkpoint ${ProjectName}_post_opt -force

place_design
write_checkpoint ${ProjectName}_post_place -force

route_design
write_checkpoint ${ProjectName}_post_route -force

# Generate bitstream, only the BIN file is needed to download onto the FPGA
write_bitstream -bin_file $BlockDesignName

# Check if there were timing errors
set par_str [report_timing_summary -return_string]
set timing_err ""
set result [regexp {Timing constraints are not met} $par_str match]
if {$result > 0} {
	set timing_err "Warning: Design does not meet all timing constraints."
}
set log ""
lappend log "\n\n---------------------------------------------------"
lappend log "   SDR for Zynq Development Boards build summary"
lappend log "---------------------------------------------------\n"
if [catch {file copy -force "$BlockDesignName\.bit" ../sdcard_image/}] {
   file delete ../sdcard_image
   lappend log "Expected programming file not generated."
   lappend log "Zynq-based SDR Targeting build failed.\n"
} else {
   if {[string length $timing_err] > 0} {
      lappend log "$timing_err\n"
      set warn_str " with warning"
   } else {
      set warn_str ""
   }
   lappend log "Programming file generated."
   lappend log "You may close this shell."
}
foreach j $log {puts $j}
}

# Run build stages
for {set x 10} {$x<[llength $argv]} {incr x} {
[lindex $argv $x]
}




