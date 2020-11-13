# Lab 2 Instructions

In this second lab we will introduce basic **VHDL logic operators** to implement fundamental **logic gates**
such as AND, NAND, OR, NOR, XOR and XNOR.

<span>&#8226;</span> As a first step, **open a terminal** and go inside the `lab2/` directory :

```
% cd Desktop/fphd/labs/lab2
```

All simulation scripts and the testbench module can be copied from the `.solutions/` directory :

```
% cp .solutions/run.tcl .
% cp .solutions/tb_Gates.vhd .
```
<br/>


<span>&#8226;</span> With a **text editor** create a new file named `Gates.vhd`, for example :

```
% gedit Gates.vhd &   (for Linux users)
% n++ Gates.vhd       (for Windows users)
```


Try to **complete** the following **code-skeleton** to implement basic gates using **VHDL logic operators** :


```vhdl
--
-- Describe basic logic gates in VHDL using signal assignments and logic operators.
--

library ieee ;
use ieee.std_logic_1164.all ;   -- include extended logic values (by default VHDL only provides 0/1 with the 'bit' data type)


-- entity declaration
entity Gates is

   port (
      A : in  std_logic ;
      B : in  std_logic ;
      Z : out std_logic_vector(5 downto 0)   -- note that Z is declared as a 6-bit width output BUS
   ) ;

end entity Gates ;


-- architecture implementation
architecture rtl of Gates is

begin

   -- AND
   Z(0) <= A and B ;

   -- NAND
   Z(1) <= ... ;

   -- OR
   ...

   -- NOR
   ...

   -- XOR
   ...

   -- XNOR
   ...

end architecture rtl ;
```
<br/>


<span>&#8226;</span> Once ready, try to **parse and compile** the code with the `xvhdl` VHDL compiler :

```
% xvhdl Gates.vhd
```

In case of **syntax errors**, fix the errors issued in the terminal and re-compile the source file
after saving your changes.
<br/><br/>


<span>&#8226;</span> In order to **simulate** the block we also need a **testbench module** to create a test pattern
for our gates.

In this case a simple **2-bits counter** can be used to easily generate
**all possible input combinations** `"00"`, `"01"`, `"10"` and `"11"` for `A` and `B` input ports.
Thus we will also learn how to generate a **clock waveform** and implement a **counter** in VHDL.

The simulation code has been already prepared for you. Explore the content of the `tb_Gates.vhd` VHDL code :


```vhdl
--
-- Example VHDL testbench to simulate basic logic gates.
--


library ieee ;
use ieee.std_logic_1164.all ;       -- include extended logic values (by default VHDL only provides 0/1 with the 'bit' data type)
use ieee.std_logic_unsigned.all ;   -- to use + operator between std_logic_vector data types

library std ;
use std.env.all ;                   -- the VHDL2008 revision provides stop/finish functions similar to Verilog to end the simulation


entity tb_Gates is   -- empty entity declaration for a testbench
end entity tb_Gates ;


architecture testbench of tb_Gates is

   --------------------------------
   --   components declaration   --
   --------------------------------

   component Gates
      port (
         A : in  std_logic ;
         B : in  std_logic ;
         Z : out std_logic_vector(5 downto 0)
      ) ;
   end component ;


   ---------------------------------------------------
   --   testbench parameters and internal signals   --
   ---------------------------------------------------

   -- clock and clock period
   constant PERIOD : time := 10 ns ;
   signal clk : std_logic ;

   -- 2-bit counter initialized to zero
   signal count : std_logic_vector(1 downto 0) := "00" ;

   -- 6-bit bus to probe outputs
   signal Z : std_logic_vector(5 downto 0) ;


begin

   ---------------------------------
   --   100 MHz clock generator   --
   ---------------------------------

   clockGen : process   -- process without sensitivity list
   begin

      clk <= '0' ;
      wait for PERIOD/2 ;   -- simply toggle clk signal every half-period
      clk <= '1' ;
      wait for PERIOD/2 ;

   end process ;


   ----------------------
   --  2-bit counter   --
   ----------------------

   counter : process(clk)
   begin

      if( rising_edge(clk) ) then   -- use the rising_edge(clk) function in place of the verbose clk'event and clk = '1' syntax

         count <= count + '1' ;

      end if ;
   end process ;


   ---------------------------------
   --   device under test (DUT)   --
   ---------------------------------

   DUT : Gates port map (A => count(0), B => count(1), Z => Z) ;


   -----------------------
   --   main stimulus   --
   -----------------------

   stimulus : process
   begin

      wait for 4*PERIOD ;   -- simply run the simulation for 4x clock cycles to explore all possible input combinations

      finish ;   -- stop the simulation (this is a VHDL2008-only feature)

      -- **IMPORTANT: the original VHDL93 standard does not provide a routine to easily stop the simulation ! You must use a failing "assertion" for this purpose
      --assert FALSE report "Simulation Finished" severity FAILURE ;

   end process ;

end architecture testbench ;
```
<br/>


