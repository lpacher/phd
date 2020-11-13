#
# Example Tcl simulation script for Xilinx XSim
#
# Luca Pacher - pacher@to.infn.it
# Fall 2020
#

## profiling
set tclStart [clock seconds]

## automatically get the name of the testbench ( [current_scope] returns /testbenchName, then remove the trailing "/" using regex)
set TOP [regsub (/) [current_scope] ""]

## open WCFG file if exists, add all top-level signals to the Wave window otherwise
if { [file exists ${TOP}.wcfg] } {

   open_wave_config ${TOP}.wcfg

} else {

   add_wave /${TOP}/*
}

## run the simulation
run all

## print overall simulation time on XSim console
puts "\nSimulation finished at [current_time]\n"

## report CPU time
set tclStop [clock seconds]
set seconds [expr $tclStop - $tclStart]

puts "\nTotal elapsed-time for [info script]: [format "%.2f" [expr $seconds/60.]] minutes\n"


## save display customizations into a waveform configuration file (XML)
#save_wave_config tb_Gates.wcfg

## restore custom waveforms configuration settings
#open_wave_config tb_Gates.wcfg

