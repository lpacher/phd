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


#############################################
##   physical constraints (port mapping)   ##
#############################################

#set_property IOSTANDARD LVCMOS33 [all_inputs]
#set_property IOSTANDARD LVCMOS33 [all_outputs]

## on-board 100 MHz clock signal
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports clk]

## map the reset to a push-button
set_property -dict { PACKAGE_PIN D9  IOSTANDARD LVCMOS33 } [get_ports rst] ;   ## BTN0

## play here with oscilloscope probes
set_property -dict { PACKAGE_PIN U11   IOSTANDARD LVCMOS33 } [get_ports { BCD[3] }] ;   ## IO26
set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 } [get_ports { BCD[2] }] ;   ## IO27
set_property -dict { PACKAGE_PIN M13   IOSTANDARD LVCMOS33 } [get_ports { BCD[1] }] ;   ## IO28
set_property -dict { PACKAGE_PIN R10   IOSTANDARD LVCMOS33 } [get_ports { BCD[0] }] ;   ## IO29


################################
##   electrical constraints   ##
################################

## just for reference, the default unit of capacitance is pF, but can be changed using the set_units command
set_units -capacitance pF

#
# **WARNING
#
# The load capacitance is used during power analysis when running the report_power
# command, but it's not used during timing analysis
#
set_load 2 [all_outputs] -verbose


############################
##   timing constraints   ##
############################

create_clock -period 10.000 -name clk -waveform {0.000 5.000} -add [get_ports clk]
