set genDirRoot [pwd]

# Ignore ADI tool version check
set ::env(ADI_IGNORE_VERSION_CHECK) "1"

for {set i 0} {$i < [expr [llength "lindex $argv"]-1]} {incr i} {
    cd $genDirRoot/library/[lindex $argv $i]
    source "[lindex $argv $i]\_ip.tcl"
}

exit
