--
-- VHDL description of a simple 4-bit Binary-Coded Decimal (BCD) counter
-- using different cosing styles.
-- Different architectures are used, one for each proposed implementation.
-- The actual architecture to be simulated is then selected using a 'configuration'
-- statement in the testbench..
--
-- Luca Pacher - pacher@to.infn.it
-- Fall 2020
--

library IEEE ;
use IEEE.std_logic_1164.all ;
use IEEE.numeric_std.all ;

--use IEEE.std_logic_arith.all ;     **DEPRECATED**
--use IEEE.std_logic_signed.all ;    **DEPRECATED**
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


library UNISIM ;
use UNISIM.vcomponents.all ;   -- external library required to simulate Xilinx FPGA primitives


entity CounterBCD is

   port (
      clk     : in  std_logic ;
      clk_sel : in  std_logic ;   -- for PLL design: 0 = 100 MHz, 1 = 200 MHz
      rst     : in  std_logic ;
      BCD     : out std_logic_vector(3 downto 0)
   ) ;

end entity CounterBCD ;


--
-- Architecture #1
--
-- Simple example of BCD counter implementation
--

architecture rtl_simple of CounterBCD is

   -- 4-bit "internal" BCD counter declared as a "VHDL unsigned" to work with IEEE.numeric_std

   signal count : unsigned(3 downto 0) ;                -- uninitialized count value
   --signal count : unsigned(3 downto 0) := "0000" ;    -- initialized count value (you can also use (others => '0') which is smarter)


begin

   ------------------------------------
   --   BCD counter (VHDL process)   --
   ------------------------------------

   process(clk)
   begin

      if( rising_edge(clk) ) then

         if( rst = '1' ) then                    -- **SYNCHRONOUS** reset
            count <= "0000" ;

         --elsif( to_integer(count) = 9 ) then   -- **NOTE: if you want to use 9 you MUST convert count to integer type !
         elsif( count = "1001" ) then 
            count <= "0000" ;                    -- force the roll-over when the count reaches 9

         else
            count <= count + 1 ;                 -- **NOTE: be aware of the usage of + 1 and not + '1'

         end if ;

      --else ? Keep memory ! Same as else count <= count ; endif ;
      end if ;

   end process ;


   --
   -- EXERCISE: implement the same counter but with ASYNCHRONOUS reset
   --
   --process(clk,rst)
   --begin
   --
   --   if( rst = '1' ) then
   --      count <= (others => '0') ;
   --
   --   elsif( rising_edge(clk) ) then
   --
   --      if( count = "1001" ) then 
   --         count <= (others => '0') ;
   --      else
   --         count <= count + 1 ;
   --      end if ;
   --   end if ;
   --
   --end process ;
   --


   -- type casting
   BCD <= std_logic_vector(count) ;   -- convert "unsigned" to "std_logic_vector" using the "std_logic_vector()" function from IEEE.numeric_std

   -- **NOTE: due to VHDL strong data typing this gives a **COMPILATION ERROR** instead :
   -- BCD <= count ;

end architecture rtl_simple ;


--
-- Architecture #2
--
-- Example of a **BAD** RTL design approach. In this case we suppose
-- to slow-down the default clock (e.g. 100 MHz) used by the BCD
-- counter in order to count at a lower frequency (e.g. 25 MHz).
-- The BAD approach here is to generate a dedicated lower-frequency
-- clock using an auxiliary counter or a simple clock divider.
--
-- On the contrary a **GOOD** synchronous digital design always uses
-- THE SAME CLOCK everywhere in the logic in order to easier digital
-- implementation tools to achieve timing closure.
--
-- Of course complex digital designs can have several different
-- "clock-domains", but then proper synchronization is required
-- between blocks running at different clock frequencies to avoid
-- timing violations due to Clock Domain Crossing (CDC).
--

architecture rtl_bad of CounterBCD is

   -- 4-bit "internal" counter
   signal count : unsigned(3 downto 0) ;

   -- auxiliary 5-bit free-running counter for clock division
   signal count_free : unsigned(5 downto 0) := (others => '0') ;

   -- divided clock e.g. 100 MHz => 50 MHz
   signal clk_div : std_logic := '0' ;


