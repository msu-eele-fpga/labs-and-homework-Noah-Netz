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
		avs_address : in std_ulogic_vector(1 downto 0);
		avs_readdata : out std_ulogic_vector(31 downto 0);
		avs_writedata : in std_ulogic_vector(31 downto 0);
		-- External I/O; export to top-level
		push_button : in std_ulogic;
		switches : in std_ulogic_vector(3 downto 0);
		led : out std_ulogic_vector(7 downto 0)
	);
end entity led_patterns_avalon;

architecture led_patterns_avalon_arch of led_patterns_avalon is
	-- Signal declarations for the registers
	signal HPS_LED_control      : std_logic;
	signal SYS_CLKs_sec         : unsigned(31 downto 0) := (others => '0');
	signal LED_reg              : std_ulogic_vector(7 downto 0) := (others => '0');
	signal Base_rate            : unsigned(7 downto 0) := (others => '0');

begin
	-- Read process
	avalon_register_read : process(clk)
	begin
		if rising_edge(clk) and avs_read = '1' then
			case avs_address is
				when "00" 		=> avs_readdata <= (others => HPS_LED_control); -- Extend HPS_LED_control to 32 bits
				when "01" 		=> avs_readdata <= std_ulogic_vector(SYS_CLKs_sec);
				when "10"		=> avs_readdata(7 downto 0) <= LED_reg; -- Map LED_reg to the lower 8 bits of avs_readdata
				when "11"		=> avs_readdata <= std_ulogic_vector(Base_rate & "0000000000000000");
				when others 	=> avs_readdata <= (others => '0');
			end case;
		end if;
	end process;

	-- Write process
	avalon_register_write : process(clk)
	begin
		if rising_edge(clk) then
			if avs_write = '1' then
				case avs_address is
					when "00" 	=> HPS_LED_control <= avs_writedata(0);
					when "01" 	=> SYS_CLKs_sec <= unsigned(avs_writedata);
					when "10" 	=> LED_reg <= avs_writedata(7 downto 0);
					when "11" 	=> Base_rate <= unsigned(avs_writedata(7 downto 0));
					when others => null; -- Ignore writes to undefined registers
				end case;
			end if;
		 end if;
	end process;

	-- Instantiate the led_patterns component
	led_patterns_inst : entity work.led_patterns
		--generic map (
			--system_clk_period => 20 ns
		--)
		port map (
			clk            => clk,
			rst            => rst,
			push_button    => push_button,
			switches       => switches,
			hps_led_control => (HPS_LED_control = '1'), -- Convert to boolean
			base_period    => Base_rate,
			led_reg        => LED_reg,
			led            => led
		);

end architecture;
