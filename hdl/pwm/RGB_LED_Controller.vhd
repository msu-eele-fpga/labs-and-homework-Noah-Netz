library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RGB_LED_Controller is
	port
	(
		clk        : in  std_logic;
		rst        : in  std_logic;
		-- Avalon memory-mapped slave interface
		avs_read      : in  std_logic;
		avs_write     : in  std_logic;
		avs_address   : in  std_logic_vector(1 downto 0);
		avs_readdata  : out std_logic_vector(31 downto 0);
		avs_writedata : in  std_logic_vector(31 downto 0);
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
	
	signal p			: std_logic_vector(31 downto 0);
	signal red		: std_logic_vector(31 downto 0);
	signal green	: std_logic_vector(31 downto 0);
	signal blue		: std_logic_vector(31 downto 0);
	
	
begin
	
	Red_Control : pwm_controller
		generic map
		(
			CLK_PERIOD 	=> 20 ns
		)
		port map
		(
			clk			=> clk,
			rst			=> rst,
			period		=> period(7 downto 0),
			duty_cycle	=> red_DC(24 downto 0),
			output		=> red_out
		);
		
	Green_Control : pwm_controller
		generic map
		(
			CLK_PERIOD 	=> 20 ns
		)
		port map
		(
			clk			=> clk,
			rst			=> rst,
			period		=> period(7 downto 0),
			duty_cycle	=> green_DC(24 downto 0),
			output		=> green_out
		);
		
	Blue_Control : pwm_controller
		generic map
		(
			CLK_PERIOD 	=> 20 ns
		)
		port map
		(
			clk			=> clk,
			rst			=> rst,
			period		=> period(7 downto 0),
			duty_cycle	=> blue_DC(24 downto 0),
			output		=> blue_out
		);
	
--	RGB_Output <= blue_out & green_out & red_out;
--	
--	red <= "00000000000000000000" & switches(3 downto 2) & "00000000000";
--	green <= "00000000000000000000" & switches(1) & "00000000000";
--	bblue <= "00000000000000000000" & switches(0) & "00000000000";
--	p			<= "000000000000000000000000" & "00100000";
--	
--	
--	red_DC	<= unsigned(red);
--	green_DC	<=	unsigned(green);
--	blue_DC	<=	unsigned(blue);
--	period	<=	unsigned(p);
	
	-- Read registers
	AVALON_REGISTER_READ : process(clk, avs_read) is
	begin
		if rising_edge(clk) and avs_read = '1' then
			case avs_address is
				
				when "00"   => avs_readdata <= std_logic_vector(red_DC);
				when "01"   => avs_readdata <= std_logic_vector(green_DC);
				when "10"   => avs_readdata <= std_logic_vector(blue_DC);
				when "11"   => avs_readdata <= std_logic_vector(period);
				when others => avs_readdata <= (others => '0');
				
			end case;
		end if;
	end process;
	
	-- Write registers
	AVALON_REGISTER_WRITE : process (clk, rst, avs_write) is
	begin
		if rst = '1' then
			red_DC   <= "0000000" & "1000000000000000000000000"; -- Red    = 1.0
			green_DC <= "0000000" & "0000000000000000000000000"; -- Green  = 0.0
			blue_DC  <= "0000000" & "0000000000000000000000000"; -- Blue   = 0.0
			period   <= "000000000000000000000000" & "00000100"; -- Period
			
		elsif rising_edge(clk) and avs_write = '1' then
			case avs_address is
				
				when "00"   => red_DC   <= unsigned(avs_writedata);
				when "01"   => green_DC <= unsigned(avs_writedata);
				when "10"   => blue_DC  <= unsigned(avs_writedata);
				when "11"   => period   <= unsigned(avs_writedata);
				when others => null; -- Ignore writes to unused registers
				
			end case;
		end if;
	end process;
	
end architecture;