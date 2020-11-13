--
-- Implement basic logic gates in terms of truth tables using 'when/else' statements
--
-- Luca Pacher - pacher@to.infn.it
-- Fall 2020
--



library ieee ;
use ieee.std_logic_1164.all ;   -- include extended logic values (by default VHDL only provides 0/1 with the 'bit' data type)


-- entity declaration
entity Gates is

   port (
      A : in  std_logic ;
      B : in  std_logic ;
      Z : out std_logic_vector(5 downto 0)   -- note that Z is declared as a 6-bit width output BUS
   ) ;

end entity Gates ;


-- architecture implementation
architecture rtl of Gates is

begin

   -- AND
   Z(0) <= '0' when A = '0' and B = '0' else
           '0' when A = '0' and B = '1' else
           '0' when A = '1' and B = '0' else
           '1' when A = '1' and B = '1' else 
           'X' ;   -- catch-all

   -- NAND
   Z(1) <= '1' when A = '0' and B = '0' else
           '1' when A = '0' and B = '1' else
           '1' when A = '1' and B = '0' else
           '0' when A = '1' and B = '1' else 
           'X' ;   -- catch-all

   -- OR
   Z(2) <= '0' when A = '0' and B = '0' else
           '1' when A = '0' and B = '1' else
           '1' when A = '1' and B = '0' else
           '1' when A = '1' and B = '1' else 
           'X' ;   -- catch-all

   -- NOR
   Z(3) <= '1' when A = '0' and B = '0' else
           '0' when A = '0' and B = '1' else
           '0' when A = '1' and B = '0' else
           '0' when A = '1' and B = '1' else 
           'X' ;   -- catch-all

   -- XOR
   Z(4) <= '0' when A = '0' and B = '0' else
           '1' when A = '0' and B = '1' else
           '1' when A = '1' and B = '0' else
           '0' when A = '1' and B = '1' else 
           'X' ;   -- catch-all

   -- XNOR
   Z(5) <= '1' when A = '0' and B = '0' else
           '0' when A = '0' and B = '1' else
           '0' when A = '1' and B = '0' else
           '1' when A = '1' and B = '1' else 
           'X' ;   -- catch-all

end architecture rtl ;

