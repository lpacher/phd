--
-- Example sine-wave generator using Read-Only Memory (ROM) and
-- Pulse-Width Modulation (PWM). This is a very simple example
-- of Direct Digital Synhesis (DDS) technique.
--
-- With this approach a finite number (e.g. 1024) of sampled sine
-- values are stored into a ROM in form of a Look-Up Table (LUT).
-- Thus each memory slot of the ROM contains a sine value with
-- a certain precision (e.g. 8-bit, 12-bit, 16-bit etc.) and with
-- some representation (usually unsigned integer, but can be also
-- interpreted as fixed-point real numbers).
-- ROM sine values are then fed as input threshold values for a PWM
-- counter. The resulting variable duty-cycle PWM encodes sine values
-- variations and can be used as input signal for a low-pass filter
-- (LPF) for analog waveform reconstruction (can be also as simple as
--  a low-pass RC filter followed by a voltage buffer).
--
-- This is the "digital" equivalent of feeding to an analog comparator
-- (e.g. an OPAMP working in open-loop configuration) a lower-frequency
-- "reference" sine wave and a higher-frequency "carrier" sowtooth
-- wave.
--
--
-- Luca Pacher - pacher@to.infn.it
-- Fall 2020
--


library IEEE ;
use IEEE.std_logic_1164.all ;
use IEEE.numeric_std.all ;


-- external custom VHDL package with ROM sizing and initialization stuffs
library work ;
use work.lab7_package.all ;   -- ROM_WIDTH and ROM_ADDR_BITS used in this code are defined in this custom package


entity SineGen is

   port(
      clk     : in  std_logic ;   -- assume 100 MHz on-board clock
      pwm_out : out std_logic     -- feed this variable-width digital toggle to an RC low-pass filter for analog waveform reconstruction
   ) ;

end entity SineGen ;


architecture rtl of SineGen is


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


   component ROM is
      port(
         clk  : in  std_logic ;
         ren  : in  std_logic ;
         addr : in  std_logic_vector(ROM_ADDR_BITS-1 downto 0) ;
         dout : out std_logic_vector(ROM_WIDTH-1 downto 0)
      ) ;
   end component ;


   component TickCounter is
      generic(
         MAX : positive := 10414
      ) ;
      port(
         clk  : in  std_logic ;
         tick : out std_logic
      ) ;
   end component ;


   component PWM is
      generic(
         THRESHOLD_NBITS : positive := 8
      ) ;
      port(
         clk       : in  std_logic ;
         rst       : in  std_logic ;
         threshold : in  std_logic_vector(THRESHOLD_NBITS-1 downto 0) ;
         pwm_out   : out std_logic ;
         pwm_eoc   : out std_logic
      ) ;
   end component PWM ;


   --------------------------------------
   --   internal signals declaration   --
   --------------------------------------

   -- PLL signals
   signal pll_clk, pll_locked, pll_locked_n : std_logic ;


   -- ROM signals (read-enable, address and ROM data)
   signal rom_ren  : std_logic ;
   signal rom_addr : unsigned(ROM_ADDR_BITS-1 downto 0) := (others => '0') ;
   signal rom_data : std_logic_vector(ROM_WIDTH-1 downto 0) ;


begin


   ----------------------------
   --   PLL (Clock Wizard)   --
   ----------------------------

   PLL_inst : PLL

      port map(
         CLK_IN  => clk,         -- assume 100 MHz input-clock from external XTAL oscillator
         CLK_OUT => pll_clk,     -- 100 MHz PLL output clock
         LOCKED  => pll_locked
      ) ;


   ----------------------
   --   tick counter   --
   ----------------------

   --
   -- **IMPORTANT
   --
   -- In this project we use the "tick" generated from our usual "ticker"
   -- as count-enable for the ROM-address generator as well as read-enable
   -- to read sine values from the ROM.
   -- The frequency of the "tick" determines the lower-frequency "reference"
   -- (quantized) waveform (in this case the sine waveform).
   -- The frequency of the "carrier" (sawtooth-like waveform) is determined 
   -- instead by the width of the PWM counter, which in turn is the ROM data-width,
   -- corresponding to the chosen precision in sampling sine values.
   -- The lowest possible frequency (along with best analog waveform reconstruction)
   -- is obtained by using as ROM read-enable the end-of-count flag from the PWM.
   --
   -- Edit the TICKER_MAX value defined in the custom lab7_package external package
   -- to tune simulation and implementation results.
   --

   TickCounter_inst : TickCounter generic map(MAX => TICKER_MAX) port map(clk=> pll_clk, tick => rom_ren) ;


   -----------------------------
   --   sine wave LUT (ROM)   --
   -----------------------------

   ROM_inst : ROM

      port map(
         clk  => pll_clk,
         ren  => rom_ren,
         addr => std_logic_vector(rom_addr),
         dout => rom_data
      ) ;


   -------------------------------
   --   ROM address generator   --
   -------------------------------

   process(pll_clk)
   begin

      if ( pll_locked = '0' ) then    -- **NOTE: wait for PLL to lock !

         rom_addr <= (others => '0') ;

      elsif( rising_edge(pll_clk) ) then

         if( rom_ren = '1' ) then

               rom_addr <= rom_addr + 1 ;   -- get new sine value from ROM and feed it as threshold value for the PWM counter

         end if ;
      end if ;
   end process ;


   -------------------------------------
   --   Pulse-Width Modulator (PWM)   --
   -------------------------------------

   pll_locked_n <= not pll_locked ; 

   PWM_inst : PWM generic map(THRESHOLD_NBITS => ROM_WIDTH)
      port map(
         clk       => pll_clk,
         rst       => pll_locked_n,
         threshold => rom_data,
         --pwm_eoc => rom_ren,            -- MINIMUM FREQUENCY !
         pwm_eoc   => open,
         pwm_out   => pwm_out
      ) ;

end architecture rtl ;

