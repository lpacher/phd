#
# Improved Makefile to automate the Xilinx XSim simulation flow
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
dut := MUX2

## export the name of the top-level module as an environment variable to be used from tclsh
export RTL_TOP_MODULE=$(dut)


############################
##   working area setup   ##
############################

## main "scratch" working area used to run the flows (work/sim for simulations, work/impl for implementation)
WORK_DIR := work


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
#XDC_DIR := xdc

## extra directories
TEMP_DIR := tmp
TEST_DIR := test


#########################
##   other variables   ##
#########################

## some useful UNIX aliases
ECHO  := echo -e
RM    := rm -f -v
RMDIR := rm -rf -v
MKDIR := mkdir -p -v


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
	@$(MKDIR) $(TCL_DIR)/sim
	@$(MKDIR) $(BIN_DIR)

	@$(MKDIR) $(LOG_DIR)
	@$(MKDIR) $(DOC_DIR)
	@$(MKDIR) $(IPS_DIR)

	@$(MKDIR) $(WORK_DIR)/sim

	@$(MKDIR) $(TEMP_DIR)
	@$(MKDIR) $(TEST_DIR)

	@$(ECHO) "\n   -- Working area setup completed !\n\n"
##_______________________________________________________________________________________


## parse and compile all RTL and simulation sources
.PHONY : compile
compile : 

ifeq ($(wildcard $(WORK_DIR)/sim/.*),)
	@$(error **ERROR: Missing simulation working area ! Run make area before running the flows.)
else
	@cd work/sim ; tclsh ../../scripts/sim/$@.tcl
endif
##_______________________________________________________________________________________


## elaborate the design
.PHONY : elaborate
elaborate :

	@cd work/sim ; tclsh ../../scripts/sim/$@.tcl
##_______________________________________________________________________________________


## run simulation executable
.PHONY : simulate
simulate :

	@cd work/sim ; tclsh ../../scripts/sim/$@.tcl
##_______________________________________________________________________________________


## one-step compilation, elaboration and simulation (same as make compile elaborate simulate)
.PHONY : sim
sim : compile elaborate simulate
##_______________________________________________________________________________________


## delete all log files and temporary files
.PHONY : clean
clean :

	@$(RM) *.log *.jou *.pb *.wdb $(LOG_DIR)/*
	@$(RMDIR) xsim.dir .Xil
	@$(RMDIR) work/sim/*
	@$(RMDIR) work/impl/*
##_______________________________________________________________________________________


## command line help
.PHONY : help
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
##_______________________________________________________________________________________

