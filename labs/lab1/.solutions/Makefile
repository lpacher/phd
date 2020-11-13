#
# Example Makefile to automate the Xilinx simulation flow
#

## compile VHDL sources (xvhdl)
compile :
	@xvhdl Inverter.vhd tb_Inverter.vhd


## elaborate the design (xelab)
elaborate :
	@xelab -debug all tb_Inverter


## run the simulation (xsim)
simulate :
	@xsim -gui -tclbatch run.tcl tb_Inverter


## one-step compilation/elaboration/simulation
sim : compile elaborate simulate


## delete all log files and simulation outputs
clean :
	@rm -rf -v rm -rf *.log *.jou *pb *.wdb xsim.dir .Xil

