
# Lab 1 Instructions

In this first lab we will implement **a simple inverter** using VHDL and simulate the code using the **XSim simulator**<br/>
that comes with Xilinx Vivado.

<span>&#8226;</span> As a first step, **open a terminal** and go inside the `lab1/` directory :

```
% cd Desktop/fphd/labs/lab1
```

Simulation scripts and the testbench module can be copied from the `.solutions/` directory using `cp` :

```
% cp .solutions/run.tcl .
% cp .solutions/cleanup* .
% cp .solutions/tb_Inverter.vhd .
```

<span>&#8226;</span> With a **text editor** program create a new file named `Inverter.vhd`.

Linux users can use the default `gedit` text editor :

```
% gedit Inverter.vhd &
```

Windows users will use Notepad++ instead :

```
% n++ Inverter.vhd
```

<span>&#8226;</span> Write the following **VHDL code** in the newly created source file `Inverter.vhd` :


```vhdl
--
-- A simple inverter (NOT gate) in VHDL
-- 


library ieee ;
use ieee.std_logic_1164.all ;   -- include extended logic values (by default VHDL only provides 0/1 with the 'bit' data type)


entity Inverter is

   port (
      X  : in  std_logic ;
      ZN : out std_logic
   ) ;

end entity Inverter ;


architecture rtl of Inverter is

begin

   -- signal assignment
   ZN <= not X ; 

end architecture rtl ;
```


<span>&#8226;</span> Once ready, try to **parse and compile** the above code using the `xvhdl` VHDL compiler :

```
% xvhdl Inverter.vhd
```

In case of **syntax errors**, fix the errors issued in the terminal and re-compile the source file
after saving your changes.

<span>&#8226;</span> Explore all command-line switches and options for the `xvhdl` compiler :

```
% xvhdl -help
```

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
use std.env.all ;   -- the VHDL2008 revision provides stop/finish functions similar to Verilog to stop simulations


entity tb_Inverter is   -- empty entity declaration for a testbench
end entity ;


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



<span>&#8226;</span> Parse and compile also the testbench code :

```
% xvhdl tb_Inverter.vhd
```

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

<span>&#8226;</span> Explore all command-line switches and options for the `xelab` elaborator :

```
% xelab -help
```

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



To add waveforms in the XSim **Wave Window** type in the **Tcl console** :

```
add_wave /tb_Inverter/*
```

Finally, run the simulation with :

```
run all
```

All these commands can also be collected into a **Tcl script** e.g. `run.tcl` and loaded from the Tcl console.

Type in the XSim console :

```
restart
source run.tcl
``` 

Explore the graphical interface of the XSim simulator. Close the simulator graphical interface when you are happy.
You can also type

```
exit
```

in the XSim Tcl console.

<span>&#8226;</span> Explore all command-line switches and options for the `xsim` simulator :

```
% xsim -help
```



<span>&#8226;</span> The simulation flow automatically creates a lot of garbage files :

```
% ls -la
```

You can cleanup the working area using either

```
% source cleanup.sh   (for Linux users)
```

or

```
% call cleanup.bat    (for Windows users)
```


## Exercise

Edit the continuous assignment in order to **add 3 ns propagation delay** between input and output :

```verilog
ZN <= not X after 3 ns ;
```

Re-compile and re-simulate the code.


## Exercise

Modify the implementation of the inverter functionality. Use a `when/else` **conditional signal assignment**
in place of the predefined `not` logic operator :

```vhdl
-- conditional signal assignment (MUX-style)
ZN <= '1' when X = '0' else '0' ;
```

Re-compile and re-simulate the code.


## Exercise

Write a simple [**GNU Makefile**](https://www.gnu.org/software/make/manual/make.html) to automate
the flow using the `make` utility. With a text editor create a new source file `Makefile` and enter the following source code :

```make

## compile VHDL sources (xvhdl)
compile :
	@xvhdl Inverter.vhd tb_Inverter.vhd


## elaborate the design (xelab)
elaborate :
	@xelab -debug all tb_Inverter


## run the simulation (xsim)
simulate :
	@xsim -gui -tclbatch run.tcl tb_Inverter


## one-step compilation/elaboration/simulation
sim : compile elaborate simulate


## delete all log files and simulation outputs
clean :
	@rm -rf -v rm -rf *.log *.jou *pb *.wdb xsim.dir .Xil
```

Save and exit. Try to run the flow with :

```
% make sim
```

<hr>

**IMPORTANT**

Remind to use **TAB characters** to indent statements within a target implementation !

```
compile :

<TAB>  @xvhdl Inverter.vhd tb_Inverter.vhd

```
<hr>


## Further readings

If you are interested in more in-depth details about the overall simulation flow in Xilinx XSim, please
ref. to the following **Xilinx official documentation** :

* [*Vivado Design Suite User Guide: Logic Simulation*](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2019_2/ug900-vivado-logic-simulation.pdf)

* [*Vivado Design Suite Tutorial: Logic Simulation*](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2019_2/ug937-vivado-design-suite-simulation-tutorial.pdf)



