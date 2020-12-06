
# Lab 5 Instructions
[[**Home**](https://github.com/lpacher/fphd)] [[**Back**](https://github.com/lpacher/fphd/tree/master/labs)]

In this lab we implement and simulate simple **4-bit Binary-Coded Decimal (BCD) counter** using VHDL.
We also use this very simple example synchronous design to discuss some **good and bad FPGA design practices**
related to **clock management** and **physical implementation**.

<br/>


<span>&#8226;</span> As a first step, **open a terminal** and move inside the `lab5/` directory :

```
% cd Desktop/fphd/labs/lab5
```
<br/>

<span>&#8226;</span> Copy from the `.solutions/` directory the main `Makefile` already prepared for you :


```
% cp .solutions/Makefile .
```

Explore **new available targets** :

```
% make help
% cat Makefile
```
<br/>

<span>&#8226;</span> Create a **new fresh working area** :

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


<span>&#8226;</span> Copy also from the `.solutions/` directory the following  **VHDL testbench and RTL sources** already prepared for you :

```
% cp .solutions/bench/ClockGen.vhd          bench/
% cp .solutions/bench/tb_CounterBCD.vhd     bench/
% cp .solutions/rtl/TickCounter.vhd         rtl/
% cp .solutions/rtl/CounterBCD_wrapper.vhd  rtl/
```
<br/>



<span>&#8226;</span> Finally, copy from the `.solutions/xdc/` directory the main **Xilinx Design Constraints (XDC)** file that will be used to<br/>
**map top-level VHDL I/O ports to physical FPGA pins** of the
[**Digilent Arty A7 development board**](https://store.digilentinc.com/arty-a7-artix-7-fpga-development-board-for-makers-and-hobbyists/) :

```
% cp .solutions/xdc/CounterBCD_wrapper.xdc  xdc/
```
<br>


<span>&#8226;</span> Create a new VHDL file `rtl/CounterBCD.vhd` :

```
% gedit rtl/CounterBCD.vhd &   (for Linux users)
% n++   rtl/CounterBCD.vhd &   (for Windows users)
```
<br/>

<span>&#8226;</span> Write the following `library` and `entity` code sections :


```vhdl
library IEEE ;
use IEEE.std_logic_1164.all ;
use IEEE.numeric_std.all ;


entity CounterBCD is

   port (
      clk : in  std_logic ;
      rst : in  std_logic ;
      BCD : out std_logic_vector(3 downto 0)
   ) ;

end entity CounterBCD ;

```
<br/>

<span>&#8226;</span> We will write **different architectures**, one for each proposed implementation.
The actual architecture to be simulated is then selected using a **component configuration (binding)** statement in the testbench.
Similarly, a top-level **wrapper** `rtl/CounterBCD_wrapper.vhd` is used to select which architecture is physically mapped to FPGA.

<br/>

<span>&#8226;</span> A first simple implementation for the BCD counter is the following :

```vhdl

architecture rtl_simple of CounterBCD is

   -- 4-bit "internal" BCD counter declared as a "VHDL unsigned" to work with IEEE.numeric_std

   signal count : unsigned(3 downto 0) ;                -- uninitialized count value
   --signal count : unsigned(3 downto 0) := "0000" ;    -- initialized count value (you can also use (others => '0') which is smarter)

begin

   ------------------------------------
   --   BCD counter (VHDL process)   --
   ------------------------------------

   process(clk)
   begin

      if( rising_edge(clk) ) then

         if( rst = '1' ) then                    -- **SYNCHRONOUS** reset
            count <= "0000" ;

         --elsif( to_integer(count) = 9 ) then   -- **NOTE: if you want to use 9 you MUST convert count to integer type !
         elsif( count = "1001" ) then
            count <= "0000" ;                    -- force the roll-over when the count reaches 9

         else
            count <= count + 1 ;                 -- **NOTE: be aware of the usage of + 1 and not + '1'

         end if ;

      --else ? Keep memory ! Same as else count <= count ; endif ;
      end if ;

   end process ;



   -- type casting
   BCD <= std_logic_vector(count) ;   -- convert "unsigned" to "std_logic_vector" using the "std_logic_vector()" function from IEEE.numeric_std

   -- **NOTE: due to VHDL strong data typing this gives a **COMPILATION ERROR** instead :
   -- BCD <= count ;

end architecture rtl_simple ;
```
<br/>

>
> **IMPORTANT !**
>
> By default VHDL provides the `+` (plus) operator to perform basic additions between
> **software-like NUMBERS** (e.g. 32-bit `integer` data type, but also `natutal`
> or `positive`, as well as `real` numbers).
> Due to **VHDL strong data typing** the usage of `+` between **hardware signals (buses)**
> requires the **OVERLOADING** of the `+` operator.
>
> As an example, a very simple
>
>   ```vhdl
>   count <= count + 1 ;
>   ```
>
> is **NOT allowed** in VHDL if `count` has been declared as `std_logic_vector`.
>
> In order to use `+` between hardware signals, the "legacy" VHDL introduced
> new "vector" data types called `std_logic_signed` and `std_logic_usigned` that
> are defined as part of `IEEE.std_logic_signed` and `IEEE.std_logic_unsigned` packages.
>
> By including these packages in the preable of the VHDL code with
>
>   ```vhdl
>   library IEEE ;
>   use IEEE.std_logic_1164.all ;
>   use IEEE.std_logic_unsigned.all ;
>   ```
>
> one can declare counters as `std_logic_vector` and the following syntax (note the usage of single quotes)
>
>   ```vhdl
>    count <= count + '1' ;
>   ```
>
> properly compiles. **HOWEVER**, in practice the usage of these packages has been
> de facto **DEPRECATED** for the following reasons :
>
>   1. despite the library name "IEEE" these packages are **NOT** provided
>      by IEEE, but are **Synopsys proprietary** !
>
>   2. despite the string "std" in (Synopsys) package names they are **NOT
>      IEEE standard at all** !
>
> This is the reason for which the **RECOMMENDED** package to be used when dealing
> with counters is `IEEE.numeric_std` that introduces new VHDL data types `signed` and
> `unsigned` along with IEEE-standard definitions to overload fudamental arithmetic
> operators such as `+` and `-` that are extensively used to generate real hardware.
>

<br/>

<span>&#8226;</span> Compile, elaborate and simulate the design with :

```
% make compile
% make elaborate
% make simulate
```

or simply use

```
% make sim
```

for less typing.


<br/>


## Clock management

Let now suppose that we want to **slow-down** the frequency of the clock fed to the BCD counter.
As a first guess, we can use an **auxiliary free-running counter** to divide the input clock and then
use this **generated clock** as clock for the BCD counter.

<br/>


<span>&#8226;</span> Add the following `architecture` implementation into `rtl/CounterBCD.vhd` :

``` vhdl
architecture rtl_bad of CounterBCD is

   -- 4-bit "internal" counter
   signal count : unsigned(3 downto 0) ;

   -- auxiliary 5-bit free-running counter for clock division
   signal count_free : unsigned(5 downto 0) := (others => '0') ;

   -- divided clock e.g. 100 MHz => 50 MHz
   signal clk_div : std_logic := '0' ;

begin

   --------------------------------------------------------
   --   EXAMPLE: a simple clock divider (VHDL process)   --
   --------------------------------------------------------

   --process(clk)
   --begin
   --   if( rising_edge(clk) ) then
   --      clk_div <= not clk_div ;     -- clk_div = clk/2
   --   end if ;
   --end process ;


   ------------------------------------------------------------------------------------
   --   EXAMPLE: clock divider using auxiliary free-running counter (VHDL process)   --
   ------------------------------------------------------------------------------------

   process(clk)
   begin
      if( rising_edge(clk) ) then
         count_free <= count_free + 1 ;
      end if ;
   end process ;


   -- choose below the desired divided clock fed to the BCD counter

   --clk_div <= clk ;                           -- clk
   --clk_div <= count_free(0) ;                 -- clk/2    e.g. 100 MHz/2 = 50   MHz
   --clk_div <= count_free(1) ;                 -- clk/4    e.g. 100 MHz/4 = 25   MHz
   --clk_div <= count_free(2) ;                 -- clk/8    e.g. 100 MHz/8 = 12.5 MHz
   --clk_div <= count_free(3) ;                 -- clk/16   etc.
   --clk_div <= count_free(4) ;                 -- clk/32
   clk_div <= count_free(5) ;                   -- clk/64


   ------------------------------------
   --   BCD counter (VHDL process)   --
   ------------------------------------

   process(clk_div)   -- this is a **BAD** RTL coding example, synchronous processes doesn't work with the same clock !
   begin

      if( rising_edge(clk_div) ) then

         if( rst = '1' ) then
            count <= (others => '0') ;

         elsif( to_integer(count) = 9 ) then   -- instead of count = "1001" we can use to_integer(count) = 9
            count <= (others => '0') ;

         else
            count <= count + 1 ;

         end if ;
      end if ;

   end process ;

   -- type casting
   BCD <= std_logic_vector(count) ;

end architecture rtl_bad ;
```
<br/>

This is an example of a a **BAD** RTL digital design approach for pure synchronous designs.
The **BAD approach** here is to generate a dedicated lower-frequency clock using an auxiliary
counter or a simple clock divider.

<br/>

<span>&#8226;</span> Modify the testbench `bench/tb_CounterBCD.vhd` in oder to **update the component configuration** in the architecture body
that selects the architecture to be used for the simulation :

```vhdl
   --------------------------------------------------------
   --   component configuration (architecture binding)   --
   --------------------------------------------------------

   -- choose here which BCD counter architecture to simulate :

   for DUT : CounterBCD
      --use entity work.CounterBCD(rtl_simple) ;
      use entity work.CounterBCD(rtl_bad) ;
      --use entity work.CounterBCD(rtl_ticker) ;
      --use entity work.CounterBCD(rtl_PLL) ;

```
<br/>

<span>&#8226;</span> Simulate the design :

```
% make sim
```
<br/>


On the contrary a **GOOD synchronous digital design** always uses **THE SAME CLOCK everywhere**
in the logic in order to easier digital implementation tools to achieve **timing closure**.

This is the **RECOMMENDED** approach whenever you need to "slow down" the speed
of the data processing in your design is to use a **tick counter** instead.
That is, we can use a "ticker" module implemented using an additional
"modulus-N free-running counter" to generate a single clock-pulse "tick"
(e.g. every 1 us) to be used as count-enable for the main BCD counter.


```vhdl
architecture rtl_ticker of CounterBCD is

   component TickCounter is
      generic(
         MAX : positive := 10414   -- default is ~9.6 kHz as for UART baud-rate
      ) ;
      port(
         clk  : in  std_logic ;
         tick : out std_logic
      ) ;
   end component ;

   -- single clock-pulse from "ticker" used as count-enable for the BCD counter
   signal count_en : std_logic ;

   -- 4-bit "internal" BCD counter
   signal count : unsigned(3 downto 0) := (others => '0') ;

begin


   ------------------------
   --   "tick" counter   --
   ------------------------

   --
   -- **NOTE
   --
   -- Assuming 100 MHz input clock we can generate up to 2^32 -1 different tick periods, e.g.
   --
   -- MAX =    10 => one "tick" asserted every    10 x 10 ns = 100 ns  => logic "running" at  10 MHz
   -- MAX =   100 => one "tick" asserted every   100 x 10 ns =   1 us  => logic "running" at   1 MHz
   -- MAX =   200 => one "tick" asserted every   200 x 10 ns =   2 us  => logic "running" at 500 MHz
   -- MAX =   500 => one "tick" asserted every   500 x 10 ns =   5 us  => logic "running" at 200 kHz
   -- MAX =  1000 => one "tick" asserted every  1000 x 10 ns =  10 us  => logic "running" at 100 kHz
   -- MAX = 10000 => one "tick" asserted every 10000 x 10 ns = 100 us  => logic "running" at  10 kHz etc.
   --

   --TickCounter_inst : TickCounter generic map(MAX => 10) port map(clk => clk, tick => count_en) ;
   TickCounter_inst : TickCounter generic map(MAX => 50000000) port map(clk => clk, tick => count_en) ;  -- OK for LED mapping


   ------------------------------------------------------
   --   BCD counter with count-enable (VHDL process)   --
   ------------------------------------------------------

   process(clk)   -- this is a **GOOD** RTL coding example, EVERYTHING is now running at the same clock !
   begin

      if( rising_edge(clk) ) then

         if( rst = '1' ) then
            count <= (others => '0') ;

         elsif( count_en = '1' ) then

            if( to_integer(count) = 9 ) then
               count <= (others => '0') ;

            else
               count <= count + 1 ;

            end if ;
         end if ;
      end if ;

   end process ;

   -- type casting
   BCD <= std_logic_vector(count) ;

end architecture rtl_ticker ;
```
<br/>


<span>&#8226;</span> Modify the testbench `bench/tb_CounterBCD.vhd` in oder to **update the component configuration** in the architecture body
that selects the architecture to be used for the simulation :

```vhdl
   --------------------------------------------------------
   --   component configuration (architecture binding)   --
   --------------------------------------------------------

   -- choose here which BCD counter architecture to simulate :

   for DUT : CounterBCD
      --use entity work.CounterBCD(rtl_simple) ;
      --use entity work.CounterBCD(rtl_bad) ;
      use entity work.CounterBCD(rtl_ticker) ;
      --use entity work.CounterBCD(rtl_PLL) ;

```
<br/>

<span>&#8226;</span> Simulate the design :

```
% make sim
```
<br/>


## Compile a Phase-Locked Loop (PLL) IP core

A more complete example of a **GOOD** RTL coding style for pure synchronous FPGA designs
is to use :

  1. a dedicated **PLL-based clock-management** IP core (_Clock Wizard_) compiled
      from the _Xilinx Vivado IP Catalog_

  2. the **tick counter** to **slow-down** the speed of the data processing without
      creating "custom" divided clock signals

  3. **output buffers primitives** `OBUF` with programmed slew-rate and drive-strength

Despite in this case we don't need to "multiply" nor to "divide" the external clock,
we use a dedicated PLL-based clock management IP core anyway.

This is the **RECOMMENDED** approach for any FPGA project, even better if you compile
the **Mixed-Mode Clock Management (MMCM)** version of the IP core which is a super-set
of the PLL. The main reason for this is that by using a dedicated clock-management
block you can **fine-tune the clock fed to FPGA internal logic** (e.g. jitter filtering, phase
adjustement, fine-delay adjustement etc.)

Compile a new **Phase-Locked Loop (PLL)** core using the **Vivado IP flow** in order to **fine-tune**
the clock fed to internal logic starting from the available **on-board 100 MHz clock**.
Additionally, we use the PLL to **double the clock frequency** up to 200 MHz as an example
of **frequency-synthesis** capabilities of the PLL. A simple multiplexer is then used
to switch between 100 MHz and 200 MHz fed to the core logic.


<span>&#8226;</span> As a first step copy from the `.solutions/` directory the following Tcl script :

```
% cp .solutions/scripts/common/ip.tcl ./scripts/common/
```
<br/>

<span>&#8226;</span> Launch the **Vivado IP flow** with :

```
% make ip
```
<br/>

<span>&#8226;</span> Select in the **IP Catalog** the **Clocking Wizard** available under *Cores > FPGA Features and Design > Clocking > Clocking Wizard*.
Right click on **Clocking Wizard** and select **Customize IP...**.

Create a new IP core named `PLL` with the following features :

* 100 MHz input clock
* primary 100 MHz output clock
* additional 200 MHz output clock
* no reset signal

Change default port names in order to have `CLK_IN`, `CLK_OUT_100`, `CLK_OUT_200` and `LOCKED`.

<br/>

<span>&#8226;</span> Compile the IP and **generate all output products**. Additionally, **export all simulation scripts**
by executing in the Tcl console the following custom Tcl procedure :

```
export_xsim_scripts
```
<br/>

<span>&#8226;</span> Inspect source files automatically generated for you in the `cores/PLL` and `cores/export_scripts` directories.

Most important files for our purposes are :

* the main **Xilinx Core Instance (XCI)** XML file `*.xci` containing the IP configuration
* the VHDL instantiation template `*.vho` (if the target language is Verilog a `.veo` would have been created instead)
* the XDC constraints file for the IP core `*.xdc`
* self-contained gate-level Verilog and VHDL netlists `*sim_netlist.v/*sim_netlist.vhd` for functional simulations

<br/>

>
> **IMPORTANT**
>
> The  **Xilinx Core Instance (XCI)** XML file containing the configuration of the IP allows to
> easily re-compile from scratch the IP core.
>

<br/>


<span>&#8226;</span> Modify the `entity` declaration into `rtl/CounterBCD.vhd` in order to **add a new** `clk_sel` **input port** :

```vhdl
library UNISIM ;
use UNISIM.vcomponents.all ;   -- external library required to simulate Xilinx FPGA primitives


entity CounterBCD is

   port (
      clk     : in  std_logic ;
      clk_sel : in  std_logic ;   -- for PLL design: 0 = 100 MHz, 1 = 200 MHz
      rst     : in  std_logic ;
      BCD     : out std_logic_vector(3 downto 0)
   ) ;

end entity CounterBCD ;
```
<br/>


<span>&#8226;</span> Add the following `architecture` implementation into `rtl/CounterBCD.vhd` :


```vhdl
architecture rtl_PLL of CounterBCD is


   --------------------------------
   --   components declaration   --
   --------------------------------

   component PLL is
     port (
        CLK_IN      : in  std_logic ;
        CLK_OUT_100 : out std_logic ;
        CLK_OUT_200 : out std_logic ;
        LOCKED      : out std_logic
     ) ;
   end component PLL ;


   component TickCounter is
      generic(
         MAX : positive := 10414   -- default is ~9.6 kHz as for UART baud-rate
      ) ;
      port(
         clk  : in  std_logic ;
         tick : out std_logic
      ) ;
   end component ;


   --------------------------------------
   --   internal signals declaration   --
   --------------------------------------

   -- PLL signals
   signal pll_clk_100, pll_clk_200, pll_clk, pll_locked : std_logic ;

   -- single clock-pulse from "ticker" used as count-enable for the BCD counter
   signal count_en : std_logic ;

   -- 4-bit "internal" BCD counter
   signal count : unsigned(3 downto 0) := (others => '0') ;


begin


   ------------------------------------
   --   PLL IP core (Clock Wizard)   --
   ------------------------------------

   -- the PLL generates two output clock signals, 100 MHz and 200 MHz frequency
   PLL_inst : PLL port map(CLK_IN => clk, CLK_OUT_100 => pll_clk_100, CLK_OUT_200 => pll_clk_200, LOCKED => pll_locked) ;


   -- MUX to switch between 100 MHz and 200 MHz
   pll_clk <= pll_clk_100 when clk_sel = '0' else pll_clk_200 ;


   ------------------------
   --   "tick" counter   --
   ------------------------

   --
   -- **NOTE
   --
   -- Assuming 100 MHz input clock we can generate up to 2^32 -1 different tick periods, e.g.
   --
   -- MAX =    10 => one "tick" asserted every    10 x 10 ns = 100 ns  => logic "running" at  10 MHz
   -- MAX =   100 => one "tick" asserted every   100 x 10 ns =   1 us  => logic "running" at   1 MHz
   -- MAX =   200 => one "tick" asserted every   200 x 10 ns =   2 us  => logic "running" at 500 MHz
   -- MAX =   500 => one "tick" asserted every   500 x 10 ns =   5 us  => logic "running" at 200 kHz
   -- MAX =  1000 => one "tick" asserted every  1000 x 10 ns =  10 us  => logic "running" at 100 kHz
   -- MAX = 10000 => one "tick" asserted every 10000 x 10 ns = 100 us  => logic "running" at  10 kHz etc.

   TickCounter_inst : TickCounter generic map(MAX => 100) port map(clk => pll_clk, tick => count_en) ;          -- OK for simulations
   --TickCounter_inst : TickCounter generic map(MAX => 150000000) port map(clk => pll_clk, tick => count_en) ;  -- OK for LED mapping


   ------------------------------------------------------
   --   BCD counter with count-enable (VHDL process)   --
   ------------------------------------------------------

   process(pll_clk)
   begin

      if( rising_edge(pll_clk) ) then

         if( (rst = '1') or (pll_locked = '0') ) then   -- **NOTE: we also use the "locked" signal from the PLL as reset !
            count <= (others => '0') ;

         elsif( count_en = '1' ) then

            if( to_integer(count) = 9 ) then
               count <= (others => '0') ;

            else
               count <= count + 1 ;

            end if ;
         end if ;
      end if ;

   end process ;

   -- type casting
   BCD <= std_logic_vector(count) ;

end architecture rtl_PLL ; 
```
<br/>

<span>&#8226;</span> Modify the testbench `bench/tb_CounterBCD.vhd` in oder to **update** in the architecture preamble
the **component declaration** for `CounterBCD` and the **component configuration** that selects the architecture to be used for the simulation :

```vhdl

architecture testbench of tb_CounterBCD is

   --------------------------------
   --   components declaration   --
   --------------------------------

   ...
   ...

   component CounterBCD is
      port (
         clk     : in  std_logic ;
         clk_sel : in  std_logic ;   -- for PLL design: 0 = 100 MHz, 1 = 200 MHz
         rst     : in  std_logic ;
         BCD     : out std_logic_vector(3 downto 0)
      ) ;
   end component ;


   ---------------------------------------------------
   --   testbench parameters and internal signals   --
   ---------------------------------------------------

   ...
   ...

   -- MUX control to switch between 100 MHz and 200 MHz PLL output clock
   signal clk_sel : std_logic := '0' ;   -- default: 100 MHz

   ...
   ...


   --------------------------------------------------------
   --   component configuration (architecture binding)   --
   --------------------------------------------------------

   -- choose here which BCD counter architecture to simulate :

   for DUT : CounterBCD
      --use entity work.CounterBCD(rtl_simple) ;
      --use entity work.CounterBCD(rtl_bad) ;
      --use entity work.CounterBCD(rtl_ticker) ;
      use entity work.CounterBCD(rtl_PLL) ;


begin

   ...
   ...


   ---------------------------------
   --   device under test (DUT)   --
   ---------------------------------

   DUT : CounterBCD port map (clk => clk_board, clk_sel => clk_sel, rst => reset, BCD => BCD) ;

```
<br/>


<span>&#8226;</span> **Update also the main stimulus** in order to simulate the clock frequency selection between 100 MHz and 200 MHz :


```vhdl
   -----------------------
   --   main stimulus   --
   -----------------------

   stimulus : process
   begin

      reset <= '0' ;

      wait for  1502 ns ; reset <= '1' ;
      wait for  1500 ns ; reset <= '0' ;

      wait for 50 us ;

      clk_sel <= '1' ;    -- switch to 200 MHz

      wait for 20 us ;

      finish ;   -- stop the simulation (this is a VHDL2008-only feature)

      --
      -- **IMPORTANT: VHDL87/VHDL93 standards does not provide a routine to easily stop the simulation !
      --              You must use a failing "assertion" for this purpose :
      --
      --assert FALSE report "Simulation Finished" severity FAILURE ;

   end process ;

```
<br/>


<span>&#8226;</span> Simulate the design :

```
% make sim
```


