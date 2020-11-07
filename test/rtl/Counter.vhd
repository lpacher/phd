--
-- Sample VHDL code for a 5-bit counter with synchronous reset
-- to test Xilinx tools installation. The RTL also contains Xilinx
-- primitives for test purposes.
--
-- Luca Pacher - pacher@to.infn.it
-- Nov 7, 2020



library IEEE ;
use IEEE.std_logic_1164.all ;       -- include extended logic values (by default VHDL only provides 0/1 with the 'bit' data type) 
use IEEE.std_logic_unsigned.all ;   -- to use + operator between std_logic_vector data types


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


   -- component declaration (IBUF is a Xilinx FPGA buffer primitive)

   component IBUF
      port (
         I : in  std_logic ;
         O : out std_logic
      ) ;
   end component ;


   -- internal signals

   signal clk_int : std_logic ;
   signal rst_int : std_logic ;

   signal count_int : std_logic_vector(4 downto 0) ;

begin



   ----------------------------------------------------------------
   --   pre-place BUFFERS on input signals (Xilinx primitives)   --
   ----------------------------------------------------------------


   clk_buffer : IBUF port map ( I => clk, O => clk_int ) ;
   rst_buffer : IBUF port map ( I => rst, O => rst_int ) ;



   -----------------------
   --   5-bit counter   --
   -----------------------

   process(clk)
   begin

      if(clk'event and clk = '1') then    -- alternatively, use the rising_edge(clk) function

         if(rst = '1') then
            count_int <= "00000" ;        -- alternatively, use (others => '0')
         else
            count_int <= count_int + '1' ;
         end if ;

      end if ;
   end process ;


   count <= count_int ;

end architecture rtl ;

