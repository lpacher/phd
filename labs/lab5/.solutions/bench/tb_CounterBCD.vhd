--
-- Example VHDL testbench to simulate 4-bit BCD counter.
--
-- Luca Pacher - pacher@to.infn.it
-- Fall 2020
--

library IEEE ;
use IEEE.std_logic_1164.all ;       -- include extended logic values (by default VHDL only provides 0/1 with the 'bit' data type)

library std ;
use std.env.all ;                   -- the VHDL2008 revision provides stop/finish functions similar to Verilog to end the simulation

library work ;
use work.all ;


entity tb_CounterBCD is             -- empty entity declaration for a testbench
end entity tb_CounterBCD ;


architecture testbench of tb_CounterBCD is

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

   -- on-board 100 MHz clock
   signal clk_board : std_logic ;

   -- MUX control to switch between 100 MHz and 200 MHz PLL output clock
   signal clk_sel : std_logic := '0' ;   -- default: 100 MHz

   -- reset signal (e.g. mapped to a push-button or slide-switch)
   signal reset : std_logic ;

   -- BCD count (e.g. mapped to some LEDs)
   signal BCD : std_logic_vector(3 downto 0) ;


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

   ---------------------------------
   --   100 MHz clock generator   --
   ---------------------------------

   ClockGen_inst : ClockGen port map(clk => clk_board) ;


   ---------------------------------
   --   device under test (DUT)   --
   ---------------------------------

   DUT : CounterBCD port map (clk => clk_board, clk_sel => clk_sel, rst => reset, BCD => BCD) ;


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

end architecture testbench ;
