--
-- VHDL testbench for the sine-wave generator using Read-Only Memory (ROM)
-- and Pulse-Width Modulation (PWM) design.
--
-- Edit constant values defined in the lab7_package to play with the "carrier"
-- and "reference" signals frequencies.
--
-- Luca Pacher - pacher@to.infn.it
-- Fall 2020
--


library IEEE ;
use IEEE.std_logic_1164.all ;
use IEEE.std_logic_unsigned.all ;

library STD ;
use STD.env.all ;


entity tb_SineGen is
end entity tb_SineGen ;


architecture testbench of tb_SineGen is

   --------------------------------
   --   components declaration   --
   --------------------------------

   component ClockGen is
      generic (
         PERIOD : time := 10 ns
      ) ;
      port (
         clk : out std_logic
      ) ;
   end component ;


   component SineGen is
      port(
         clk     : in  std_logic ;
         pwm_out : out std_logic
      ) ;
   end component ;


   ------------------------------------
   --   testbench internal signals   --
   ------------------------------------

   signal clk_board, pwm_out : std_logic ;


begin

   ---------------------------------
   --   100 MHz clock generator   --
   ---------------------------------

   ClockGen_inst : ClockGen port map(clk => clk_board) ;


   -------------------------------
   -- device under test (DUT)   --
   -------------------------------

   DUT : SineGen port map(clk => clk_board, pwm_out => pwm_out) ; 


   -----------------------
   --   main stimulus   --
   -----------------------

   stimulus : process
   begin

      wait for 1ms ; finish ;   -- simply run for some time and observe DUT internal signals
 
   end process ;

end architecture testbench ;

