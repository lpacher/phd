
# Lab 3 Instructions

[[**Home**](https://github.com/lpacher/fphd)] [[**Back**](https://github.com/lpacher/fphd/tree/master/labs)]

In this lab we introduce a certain number of **new VHDL constructs** and we discuss different **coding styles** in HDL.<br/>
The digital block used for this purpose is a simple **2-inputs multiplexer**.

We also introduce a **better working area organization** and an **improved simulation flow**
that allows to **re-invoke compilation/elaboration/simulation teps** from the XSim GUI in non-project mode.

<br/>

<span>&#8226;</span>  As a first step, **open a terminal** and go inside the `lab3/` directory :

```
% cd Desktop/fphd/labs/lab3
```
<br/>

<span>&#8226;</span> Copy from the `.solutions/` directory the main `Makefile` already prepared for you :

```
% cp .solutions/Makefile .
```

Explore available targets :

```
% make help
```

Finally, **create a new fresh working area** :

```
% make area
```

List the content of the directory to understand the new sources organization :

```
% ls -l
```

|     Folder     |                           Description                                |
|----------------|----------------------------------------------------------------------|
| `rtl/`         | RTL sources (synthesizable code that can be mapped on a target FPGA) |
| `bench/`       | simulation sources (non-synthesizable code) |
| `scripts/sim/` | Tcl scripts for compilation/elaboration/simulation |
| `work/sim/`    | scratch working area where `xvhdl/xelab/xsim` executables are invoked |
| `bin/`         | additional directory for non-Tcl scripts and programs (e.g. Python) |
| `log/`         | all log files |
| `cores/`       | IP sources (compiled from the IP Catalog within Vivado) |
| `test/`        | directory for additional user tests |
| `tmp/`         | temporary directory |
| `doc/`         | specifications, design documentation, PDF etc. |

<br/>

>
> **NOTE**
>
> The proposed working area has been re-adapted from the
> [**directory structure recommended by OpenCores**](https://cdn.opencores.org/downloads/opencores_coding_guidelines.pdf).
>

<br/>


<span>&#8226;</span> Copy from the `.solutions/` directory all **Tcl simulation scripts**


```
% cp .solutions/scripts/sim/compile.tcl    ./scripts/sim/
% cp .solutions/scripts/sim/elaborate.tcl  ./scripts/sim/
% cp .solutions/scripts/sim/simulate.tcl   ./scripts/sim/
% cp .solutions/scripts/sim/run.tcl        ./scripts/sim/
```

and also **VHDL testbench sources** already prepared for you :

```
% cp .solutions/bench/ClockGen.vhd  ./bench
% cp .solutions/bench/tb_MUX2.vhd   ./bench
```
<br/>


<span>&#8226;</span> Create a new VHDL file `rtl/MUX2.vhd` :

```
% gedit rtl/MUX2.vhd &   (for Linux users)
% n++ rtl\MUX2.vhd       (for Windows users)
```
<br/>


<span>&#8226;</span>  Write the following code skeleton :

```vhdl
library ieee ;
use ieee.std_logic_1164.all ;   -- include extended logic values (by default VHDL only provides 0/1 with the 'bit' data type)


entity MUX2 is

   port (
      A : in  std_logic ;
      B : in  std_logic ;
      S : in  std_logic ;   -- select bit
      Z : out std_logic
   ) ;

end entity MUX2 ;


architecture archName of MUX2 is

begin


end architecture archName ;
```

In this case we will write **different architectures**, one for each proposed implementation.
The actual architecture to be simulated is then selected using a **component configuration (binding)**
statement in the testbench.


<br/>

<span>&#8226;</span> A first possible implementation for the multiplexer is using a **behavioural description** with a
**software-like** `if/else` **conditional assignment** inside a `process` **sequential block** :


```vhdl
architecture if_else of MUX2 is

begin

   --------------------------------
   --   behavioral description   --
   --------------------------------

   process(A,B,S)   -- **IMPORTANT: this is a COMBINATIONAL block, all signals contribute to the SENSITIVITY LIST
   begin

      if(S = '0') then
         Z <= A ;
      else
         Z <= B ;
      end if ;

   end process ;

end architecture if_else ;
```
<br/>


<span>&#8226;</span> Another possibility is to use a more compact `when/else` **conditional assignment** :


```vhdl
architecture when_else of MUX2 is

begin

   ------------------------------------------
   --   when/else conditional assignment   --
   ------------------------------------------

   Z <= A when S = '0' else
        B when S = '1' else
        'X' ;   -- catch-all

end architecture when_else ;
```
<br/>


<span>&#8226;</span> Alternatively we can use a `with/select` **conditional assignment**, which is similar to the previous `when/else` construct
and does not require a `process` :


```vhdl
architecture with_select of MUX2 is

begin

   --------------------------------------------
   --   with/select conditional assignment   --
   --------------------------------------------

   with S select

      Z <= A when '0',
           B when '1',
           'X' when others ;   -- catch-all

end architecture with_select ;
```
<br/>


<span>&#8226;</span> We can also use a `case` statement within a `process` block and write the **truth table** of the combinational block :

```vhdl
architecture truth_table of MUX2 is

   signal SAB : std_logic_vector(2 downto 0) ;


begin

   SAB <= S & A & B ;   -- concatenation


   --------------------------------------
   --   truth table (case statement)   --
   --------------------------------------

   process(A,B,S)
   begin

      case( SAB ) is

         when "000" => Z <= '0' ;   -- A
         when "001" => Z <= '0' ;   -- A
         when "010" => Z <= '1' ;   -- A
         when "011" => Z <= '1' ;   -- A
         when "100" => Z <= '0' ;   -- B
         when "101" => Z <= '1' ;   -- B
         when "110" => Z <= '0' ;   -- B
         when "111" => Z <= '1' ;   -- B

         -- catch-all
         when others => Z <= 'X' ;

      end case ;
   end process ;

end architecture truth_table ;
```
<br/>


<span>&#8226;</span> A further possibility is to explicitly write the **logic equation** as it can be derived from the **truth table** :

```vhdl
architecture logic_equation of MUX2 is

begin

   ------------------------
   --   logic equation   --
   ------------------------

   Z <= (A and (not S)) or (B and S) ;

end architecture logic_equation ;
```
<br/>


<span>&#8226;</span>  Try to **simulate all possible different implementations** and **verify the expected functionality**
of a 2:1 multiplexer. Use the `Makefile` to automate the simulation flow :

```
% make clean sim
```

In order to **switch between architectures** you have to **modify the testbench** `bench/tb_MUX2.vhd`
each time and update the **component configuration**  in the architecture body that selects the MUX2 architecture
to be used for the simulation :


```vhdl
-- choose here which MUX2 architecture to simulate
for DUT : MUX2
   use entity work.MUX2(if_else) ;
   --use entity work.MUX2(when_else) ;
   --use entity work.MUX2(with_select) ;
   --use entity work.MUX2(truth_table) ;
   --use entity work.MUX2(logic_equation) ;
```

Thanks to the improved flow you do not need to close the XSim GUI and re-invoke the compilation/elaboration process each time,
simply save your changes to the testbench and type

```
relauch
```

in the XSim Tcl console to re-launch the simulation.


## Additional notes

Vivado extensively supports scripts-based FPGA implementation flows either in so called **project** or **non-project modes**. 
Indeed, there is no "non-project mode" Tcl simulation flow in Vivado, the "non-project mode" flow
requires to call standalone `xvlog/xvhdl`, `xelab` and `xsim` executables from the command-line, from a shell script
or inside a GNU Makefile.

However in "non-project mode" the simulation **cannot be re-invoked** from the XSim GUI using
**Run > Relaunch Simulation** (or using the `relaunch_sim` command)
after RTL or testbench changes, thus requiring to exit from XSim and re-build the simulation
from scratch. This happens because the XSim standalone flow doesn't keep track of `xvlog/xvhdl`
and `xelab` flows.

In order to be able to **"relaunch" a simulation from the GUI** you necessarily have to
**create a project in Vivado**, either in GUI mode or using a "project mode" Tcl script
to automate the simulation.

As an example :

```
## create Vivado project attached to Arty-A7 device
create_project project_1 project_1 -part xc7a35ticsg324-1L

## target HDL
set_property simulator_language VHDL [current_project]

## add RTL sources to the propject
add_files -norecurse -fileset sources_1 [glob [pwd]/rtl/*.vhd]

## add simulation sources to the project
add_files -fileset sim_1 -norecurse [glob [pwd]/bench/*.vhd]

## import all files
import_files -force -norecurse
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

## one-step compilation/elaboration/simulation
launch_simulation
```

The overhead of creating an in-memory project is low compared to the benefits of fully automated
one-step compilation/elaboration/simulation and re-launch features.

An alternative solution is to use `tclsh`. In this lab in fact we improved the simulation flow
moving all calls to standalone executables `xvlog/xvhdl`, `xelab` and `xsim`
into Tcl scripts executed by `tclsh`. This **custom** Tcl-based simulation flow basically reproduces
all compilation/elaboration/simulation steps that actually Vivado performs "under the hood" for you without notice
in project-mode.

Most important, this custom flow is **portable across Linux/Windows systems** and allows
to "relaunch" a simulation after RTL or testbench changes from the XSim Tcl console using
the custom routine

```
relaunch
```

without the need of creating a project.

Finally, using the Tcl command `exec` to invoke `xsim` allows to **fork the process in background** with `&`
also on Windows, thus leaving the terminal available for typing new commands.

Credits :

<https://www.edn.com/improve-fpga-project-management-test-by-eschewing-the-ide>


## Exercise

The clock-generator has a parameterized clock period using a `generic` specification. Modify the default clock
period of 10 ns and re-simulate the code without closing the XSim graphical interface :

```vhdl
ClockGen_inst : ClockGen
   generic map(PERIOD => 100 ns) ;
   port map(clk => clk) ;
```

```
relaunch
```



## Exercise

Create a new source file `rtl/MUX4.vhd`. Start from the code of a 2-inputs multiplexer and
try to implement a **4-inputs multiplexer** instead :


```vhdl
library ieee ;
use ieee.std_logic_1164.all ;


entity MUX4 is

   port(
      D : in  std_logic_vector(3 downto 0) ;
      S : in  std_logic ;
      Z : out std_logic
   ) ;

end entity MUX4 ;


architecture rtl of MUX4 is

begin

   ...
   ...

end architecture rtl ;
```

Write a suitable VHDL testbench `bench/tb_MUX4.vhd` in order to verify the proper functionality of the new block.

