--
-- Parameterized modulus-MAX 32-bit tick generator. Use the resulting "tick"
-- single clock-pulse as "enable" for your synchronous logic if you need to
-- decrease the speed of the data processing without the need of a dedicated
-- extra clock signal.
--
-- Luca Pacher - pacher@to.infn.it
-- Fall 2020
--


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



library IEEE ;
use IEEE.std_logic_1164.all ;
use IEEE.std_logic_unsigned.all ;   -- to use + operator between std_logic_vector data types
use IEEE.numeric_std.all ;

entity TickCounter is

   generic(
      MAX : integer := 10414   -- default is ~9.6 kHz as for UART baud-rate
   ) ;

   port(
      clk  : in  std_logic ;
      tick : out std_logic
   ) ;

end entity TickCounter ;




architecture rtl of TickCounter is


begin

   process(clk)

      variable count : integer ;

   begin

      if( rising_edge(clk) ) then

         if( count = MAX-1) then
            count := 0 ;                  -- force the roll-over
            tick <= '1' ;                 -- assert a single-clock pulse each time the counter resets
         else
            count := count + 1 ;          -- increment the counter otherwise
            tick <= '0' ;
         end if ;
      end if ;
   end process ;

end architecture rtl ;

