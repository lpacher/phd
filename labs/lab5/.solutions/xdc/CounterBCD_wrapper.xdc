#
# Implementation constraints for the Gates.vhd VHDL example.
# All pin positions and electrical properties refer to the
# Digilent Arty-A7 development board.
#
# The complete .xdc for the board can be downloaded from the
# official Digilent GitHub repository at :
# 
#    https://github.com/Digilent/Arty/blob/master/Resources/XDC/Arty_Master.xdc
#
# To find actual physical locations of pins on the board, please check
# board reference schematics :
#
#    https://reference.digilentinc.com/_media/arty:arty_sch.pdf
#
# Luca Pacher - pacher@to.infn.it
# Fall 2020
#

#set MAP_TO_LEDS 1
set MAP_TO_LEDS 0

#############################################
##   physical constraints (port mapping)   ##
#############################################

## on-board 100 MHz clock signal
set_property -dict { PACKAGE_PIN E3 IOSTANDARD LVCMOS33 } [get_ports clk]

## map the reset to a push-button
set_property -dict { PACKAGE_PIN D9  IOSTANDARD LVCMOS33 } [get_ports rst] ;   ## BTN0

## map the MUX selector between 100 MHz/200 MHz PLL clock 
set_property -dict { PACKAGE_PIN A8  IOSTANDARD LVCMOS33 } [get_ports clk_sel] ; ## SW0


## play here with either LEDs or oscilloscope probes

#
# **IMPORTANT !
#
# In this XDC example we also use a Tcl control statement if/else to easily switch
# between mapping the BCD count to on-board LEDs or to some on-board pin headers for
# oscilloscope probing.
# Be aware that by default the 'read_xdc' Vivado command **DOES NOT SUPPORT** the usage
# of all Tcl statements (such as if/else, for, foreach etc.).
# In order to use any valid Tcl statement into a constraint file you must specify the
# "-unmanaged" flag when executing the 'read_xdc' command :
#
#    read_xdc -unmanaged /path/to/filename.xdc 
#
# Ref. also to Vivado Design Suite User Guide: Using Constraints (UG903)
#
#   https://www.xilinx.com/support/documentation/sw_manuals/xilinx2019_2/ug903-vivado-using-constraints.pdf
#

if { $MAP_TO_LEDS } {

   set_property -dict { PACKAGE_PIN T10 IOSTANDARD LVCMOS33 } [get_ports { BCD[3] }] ; ## LD7
   set_property -dict { PACKAGE_PIN T9  IOSTANDARD LVCMOS33 } [get_ports { BCD[2] }] ; ## LD6
   set_property -dict { PACKAGE_PIN J5  IOSTANDARD LVCMOS33 } [get_ports { BCD[1] }] ; ## LD5
   set_property -dict { PACKAGE_PIN H5  IOSTANDARD LVCMOS33 } [get_ports { BCD[0] }] ; ## LD4

} else {

   set_property -dict { PACKAGE_PIN U11 IOSTANDARD LVCMOS33 } [get_ports { BCD[3] }] ;   ## IO26
   set_property -dict { PACKAGE_PIN V16 IOSTANDARD LVCMOS33 } [get_ports { BCD[2] }] ;   ## IO27
   set_property -dict { PACKAGE_PIN M13 IOSTANDARD LVCMOS33 } [get_ports { BCD[1] }] ;   ## IO28
   set_property -dict { PACKAGE_PIN R10 IOSTANDARD LVCMOS33 } [get_ports { BCD[0] }] ;   ## IO29
}


################################
##   electrical constraints   ##
################################

#set_property SLEW FAST [all_outputs]
#set_property SLEW SLOW [all_outputs] ;  ## default

#set_property IOSTANDARD LVCMOS33 [all_inputs]
#set_property IOSTANDARD LVCMOS33 [all_outputs]


## just for reference, the default capacitance unit is pF, but can be changed using the set_units command
set_units -capacitance pF

#
# **WARNING
#
# The load capacitance is used during power analysis when running the report_power
# command, but it's not used during timing analysis
#
set_load 5 [all_outputs] -verbose


############################
##   timing constraints   ##
############################

## just for reference, the default time unit is ns
set_units -time ns

## create a 100 MHz clock signal with 50% duty cycle for Static Timing Analysis (STA)
create_clock -period 10.000 -name clk100 -waveform {0.000 5.000} -add [get_ports clk]
