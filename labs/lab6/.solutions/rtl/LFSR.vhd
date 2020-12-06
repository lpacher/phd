--
-- Simple Pseudo-Random Bit Sequence (PRBS) generator using a Linear Feedback
-- Shift Register (LFSR).
--
-- Code derived and readapted from https://www.fpga4fun.com
--
-- Luca Pacher - pacher@to.infn.it
-- Fall 2020
--

library IEEE ;
use IEEE.std_logic_1164.all ;
use IEEE.numeric_std.all ;              -- to use to_integer() and unsigned() type-casting functions

entity LFSR is

   generic(
      SEED : std_logic_vector(7 downto 0) := x"FF"   -- seed of the pseudo-random bit sequence
   ) ;

   port(
      clk  : in  std_logic ;   -- assume 100 MHz input clock fed to PLL (Clock Wizard)
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

   --TickCounter_inst : TickCounter generic map(MAX => 2) port map(clk => pll_clk, tick => shift_enable) ;   -- BAD eye diagram
   --TickCounter_inst : TickCounter generic map(MAX => 3) port map(clk => pll_clk, tick => shift_enable) ;   -- eye diagram a little bit open
   TickCounter_inst : TickCounter generic map(MAX => 10) port map(clk => pll_clk, tick => shift_enable) ;    -- eye diagram clean


   --------------------------------------------------------------
   --   Linear Feedback Shift Register (LFSR) implementation   --
   --------------------------------------------------------------

   -- choose here the desired feedback combinational logic
   feedback <= SR(7) ;

   -- this modified feedback allows reaching 256 states instead of 255
   --feedback <= SR(7) xor '1' when SR(6 downto 0) = "0000000" else
   --            SR(7) xor '0' ;

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
