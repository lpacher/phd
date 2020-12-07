--
-- Example Read-Only Memory (ROM) implementation in VHDL.
-- The ROM is used to store sampled values of a sine waveform.
--
-- Use the ROM_STYLE "synthesis pragma" to instruct the synthesis
-- tool how to infer the ROM memory in FPGA hardware :
--
-- rom_style = "block"        => infer memory using BRAMs
-- rom_style = "distributed"  => infer memory using LUTs
--
-- This can be set either in RTL code or in XDC as set_property.
-- By default the tool selects which ROM style to infer based on
-- heuristics that give the best results for the most designs.
--
-- Ref. also to Vivado Design Suite User Guide: Synthesis (UG901)
--
-- https://www.xilinx.com/support/documentation/sw_manuals/xilinx2019_2/ug901-vivado-synthesis.pdf
--
-- Luca Pacher - pacher@to.infn.it
-- Fall 2020
--


library IEEE ;
use IEEE.std_logic_1164.all ;
use IEEE.numeric_std.all ;       -- to use the type-casting function to_integer()
use IEEE.math_real.all ;


-- additional packages to work with I/O text files
use STD.textio.all ;
use IEEE.std_logic_textio.all ;


-- example usage of custom external package compiled into default working library "work"
library work ;
use work.lab7_package.all ;


-- **NOTE: ROM_WIDTH , ROM_DEPTH, ROM_ADDR_BITS and ROM_INIT_FILE are defined in custom package 
entity ROM is

   port(
      clk  : in  std_logic ;
      ren  : in  std_logic ;
      addr : in  std_logic_vector(ROM_ADDR_BITS-1 downto 0) ;  -- address 0 to ROM_DEPTH-1 memory locations (10-bits for 1024 samples)
      dout : out std_logic_vector(ROM_WIDTH-1 downto 0) 
   ) ;

end entity ROM ;


architecture rtl of ROM is


   --------------------------------------
   --   ROM memory array declaration   --
   --------------------------------------

   -- declare the ROM as a **NEW CUSTOM TYPE** made of an "array" of "std_logic_vector"
   --type rom_t is array (0 to 1023) of std_logic_vector(15 downto 0) ;


   ----------------------------
   --   ROM initialization   --
   ----------------------------

   --
   -- **IMPORTANT
   --
   -- By default VHDL natively only supports to specify ROM initial values in the
   -- RTL code in form of an initial signal assignment to an array of vectors.
   -- On the contrary, Verilog provides built-in $readmemb() and $readmemb()
   -- tasks for this purpose to easily import ROM init values from an external
   -- file (either as binary or hex values respectively). 
   -- If you want to import ROM init values from an external file in VHDL
   -- you must write **YOUR OWN CUSTOM VHDL FUNCTION** to open the file and read
   -- lines from it using routines from STD.textio and IEEE.std_logic_textio packages.
   --
   -- Ref. also to :
   --
   -- https://forums.xilinx.com/t5/Spartan-Family-FPGAs-Archived/Initializing-Block-RAM-with-External-Data-File/td-p/229193
   --

   --
   -- you can specify ROM values for each address using
   -- a standard initial signal assignment...

   --signal sine_lut : rom_t := (
   --
   --   x"0123",
   --   x"4567",
   --   x"89AB",
   --   x"CDEF",   etc.
   --
   --) ;


   --
   -- or you can write your own **CUSTOM VHDL FUNCTION** to read
   -- ROM init values from a text file (even better if implemented
   -- into an external custom package) :
   --

   ----------
   --impure function InitRomFromFile (fileName : in string) return rom_t is
   --
   --   file romInitFile : text is in fileName ;
   --
   --   variable row : line ;
   --   variable romInitData : rom_t ;
   --
   --begin
   --
   --   for i in rom_t'range loop
   --
   --      -- read the line "string" from the file...
   --      readline(romInitFile, row) ;
   --
   --      -- then flush the read value to variable romInitData
   --      hread(row, romInitData(i)) ;
   --
   --   end loop ;
   --
   --   return romInitData ;
   --
   --end function ;
   ----------

   
   signal sine_lut : rom_t := InitRomFromFile(ROM_INIT_FILE) ;


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

