#
# Sample Makefile to test tools installation and setup.
#
# Luca Pacher - pacher@to.infn.it
# Nov 7, 2020
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
# By default all rtl/*.v and bench/*.v sources are parsed and compiled using xvlog,
# then tb_$(dut) is considered as testbench module when xelab is invoked for elaboration.
#
dut := Counter



############################
##   working area setup   ##
############################

## main "scratch" working area used to run the flows (work/sim for simulations, work/impl for implementation)
WORK_DIR := work


## additional useful "clean" directories to store input design data
RTL_DIR := rtl
SIM_DIR := bench
TCL_DIR := scripts
LOG_DIR := logs

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
##   targets implementation   ##
################################


## default target
default : help


## creates a new fresh working area with all necessary directories used in the flows
.PHONY : area
area :

	@$(MKDIR) $(RTL_DIR)
	@$(MKDIR) $(SIM_DIR)
	@$(MKDIR) $(TCL_DIR)/sim
	@$(MKDIR) $(TCL_DIR)/impl
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


## parse and compile all Verilog sources
compile : $(WORK_DIR)/sim

	@cd work/sim ; tclsh ../../scripts/sim/$@.tcl


## elaborate the design
elaborate :

	@cd work/sim ; export RTL_TOP_MODULE=$(dut) ; tclsh ../../scripts/sim/$@.tcl


## run simulation executable
simulate :

	@cd work/sim ; export RTL_TOP_MODULE=$(dut) ; tclsh ../../scripts/sim/$@.tcl


## one-step compilation, elaboration and simulation (same as make compile elaborate simulate)
sim : compile elaborate simulate


## delete all log files and temporary files
clean :

	@$(RM) *.log *.jou *.pb *.wdb $(LOG_DIR)/*
	@$(RMDIR) xsim.dir .Xil
	@$(RMDIR) work/sim/*
	@$(RMDIR) work/impl/*


## command line help 
help :

	@$(ECHO) ""
	@$(ECHO) "\nUsage: make <target> [dut=ModuleName]"
	@$(ECHO) ""
	@$(ECHO) "Available targets:"
	@$(ECHO) ""
	@$(ECHO) " - make help        Command-line help"
	@$(ECHO) " - make area        Creates new fresh working area"
	@$(ECHO) " - make compile     Parse and compile Verilog sources"
	@$(ECHO) " - make elaborate   Elaborate design" 
	@$(ECHO) " - make simulate    Run simulation executable"
	@$(ECHO) " - make sim         Alias, one step compilation, elaboration and simulation"
	@$(ECHO) " - make clean       Delete all log files and temporary files\n"

