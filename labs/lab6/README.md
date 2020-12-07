# Lab 6 Instructions
[[**Home**](https://github.com/lpacher/fphd)] [[**Back**](https://github.com/lpacher/fphd/tree/master/labs)]


In this lab we implement and simulate an **8-bit Pseudo-Random Bit Sequence (PRBS) generator** in VHDL using a **Linear-Feedback**<br/>
**Shift-Register (LFSR)**.

<br/>

<span>&#8226;</span>  As a first step, **open a terminal** and move inside the `lab6/` directory :

```
% cd Desktop/fphd/labs/lab6
```
<br/>

<span>&#8226;</span> Copy from the `.solutions/` directory the main `Makefile` already prepared for you :

```
% cp .solutions/Makefile .
```
<br/>

<span>&#8226;</span> Create a new **fresh working area** :

```
% make area
% ls -l
```
<br/>


<span>&#8226;</span> Copy from the `.solutions/` directory all **simulation and implementation Tcl scripts** as follows :

```
% cp .solutions/scripts/common/*.tcl  scripts/common/
% cp .solutions/scripts/sim/*.tcl     scripts/sim/
% cp .solutions/scripts/impl/*.tcl    scripts/impl/
```
<br/>

>
> **WARNING**
>
> If you want to use the asterisk `*` as **wildcar** for `cp` on Windows, please be aware that the `cp.exe` executable<br/>
> that comes with GNU Win works properly **only using forward slashes in the path !**
>
> If you use the TAB completion on Windows the following commands **will not work** :
>
> ```
> % cp .solutions\scripts\common\*.tcl  scripts\common\
> % cp .solutions\scripts\sim\*.tcl     scripts\sim\
> % cp .solutions\scripts\impl\*.tcl    scripts\impl\
> ```
>
> You can use the native `copy` DOS command instead :
>
> ```
> % copy .solutions\scripts\common\*.tcl  scripts\common\
> % copy .solutions\scripts\sim\*.tcl     scripts\sim\
> % copy .solutions\scripts\impl\*.tcl    scripts\impl\
> ```
>
<br/>

<span>&#8226;</span> Create a new directory `cores/PLL` in which we will **compile a PLL** from
the **Vivado IP Catalog** (_Clock Wizard_) :

```
% mkdir cores/PLL
``` 

Additionally, copy from the `.solutions/` directory the main **Xilinx Core Instance (XCI) file** already prepared for you and<br/>
containing the PLL configuration :

```
% cp .solutions/cores/PLL/PLL.xci cores/PLL
```
<br/>


<span>&#8226;</span> **Compile the PLL core** from the provided `.xci` configuration file :

```
% make ip xci=cores/PLL/PLL.xci mode=batch
```
<br/>

<span>&#8226;</span> At the end of the compilation process verify that all required **output products** generated
by the Vivado IP flow are in place :

```
% ls -l cores/PLL
```
<br/>


<span>&#8226;</span> With your preferred text editor create a new RTL source file `rtl/LFSR.vhd` with the following content :

```vhdl
library IEEE ;
use IEEE.std_logic_1164.all ;
use IEEE.numeric_std.all ;              -- to use to_integer() and unsigned() type-casting functions

entity LFSR is

   generic(
      SEED : std_logic_vector(7 downto 0) := x"FF"   -- seed of the pseudo-random bit sequence
   ) ;

   port(
      clk  : in  std_logic ;   -- assume 100 MHz input clock fed to PLL
      PRBS : out std_logic     -- output pseudo-random bit sequence
   ) ;

end entity LFSR ;


architecture rtl of LFSR is

   --------------------------------
   --   components declaration   --
   --------------------------------

   component PLL is
      port(
         CLK_IN  : in  std_logic ;
         CLK_OUT : out std_logic ;
         LOCKED  : out std_logic
      ) ;
   end component ;


   component TickCounter is
      generic(
         MAX : positive := 10414   -- default is ~9.6 kHz as for UART baud-rate
      ) ;
      port(
         clk  : in  std_logic ;
         tick : out std_logic
      ) ;
   end component ;


   --------------------------
   --   internal signals   --
   --------------------------

   -- PLL signals
   signal pll_clk, pll_locked : std_logic ;

   -- "tick" from tick-counter
   signal shift_enable : std_logic ;

   -- 8-bit shift-register internal parallel output
   signal SR : std_logic_vector(7 downto 0) := SEED ;   -- SR(0), SR(1), ... SR(7) are FFs outputs

   -- feedback combinational logic
   signal feedback : std_logic ;

   -- **ONLY FOR SIMULATION** (easier hierarchical probing from testbench)
   signal rndm : integer ;


begin


   ----------------------------
   --   PLL (Clock Wizard)   --
   ----------------------------

   PLL_inst : PLL port map(CLK_IN => clk, CLK_OUT => pll_clk, LOCKED => pll_locked) ;


   ----------------------
   --   tick counter   --
   ----------------------

   TickCounter_inst : TickCounter generic map(MAX => 10) port map(clk => pll_clk, tick => shift_enable) ;



   --------------------------------------------------------------
   --   Linear Feedback Shift Register (LFSR) implementation   --
   --------------------------------------------------------------

   -- choose here the desired feedback combinational logic
   feedback <= SR(7) ;


   process(pll_clk)
   begin

      if( rising_edge(pll_clk) ) then

         if( (shift_enable = '1') and (pll_locked = '1') ) then

            SR(0) <= feedback ;
            SR(1) <= SR(0) ;
            SR(2) <= SR(1) xor feedback ;
            SR(3) <= SR(2) xor feedback ;
            SR(4) <= SR(3) xor feedback ;
            SR(5) <= SR(4) ;
            SR(6) <= SR(5) ;
            SR(7) <= SR(6) ;

         end if ;
      end if ;
   end process ;

   -- pseudo-random serial output
   PRBS <= SR(7) ;


   -- probe this value from testbench and dump "integer" values to ASCII file for later histogramming
   rndm <= to_integer(unsigned(SR)) ;

end architecture rtl ;
```
<br/>


<span>&#8226;</span> Copy remaining **RTL and simulation sources** already prepared for you
from the `.solutions/` directory as follows :

```
% cp .solutions/bench/ClockGen.vhd       bench/
% cp .solutions/bench/tb_LFSR.vhd        bench/
% cp .solutions/rtl/TickCounter.vhd      rtl/
```
<br/>


<span>&#8226;</span>  Compile, elaborate and simulate the design with :

```
% make compile
% make elaborate
% make simulate
```
<br/>

or simply use

```
% make sim
```
<br/>

for less typing. Observe the **pseudo-random bit sequence** generated by the circuit.

<br/>

<span>&#8226;</span> Integer values corresponding to **LFSR binary outputs (bytes)** are automatically dumped from the VHDL testbench
into the `work/sim/bytes.txt` ASCII file. A simple **PyROOT** script is available to **plot the "trend" of values** generated by the LFSR :

```
% cp .solutions/bin/histoBytes.py bin/
% python ./bin/histoBytes.py
```
<br/>

>
> **WARNING**
>
> A proper **PyROOT installation** is required to run the script !
>

<br/>

<br/>

>
> **Q.** Which is the **repetition period** of the pseudo-random bit sequence ?<br/>
> &nbsp;&nbsp;&nbsp;&nbsp; Are **all possible integer values** between 0 and (2<sup>8</sup> -1) generated by the circuit ?
>
>**A.** &nbsp; __________________________________________________
>

<br/>

## Exercise

Play with the **seed** of the LFSR in the VHDL testbench by editing the `SEED` value in the `generic map` of the DUT instantiation :

```vhdl
DUT : LFSR generic map(SEED => x"FF") port map (clk => clk_board, PRBS => PRBS) ;
```
<br/>

>
> **Q.** What happens to the output pattern if the seed is `x"00"` ?
>
>**A.** &nbsp; __________________________________________________
>

<br/>

## Exercise

Modify the **feedback implementation** in `rtl/LFSR.vhd` as follows :

```vhdl
--feedback <= SR(7) ;

feedback <= SR(7) xor '1' when SR(6 downto 0) = "0000000" else
            SR(7) xor '0' ;
```
<br/>

Re-simulate the design and re-generate the histogram with the "trend" of pseudo-random values :

```
% make clean sim
% python ./bin/histoBytes.py
```
<br/>

>
> **Q.** Which change can you now observe in the output pattern after the proposed feedback modification ?
>
>**A.** &nbsp; __________________________________________________
>

<br/>

