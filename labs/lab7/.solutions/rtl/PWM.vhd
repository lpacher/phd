--
-- Parameterized Pulse-Width Modulation (PWM) generator in VHDL.
--
-- The simplest way to implement a PWM signal is using a counter
-- and a binary comparator to compare the count value with some
-- programmable threshold value. In the proposed implementation
-- the comparator asserts a logic '1' when the internal free-running
-- count value is lower than the chosen threshold, '0' otherwise.
--
-- Code derived and readapted from https://www.fpga4fun.com
--
-- Luca Pacher - pacher@to.infn.it
-- Fall 2020
--


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

