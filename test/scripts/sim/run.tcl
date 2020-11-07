#
# Example Tcl simulation script for Xilinx XSim simulator
#
# Luca Pacher - pacher@to.infn.it
# Nov 7, 2020
#

## profiling
set tclStart [clock seconds]

## create new Wave window (default name is "Untitled 1")
create_wave_config "Untitled 1"

## add all top-level signals to the Wave window
add_wave /*

## set unsigned-decimal radix for the count
set_property radix unsigned [get_waves count*] 

## run the simulation
run all

## print overall simulation time on XSim console
puts "Simulation finished at [current_time]"

## report CPU time
set tclStop [clock seconds]
set seconds [expr $tclStop - $tclStart]

puts "\nTotal elapsed-time for [info script]: [format "%.2f" [expr $seconds/60.]] minutes\n"


########################################################
##   other simulation commands (just for reference)   ##
########################################################

## reset simulation time back to t=0
#restart

## get/set current scope
#current_scope
#get_scopes
#report_scopes

## change default radix for buses (default is hexadecimal)
#set_property radix bin       [get_waves *]
#set_property radix unsigned  [get_waves *] ;  ## unsigned decimal
#set_property radix hex       [get_waves *]
#set_property radix dec       [get_waves *] ;  ## signed decimal
#set_property radix ascii     [get_waves *]
#set_property radix oct       [get_waves *]

## save Waveform Configuration File (WCFG) for later restore
# save_wave_config /path/to/filename.wcfg

## query signal values and drivers
#get_value /path/to/signal
#describe /path/to/signal
#report_values
#report_drivers /path/to/signal
#report_drivers [get_nets *signal]

## deposit a logic value on a signal
#set_value [-radix bin] /hierarchical/path/to/signal value

## force a signal
#add_force [-radix] [-repeat_every] [-cancel_after] [-quiet] [-verbose] /hierarchical/path/to/signal value
#set forceName [add_force /hierarchical/path/to/signal value]

## delete a force or all forces
#remove_forces ${forceName}
#remove_forces -all

## add/remove breakpoints to RTL sources
#add_bp fileName.v lineNumber
#remove_bp -file fileName -line lineNumber
#remove_bp -all

## unload the simulation snapshot without exiting Vivado
#close_sim

## dump Switching Activity Interchange Format (SAIF) file for power analysis
#open_saif /path/to/file.saif
#log_saif /path/to/signal
#log_saif [get_objects]
#close_saif

## hide the GUI
#stop_gui

## exit the simulator
#exit


###############################################################################
##   custom Tcl procedure to relaunch the simulation after sources changes   ##
###############################################################################

#
# **NOTE
#
# There is no "non-project mode" simulation Tcl flow in Vivado, the "non-project mode" flow
# requires to call standalone xvlog/xvhdl, xelab and xsim executables from the command-line
# or inside a GNU Makefile.
# However in "non-project mode" the simulation can't be re-invoked from the GUI after RTL
# or testbench changes, thus requiring to exit from the GUI and re-build the simulation
# from scratch. This happens because XSim doesn't keep track of xvlog/xvhdl and xelab flows.
#
# In order to be able to "relaunch" a simulation from the XSim GUI you necessarily have to
# create a project in Vivado or to use a "project mode" Tcl script to automate the simulation.
# The overhead of creating an in-memory project is low compared to the benefits of fully automated
# one-step compilation/elaboration/simulation and re-launch features.
#
# This **CUSTOM** Tcl-based simulation flow basically reproduces all compilation/elaboration/simulation
# steps that actually Vivado performs "under the hood" for you without notice in project-mode.
# Most important, this custom flow is **PORTABLE** across Linux/Windows systems and allows
# to "relaunch" a simulation after RTL or testbench changes from the XSim Tcl console without
# the need of creating a project.
#
# Ref. also to  https://www.edn.com/improve-fpga-project-management-test-by-eschewing-the-ide
#

proc relaunch {} {

   ## optionally, save waveforms setup
   #save_wave_config [current_wave_config]

   ## unload the current simulation snapshot without exiting XSim
   close_sim -force -quiet

   ## ensure to start from scratch
   catch {exec rm -rf xsim.dir .Xil [glob *.pb] [glob *.wdb] }

   ## re-compile sources
   source [pwd]/../../scripts/sim/compile.tcl -notrace ;   ## **IMPORTANT: assume to run the flow inside work/sim !

   ## re-elaborate the design
   source [pwd]/../../scripts/sim/elaborate.tcl -notrace

   ## reload the simulation snapshot
   xsim tb_${::env(RTL_TOP_MODULE)}

   ## optionally, restore previous waveforms setup
   #open_wave_config /path/to/file.wcfg

   create_wave_config "Untitled 1" ; add_wave /*

   ## re-run the simulation
   run all
}

