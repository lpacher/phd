--
-- VHDL testbench to simulate Pseudo-Random Bit Sequence (PRBS) generator
-- using a Linear Feedback Shift Register (LFSR).
--
-- Luca Pacher - pacher@to.infn.it
-- Fall 2020
--
--
-- **IMPORTANT
--
-- In order to work with I/O files in VHDL we need dedicated packages.
-- One possibility is tu use the STD.textio package that allows the usage
-- of keywords such as :
--
-- file_open, file_close, read, readline, write, writeline, flush, endfile, etc.
--
-- One issue to be aware of is that STD.textio.all only allows for reading and
-- writing values of type :
--
--    bit, bit_vector, boolean, character, integer, real, string, and time.
--
-- This package file does not allow for reading/writing IEEE std_logic and
-- std_logic_vector types to a file. To allow for this, include the package
-- IEEE.std_logic_textio instead.
--

library IEEE ;
use IEEE.std_logic_1164.all ;       -- include extended logic values (by default VHDL only provides 0/1 with the 'bit' data type)
use IEEE.numeric_std.all ;
use IEEE.std_logic_textio.all ;

library STD ;
use STD.env.all ;                   -- the VHDL-2008 revision provides stop/finish functions similar to Verilog to end the simulation
use STD.textio.all ;

library work ;
use work.all ;


entity tb_LFSR is             -- empty entity declaration for a testbench
end entity tb_LFSR ;


architecture testbench of tb_LFSR is

   --------------------------------
   --   components declaration   --
   --------------------------------

   component ClockGen
      generic (
         PERIOD : time := 10 ns
      ) ;
      port (
         clk : out std_logic
      ) ;
   end component ;


   component LFSR is
      generic(
         SEED : std_logic_vector(7 downto 0) := x"FF"   -- seed of the pseudo-random bit sequence
      ) ;
      port (
         clk  : in  std_logic ;   -- assume 100 MHz input clock fed to "ticker"
         PRBS : out std_logic     -- output pseudo-random bit sequence
      ) ;
   end component ;


   ---------------------------------------------------
   --   testbench parameters and internal signals   --
   ---------------------------------------------------

   -- on-board 100 MHz clock
   signal clk_board : std_logic ;

   -- pseudo-random bit sequence from DUT
   signal PRBS : std_logic ;

   --
   -- **IMPORTANT
   --
   -- VHDL-87 and VHDL-93 do not support "hierarchical probing" of internal signals as Verilog.
   -- This feature is introduced only with VHDL-2008 (and you MUST compile with xvhdl --2008)
   --
   alias trigger is <<signal DUT.shift_enable : std_logic>> ;
   alias rndm    is <<signal DUT.rndm : integer>> ;

   -- output file to dump LFSR pseudo-random output logic values as "integer" values
   file fout : text ;


begin


   ---------------------------------
   --   100 MHz clock generator   --
   ---------------------------------

   ClockGen_inst : ClockGen port map(clk => clk_board) ;


   ---------------------------------
   --   device under test (DUT)   --
   ---------------------------------

   DUT : LFSR generic map(SEED => x"FF") port map (clk => clk_board, PRBS => PRBS) ;

   -- **QUESTION: what happens if as SEED we choose x"00" instead ?
   --DUT : LFSR generic map(SEED => x"00") port map (clk => clk_board, PRBS => PRBS) ;


   -----------------------
   --   main stimulus   --
   -----------------------

   stimulus : process
   begin

      file_open(fout, "bytes.txt", write_mode) ;   -- open the file handler

      wait for (8*100*1000)*1ns ;   -- simply run for some time and observe the pseudo-random output bit pattern

      file_close(fout) ;   -- close the file handler
      finish ;             -- stop the simulation (this is a VHDL-2008 only feature)

      --
      -- **IMPORTANT
      --
      -- VHDL-87/VHDL-93 standards does not provide a routine to easily stop the simulation !
      -- You must use a failing "assertion" for this purpose :
      --
      --assert FALSE report "Simulation Finished" severity FAILURE ;

   end process ;


   ----------------------
   --   file monitor   --
   ----------------------

   -- register pseudo-random bit values to ASCII file
   -- whenever a "tick" is asserted inside the LFSR

   process(trigger)

      -- **NOTE: alternatively you can also declare the file-handler inside the process
      --file fout : text open write_mode is "bytes.txt" ;

      variable row : line ;   -- file row of data type "line", derived from "string"

   begin

      if( rising_edge(trigger) ) then  

         write(row, rndm) ;      -- as a first step you must build the "line" that you want to write to the file ...
         writeline(fout,row) ;   -- and then write the string to file ! This is VHDL ...

      end if ;
   end process ;

end architecture testbench ;
