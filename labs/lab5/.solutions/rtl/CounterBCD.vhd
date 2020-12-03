--
-- Example 4-bit Binary-Coded Decimal (BCD) counter in VHDL.
--
-- Luca Pacher - pacher@to.infn.it
-- Fall 2020
--

library IEEE ;
use IEEE.std_logic_1164.all ;
use IEEE.numeric_std.all ;

--use IEEE.std_logic_arith.all ;
--use IEEE.std_logic_unsigned.all ;
--use IEEE.std_logic_unsigned.all ;  **DEPRECATED** (see below)

--
-- **IMPORTANT !
--
-- By default VHDL provides the + (plus) operator to perform basic additions between
-- software-like NUMBERS (e.g. 32-bit "integer" data type, but also "natutal"
-- or "positive", as well as "real" numbers).
-- Due to VHDL strong data typing the usage of + between "hardware signals" (buses)
-- requires the OVERLOADING of the + operator.
--
-- As an example, a very simple
--
--    count <= count + 1 ;
--
-- is NOT allowed in VHDL if count has been declared as std_logic_vector.
--
-- In order to perform + between "hardware signals", the "legacy" VHDL introduced
-- new "vector" data types called "std_logic_signed" and "std_logic_usigned" that
-- are defined as part of IEEE.std_logic_unsigned and IEEE.std_logic_unsigned packages.
--
-- By including these packages in the preable of the VHDL code one can declare counters
-- as std_logic_vector and the following syntax (note the usage of single quotes)
--
--    count <= count + '1' ;
--
-- properly compiles. HOWEVER, in practice the usage of these packages has been
-- de facto **DEPRACTED** for the following reasons :
--
--   1. despite the library name "IEEE" these packages are **NOT** provided
--      by IEEE, but are Synopsys proprietary !
--
--   2. despite the string "std" in (Synopsys) package names they are **NOT**
--      IEEE standard at all !
--
-- This is the reason for which the **RECOMMENDED** package to be used when dealing
-- with counters is IEEE.numeric_std that introduces new VHDL data types SIGNED and
-- UNSIGNED along with IEEE-standard definitions to overload fudamental arithmetic
-- operators such as + and - that are extensively used to generate real hardware.
--

entity CounterBCD is

   port (
      clk : in  std_logic ;
      rst : in  std_logic ;
      BCD : out std_logic_vector(3 downto 0)
   ) ;

end entity CounterBCD ;


--
-- Architecture #1
--
-- Simple example of BCD counter implementation
--

architecture rtl_simple of CounterBCD is

   -- 4-bit "internal" counter declared as a "VHDL unsigned" to work with IEEE.numeric_std
   signal count : unsigned(3 downto 0) ;                -- uninitialized count value
   --signal count : unsigned(3 downto 0) := "0000" ;    -- initialized count value (you can lso use (others => '0') which is smarter)

begin

   process(clk)
   begin

      if( rising_edge(clk) ) then

         if( rst = '1' ) then    -- **SYNCHRONOUS** reset
            count <= "0000" ;
         elsif( count = "1001" ) then
            count <= "0000" ;
         else
            count <= count + 1 ;
         end if ;

------else
------   count <= count ;   -- keep memory otherwise
      end if ;

   end process ;

   -- type casting
   BCD <= std_logic_vector(count) ;   -- convert unsigned to std_logic using the std_logic_vector() function from IEEE.numeric_std

   -- **NOTE: due to VHDL strong typing this gives a **COMPILATION ERROR** instead :
   -- BCD <= count ;

end architecture rtl_simple ;



architecture rtl_PLL of CounterBCD is


   --------------------------------
   --   components declaration   --
   --------------------------------

   component PLL is
     port (
        ClkIn  : in  std_logic ;
        ClkOut : out std_logic ;
        Locked : out std_logic
     ) ;

   end component PLL ;


   --------------------------------------
   --   internal signals declaration   --
   --------------------------------------

   -- PLL signals
   signal pll_clk, pll_locked : std_logic ;

   -- 4-bit "internal" counter declared as a "VHDL unsigned" to work with IEEE.numeric_std
   signal count : unsigned(3 downto 0) ;                -- uninitialized count value
   --signal count : unsigned(3 downto 0) := "0000" ;    -- initialized count value (you can lso use (others => '0') which is smarter)


begin

   -------------------------------
   --   PLL (Clock Wizard IP)   --
   -------------------------------

   PLL_inst : PLL port map(ClkIn => clk, ClkOut => pll_clk, Locked => pll_locked) ;


   ------------------------------------
   --   BCD counter (VHDL process)   --
   ------------------------------------

   process(pll_clk)
   begin

      if( rising_edge(pll_clk) ) then

         if( (rst = '1') or (pll_locked = '0') ) then    -- **SYNCHRONOUS** reset
            count <= "0000" ;
         elsif( count = "1001" ) then
            count <= "0000" ;
         else
            count <= count + 1 ;
         end if ;

------else
------   count <= count ;   -- keep memory otherwise
      end if ;

   end process ;

   -- type casting
   BCD <= std_logic_vector(count) ;   -- convert unsigned to std_logic using the std_logic_vector() function from IEEE.numeric_std

   -- **NOTE: due to VHDL strong typing this gives a **COMPILATION ERROR** instead :
   -- BCD <= count ;

end architecture rtl_PLL ;
