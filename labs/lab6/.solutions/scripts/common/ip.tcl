#
# Example Tcl script to create/open a standalone IP project
# to compile IP cores using Xilinx Vivado.
# Optionally, if a Xilinx Core Instance (.xci) XML configuraton file
# is specified at the command line the script will try to re-generate
# all output products according to IP configuration. 
#
# Luca Pacher - pacher@to.infn.it
# Fall 2020
#

puts "\nINFO: \[TCL\] Running [file normalize [info script]]\n"

## profiling
set tclStart [clock seconds]

## location of IP repository
set IPS_DIR [pwd]/cores

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

   file mkdir ${IPS_DIR}

   ## create new IP project otherwise (same as Manage IP > New IP Location)
   create_project -ip -force -part ${targetFpga} ${projectName} ${IPS_DIR}/${projectName} -verbose

   ## simulation settings
   #set_property target_language     Verilog  [current_project]
   set_property target_language     VHDL     [current_project]
   set_property target_simulator    XSim     [current_project]
   set_property simulator_language  Mixed    [current_project]

   set_property ip_repo_paths ${IPS_DIR} [current_project]
   update_ip_catalog

   ## **DEBUG
   puts "**INFO: Target FPGA set to [get_parts -of_objects [current_project]]"

   ## display the IP catalog in the main window
   load_features ipintegrator

   puts "**INFO: IPs already in the repo: [get_ips]"

}


## optionally, synthesize IP from .xci XML configuration file passed as Makefile argument
if { [llength ${argv}] > 0 } {

   set xciFile [file normalize [lindex ${argv} 0]] ;  ## **IMPORTANT: use [file normalize $filename] to automatically map \ into /

   if { [file exists ${xciFile}]} {

      ## read IP customization (XML file)
      puts "\n\nINFO \[TCL\] Loading IP customization file [file normalize ${xciFile}]\n\n"

      ## check if IP is already part of the project
      if { [llength [get_files ${xciFile}]] == 1 } {

         puts -nonewline "WARNING: IP already in the repository ! Do you want to re-compile it from scratch ? (y/n): "

         gets stdin answer ;  ## read y/n character from console

         if { ![string compare -nocase ${answer} "y"] } {

            puts "\n\n\IP will be recompiled...\n"

            ## reset output products
            reset_target all -verbose [get_files ${xciFile}]  
            remove_files -verbose [get_files ${xciFile}]

            ## re-load IP customization
            read_ip -verbose  [file normalize ${xciFile}]

            ## re-generate output products
            generate_target all -force -verbose [get_files ${xciFile}]

            ## synthesize the IP to generate Out-Of Context (OOC) design checkpoint (.dcp)
            synth_ip [get_files ${xciFile}] ; puts "\n\nDone !\n\n"

         } elseif { ![string compare -nocase ${answer} "n"] } {

            puts "\n\n\Skip recompilation !\n\n"

         } else {

            puts "\n\n\**ERROR: Invalid choice ${answer} ! Force an exit now.\n\n"

            ## script failure
            exit 1
         }

      } else {

         ## IP not yet part of the repository, compile it from .xci
         read_ip -verbose ${xciFile}

         ## generate output products
         generate_target all -force -verbose [get_files ${xciFile}] ; puts "\n\nDone !\n\n"

         ## synthesize the IP to generate Out-Of Context (OOC) design checkpoint (.dcp)
         synth_ip [get_files ${xciFile}]
      }

   } else {

      puts "\n\nERROR: \[TCL\] The specified XCI file ${xciFile} does not exist !"
      puts "             Please specify a valid path to an existing XCI file."
      puts "             Force an exit now.\n\n"

      ## script failure
      exit 1
   }
}


## report CPU time
set tclStop [clock seconds]
set seconds [expr ${tclStop} - ${tclStart} ]

puts "\nTotal elapsed-time for [file normalize [info script]]: [format "%.2f" [expr $seconds/60.]] minutes\n"


## custom procedure to export all XSim simulation scripts
proc export_xsim_scripts {} {

   file mkdir ${::IPS_DIR}/export_scripts

   ## export XSim simulation scripts for all IPs in the current repo
   export_simulation -force -simulator xsim -directory ${::IPS_DIR}/export_scripts -of_objects [get_ips]
}
