#
# Sample Makefile to test tools installation and setup.
#
# Luca Pacher - pacher@to.infn.it
# Fall 2020
#

#######################################
##   preamble (reserved variables)   ##
#######################################

#
# **IMPORTANT
#
# This is a fully UNIX-compliant Makefile that can run on both Linux and Windows systems.
# On Windows, please ensure that all required Linux executables are available in the search
# path from the Command Prompt. Required executables are :
#
# make.exe bash.exe mkdir.exe echo.exe rm.exe tclsh.exe
#


## 'make' extra flags
MAKEFLAGS += --warn-undefined-variables --debug

## Bash configuration (be picky and exit immediately on any error)
SHELL := bash
.SHELLFLAGS := -e -u -o pipefail -c



##############################
##   top-level RTL module   ##
##############################

#
# **NOTE
#
# By default all rtl/*.vhd and bench/*.vhd sources are parsed and compiled using xvhdl,
# then tb_$(dut) is considered as testbench module when xelab is invoked for elaboration.
#
dut := Counter

## export the name of the top-level module as an environment variable to be used from tclsh
export RTL_TOP_MODULE=$(dut)


############################
##   working area setup   ##
############################

## main "scratch" working area used to run the flows (default: work/sim for simulations, work/impl for implementation)
WORK_DIR := work

## export the chosen working directory to all flows
export WORK_DIR

## additional useful "clean" directories to store input design data
RTL_DIR := rtl
SIM_DIR := bench
TCL_DIR := scripts
LOG_DIR := log
DOC_DIR := doc

## put non-Tcl scripts and programs into a ./bin directory (e.g. Python scripts)
BIN_DIR := bin

## flows-specific directories
IPS_DIR := cores
XDC_DIR := xdc
SDF_DIR := sdf
RPT_DIR := reports


## extra directories
TEMP_DIR := tmp
TEST_DIR := test


## some useful UNIX aliases
ECHO  := echo -e
RM    := rm -f -v
RMDIR := rm -rf -v
MKDIR := mkdir -p -v


################################
##   Xilinx Vivado settings   ##
################################

## by default, run Vivado/XSim in GUI mode
mode ?= gui


################################
##   targets implementation   ##
################################


## default target
.PHONY : default
default : help


## creates a new fresh working area with all necessary directories used in the flows
.PHONY : area
area :

	@$(MKDIR) $(RTL_DIR)
	@$(MKDIR) $(SIM_DIR)

	@$(MKDIR) $(TCL_DIR)/common
	@$(MKDIR) $(TCL_DIR)/sim
	@$(MKDIR) $(TCL_DIR)/impl
	@$(MKDIR) $(BIN_DIR)
	@$(MKDIR) $(DOC_DIR)

	@$(MKDIR) $(LOG_DIR)
	@$(MKDIR) $(IPS_DIR)
	@$(MKDIR) $(XDC_DIR)
	@$(MKDIR) $(SDF_DIR)
	@$(MKDIR) $(RPT_DIR)

	@$(MKDIR) $(WORK_DIR)/sim
	@$(MKDIR) $(WORK_DIR)/impl

	@$(MKDIR) $(TEMP_DIR)
	@$(MKDIR) $(TEST_DIR)

	@$(ECHO) "\n   -- Working area setup completed !\n\n"
##_______________________________________________________________________________________


## parse and compile all RTL and simulation sources
.PHONY : compile
compile : $(TCL_DIR)/sim/compile.tcl

ifeq ($(wildcard $(WORK_DIR)/sim/.*),)
	@$(error ERROR: Missing simulation working area ! Run 'make area' before running the flows.)
else
	@tclsh $(TCL_DIR)/sim/compile.tcl $@
endif
##_______________________________________________________________________________________


## elaborate the design
.PHONY : elaborate
elaborate : $(TCL_DIR)/sim/elaborate.tcl

	@tclsh $(TCL_DIR)/sim/elaborate.tcl $@
##_______________________________________________________________________________________


## run simulation executable
.PHONY : simulate
simulate : $(TCL_DIR)/sim/simulate.tcl $(WORK_DIR)/sim/xsim.dir

	@tclsh $(TCL_DIR)/sim/simulate.tcl $@
##_______________________________________________________________________________________

## one-step compilation, elaboration and simulation (same as make compile elaborate simulate)
.PHONY : sim
sim : compile elaborate simulate
##_______________________________________________________________________________________


## create fresh Vivado project attached to Arty7 device
.PHONY : project
project : $(TCL_DIR)/common/init.tcl $(TCL_DIR)/common/project.tcl

	@vivado -mode $(mode) -source $(TCL_DIR)/common/init.tcl -source $(TCL_DIR)/common/$@.tcl -log $(LOG_DIR)/$@.log -nojournal -verbose -notrace -tclargs $(dut)
