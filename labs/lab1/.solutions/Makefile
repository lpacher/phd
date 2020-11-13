#
# A first simple Makefile example to automate the Xilinx XSim simulation flow
#

## list of VHDL sources to be compiled
SOURCES := Inverter.vhd tb_Inverter.vhd


## top-level module (testbench)
TOP := tb_Inverter


## some useful Linux aliases
RM := rm -f -v
RMDIR := rm -rf -v


## compile VHDL sources (xvhdl)
compile :
	@xvhdl $(SOURCES)


## elaborate the design (xelab)
elaborate :
	@xelab -debug all $(TOP)


## run the simulation (xsim)
simulate :
	@xsim -gui -tclbatch run.tcl $(TOP)


## one-step compilation/elaboration/simulation
sim : compile elaborate simulate


## delete all log files and simulation outputs
clean :
	@$(RM) *.log *.jou *.pb *.wdb *.wcfg
	@$(RMDIR) xsim.dir .Xil

