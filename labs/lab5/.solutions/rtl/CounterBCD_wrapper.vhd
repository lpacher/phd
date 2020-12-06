--
-- Top-level VHDL "wrapper" for BCD counter design. This "wrapper" is used
-- to instantiate the actual CounterBCD entity and to select which architecture
-- is used for actual synthesis and physical implementation.
--
-- The wrapper also shows how to instantiate and **CONFIGURE** already in the RTL
-- code Xilinx FPGA I/O primitives such as simple OBUF output buffers.
-- This is another example of a **GOOD** FPGA design practice. For complex FPGA
-- digital designs in fact it is always recommended to know how to program/fine-tune
-- the I/O interface with the external PCB (e.g.  set I/O termination for LVDS RX/TX,
-- add pull-up/pull-down for selected signals, program slew rate/drive-strength etc).
-- This can be done by writing a dedicated I/O code that "wraps" the FPGA core logic
-- (similarly to a "padframe" that instantiates I/O cells in digital-on-top ASIC
-- design flows).
--
-- Luca Pacher - pacher@to.infn.it
-- Fall 2020
--
--
-- **NOTES
--
-- N1.
-- Using a VHDL configuration without the component instantiation statement
-- is not supported by Xilinx Vivado. If you have multiple VHDL architectures
-- for a certain digital block the usage of a top-level wrapper including the
-- "component configuration" is therefore mandatory. Ref. also to :
--
--    https://www.xilinx.com/support/answers/67946.html
--
-- N2.
-- By default dut=CounterBCD is assumed in .solutions/Makefile. Please, use
--
--   % make build top=CounterBCD_wrapper
--
-- to synthesize and implement the design. Edit the VHDL "component configuration"
-- statement in this wrapping code to choose which architecture to synthesize.
--


library IEEE ;
use IEEE.std_logic_1164.all ;


entity CounterBCD_wrapper is

   port (
      clk     : in  std_logic ;
      clk_sel : in  std_logic ;   -- for PLL design: 0 = 100 MHz, 1 = 200 MHz
      rst     : in  std_logic ;
      BCD     : out std_logic_vector(3 downto 0)
   ) ;

end entity CounterBCD_wrapper ;


architecture wrapper of CounterBCD_wrapper is

   --------------------------------
   --   components declaration   --
   --------------------------------

   component CounterBCD is
      port(
         clk     : in  std_logic ;
         clk_sel : in  std_logic ;
         rst     : in  std_logic ;
         BCD     : out std_logic_vector(3 downto 0)
      ) ;
   end component ;

   component OBUF is
      generic(
         CAPACITANCE : string  := "DONT_CARE" ;
         DRIVE       : integer := 12 ;
         IOSTANDARD  : string  := "DEFAULT" ;
         SLEW        : string  := "SLOW"
      ) ;
      port(
         I : in  std_logic ;
         O : out std_logic
      ) ;
   end component ;


   --------------------------------------------------------
   --   component configuration (architecture binding)   --
   --------------------------------------------------------

   -- choose here which BCD counter architecture to synthesize :

   for CounterBCD_inst : CounterBCD
      --use entity work.CounterBCD(rtl_simple) ;
      --use entity work.CounterBCD(rtl_bad) ;
      --use entity work.CounterBCD(rtl_ticker) ;
      use entity work.CounterBCD(rtl_PLL) ;


   -- BCD count from core logic fed to pre-placed OBUF output buffers
   signal BCD_int : std_logic_vector(3 downto 0) ;

begin


   ------------------------------------------
   --   BCD counter implementation (RTL)   --
   ------------------------------------------

   CounterBCD_inst : CounterBCD port map(clk => clk, clk_sel => clk_sel, rst => rst, BCD => BCD_int) ;


   --------------------------------------------------------
   --   RTL output buffers with detailed configuration   --
   ---------------------------------------------------------

   --
   -- EXAMPLE
   --
   -- Pre-place and configure Xilinx FPGA output buffer primitives OBUF already in RTL.
   -- SLEW => "SLOW" (default) or "FAST"
   -- DRIVE => 2, 4, 6, 8, 12(default), 16 or 24. Allowed values for LVCMOS33 IOSTANDARD are: 4, 6, 8, 12(default) or 16
   --
   -- Ref. also to Xilinx official documentation :
   --
   --   Vivado Design Suite Properties Reference Guide (UG912)
   --   Vivado Design Suite 7 Series FPGA and Zynq-7000 SoC Libraries Guide (UG953) 
   --

   -- use a "generate" for loop to easily instantiate and CONFIGURE a bank of output buffers
   OutputBuffers : for k in 0 to 3 generate

      OBUF_inst : OBUF generic map(IOSTANDARD => "LVCMOS33", DRIVE => 12, SLEW => "FAST") port map(I=> BCD_int(k), O => BCD(k)) ;

   end generate OutputBuffers ;

end architecture wrapper ;
