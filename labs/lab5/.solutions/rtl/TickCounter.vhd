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
use IEEE.numeric_std.all ;
use IEEE.math_real.all ;        -- math functions e.g. log2() and ceil() 

entity TickCounter is

   generic(
      MAX : positive := 10414   -- default is ~9.6 kHz as for UART baud-rate
   ) ;

   port(
      clk  : in  std_logic ;
      tick : out std_logic
   ) ;

end entity TickCounter ;


architecture rtl of TickCounter is

   -- N-bits counter (automatically determine the actual size of the bus)
   constant NBITS : natural := natural(ceil(log2(real(MAX)))) ;
 
   signal count : unsigned(NBITS-1 downto 0) := (others => '0') ;

begin

   process(clk)

      -- **NOTE: alternatively to an unsigned vector, declare the count as a true "software-like" variable
      --variable count : unsigned(NBITS-1 downto 0) := (others => '0') ;

   begin

      if( rising_edge(clk) ) then

         if( to_integer(count) = MAX-1 ) then
            --count := (others => '0') ;
            count <= (others => '0') ;             -- force the roll-over
            tick <= '1' ;                          -- assert a single-clock pulse each time the counter resets
         else
            --count := count + 1 ;
            count <= count + 1 ;                   -- increment the counter otherwise (note the usage of +1 and NOT +'1')
            tick <= '0' ;
         end if ;
      end if ;
   end process ;

end architecture rtl ;
