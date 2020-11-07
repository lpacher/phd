#
# Example custom Tcl-based simulation flow to run XSim simulation flows interactively [SIMULATION step]
#
# Luca Pacher - pacher@to.infn.it
# Nov 7, 2020
#

###################################################################################################
#
# **NOTE
#
# There is no "non-project mode" simulation Tcl flow in Vivado, the "non-project mode" flow
# requires to call standalone xvlog/xvhdl, xelab and xsim executables from the command-line
# or inside a GNU Makefile.
# However in "non-project mode" the simulation can't be re-invoked from the GUI after RTL
# or testbench changes, thus requiring to exit from the GUI and re-build the simulation
# from scratch. This happens because XSim doesn't keep track of xvlog/xvhdl and xelab flows.
#
# In order to be able to "relaunch" a simulation from the XSim GUI you necessarily have to
# create a project in Vivado or to use a "project mode" Tcl script to automate the simulation.
# The overhead of creating an in-memory project is low compared to the benefits of fully automated
# one-step compilation/elaboration/simulation and re-launch features.
#
# This **CUSTOM** Tcl-based simulation flow basically reproduces all compilation/elaboration/simulation
# steps that actually Vivado performs "under the hood" for you without notice in project-mode.
# Most important, this custom flow is **PORTABLE** across Linux/Windows systems and allows
# to "relaunch" a simulation after RTL or testbench changes from the XSim Tcl console without
# the need of creating a project.
#
# Ref. also to  https://www.edn.com/improve-fpga-project-management-test-by-eschewing-the-ide
#
###################################################################################################


## variables
set TCL_DIR  [pwd]/../../scripts ;   ## **IMPORTANT: assume to run the flow inside work/sim !
set LOG_DIR  [pwd]/../../logs

## top-level RTL module (then tb_${RTL_TOP_MODULE}.(s)v is the testbench)
set RTL_TOP_MODULE $::env(RTL_TOP_MODULE)

puts "\n**INFO: Invoking XSim standalone executable from [pwd]" ;

## launch the xsim executable from Tcl
exec xsim -gui tb_${RTL_TOP_MODULE} -onerror stop -stats -tclbatch ${TCL_DIR}/sim/run.tcl -log ${LOG_DIR}/simulate.log &

