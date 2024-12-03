library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm_controller is
	generic
	(
		CLK_PERIOD : time := 20 ns
	);
	port
	(
		clk        : in  std_logic;
		rst        : in  std_logic;
		-- PWM period in milliseconds
		-- period data type: u8.2
		period     : in  unsigned(7 downto 0);
		-- PWM duty cycle between 0 and 1, out-of-range values are hard-limited
		-- duty_cycle data type: u25.24
		duty_cycle : in  unsigned(24 downto 0);
		output     : out std_logic
	);
end entity;

architecture pwm_controller_arch of pwm_controller is
	
	constant CYC_PER_MS : unsigned(15 downto 0) := to_unsigned(50000, 16);
	
	signal cyc_per_period_int        : unsigned(21 downto 0);
	signal cyc_per_period_fractional : unsigned(17 downto 0);
	signal cyc_per_period            : unsigned(21 downto 0);
	signal cyc_per_dc_fractional     : unsigned(45 downto 0);
	signal cyc_per_dc                : unsigned(22 downto 0);
	signal dc_is_one                 : boolean;
	signal counter                   : natural := 0;
	
begin
	
	-- Conversion from fixed point to clock-cycle countable integers
	cyc_per_period_int        <= period(7 downto 2) * CYC_PER_MS;
	cyc_per_period_fractional <= period(1 downto 0) * CYC_PER_MS;
	cyc_per_period            <= cyc_per_period_int + ("000000" & cyc_per_period_fractional(17 downto 2));
	
	cyc_per_dc_fractional	  <= duty_cycle(23 downto 0) * cyc_per_period;
	cyc_per_dc                <= "0" & cyc_per_dc_fractional(45 downto 24);
	dc_is_one                 <= (duty_cycle(24) = '1');
	
	-- Counter control
	-- 1 when < cyc_per_dc
	-- 0 when > cyc_per_dc
	PULSE_WIDTH_MODULATION : process (clk, rst, cyc_per_period, cyc_per_dc, dc_is_one)
	begin
		if rst = '1' then
			output <= '0';
			counter <= 0;
			
		elsif rising_edge(clk) then
			if dc_is_one then
				output <= '1';
				counter <= 0;
				
			else
				if counter < cyc_per_dc then
					output <= '1';
					counter <= counter + 1;
					
				elsif counter >= cyc_per_dc and counter < cyc_per_period then
					output <= '0';
					counter <= counter + 1;
					
				else
					output <= '1';
					counter <= 1;
					
				end if;
			end if;
		end if;
	end process;
	
end architecture;