##_______________________________________________________________________________________


## restore Vivado project from XML project file (.xpr) or design checkpoint (.dcp)
restore :

	@vivado -mode $(mode) -source $(TCL_DIR)/common/init.tcl -log $(LOG_DIR)/$@.log -nojournal -verbose -notrace $(db)
##_______________________________________________________________________________________


## launch IP flow in GUI mode
.PHONY : ip
ip : $(IPS_DIR) $(TCL_DIR)/common/init.tcl $(TCL_DIR)/common/ip.tcl

	@vivado -mode gui -source $(TCL_DIR)/common/init.tcl -source $(TCL_DIR)/common/$@.tcl -notrace -log $(LOG_DIR)/$@.log -nojournal
##_______________________________________________________________________________________


## run Vivado FPGA implementation flow in non-project mode
.PHONY : xflow
xflow : $(WORK_DIR)/impl $(TCL_DIR)/common/init.tcl $(TCL_DIR)/impl/xflow.tcl

	@vivado -mode $(mode) -source $(TCL_DIR)/common/init.tcl -source $(TCL_DIR)/impl/$@.tcl -log $(LOG_DIR)/$@.log -nojournal -verbose -notrace -tclargs $(dut)
##_______________________________________________________________________________________


## alias, same as 'make xflow'
.PHONY : bit
bit : xflow
##_______________________________________________________________________________________


## launch Vivado GUI and open the Hardware Manager
.PHONY :
hm : $(TCL_DIR)/common/init.tcl $(TCL_DIR)/common/hm.tcl

	@vivado -mode gui -source $(TCL_DIR)/common/init.tcl -source $(TCL_DIR)/common/$@.tcl -notrace -log $(LOG_DIR)/$@.log -nojournal
##_______________________________________________________________________________________


## upload bitstream to target FPGA using Hardware Manager
.PHONY : upload
upload : $(TCL_DIR)/common/init.tcl $(TCL_DIR)/impl/upload.tcl

	@vivado -mode $(mode) -source $(TCL_DIR)/common/init.tcl -source $(TCL_DIR)/impl/$@.tcl -notrace -log $(LOG_DIR)/$@.log -nojournal -tclargs $(dut)
##_______________________________________________________________________________________


## alias, same as 'make upload'
install : upload
##_______________________________________________________________________________________


## program external Quad Flash memory
.PHONY : flash
flash : $(TCL_DIR)/common/init.tcl $(TCL_DIR)/impl/flash.tcl

	@vivado -mode $(mode) -source $(TCL_DIR)/common/init.tcl -source $(TCL_DIR)/impl/$@.tcl -notrace -log $(LOG_DIR)/$@.log -nojournal -tclargs $(dut)
##_______________________________________________________________________________________


## delete all log files and temporary files
.PHONY : clean
clean :

	@$(RM) *.log *.jou *.pb *.wdb $(LOG_DIR)/*
	@$(RMDIR) xsim.dir .Xil
	@$(RMDIR) $(WORK_DIR)/sim/*
	@$(RMDIR) $(WORK_DIR)/impl/*
##_______________________________________________________________________________________


## command line help
.PHONY : help
help :

	@$(ECHO) ""
	@$(ECHO) "\nUsage: make <target> [dut=ModuleName] [mode=gui|tcl|batch] [db=/path/to/project.xpr | db=/path/to/project.dcp]"
	@$(ECHO) ""
	@$(ECHO) "Available targets:"
	@$(ECHO) ""
	@$(ECHO) " - make help        Command-line help"
	@$(ECHO) " - make area        Creates new fresh working area"
	@$(ECHO) " - make compile     Parse and compile Verilog sources"
	@$(ECHO) " - make elaborate   Elaborate design"
	@$(ECHO) " - make simulate    Run simulation executable"
	@$(ECHO) " - make sim         Alias, one step compilation, elaboration and simulation"
	@$(ECHO) " - make project     Creates new fresh project attached to Arty7 device"
	@$(ECHO) " - make restore     Restore Vivado project from XML project file (.xpr) or design checkpoint (.dcp)"
	@$(ECHO) " - make ip          Customize and compile IP cores for your design"
	@$(ECHO) " - make xflow       Run Vivado FPGA implementation flow in non-project mode"
	@$(ECHO) " - make bit         Alias, same as make xflow"
	@$(ECHO) " - make hm          Launch Vivado in GUI mode and open the Hardware Manager"
	@$(ECHO) " - make upload      Upload bitsream to target FPGA using Hardware Manager"
	@$(ECHO) " - make install     Alias, same as make upload"
	@$(ECHO) " - make flash       Program external Quad Flash memory"
	@$(ECHO) " - make clean       Delete all log files and temporary files\n"
##_______________________________________________________________________________________

