library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity led_pattern_state_machine is
	generic (
		system_clk_period : time := 20 ns;
	port (
		clk				: in  std_logic;
		rst				: in  std_logic;
		base_period		: in  unsigned(7 downto 0);
		button_pulse	: in  std_logic;
		switches		: in  std_logic_vector(3 downto 0);
		pattern_gen		: in  std_ulogic_vector(7 downto 0);
		pattern_sel		: out std_logic_vector(2 downto 0)
	);
end entity;

architecture led_pattern_state_machine_arch of led_pattern_state_machine is
	-- State type declaration
	type state_type is (S0, S1, S2, S3, S4, S5);
	signal current_state, next_state : state_type;

	constant sec_count     : natural := 1000000000 ns / system_clk_period;
    signal cycle_count     : natural := 0;


begin
	process(clk, rst)
	begin
		if rst = '1' then
			current_state <= S0;
			timer <= (others => '0');
			display_done <= '0';
		elsif rising_edge(clk) then
			current_state <= next_state;


	-- Process for determining the next state
	process(current_state, button_pulse, switches, display_done)
	begin
		case state is
			when S0 =>
				if button_pulse = '1' then
					next_state <= S5;
				end if;
			when S1 =>
				if button_pulse = '1' then
					next_state <= S5;
				end if;
			when S2 =>
				if button_pulse = '1' then
					next_state <= S5;
				end if;
			when S3 =>
				if button_pulse = '1' then
					next_state <= S5;
				end if;
			when S4 =>
				if button_pulse = '1' then
					next_state <= S5;
				end if;
			when S5 =>
				if button_pulse = '1' then
					next_state <= S5;
				end if;
end architecture;