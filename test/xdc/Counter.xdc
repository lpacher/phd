#######################################
##   on-board 100 MHz clock signal   ##
#######################################

set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -period 10.000 -name clk -waveform {0.000 5.000} -add [get_ports clk]


###############
##   reset   ##
###############

set_property -dict {PACKAGE_PIN D9 IOSTANDARD LVCMOS33} [get_ports rst] ;   ## BTN0


#####################
##   5-bit count   ##
#####################

set_property -dict {PACKAGE_PIN G13 IOSTANDARD LVCMOS33} [get_ports {count[0]} ] ;   ## map the LSB to PMOD header JA[1]

set_property -dict {PACKAGE_PIN H5  IOSTANDARD LVCMOS33} [get_ports {count[1]} ] ;   ## LD4
set_property -dict {PACKAGE_PIN J5  IOSTANDARD LVCMOS33} [get_ports {count[2]} ] ;   ## LD5
set_property -dict {PACKAGE_PIN T9  IOSTANDARD LVCMOS33} [get_ports {count[3]} ] ;   ## LD6
set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVCMOS33} [get_ports {count[4]} ] ;   ## LD7
