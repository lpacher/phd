#
# Example Tcl script to create/open a standalone IP project to compile IP cores using Xilinx Vivado
#
# Luca Pacher - pacher@to.infn.it
# Spring 2020
#


## location of IP repository
set IPS_DIR [pwd]/cores ; file mkdir ${IPS_DIR}

## target FPGA
set targetFpga ${::env(XILINX_DEVICE)} 

## project name and XML file (use the same default naming convention as in the GUI flow)
set projectName managed_ip_project
set projectFile ${IPS_DIR}/${projectName}/${projectName}.xpr

## check if an IP project already exists
if { [file exists ${projectFile}] } {

   ## an IP project already exists, just re-open it (same as Manage IP > Open IP Location)
   open_project ${projectFile}

} else {

   ## create new IP project otherwise (same as Manage IP > New IP Location)
   create_project -ip -force -part ${targetFpga} ${projectName} ${IPS_DIR}/${projectName} -verbose

   ## simulation settings
   set_property target_simulator    XSim     [current_project]
   set_property target_language     Verilog  [current_project]
   set_property simulator_language  Mixed    [current_project]

   set_property ip_repo_paths ${IPS_DIR} [current_project]
   update_ip_catalog

   ## **DEBUG
   puts "**INFO: Target FPGA set to [get_parts -of_objects [current_project]]"

   ## display the IP catalog in the main window
   load_features ipintegrator
}


## optionally, synthesize IP from .xci XML configuration file passed as Makefile argument
if { [info exists argv] } {

   set xciFile [lindex ${argv} 0]

   if { [file exists ${xciFile} ]} {

      ## read IP customization (XML file)
      read_ip ${xciFile}

      ## generate all output products
      generate_target -force all [get_ips]

      ## synthesize the IP
      synth_ip [get_ips]
   }
}


## custom procedure to export all XSim simulation scripts
proc export_xsim_scripts {} {

   file mkdir ${::IPS_DIR}/export_scripts

   ## export XSim simulation scripts for all IPs in the current repo
   export_simulation -force -simulator xsim -directory ${::IPS_DIR}/export_scripts -of_objects [get_ips]
}
