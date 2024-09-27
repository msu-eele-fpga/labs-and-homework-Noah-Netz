library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity led_pattern_state_machine is
port (
	clk			: in  std_logic;
	rst			: in  std_logic;
	sync		: in  std_logic;
	switches	: in  std_logic_vector(3 downto 0);
	pattern_sel : out std_logic_vector(2 downto 0)
);
end entity;

architecture led_pattern_state_machine_arch of led_pattern_state_machine is

end architecture;