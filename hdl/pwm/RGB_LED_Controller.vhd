library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RGB_LED_Controller is
	port
	(
		clk        : in  std_logic;
		rst        : in  std_logic;
		-- External I/O; export to top-level
		switches   : in std_ulogic_vector(3 downto 0);
		RGB_Output : out std_ulogic_vector(2 downto 0)
	);
end entity;

architecture RGB_LED_Controller_arch of RGB_LED_Controller is

	signal period				: unsigned(31 downto 0);
	signal red_DC				: unsigned(31 downto 0);
	signal green_DC			: unsigned(31 downto 0);
	signal blue_DC				: unsigned(31 downto 0);
	
	signal red_out				: std_logic;
	signal green_out			: std_logic;
	signal blue_out			: std_logic;
	
	-- Instantiate PWM Controller
	component pwm_controller is
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
	end component;
	
	