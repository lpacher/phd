#
# Xilinx implementation constraints for Pseudo-Random Bit Sequence (PRBS)
# generator using a Linear Feedback Shift Register (LFSR) in VHDL.
#
# **NOTE: All pin positions and electrical properties refer to the
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
#
# Luca Pacher - pacher@to.infn.it
# Fall 2020
#


#############################################
##   physical constraints (port mapping)   ##
#############################################

## on-board 100 MHz clock signal
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports clk]

## map PRBS output to pin header IO26
set_property -dict { PACKAGE_PIN U11 IOSTANDARD LVCMOS33 } [get_ports PRBS]


###########################################
##   electrical and timing constraints   ##
###########################################

## just for reference, these are already default units
set_units -capacitance pF
set_units -time ns

## assume 10 pF parasitic capacitance from oscilloscope probe
set_load 10 [get_ports PRBS] -verbose

## create a 100 MHz clock signal with 50% duty cycle for reg2reg Static Timing Analysis (STA)
create_clock -period 10.000 -name clk -waveform {0.000 5.000} -add [get_ports clk]
