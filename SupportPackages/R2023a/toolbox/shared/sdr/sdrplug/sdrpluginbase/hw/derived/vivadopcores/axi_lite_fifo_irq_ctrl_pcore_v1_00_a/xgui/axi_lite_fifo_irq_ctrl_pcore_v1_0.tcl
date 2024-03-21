# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
	set Page0 [ipgui::add_page $IPINST -name "Page 0" -layout vertical]
	set Component_Name [ipgui::add_param $IPINST -parent $Page0 -name Component_Name]
	set base_addr [ipgui::add_param $IPINST -parent $Page0 -name base_addr]
}

proc update_PARAM_VALUE.base_addr { PARAM_VALUE.base_addr } {
	# Procedure called to update base_addr when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.base_addr { PARAM_VALUE.base_addr } {
	# Procedure called to validate base_addr
	return true
}


proc update_MODELPARAM_VALUE.base_addr { MODELPARAM_VALUE.base_addr PARAM_VALUE.base_addr } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.base_addr}] ${MODELPARAM_VALUE.base_addr}
}

