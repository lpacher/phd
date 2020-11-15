
# Lab 1 Instructions

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
   
   DUT : Inverter port map (X => X, ZN => ZN) ;


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


