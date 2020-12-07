--
-- Example external custom VHDL package to collect project-specific
-- stuffs for easier code reuse. In fact you can always put into
-- a custom package :
--
--   - constants definitions
--   - new data-types definition (e.g. rom_t here)
--   - custom VHDL functions
--   - the implementation of recurrent digital blocks (entities)
--
-- VHDL code for importing ROM init values from external ASCII file readapted from :
--
-- https://forums.xilinx.com/t5/Spartan-Family-FPGAs-Archived/Initializing-Block-RAM-with-External-Data-File/td-p/229193
--
-- Luca Pacher - pacher@to.infn.it
-- Fall 2020
--

--
-- **IMPORTANT
--
-- Since the XSim simulation flow runs into WORK_DIR/sim while
-- the Vivado implementation flow into WORK_DIR/impl default
-- paths to ROM initialization files point to "../../rtl/*.hex"
--


library IEEE ;
use IEEE.std_logic_1164.all ;
use IEEE.numeric_std.all ;
use IEEE.math_real.all ;        -- to use math functions e.g. ceil() and log2()


-- additional packages to work with I/O text files
use STD.textio.all ;
use IEEE.std_logic_textio.all ;


-----------------------------
--   package declaration   --
-----------------------------

package lab7_package is

   --
   -- **IMPORTANT
   --
   -- In this project we use the "tick" generated from our usual "ticker"
   -- as count-enable for the ROM-address counter and read-enable for the ROM.
   -- The frequency of the "tick" determines the frequency of the "reference"
   -- (quantized) sine waveform.
   --
   -- The frequency of the "carrier" (sawtooth-like waveform) is determined 
   -- instead by the threshold width of the PWM counter, which in turn is the
   -- ROM data-width, corresponding to the chosen precision (e.g. 8-bit, 12-bit etc.)
   -- in sampling sine values.
   --
   -- The lowest possible frequency (along with best analog waveform reconstruction)
   -- is obtained by using as ROM read-enable the end-of-count flag from the PWM.
   --


   --------------- + ------------------------------- + --------------- + ------------------------------ +
   --  ROM_WIDTH   |   Tpwm = (2^ROM_WIDTH) x 10ns   |    frequency    |   RC-sizing (assume C= 10nF)   |
   --------------- + ------------------------------- + --------------- + ------------------------------ +
   --    8-bit     |      256 x 10ns =   2.56 us     |   390.0 kHz     |             250  ohm           |
   --   12-bit     |     4096 x 10ns =  40.96 us     |    24.4 kHz     |             3.1 kohm           |
   --   16-bit     |    65536 x 10ns = 655.36 us     |     1.5 kHz     |            65.5 kohm           |
   --------------- + ------------------------------- + --------------- + ------------------------------ +


   ----------- + ------------------------- + ------------------------------ + ---------------- +
   --   MAX    |   Tsample = MAX x 10ns    |   Tsine = 1024 x MAX x 10ns    |    frequency     |
   ----------- + ------------------------- + ------------------------------ + ---------------- +
   --    10    |          100 ns           |            102.4 us            |     9.76 kHz     |
   --    20    |          200 ns           |            204.8 us            |     4.88 kHz     |
   --    50    |          500 ns           |            512.0 us            |     1.95 kHz     |
   --   100    |          1.0 us           |            1.024 ms            |      970  Hz     |
   --   250    |          2.5 us           |            2.560 ms            |      390  Hz     |
   --   500    |          5.0 us           |            5.120 ms            |      195  Hz     |
   --  1000    |         10.0 us           |           10.240 ms            |      97.6 Hz     |
   ----------- + ------------------------- + ------------------------------ + ---------------- +


   constant ROM_WIDTH : positive := 8  ; constant ROM_INIT_FILE  : string := "../../rtl/ROM_8x1024.hex"  ;
   --constant ROM_WIDTH : positive := 12 ; constant ROM_INIT_FILE  : string := "../../rtl/ROM_12x1024.hex"  ;
   --constant ROM_WIDTH : positive := 16 ; constant ROM_INIT_FILE  : string := "../../rtl/ROM_16x1024.hex"  ;

   constant TICKER_MAX : positive := 10 ;


   --
   -- **NOTES
   --
   --   N1. In order to filter out the "carrier", the analog low-pass filter (LPF) must have RC > Tpwm
   --

   ---------------------------------------------------------
   --   ROM sizing, declaration and initialization file   --
   ---------------------------------------------------------


   -- ROM depth and addressing (i.e. number of sine waveform sampled values)
   constant ROM_DEPTH     : positive := 1024 ;
   constant ROM_ADDR_BITS : positive := natural(ceil(log2(real(ROM_DEPTH)))) ;

   -- declare the ROM as a new custom data-type made of an "array" of "std_logic_vector"
   type rom_t is array (0 to ROM_DEPTH-1) of std_logic_vector(ROM_WIDTH-1 downto 0) ;


   -- custom routine to read ROM init values from external ASCII file (function prototype)
   impure function InitRomFromFile (fileName : in string) return rom_t ;

end package lab7_package ;


--------------------------------
--   package implementation   --
--------------------------------

package body lab7_package is

   -- the actual function implementation goes into package body
   impure function InitRomFromFile (fileName : in string) return rom_t is

      file romInitFile : text is in fileName ;

      variable row : line ;               -- file row of data type "line", derived from "string"
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

end package body lab7_package ;

