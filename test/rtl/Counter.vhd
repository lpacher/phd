--
-- Sample VHDL code for a 5-bit counter with synchronous reset
-- to test Xilinx tools installation. The RTL also contains Xilinx
-- primitives for test purposes.
--
-- Luca Pacher - pacher@to.infn.it
-- Nov 7, 2020



library IEEE ;
use IEEE.std_logic_1164.all ;       -- include extended logic values (by default VHDL only provides 0/1 with the 'bit' data type) 
use IEEE.numeric_std.all ;          -- to use + operator between "unsigned" data types

library UNISIM ;
use UNISIM.vcomponents.all ;   -- to simulate RTL including Xilinx primitives


entity Counter is

   port (
      clk   : in  std_logic ;                    -- input clock
      rst   : in  std_logic ;                    -- synchronous, active-high reset
      count : out std_logic_vector(4 downto 0)   -- 5-bit output count 
   ) ;

end entity Counter ;



architecture rtl of Counter is

   --------------------------------
   --   components declaration   --
   --------------------------------

   component PLL is
      port(
         CLK_IN  : in  std_logic ;   -- 100 MHz input clock (from external XTAL oscillator)
         CLK_OUT : out std_logic ;   -- 100 MHz PLL output clock with jiiter filtering
         LOCKED  : out std_logic
      ) ;
   end component ;

   component IBUF
      port (
         I : in  std_logic ;
         O : out std_logic
      ) ;
   end component ;


   --------------------------
   --   internal signals   --
   --------------------------

   -- PLL signals
   signal pll_clk    : std_logic ;
   signal pll_locked : std_logic ; 

   -- buffered signals
   signal clk_int : std_logic ;
   signal rst_int : std_logic ;

   -- internal count
   signal count_int : unsigned(4 downto 0) ;

begin

   ----------------------------------------------------------------
   --   pre-place BUFFERS on input signals (Xilinx primitives)   --
   ----------------------------------------------------------------


   clk_buffer : IBUF port map ( I => clk, O => clk_int ) ;
   rst_buffer : IBUF port map ( I => rst, O => rst_int ) ;


   ----------------------------
   --   PLL (Clock Wizard)   --
   ----------------------------

   PLL_inst : PLL port map(CLK_IN => clk_int, CLK_OUT => pll_clk, LOCKED => pll_locked) ;


   -----------------------
   --   5-bit counter   --
   -----------------------

   process(pll_clk)
   begin

      if( rising_edge(pll_clk) ) then    -- alternatively, use the "old style" syntax pll_clk'event and pll_clk = '1'

         if( (rst = '1') or (pll_locked = '0') ) then
            count_int <= "00000" ;        -- alternatively, use (others => '0')
         else
            count_int <= count_int + 1 ;
         end if ;

      end if ;
   end process ;

   -- type casting
   count <= std_logic_vector(count_int) ;

end architecture rtl ;
