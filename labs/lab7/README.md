# Lab 7 Instructions
[[**Home**](https://github.com/lpacher/fphd)] [[**Back**](https://github.com/lpacher/fphd/tree/master/labs)]


In this lab we implement and simulate a **sine-wave generator** using **Read-Only Memory (ROM)** and **Pulse-Width Modulation (PWM)**.<br/>
This is an example of **Direct Digital Synhesis (DDS)** of arbitrary waveforms.

With this approach a finite number (e.g. 1024) of sampled sine values are stored into a ROM in form of a **Look-Up Table (LUT)**.
Thus each memory slot of the ROM contains a sine value with a certain precision (e.g. 8-bit, 12-bit, 16-bit etc.) and with
some representation (usually unsigned integer, but can be also interpreted as fixed-point real numbers).
ROM sine values are then fed as input threshold values for a PWM counter. The resulting variable duty-cycle PWM encodes sine values
variations and can be used as input signal for a **low-pass filter (LPF)** for **analog waveform reconstruction** (can be also as simple as
 a low-pass RC filter followed by a voltage buffer).

This is the "digital" equivalent of feeding to an analog comparator (e.g. an OPAMP working in open-loop configuration) a lower-frequency
"reference" sine wave and a higher-frequency "carrier" sowtooth wave.


<br/>

<span>&#8226;</span>  As a first step, **open a terminal** and move inside the `lab7/` directory :

```
% cd Desktop/fphd/labs/lab7
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


<span>&#8226;</span> The first VHDL component that we need to implement is a **Read-Only Memory (ROM)**.
In the following a first example of an **8 x 1024** ROM is presented, thus assuming to
**sample sine-values with 8-bit precision**.

With your preferred text editor create a new RTL source file `rtl/ROM.vhd` with the following content :


```vhdl
library IEEE ;
use IEEE.std_logic_1164.all ;
use IEEE.numeric_std.all ;

-- additional packages to work with I/O text files
use STD.textio.all ;                                  -- **NOTE: by default library STD and library work are automatically added for you !
use IEEE.std_logic_textio.all ;


entity ROM is

   port(
      clk  : in  std_logic ;
      ren  : in  std_logic ;
      addr : in  std_logic_vector(9 downto 0) ;  -- 10-bit to address 0 to 1023 memory locations, i.e. 1024 samples
      dout : out std_logic_vector(7 downto 0)
   ) ;

end entity ROM ;


architecture rtl of ROM is


   --------------------------------------
   --   ROM memory array declaration   --
   --------------------------------------

   -- declare the ROM as a **NEW CUSTOM TYPE** made of an "array" of "std_logic_vector"
   type rom_t is array (0 to 1023) of std_logic_vector(7 downto 0) ;


   ----------------------------
   --   ROM initialization   --
   ----------------------------

   ----------
   impure function InitRomFromFile (fileName : in string) return rom_t is
   
      file romInitFile : text is in fileName ;
   
      variable row : line ;
      variable romInitData : rom_t ;
   
   begin
   
      for i in rom_t'range loop
   
         -- read the line "string" from the file...
         readline(romInitFile, row) ;
   
         -- then flush the read value to variable romInitData
         hread(row, romInitData(i)) ;
   
      end loop ;
   
      return romInitData ;
   
   end function ;
   ----------

   signal sine_lut : rom_t := InitRomFromFile("../../rtl/ROM_8x1024.hex") ;


   -------------------------------------------------------
   --   ROM implementation style (synthesis "pragma")   --
   -------------------------------------------------------

   --
   -- this is a first example of a **SYNTHESIS PRAGMA** to instruct Vivado
   -- how to infer the ROM memory in FPGA using LUTs or BRAMs
   --
   attribute rom_style : string ;

   attribute rom_style of sine_lut : signal is "block" ;          -- instruct the synthesis tool to infer memory using BRAMs
   --attribute rom_style of sine_lut : signal is "distributed" ;    -- instruct the synthesis tool to infer memory using LUTs

begin


   --------------------
   --   read logic   --
   --------------------

   process(clk)
   begin
      if( rising_edge(clk) ) then
         if( ren = '1' ) then

            dout <= sine_lut(to_integer(unsigned(addr))) ;  -- simply read the ROM word from address i-th

         end if ;
      end if ;
   end process ;

end architecture rtl ;

```
<br>

>
> **IMPORTANT**
>
> By default VHDL natively **only supports to specify ROM initial values** in the
> RTL code in form of an initial signal assignment to an array of vectors.
> On the contrary, Verilog provides built-in `$readmemb()` and `$readmemb()`
> tasks for this purpose to easily import ROM init values from an external
> file (either as binary or hex values respectively).
> If you want to import ROM init values **from an external file in VHDL**
> you must write **YOUR OWN CUSTOM VHDL FUNCTION** to open the file and read
> lines from it using routines from `STD.textio` and `IEEE.std_logic_textio` packages.
>
> Ref. also to :
>
> <https://forums.xilinx.com/t5/Spartan-Family-FPGAs-Archived/Initializing-Block-RAM-with-External-Data-File/td-p/229193>
>

<br/>

<span>&#8226;</span> The second VHDL component that we need to implement is a **Pulse-Width Modulator (PWM)**.
The simplest way to implement a PWM signal is using a counter and a binary comparator to compare the count value with some
programmable threshold value. In the proposed implementation the comparator asserts a logic 1 when the internal free-running
count value is lower than the chosen threshold, 0 otherwise.


With your preferred text editor create another new RTL source file `rtl/PWM.vhd` with the following content :

```vhdl
library IEEE ;
use IEEE.std_logic_1164.all ;
use IEEE.numeric_std.all ;


entity PWM is

   generic(
      THRESHOLD_NBITS : positive := 8
   ) ;

   port(
      clk       : in  std_logic ;
      rst       : in  std_logic ;                                      -- synchronous reset, active-high
      threshold : in  std_logic_vector(THRESHOLD_NBITS-1 downto 0) ;   -- programmable threshold, determines the duty-cycle of the PWM output waveform
      pwm_eoc   : out std_logic ;                                      -- End of Count (EoC) flag, asserted when the counter resets back to zero
      pwm_out   : out std_logic

   ) ;

end entity PWM ;


architecture rtl of PWM is

   -- internal free-running counter
   signal pwm_count : unsigned(THRESHOLD_NBITS-1 downto 0) := (others => '0') ;


begin


   ------------------------------
   --   free-running counter   --
   ------------------------------

   process(clk)
   begin

      if( rst = '1' ) then                -- synchronous reset, active-high
         pwm_count <= (others => '0') ;

      elsif( rising_edge(clk) ) then

         pwm_count <= pwm_count + 1 ;

      end if ;
   end process ;


   ----------------------------
   --   binary comparators   --
   ----------------------------

   -- PWM output: logic '1' if pwm_count < threshold, '0' otherwise
   pwm_out <= '1' when (to_integer(unsigned(pwm_count)) < to_integer(unsigned(threshold))) else '0' ;

   -- assert an End-of-Count (EOC) flag whenever the counter resets to zero
   pwm_eoc <= '1' when (to_integer(unsigned(pwm_count)) = 0) else '0' ;

end architecture rtl ;
```
<br/>

<span>&#8226;</span> Copy remaining **RTL and simulation sources** already prepared for you
from the `.solutions/` directory as follows :

```
% cp .solutions/rtl/TickCounter.vhd      rtl/
% cp .solutions/rtl/SineGen.vhd          rtl/
% cp .solutions/rtl/ROM_8x1024.hex       rtl/
% cp .solutions/bench/ClockGen.vhd       bench/
% cp .solutions/bench/tb_SineGen.vhd     bench/
```
<br/>

Sample **sine values** to be stored in the ROM can be generated using any kind of programming or scripting language (C/C++, Python, Perl etc.).
Several on-line sine wave LUT generators exists indeed. Proposed sampled values contained in `rtl/ROM_8x1024.hex` have been generated using
[this online sine-generator calculator](https://daycounter.com/Calculators/Sine-Generator-Calculator.phtml).
<br/>

<span>&#8226;</span>  For easier waveform debug a **Waveform Configuration File (WCFG)** has been already prepared for you :

```
% mkdir wcfg
% cp .solutions/wcfg/tb_SigeGen.wcfg   wcfg/
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

for less typing. Inspect waveforms and observe the **variable duty-cycle PWM signal** generated by the circuit.
<br/>

<span>&#8226;</span> Run the FPGA implementation flow in non-project mode :

```
% make build
```
<br/>

Once done, open the final **gate-level schematic**.


>
> **Q.** Which FPGA resources have been used by the synthesizer to implement the ROM memory ? 
>
>**A.** &nbsp; __________________________________________________
>

<br/>


## Exercise

Xilinx offers the possibility to **compile ROMs as IP cores**. We can therefore replace our 8x1024
ROM with a compiled version from the **Vivado IP Catalog**.

<br/>

<span>&#8226;</span> Launch the **Vivado IP flow** in graphic mode with :

```
% make ip
```
<br/>

<span>&#8226;</span> Select in the **IP Catalog** the **Distributed Memory Generator**
under _Memories & Storage Elements > RAMs & ROMs > Distributed Memory Generator_. Then right-click on **Distributed Memory Generator** 
and select **Customize IP...**

<br/>

<span>&#8226;</span> Create new ROM IP with the following configuration :


* Component Name: ROM_WIDTH16_DEPTH1024
* Depth: 1024
* Width: 8
* Memory Type: ROM
* Output Options: Registered + Single Port Output CE
* Coefficients file: /path/to/rtl/ROM_8x1024.coe

Once done, left-click _OK_ and **generate all output products** (choose Out-of Context).
<br/>
<br/>

<span>&#8226;</span> Inspect the **VHDL instantiation template** automatically generated by Vivado for you :

```
% cat cores/ROM_WIDTH8_DEPTH1024/ROM_WIDTH8_DEPTH1024.vho
```
<br/>


<span>&#8226;</span> Modify the top-level RTL module `rtl\SineGen.vhd` in order to **instantiate the new ROM**.
For this purpose, **update the component delcaration** and the **ROM instantiation** according to the VHDL
instantiation template as follows :


```vhdl
--component ROM is
--      port(
--         clk  : in  std_logic ;
--         ren  : in  std_logic ;
--         addr : in  std_logic_vector(9 downto 0) ;
--         dout : out std_logic_vector(7 downto 0)
--      ) ;
--   end component ;

component ROM_WIDTH8_DEPTH64 is
   port(
      clk      : in  std_logic ;
      qspo_ce  : in  std_logic ;                        -- single-port output clock enable => this is the "read enable" control
      a        : in  std_logic_vector(9 downto 0) ;     -- 10-bit address
      qspo     : out std_logic_vector(7 downto 0)       -- 8-bit single-port output (SPO)
      ) ;
end component ;

...
...


--ROM_inst : ROM
--
--   port map(
--      clk  => pll_clk,
--      ren  => rom_ren,
--      addr => std_logic_vector(rom_addr),
--      dout => rom_data
--   ) ;


ROM_inst : ROM_WIDTH8_DEPTH64

   port map(
      clk      => pll_clk,
      qspo_ce  => rom_ren,
      a        => std_logic_vector(rom_addr),
      qspo     => rom_data
   ) ;
```

<br/>

<span>&#8226;</span> After changes, try to recompile and resimulate the design :

```
% make clean sim
```
<br/>

<span>&#8226;</span> Re-run also the physical implementation flow :

```
% make build
```
<br/>

Once done, open the new final **gate-level schematic**.


>
> **Q.** Which FPGA resources have been now used by the synthesizer to implement the ROM memory ? 
>
>**A.** &nbsp; __________________________________________________
>