begin

   --------------------------------------------------------
   --   EXAMPLE: a simple clock divider (VHDL process)   --
   --------------------------------------------------------

   --process(clk)
   --begin
   --   if( rising_edge(clk) ) then
   --      clk_div <= not clk_div ;     -- clk_div = clk/2
   --   end if ;
   --end process ;


   ------------------------------------------------------------------------------------
   --   EXAMPLE: clock divider using auxiliary free-running counter (VHDL process)   --
   ------------------------------------------------------------------------------------

   process(clk)
   begin
      if( rising_edge(clk) ) then
         count_free <= count_free + 1 ;
      end if ;
   end process ;


   -- choose below the desired divided clock fed to the BCD counter

   --clk_div <= clk ;                           -- clk
   --clk_div <= count_free(0) ;                 -- clk/2    e.g. 100 MHz/2 = 50   MHz
   --clk_div <= count_free(1) ;                 -- clk/4    e.g. 100 MHz/4 = 25   MHz
   --clk_div <= count_free(2) ;                 -- clk/8    e.g. 100 MHz/8 = 12.5 MHz
   --clk_div <= count_free(3) ;                 -- clk/16   etc.
   --clk_div <= count_free(4) ;                 -- clk/32
   clk_div <= count_free(5) ;                   -- clk/64


   ------------------------------------
   --   BCD counter (VHDL process)   --
   ------------------------------------

   process(clk_div)   -- this is a **BAD** RTL coding example, synchronous processes doesn't work with the same clock !
   begin

      if( rising_edge(clk_div) ) then

         if( rst = '1' ) then
            count <= (others => '0') ;

         elsif( to_integer(count) = 9 ) then   -- instead of count = "1001" we can use to_integer(count) = 9
            count <= (others => '0') ;

         else
            count <= count + 1 ;

         end if ;
      end if ;

   end process ;

   -- type casting
   BCD <= std_logic_vector(count) ;

end architecture rtl_bad ;



--
-- Architecture #3
--
-- Example of a **GOOD** RTL coding style for pure synchronous digital designs.
-- In this case we use a "ticker" module implemented using an additional
-- "modulus-N free-running counter" to generate a single clock-pulse "tick"
-- (e.g. every 1 us) to be used as count-enable for the main BCD counter.
--
-- This is the ***RECOMMENDED** approach whenever you need to "slow down" the speed
-- of the data processing in your design.
-- On the contrary, try to **AVOID** to generate "custom" additional clocks by means
-- of counters, clock-dividers or even a dedicated clock manager. Generate a single
-- clock-pulse "tick" to be used as "enable" for the data processing in your synchronous
-- logic instead.
--

architecture rtl_ticker of CounterBCD is

   component TickCounter is
      generic(
         MAX : positive := 10414   -- default is ~9.6 kHz as for UART baud-rate
      ) ;
      port(
         clk  : in  std_logic ;
         tick : out std_logic
      ) ;
   end component ;

   -- single clock-pulse from "ticker" used as count-enable for the BCD counter
   signal count_en : std_logic ;

   -- 4-bit "internal" BCD counter
   signal count : unsigned(3 downto 0) := (others => '0') ;


begin


   ------------------------
   --   "tick" counter   --
   ------------------------

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

   --TickCounter_inst : TickCounter generic map(MAX => 10) port map(clk => clk, tick => count_en) ;       -- OK for simulations
   TickCounter_inst : TickCounter generic map(MAX => 50000000) port map(clk => clk, tick => count_en) ;   -- OK for LED mapping


   ------------------------------------------------------
   --   BCD counter with count-enable (VHDL process)   --
   ------------------------------------------------------

   process(clk)   -- this is a **GOOD** RTL coding example, EVERYTHING is now running at the same clock !
   begin

      if( rising_edge(clk) ) then

         if( rst = '1' ) then
            count <= (others => '0') ;

         elsif( count_en = '1' ) then

            if( to_integer(count) = 9 ) then
               count <= (others => '0') ;

            else
               count <= count + 1 ;

            end if ;
         end if ;
      end if ;

   end process ;

   -- type casting
   BCD <= std_logic_vector(count) ;

