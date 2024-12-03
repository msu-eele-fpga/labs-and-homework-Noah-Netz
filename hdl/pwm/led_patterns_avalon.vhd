library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;

entity led_patterns_avalon is
	port (
		clk : in std_ulogic;
		rst : in std_ulogic;
		-- Avalon memory-mapped slave interface
		avs_read : in std_logic;
		avs_write : in std_logic;
		avs_address : in std_logic_vector(1 downto 0);
		avs_readdata : out std_logic_vector(31 downto 0);
		avs_writedata : in std_logic_vector(31 downto 0);
		-- External I/O; export to top-level
		push_button : in std_ulogic;
		switches : in std_ulogic_vector(3 downto 0);
		led : out std_ulogic_vector(7 downto 0)
	);
end entity led_patterns_avalon;

architecture led_patterns_avalon_arch of led_patterns_avalon is
	-- Signal declarations for the registers
	signal HPS_LED_control        : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
	--signal SYS_CLKs_sec         : std_ulogic_vector(31 downto 0) := "00000000000000000000000000000000";
	signal LED_reg	               : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
	signal base_period            : std_logic_vector(31 downto 0) := "00000000000000000000000000010000";
	signal HPS_signal					: boolean;
	
	
	component led_patterns is
	generic (
		system_clk_period : time := 20 ns
	);
	port (
		clk 			: in std_ulogic;
		rst 			: in std_ulogic;
		push_button 	: in std_ulogic;
		switches 		: in std_ulogic_vector(3 downto 0);
		hps_led_control : in boolean;
		base_period 	: in unsigned(7 downto 0) := "00010000";
		led_reg 		: in std_ulogic_vector(7 downto 0);
		led 			: out std_ulogic_vector(7 downto 0)
	);
	end component led_patterns;
begin

	HPS_signal <= True when HPS_LED_control(0) = '1' else False;
	-- Read process
	avalon_register_read : process(clk)
	begin
		if rising_edge(clk) and avs_read = '1' then
			case avs_address is
				when "00" 		=> avs_readdata <= HPS_LED_control;
				when "01" 		=> avs_readdata <= LED_reg;
				when "10"		=> avs_readdata <= base_period;
				when others 	=> avs_readdata <= (others => '0');
			end case;
		end if;
	end process;

	-- Write process
	avalon_register_write : process(clk)
	begin
		if rst = '1' then
			HPS_LED_control	<= "00000000000000000000000000000000";
			LED_reg				<= "00000000000000000000000000000000";
			base_period			<=	"00000000000000000000000000010000";
		elsif rising_edge(clk) and avs_write = '1' then
			case avs_address is
				when "00" 	=> HPS_LED_control <= avs_writedata(31 downto 0);
				when "01" 	=> LED_reg <= avs_writedata(31 downto 0);
				when "10" 	=> base_period <= avs_writedata(31 downto 0);
				when others => null; -- Ignore writes to undefined registers
			end case;
		end if;
	end process;

	-- Instantiate the components
	led_patterns_inst : entity work.led_patterns
		port map (
			clk            => clk,
			rst            => rst,
			push_button    => push_button,
			switches       => switches,
			hps_led_control => HPS_signal,
			base_period    => unsigned(base_period)(7 downto 0),
			led_reg        => std_ulogic_vector(LED_reg)(7 downto 0),
			led            => led
		);
	
end architecture;
