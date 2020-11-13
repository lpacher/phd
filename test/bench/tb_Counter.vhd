--
-- Testbench for Counter module.
--
-- Luca Pacher - pacher@to.infn,it
-- Fall 2020
--


-- include extended logic values (by default VHDL only provides 0/1 with the 'bit' data type)
library IEEE ;
use IEEE.std_logic_1164.all ;


library std ;
use std.env.all ;   -- VHDL-2008 revision provides a stop function to stop simulations ! Compile with --2008 switch

entity tb_Counter is   -- empty entity declaration for a testbench
end entity ;


architecture testbench of tb_Counter is


   --------------------------------
   --   components declaration   --
   --------------------------------

   component ClockGen
      port (
         clk : out std_logic
      ) ;
   end component ;


   component Counter
      port (
         clk   : in  std_logic ;
         rst   : in  std_logic ;
         count : out std_logic_vector(4 downto 0)
      ) ;
   end component ;


   --------------------------
   --   internal signals   --
   --------------------------

   signal clock : std_logic ;
   signal reset : std_logic ;

   signal count : std_logic_vector(4 downto 0) ;

begin


   -------------------------
   --   clock generator   --
   -------------------------

   ClockGen_inst : ClockGen port map ( clk => clock ) ;



   ---------------------------------
   --   device under test (DUT)   --
   ---------------------------------

   DUT : Counter port map ( clk => clock, rst => reset, count => count ) ;



   -----------------------
   --   main stimulus   --
   -----------------------

   stimulus : process
   begin

      wait for 502 ns ; reset <= '1' ;   -- assert the reset (active-high)
      wait for 360 ns ; reset <= '0' ;   -- release the reset

      wait for 3000 ns ;            -- run the counter for 3us

      --assert FALSE report "Simulation Finished" severity FAILURE ;   -- finish the simulation

      finish ;   -- VHDL-2008 provides stop/finish procedures similar to Verilog

   end process stimulus ;

end architecture testbench ;