<span>&#8226;</span> Parse and compile also the VHDL testbench :

```
% xvhdl tb_Gates.vhd
```
<br/>


<span>&#8226;</span> After compilation,  **elaborate** the top-level module and **launch the simulation** :

```
% xelab -debug all tb_Gates
% xsim -gui tb_Gates
```
<br/>


<hr>

**REMINDER**

The value to be passed as main argument to `xelab` and `xsim` executables is the **NAME** of the top-level module,
**NOT the corresponding VHDL source file** ! The following command-line syntax are therefore **WRONG** :

```
% xelab -debug all tb_Gates.vhd
% xsim -gui tb_Gates.vhd
```
Do not call `xelab` or `xsim` targeting a `.vhd` file and **always pay attention to TAB completion on files !**

<hr>
<br/>


<span>&#8226;</span> Add all testbench waveforms to the XSim **Wave window** by typing in the **Tcl console** :

```
add_wave /*
```

Finally, **run the simulation** with :

```
run all
```

Debug your simulation results.
<br/>
<br/>


<span>&#8226;</span> All previous **Tcl simulation commands** can be collected into a **Tcl script** e.g. `run.tcl` and loaded from the Tcl console :

```
restart
source run.tcl
```

In order to save time we can profit from the fact that a **Tcl init script** can be specified as additional
argument to the `xsim` executable when invoked :

```
% xsim -gui -tclbatch run.tcl tb_Gates
```

With this syntax **all top-level waveforms** will be automatically added to the XSim Wave window and the simulation will automatically<br/>
run until the `std.env.finish` (or a failing assertion) directive is encountered.
<br/><br/>



<span>&#8226;</span> You can also **customize waveform names and buses radix** in the Wave window. As an example,
**rename top-level signals** `count[0]`, `count[1]`, `Z[0]`, `Z[1]` etc. with more meaningful names such as `A`, `B`, `AND`, `OR` etc.
and **change the default radix** for the `count[1:0]` bus to **binary**.

After signals renaming you can **save your display customizations** into a **waveform configuration XML file** (`.wcfg`).<br/>
To save your customization either use the `save_wave_config` Tcl command

```
save_wave_config tb_Gates.wcfg
```

or navigate through **File > Simulation Waveform > Save Configuration As**.

You can later **restore your custom display settings** with the Tcl command

```
open_wave_config tb_Gates.wcfg
```

or using the `-view` command line switch when invoking the `xsim` executable :

```
% xsim -gui -tclbatch run.tcl -view tb_Gates.wcfg tb_Gates
```

Close the simulator graphical interface when done.


## Run the simulation flow using a GNU Makefile

From now on we will run all Xilinx flows from the command line with a [**GNU Makefile**](https://www.gnu.org/software/make/manual/make.html).

Copy from the `.solutions/` directory the main `Makefile` already prepared for you :

```
% cp .solutions/Makefile .
```

List all available targets and explore the content of the file :

```
% make help
% cat Makefile
```

Run compilation/elaboration/simulation with :


```
% make sim
```

This target is equivalent to :

```
% make compile
% make elaborate
% make simulate
```

To delete all log files and temporary files use :


```
% make clean
```


## Exercise

Instead of using logic operators we can also implement the functionality of each basic gate in terms of its **truth table**.<br/>
A VHDL `when/else` **conditional signal assignment** can be used for this purpose.


Create a new file e.g. `GatesWhenElse.vhd` and try to complete the following **code-skeleton** :


```vhdl
--
-- Implement basic logic gates in terms of truth tables using 'when/else' statements
--


library ieee ;
use ieee.std_logic_1164.all ;   -- include extended logic values (by default VHDL only provides 0/1 with the 'bit' data type)


-- entity declaration
entity Gates is

   port (
      A : in  std_logic ;
      B : in  std_logic ;
      Z : out std_logic_vector(5 downto 0)   -- note that Z is declared as a 6-bit width output BUS
   ) ;

end entity Gates ;


-- architecture implementation
architecture rtl of Gates is

begin

   -- AND
   Z(0) <= '0' when A = '0' and B = '0' else
           '0' when A = '0' and B = '1' else
           '0' when A = '1' and B = '0' else
           '1' when A = '1' and B = '1' else
           'X' ;   -- catch-all

   -- NAND
   ...
   ...


   -- OR
   ...
   ...


   -- NOR
   ...
   ...


   -- XOR
   ...
   ...


   -- XNOR
   ...
   ...

end architecture rtl ;
```

We can simulate this new implementation using the same previous testbench code, just **update the list of sources**<br/>
in your `Makefile` in order to parse and compile `GatesWhenElse.vhd` instead of `Gates.vhd` :


```
#SOURCES := Gates.vhd tb_Gates,vhd
SOURCES := GatesWhenElse.vhd tb_Gates.vhd
```

Save your changes and re-run the simulation with :

```
% make clean
% make sim
```

