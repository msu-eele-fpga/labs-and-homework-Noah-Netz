library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity LED_pattern_gen is
	generic (
		system_clock_period : time := 20 ns
	);
	port (
		clk			: in  std_ulogic;
		rst			: in  std_ulogic;
		base_period	: in  unsigned(7 downto 0);
		pattern_sel	: in  std_ulogic_vector(2 downto 0);
		pattern_gen	: out std_ulogic_vector(7 downto 0)
	);
end entity;

architecture 