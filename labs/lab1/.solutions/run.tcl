#
# Example Tcl simulation script for Xilinx XSim
#
# Luca Pacher - pacher@to.infn.it
# Fall 2020
#

## profiling
set tclStart [clock seconds]

## add all top-level signals to the Wave window
add_wave /tb_Inverter/*

## run the simulation
run all

## print overall simulation time on XSim console
puts "\nSimulation finished at [current_time]\n"

## report CPU time
set tclStop [clock seconds]
set seconds [expr $tclStop - $tclStart]

puts "\nTotal elapsed-time for [info script]: [format "%.2f" [expr $seconds/60.]] minutes\n"

