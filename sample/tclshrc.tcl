#
# Example tclsh init script for MS Windows operating systems.
#
# If present, by default tclsh automatically sources :
#
#    - $HOME/.tclshrc              UNIX/Linux
#    - %USERPROFILE%\tclshrc.tcl   MS Windows
#
# Put this file in your main %USERPROFILE% directory and use it
# to customize the tclsh runtime environment.
#

## Tcl version and loading notification
puts "Tcl version $tcl_version"
puts "\nLoading [info script]\n"

## change default prompt
set tcl_prompt1  {puts -nonewline "tclsh$ "}


## add here additional customizations

