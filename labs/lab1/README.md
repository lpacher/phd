
# Lab 1 Instructions
[[**Home**](https://github.com/lpacher/fphd)] [[**Back**](https://github.com/lpacher/fphd/tree/master/labs)]

In this first lab we will implement **a simple inverter** using VHDL and simulate the code using the **XSim simulator**<br/>
that comes with Xilinx Vivado.<br/>

We will also learn how to write a [**GNU Makefile**](https://www.gnu.org/software/make/manual/make.html)
to **automate the simulation flow**.
<br/>

<span>&#8226;</span> As a first step, **open a terminal** and go inside the `lab1/` directory :

```
% cd Desktop/fphd/labs/lab1
```

Simulation scripts and the testbench module can be copied from the `.solutions/` directory :

```
% cp .solutions/run.tcl .
% cp .solutions/cleanup* .
% cp .solutions/tb_Inverter.vhd .
```
<br/>


<span>&#8226;</span> With a **text editor** program create a new file named `Inverter.vhd`.

Linux users can use the default `gedit` text editor :

```
% gedit Inverter.vhd &
```

Windows users will use [**Notepad++ from the command line**](/labs/lab0/README.md#add-notepad-executable-to-search-path)
instead :

```
% n++ Inverter.vhd
```
<br/>


<span>&#8226;</span> Write the following **VHDL code** in the newly created source file `Inverter.vhd` :


```vhdl
--
-- A simple inverter (NOT gate) in VHDL
-- 


library ieee ;
use ieee.std_logic_1164.all ;   -- include extended logic values (by default VHDL only provides 0/1 with the 'bit' data type)


-- entity declaration
entity Inverter is

   port (
      X  : in  std_logic ;
      ZN : out std_logic
   ) ;

end entity Inverter ;


-- architecture implementation
architecture rtl of Inverter is

begin

   -- signal assignment
   ZN <= not X ; 

end architecture rtl ;
```
<br/>


<span>&#8226;</span> Once ready, try to **parse and compile** the above code using the `xvhdl` VHDL compiler :

```
% xvhdl Inverter.vhd
```

In case of **syntax errors**, fix the errors issued in the terminal and re-compile the source file
after saving your changes.
<br/>
<br/>


<span>&#8226;</span> Explore all command-line switches and options for the `xvhdl` compiler :

```
% xvhdl -help

Usage: xvhdl [options] file...
(Switches with double dash '--' can also be used with a single dash '-')

Vivado Simulator xvhdl options:
  -f [ --file ] arg     Read additional options from the specified file
  -h [ --help ]         Print this help message
  --version             Print the compiler version
  --initfile arg        Use user defined simulator init file to add to or 
                        override the settings provided by the default xsim.ini 
                        file
  -L [ --lib ] arg      Specify search libraries for the instantiated design 
                        units in a Verilog or Mixed language design. Use 
                        -L|--lib for each search library. The format of the 
                        argument is <name>[=<dir>] where <name> is the logical 
                        name of the library and <dir> is an optional physical 
                        directory of the library
  --nolog               Suppress log file generation
  --log arg             Specify the log file name. Default is <application 
                        name>.log
  --prj arg             Specify Vivado Simulator  project file containing one 
                        or more entries of 'vhdl|verilog <work lib> <HDL file 
                        name>'
  --relax               Relax strict HDL language checking rules
  -v [ --verbose ] arg  Specify verbosity level for printing messages. Allowed 
                        values are: 0, 1, 2 (Default:0)
  --incr                Enable incremental parsing and compilation check point
  --nosignalhandlers    Run with no XSim specific signal handlers. Necessary 
                        when 3rd party software such as antivirus, firewall is 
                        generating signals as part of its normal usage, causing
                        XSim Compiler and Kernel executables to trap these 
                        signals and report a crash.
  --93_mode             Force usage of VHDL-93 mode for STD and IEEE libraries.
                        Default is mixed 93 and 2008. If used, should be used 
                        for all VHDL files for the specific project
  --work arg            Specify the work library. The format of the argument is
                        <name>[=<dir>] where <name> is the logical name of the 
                        library and <dir> is an optional physical directory of 
                        the library
  --encryptdumps        Encrypt parse dump of design units
  --2008                Specify input files to be VHDL-2008 files

Examples:
  xvhdl file1.vhd file2.vhd
  xvhdl -work worklib file1.vhd file2.vhd
  xvhdl -prj files.prj
```
<br/>


<span>&#8226;</span> In order to **simulate** the block we also need a **testbench module** to create a
**test pattern** for our **Device Under Test (DUT)**.

The VHDL code for the `tb_Inverter.vhd` testbench code is the following :


```vhdl
--
-- Simple testbench for the Inverter module
--

library ieee ;
use ieee.std_logic_1164.all ;   -- include extended logic values (by default VHDL only provides 0/1 with the 'bit' data type)

library std ;
use std.env.all ;   -- the VHDL2008 revision provides stop/finish functions similar to Verilog to end the simulation


entity tb_Inverter is   -- empty entity declaration for a testbench
end entity tb_Inverter ;


architecture testbench of tb_Inverter is

   --------------------------------
   --   components declaration   --
   --------------------------------

   component Inverter
      port (
         X  : in  std_logic ;
         ZN : out std_logic
      ) ;
   end component ;


   --------------------------
   --   internal signals   --
   --------------------------

   signal X  : std_logic ;
   signal ZN : std_logic ;


begin


   ---------------------------------
   --   device under test (DUT)   --
   ---------------------------------
   
   --DUT : Inverter port map (X, ZN) ;            -- ORDERED (positional) port mapping
   DUT : Inverter port map (X => X, ZN => ZN) ;   -- BY-NAME port mapping


   -----------------------
   --   main stimulus   --
   -----------------------

   stimulus : process
   begin
   
      wait for 500 ns ; X <= '0' ;
      wait for 200 ns ; X <= '1' ;
      wait for 750 ns ; X <= '0' ;

      wait for 500 ns ; finish ;     -- stop the simulation (this is a VHDL2008-only feature)

      -- **IMPORTANT: the original VHDL93 standard does not provide a routine to easily stop the simulation ! You must use a failing "assertion" for this purpose
      --wait for 500 ns ; assert FALSE report "Simulation Finished" severity FAILURE ; 

   end process ;

end architecture testbench ;
```
<br/>



<span>&#8226;</span> Parse and compile also the testbench code :

```
% xvhdl tb_Inverter.vhd
```
<br/>


<span>&#8226;</span> Before **simulating the testbench** we have at first to **merge toghether** the compiled code
of our inverter with the compiled code of the testbench.
This process is called **elaboration** and in the Xilinx XSim simulation flow this is performed
by the `xelab` executable.

Elaboration is always done specifying the **NAME of the top-level module** of the simulation project, which is 
the name of the **testbench module** :

```
% xelab -debug all tb_Inverter
```

The `-debug all` option is **REQUIRED** to make all signals **accessible** from the simulator
graphical interface in form of **digital waveforms**. If you elaborate compiled sources without this option
**you will NOT BE ABLE to probe signals** in the XSim graphical interface !
<br/>
<br/>


<span>&#8226;</span> Explore all command-line switches and options for the `xelab` elaborator :

```
% xelab -help

Usage: xelab [options] [libname.]unitname...
(Switches with double dash '--' can also be used with a single dash '-')

Vivado Simulator xelab options:
******************************:
  -a [ --standalone ]              Generates a standalone non-interactive 
                                   simulation executable that performs run-all.
  -d [ --define ] arg              Define Verilog macros. Use -d|--define for 
                                   each Verilog macro. The format of the macro 
                                   is <name>[=<val>] where <name> is name of 
                                   the macro and <value> is an optional value 
                                   of the macro
  --debug arg                      Compile with specified HDL debugging ability
                                   turned on. Choices are:
                                     line: HDL breakpoint
                                     wave: waveform generation, conditional 
                                           execution, force value
                                     drivers: signal driver value probing
                                     readers: signal reader (load) probing
                                     xlibs: visibility into libraries 
                                            precompiled by xilinx
                                     all: all the above
                                     typical: line, wave and drivers
                                     subprogram: subprogram variable value 
                                                 probing
                                     off: turn off all debugging abilities
                                   (Default: off)
  -f [ --file ] arg                Read additional options from the specified 
                                   file
  -h [ --help ]                    Print this help message
  --incr                           Enable incremental parsing and compilation 
                                   check point
  -i [ --include ] arg             Specify directories to be searched for files
                                   included using Verilog `include. Use 
                                   -i|--include for each specified search 
                                   directory
  --initfile arg                   Use user defined simulator init file to add 
                                   to or override the settings provided by the 
                                   default xsim.ini file
  --log arg                        Specify the log file name. Default is 
                                   <application name>.log
  -L [ --lib ] arg                 Specify search libraries for the 
                                   instantiated design units in a Verilog or 
                                   Mixed language design. Use -L|--lib for each
                                   search library. The format of the argument 
                                   is <name>[=<dir>] where <name> is the 
                                   logical name of the library and <dir> is an 
                                   optional physical directory of the library
  --nolog                          Suppress log file generation
  --override_timeunit              Override timeunit for all Verilog modules, 
                                   with the specified time unit in -timescale 
                                   option
  --prj arg                        Specify Vivado Simulator  project file 
                                   containing one or more entries of 
                                   'vhdl|verilog <work lib> <HDL file name>'
  -r [ --run ]                     Run the generated executable
  --relax                          Relax strict HDL language checking rules
  -R [ --runall ]                  Run the generated executable till end of 
                                   simulation (xsim -runall)
  -s [ --snapshot ] arg            Specify the name of design snapshot
  --timescale arg                  Specify default timescale for Verilog 
                                   modules( Default: 1ns/1ps )
  --version                        Print the compiler version
  -v [ --verbose ] arg             Specify verbosity level for printing 
                                   messages. Allowed values are: 0, 1, 2 
                                   (Default:0)
  --uvm_version arg                Specify the uvm version(default: 1.2)

 Advance options:
 ***************:
  --93_mode                        Force usage of VHDL-93 mode for STD and IEEE
                                   libraries. Default is mixed 93 and 2008. If 
                                   used, should be used for all VHDL files for 
                                   the specific project
  --driver_display_limit arg       Set the maximum number of elements a signal 
                                   may contain for driver information to be 
                                   recorded for the signal (Default: arg = 
                                   65536 elements)
  --generic_top arg                Override generic or parameter of a top level
                                   design unit with specified value( Example: 
                                   -generic_top "P1=10" 
  --ignore_assertions              Ignore System Verilog Concurrent Assertions
  --report_assertion_pass          Report System Verilog Concurrent Assertions 
                                   Pass, even if there is no pass action block
  --ignore_coverage                Ignore System Verilog Functional Coverage
  --maxarraysize arg               Set the maximum VHDL array size, beyond 
                                   which an array declaration will generate an 
                                   error, to be 2**arg elements (Default: arg =
                                   28, which is 2**28 elements)
  --mt arg (=auto)                 Specifies the number of sub-compilation jobs
                                   which can be run in parallel. Choices are:
                                     auto: automatic
                                     n: where n is an integer greater than 1
                                     off: turn off multi-threading
                                   (Default:auto)
  --maxdesigndepth arg             Override maximum design hierarchy depth 
                                   allowed by the elaborator (Default: 5000)
  --noname_unnamed_generate        Generate name for an unnamed generate block
  --nosignalhandlers               Run with no XSim specific signal handlers. 
                                   Necessary when 3rd party software such as 
                                   antivirus, firewall is generating signals as
                                   part of its normal usage, causing XSim 
                                   Compiler and Kernel executables to trap 
                                   these signals and report a crash.
  --override_timeprecision         Override time precision for all Verilog 
                                   modules, with the specified time precision 
                                   in -timescale option
  --rangecheck                     Enable runtime value range check for VHDL
  --sourcelibdir arg               Directory for Verilog source files of 
                                   uncompiled modules. Use 
                                   -sourcelibdir|--sourcelibdir <dirname> for 
                                   each source directory.
  --sourcelibext arg               File extension for Verilog source files of 
                                   uncompiled modules. Use 
                                   -sourcelibext|--sourcelibext <file 
                                   extension> for source file extension.
  --sourcelibfile arg              Filename of a Verilog source file which has 
                                   uncompiled modules. Use 
                                   -sourcelibfile|--sourcelibfile <filename>.
  --stats                          Print tool CPU and memory usages, and design
                                   statistics
  --timeprecision_vhdl arg (=1ps)  Specify time precision for vhdl designs( 
                                   Default: 1ps)
  --transform_timing_checkers      Transform timing checkers to Verilog 
                                   processes

 timing simulation:
 *****************:
  --maxdelay                       Compile Verilog design units with maximum 
                                   delays
  --mindelay                       Compile Verilog design units with minimum 
                                   delays
  --nosdfinterconnectdelays        Ignore SDF port and interconnect delay 
                                   constructs in SDF
  --nospecify                      Ignore Verilog path delays and timing checks
  --notimingchecks                 Ignore timing check constructs in Verilog 
                                   specify block(s)
  --pulse_int_e arg                Interconnect pulse error limit as percentage
                                   of  delay. Allowed values are 0 to 100 
                                   (Default: 100)
  --pulse_int_r arg                Interconnect pulse reject limit as 
                                   percentage of  delay. Allowed values are 0 
                                   to 100 (Default: 100)
  --pulse_e arg                    Path pulse error limit as percentage of path
                                   delay. Allowed values are 0 to 100 (Default:
                                   100)
  --pulse_r arg                    Path pulse reject limit as percentage of 
                                   path delay. Allowed values are 0 to 100 
                                   (Default: 100)
  --pulse_e_style arg (=onevent)   Specify when error about pulse being shorter
                                   than module path delay should be handled. 
                                   Choices are:
                                     ondetect: report error right when 
                                               violation is detected
                                     onevent:  report error after the module 
                                               path delay
                                   (Default: onevent)
  --sdfmax arg                     <root=file> Sdf annotate <file> at <root> 
                                   with maximum delay
  --sdfmin arg                     <root=file> Sdf annotate <file> at <root> 
                                   with minimum delay
  --sdfnoerror                     Treat errors found in sdf file as warning
  --sdfnowarn                      Do not emit sdf warnings
  --sdfroot arg                    <root_path> Default design hierarchy at 
                                   which sdf annotation is applied
  --sdftyp arg                     <root=file> Sdf annotate <file> at <root> 
                                   with typical delay
  --transport_int_delays           Use transport model for interconnect delays
  --typdelay                       Compile Verilog design units with typical 
                                   delays (Default)

 Optimization:
 ************:
  --O0                             Disable all optimizations
  --O1                             Enable basic optimizations
  --O2                             Enable most commonly desired optimizations 
                                   (Default)
  --O3                             Enable advance optimizations

 Mixed Language:
 ************:
  --dup_entity_as_module           Enable support for hierarchical references 
                                   inside the Verilog hierarchy in mixed 
                                   language designs. Warning: this may cause 
                                   significant slow down of compilation

 SystemC/DPI options:
 *******************:
  --dpi_absolute                   Use absolute paths instead of 
                                   LD_LIBRARY_PATH on Linux for DPI libraries 
                                   that are formatted as lib<libname>.so
  --dpiheader arg                  Header filename for the exported and 
                                   imported functions.
  --dpi_stacksize arg              User-defined stack size for DPI tasks
  --sc_lib arg                     Shared library name for SystemC functions; 
                                   (.dll/.so) without the file extension 
  --sv_lib arg                     Shared library name for DPI imported 
                                   functions; (.dll/.so) without the file 
                                   extension 
  --sv_liblist arg                 Bootstrap file pointing to DPI shared 
                                   libraries.
  --sc_root arg                    Root directory off which SystemC libraries 
                                   are to be found. Default: 
                                   <current_directory>/xsim.dir/work/xsc
  --sv_root arg                    Root directory off which DPI libraries are 
                                   to be found. Default: <current_directory>/xs
                                   im.dir/work/xsc

 Coverage options:
 *******************:
  --cov_db_dir arg                 Functional Coverage database dump directory.
                                   The coverage data will be present under 
                                   <arg>/xsim.covdb/<cov_db_name> directory. 
                                   Default is ./
  --cov_db_name arg                Functional Coverage database name. The 
                                   coverage data will be present under 
                                   <cov_db_dir>/xsim.covdb/<arg> directory. 
                                   Default is snapshot name.

Examples:
  xelab top1 top2
  xelab lib1.top1 lib2.top2
  xelab top1 top2 -prj files.prj
  xelab lib1.top1 lib2.top2 -prj files.prj
```
<br/>


<span>&#8226;</span> After elaboration a **simulation executable** is created and can be run using the `xsim
simulator as follows :

```
% xsim -gui tb_Inverter
```

<hr>

**WARNING**

The value to be passed as main argument to `xelab` and `xsim` executables is the **NAME** of the top-level module,
**NOT the corresponding VHDL source file** ! The following command-line syntax are therefore **WRONG** :

```
% xelab -debug all tb_Inverter.vhd
% xsim -gui tb_Inverter.vhd
```

Do not call `xelab` or `xsim` targeting a `.vhd` file and **always pay attention to TAB completion on files** !
<hr>


Before running the simulation, **probe all top-level signals** in the XSim **Wave window** using the `add_wave` command<br/>
in the **Tcl console** as follows :


```
add_wave /*
```

Finally, **run the simulation** with the Tcl command

```
run all
```

or navigate through **Run > Run All**. You can also **reset the simulation at time 0** using

```
restart
```

or through **Run > Restart**.

<br/>
<br/>

<span>&#8226;</span> Simulation commands can be collected into a **Tcl script** e.g. `run.tcl` and loaded from the Tcl console. Type in the XSim console :

```
restart
source run.tcl
``` 

Explore the graphical interface of the XSim simulator. Close the simulator graphical interface when you are happy.<br/>
You can also type

```
exit
```

in the XSim Tcl console.
<br/>
<br/>


<span>&#8226;</span> Explore all command-line switches and options for the `xsim` simulator :

```
% xsim -help

XSim simulation executable
Usage: /path/to/xsim [options]
(Switches with double dash '--' can also be used with a single dash '-')
    --R                  : Run simulation till end i.e. do 'run all;quit'
    --f                  : Take command line options from a file
    --file               : Take command line options from a file
    --g                  : Run with interactive GUI
    --gui                : Run with interactive GUI
    --h                  : Print help message and exit
    --help               : Print help message and exit
    --ieeewarnings       : Enable warnings from VHDL IEEE functions
    --log                : Specify the log file name
    --maxdeltaid         : Specify the maximum delta number. Will report error if it exceeds maximum simulation loops at the same time
    --maxlogsize         : Set the maximum size a log file can reach in MB. The default setting is unlimited
    --nolog              : Suppress log file generation
    --nosignalhandlers   : Run with no signal handlers to avoid conflict with security software.
    --onerror            : Specify behavior upon simulation run-time error: quit|stop
    --onfinish           : Specify behavior at end of simulation: quit|stop
    --protoinst          : Specify a .protoinst file for protocol analysis
    --runall             : Run simulation till end i.e. do 'run all;quit'
    --scNoLogFile        : Keep the SystemC output separate from XSim output
    --stats              : Display memory and cpu stats upon exiting
    --sv_seed            : seed for sv constraint random
    --t                  : Specify the TCL file for batch mode execution
    --tclbatch           : Specify the TCL file for batch mode execution
    --testplusarg        : Specify plus args to be used by $test$plusargs and $value$plusargs system functions
    --tl                 : Enable printing of file name and line number of statements being executed.
    --tp                 : Enable printing of hierarchical names of process being executed.
    --version            : Print the simulator version and quit.
    --view               : Open a wave configuration file. This switch should be used together with -gui switch
    --wdb                : Specify the waveform database output file.
```
<br/>



<span>&#8226;</span> The simulation flow automatically created a lot of **garbage files** :

```
% ls -la
```

It is always a good practice to have some **shell script** to
easily **cleanup the working area**.

You can delete all log files, temporary files etc. using :


```
% source cleanup.sh   (for Linux users)
% call cleanup.bat    (for Windows users)
```

We will later use a `Makefile` target for this purpose.
<br/>


## Exercise

Edit the continuous assignment in order to **add 3 ns propagation delay** between input and output :

```verilog
ZN <= not X after 3 ns ;
```

Re-compile and re-simulate the code.


## Exercise

Modify the implementation of the inverter functionality. Use a VHDL `when/else` **conditional signal assignment**
in place of the predefined `not` logic operator :

```vhdl
-- conditional signal assignment (MUX-style)
ZN <= '1' when X = '0' else '0' ;
```

Re-compile and re-simulate the code.

<br/>

>
> **QUESTION**
>
> Is the above `when/else` VHDL inverter implementation completely exhaustive ? Are we missing the definition
> of the output logic value for any "special" input values ?
>


## Exercise

Up to now we learned how to **compile**, **elaborate** and **run a simulation** in Xilinx XSim
by invoking `xvlog`, `xelab` and `xsim` **standalone executables** at the command-line each time.

A more efficient solution is to **automate the simulation flow** by collecting these commands inside
a [**GNU Makefile**](https://www.gnu.org/software/make/manual/make.html) parsed by the `make` utility.

As a first step, create a new text file named `Makefile` (without extension) :

```
% gedit Makefile &   (for Linux users)
% n++ Makefile       (for Windows users)
```

Then enter the following source code :


```make
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
```

Save and exit. Try to run the flow with :

```
% make sim
```

<hr>

**IMPORTANT**

According to `Makefile` syntax, instructions inside each target **MUST BE IDENTED USING A TAB CHARACTER !**

```
target :

<TAB> @write here some cool stuff to be executed
```

**DO NOT USE SPACES TO IDENT TARGET DIRECTIVES !**
<hr>


## Extra: comparison with Verilog code

Compare the VHDL syntax with its Verilog equivalent :

```verilog
//
// A simple inverter (NOT-gate) in Verilog
//

`timescale 1ns / 1ps   // specify time-unit and time-precision, this is only for simulation purposes

module Inverter (

   input  wire X,
   output wire ZN ) ;   // this is reduntant, by default I/O ports are always considered WIRES unless otherwise specified


   // continuous assignment
   assign ZN = !X ;                // **NOTE: you can also use ~X

endmodule
```


Interested students can also try to simulate a **mixed-languge** design by compiling Verilog using the `xvlog` compiler instead :

```
% cp .solutions/Inverter.v
% xvlog Inverter.v
% xvhdl tb_Inverter.vhd
% xelab -debug all tb_Inverter
% xsim -gui tb_Inverter
```

## Further readings

If you are interested in more in-depth details about the overall simulation flow in Xilinx XSim, please
ref. to the following **Xilinx official documentation** :

* [*Vivado Design Suite User Guide: Logic Simulation*](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2019_2/ug900-vivado-logic-simulation.pdf)
* [*Vivado Design Suite Tutorial: Logic Simulation*](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2019_2/ug937-vivado-design-suite-simulation-tutorial.pdf)


