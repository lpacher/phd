#
# Example Makefile to automate the Xilinx XSim simulation flow
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


############################
##   VHDL sources setup   ##
############################

## list of VHDL sources to be compiled
SOURCES := Gates.vhd tb_Gates.vhd
#SOURCES := GatesWhenElse.vhd tb_Gates.vhd

## top-level module (testbench)
TOP := tb_Gates


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

#
# **NOTE: none of implemented targets are on-disk files, declare each target as PHONY
#

## default target
.PHONY : default
default : help


## compile VHDL sources (xvhdl)
.PHONY : default
compile :
	@xvhdl $(SOURCES)
##_______________________________________________________________________________________


## elaborate the design (xelab)
.PHONY : elaborate
elaborate :
	@xelab -debug all $(TOP)
##_______________________________________________________________________________________


## run the simulation (xsim)
.PHONY : simulate
simulate :
	@xsim $(TOP) -gui -tclbatch run.tcl
##_______________________________________________________________________________________


## one-step compilation/elaboration/simulation
.PHONY : sim
sim : compile elaborate simulate
##_______________________________________________________________________________________


## delete all log files and simulation outputs
.PHONY : clean
clean :
	@$(RM) *.log *.jou *.pb *.wdb
	@$(RMDIR) xsim.dir .Xil
##_______________________________________________________________________________________


## command line help
.PHONY : help
help :

	@$(ECHO) ""
	@$(ECHO) "\nUsage: make <target>" 
	@$(ECHO) ""
	@$(ECHO) "Available targets:"
	@$(ECHO) ""
	@$(ECHO) " - make help        Command-line help"
	@$(ECHO) " - make compile     Parse and compile Verilog sources"
	@$(ECHO) " - make elaborate   Elaborate design"
	@$(ECHO) " - make simulate    Run simulation executable"
	@$(ECHO) " - make sim         Alias, one step compilation, elaboration and simulation"
	@$(ECHO) " - make clean       Delete all log files and temporary files\n"
##_______________________________________________________________________________________

