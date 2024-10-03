library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity led_pattern_state_machine is
	generic (
		system_clk_period : time := 20 ns
	);
	port (
		clk				: in  std_logic;
		rst				: in  std_logic;
		base_period		: in  unsigned(7 downto 0);
		button_pulse	: in  std_logic;
		switches		: in  std_ulogic_vector(3 downto 0);
		pattern_gen		: in  std_ulogic_vector(7 downto 0);
		pattern_sel		: out std_ulogic_vector(2 downto 0);
		led_pattern		: out std_ulogic_vector(7 downto 0)
	);
end entity;

architecture led_pattern_state_machine_arch of led_pattern_state_machine is
	-- State type declaration
	type state_type is (S0, S1, S2, S3, S4, S5);
	signal current_state, prev_state : state_type;

	constant sec_count     : natural := 1000000000 ns / system_clk_period;
    signal cycle_count     : natural := 0;


begin
	process(clk, rst, current_state, prev_state, switches, button_pulse, cycle_count)
	begin
		if rst = '1' then
			current_state <= S0;
			cycle_count <= 0;
		elsif rising_edge(clk) then
			case current_state is
				when S5 =>
					if cycle_count < sec_count then
						cycle_count <= cycle_count + 1;
						current_state <= S5;
					else
						cycle_count <= 0;
						case switches is
							when "0000" =>
								current_state <= S0;
							when "0001" =>
								current_state <= S1;
							when "0010" =>
								current_state <= S2;
							when "0011" =>
								current_state <= S3;
							when "0100" =>
								current_state <= S4;
							when others =>
								current_state <= prev_state;
						end case;
					end if;
				when others =>
					cycle_count <= 0;
					current_state <= prev_state;
					if button_pulse = '1' then
						current_state <= S5;
					else
						current_state <= current_state;
					end if;
			end case;
		end if;
	end process;


	-- Output process
	process(pattern_gen, switches, current_state)
	begin
		case current_state is
			when S0 =>
				pattern_sel <= "000";
				led_pattern <= pattern_gen;
			when S1 =>
				pattern_sel <= "001";
				led_pattern <= pattern_gen;
			when S2 =>
				pattern_sel <= "010";
				led_pattern <= pattern_gen;
			when S3 =>
				pattern_sel <= "011";
				led_pattern <= pattern_gen;
			when S4 =>
				pattern_sel <= "100";
				led_pattern <= pattern_gen;
			when S5 =>
				pattern_sel <= "111";
				led_pattern <= switches;
		end case;
	end process;

	
end architecture;