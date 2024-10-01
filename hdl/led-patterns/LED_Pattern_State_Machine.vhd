library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity led_pattern_state_machine is
port (
	clk				: in  std_logic;
	rst				: in  std_logic;
	button_pulse	: in  std_logic;
	switches		: in  std_logic_vector(3 downto 0);
	pattern_sel		: out std_logic_vector(2 downto 0)
);
end entity;

architecture led_pattern_state_machine_arch of led_pattern_state_machine is
	-- State type declaration
	type state_type is (S0, S1, S2, S3, S4, S5);
	signal current_state, next_state : state_type;

	-- Timer signal for 1-sec display of switches
	signal timer 		: unsigned(23 downto 0) := (others => '0');
	signal display_done	: std_logic := '0';


begin
	process(clk, rst)
	begin
		if rst = '1' then
			current_state <= S0;
			timer <= (others => '0');
			display_done <= '0';
		elsif rising_edge(clk) then
			current_state <= next_state;

			-- Timer logic for display state
			if current_state = S5 then
				if timer < 50000000 then
					timer <= timer + 1;
					display_done <= '0';
				else
					display_done <= '1';
					timer <= (others => '0');
				end if;
			else
				timer <= (others => '0'); -- Reset timer when not in state S5
				display_done <= '0';
			end if;
		end if;
	end process;

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