end architecture rtl_ticker ;


--
-- Architecture #4
--
-- A more complete example of a **GOOD** RTL coding style for pure synchronous FPGA designs.
-- In particular in this architecture implementation we use :
--
--    1. a dedicated PLL-based "clock-management" IP core (Clock  Wizard) compiled
--       from the Xilinx Vivado IP Catalog
--
--    2. the "tick" counter to "slow-down" the speed of the data processing without
--       creating "custom" divided clock signals
--
--    3. output buffers primitives OBUF with programmed slew-rate and drive-strength
--
-- **IMPORTANT
--
-- Despite in this case we don't need to "multiply" nor to "divide" the external clock,
-- we use a dedicated PLL-based clock management IP core anyway.
--
-- This is the **RECOMMENDED** approach for any FPGA project, even better if you compile
-- the Mixed-Mode Clock Management (MMCM) version of the IP core which is a super-set
-- of the PLL. The main reason for this is that by using a dedicated clock-management
-- block you can fine-tune the clock fed to FPGA internals (e.g. jitter filtering, phase
-- adjustement, fine-delay adjustement etc.) 
--

architecture rtl_PLL of CounterBCD is


   --------------------------------
   --   components declaration   --
   --------------------------------

   component PLL is
     port (
        CLK_IN      : in  std_logic ;
        CLK_OUT_100 : out std_logic ;
        CLK_OUT_200 : out std_logic ;
        LOCKED      : out std_logic
     ) ;
   end component PLL ;


   component TickCounter is
      generic(
         MAX : positive := 10414   -- default is ~9.6 kHz as for UART baud-rate
      ) ;
      port(
         clk  : in  std_logic ;
         tick : out std_logic
      ) ;
   end component ;


   --------------------------------------
   --   internal signals declaration   --
   --------------------------------------

   -- PLL signals
   signal pll_clk_100, pll_clk_200, pll_clk, pll_locked : std_logic ;

   -- single clock-pulse from "ticker" used as count-enable for the BCD counter
   signal count_en : std_logic ;

   -- 4-bit "internal" BCD counter
   signal count : unsigned(3 downto 0) := (others => '0') ;


begin


   ------------------------------------
   --   PLL IP core (Clock Wizard)   --
   ------------------------------------

   -- the PLL generates two output clock signals, 100 MHz and 200 MHz frequency
   PLL_inst : PLL port map(CLK_IN => clk, CLK_OUT_100 => pll_clk_100, CLK_OUT_200 => pll_clk_200, LOCKED => pll_locked) ;


   -- MUX to switch between 100 MHz and 200 MHz
   pll_clk <= pll_clk_100 when clk_sel = '0' else pll_clk_200 ;


   ------------------------
   --   "tick" counter   --
   ------------------------

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

   TickCounter_inst : TickCounter generic map(MAX => 100) port map(clk => pll_clk, tick => count_en) ;          -- OK for simulations
   --TickCounter_inst : TickCounter generic map(MAX => 150000000) port map(clk => pll_clk, tick => count_en) ;  -- OK for LED mapping


   ------------------------------------------------------
   --   BCD counter with count-enable (VHDL process)   --
   ------------------------------------------------------

   process(pll_clk)
   begin

      if( rising_edge(pll_clk) ) then

         if( (rst = '1') or (pll_locked = '0') ) then   -- **NOTE: we also use the "locked" signal from the PLL as reset !
            count <= (others => '0') ;

         elsif( count_en = '1' ) then

            if( to_integer(count) = 9 ) then
               count <= (others => '0') ;

            else
               count <= count + 1 ;

            end if ;
         end if ;
      end if ;

   end process ;

   -- type casting
   BCD <= std_logic_vector(count) ;

end architecture rtl_PLL ;
