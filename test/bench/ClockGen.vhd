--
-- A very simple clock-generator example in VHDL.
--
-- Luca Pacher - pacher@to.infn,it
-- Nov 7, 2020
--
-- **NOTE: Default clock frequency is 100 MHz (Digilent Arty A7 on-board master clock)
--

-- include extended logic values (by default VHDL only provides 0/1 with the 'bit' data type)
library IEEE ;
use IEEE.std_logic_1164.all ;


entity ClockGen is

   port (

      clk : out std_logic
   ) ;

end entity ClockGen ;


architecture stimulus of ClockGen is


   constant PERIOD : time := 10 ns ;

begin

   process   -- process without sensitivity list
   begin

      clk <= '0' ;
      wait for PERIOD/2 ;   -- simply toggle clk signal every half-period
      clk <= '1' ;
      wait for PERIOD/2 ;

   end process ;

end architecture stimulus ;

