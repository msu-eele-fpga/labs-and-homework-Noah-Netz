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
	
	signal button_pulse : std_ulogic;
	signal pattern_sel : std_ulogic_vector(2 downto 0);
	signal pattern_gen : std_ulogic_vector(6 downto 0);

	
	-- Async Conditioner Component
	component async_conditioner is
		 port (
			  clk   : in std_ulogic;
			  rst   : in std_ulogic;
			  async : in std_ulogic;
			  sync  : out std_ulogic
		 );
	end component;

	-- Debouncer Component
	component debouncer is
		 generic (
			  CLK_PERIOD     : time := 20 ns;
			  debounce_time  : time
		 );
		 port (
			  clk        : in std_ulogic;
			  rst        : in std_ulogic;
			  input      : in std_ulogic;
			  debounced  : out std_ulogic
		 );
	end component;

	-- One Pulse Component
	component one_pulse is
		 port (
			  clk   : in std_ulogic;
			  rst   : in std_ulogic;
			  input : in std_ulogic;
			  pulse : out std_ulogic
		 );
	end component;

	-- LED Pattern Generator Component
	component LED_pattern_gen is
		 generic (
			  system_clk_period : time := 20 ns
		 );
		 port (
			  clk         : in std_ulogic;
			  rst         : in std_ulogic;
			  base_period : in unsigned(7 downto 0);
			  pattern_sel : in std_ulogic_vector(2 downto 0);
			  pattern_gen : out std_ulogic_vector(6 downto 0)
		 );
	end component;

	-- LED Pattern State Machine Component
	component led_pattern_state_machine is
		 generic (
			  system_clk_period : time := 20 ns
		 );
		 port (
			  clk          : in std_logic;
			  rst          : in std_logic;
			  base_period  : in unsigned(7 downto 0);
			  button_pulse : in std_ulogic;
			  switches     : in std_ulogic_vector(3 downto 0);
			  pattern_gen  : in std_ulogic_vector(6 downto 0);
			  pattern_sel  : out std_ulogic_vector(2 downto 0);
			  led_pattern  : out std_ulogic_vector(7 downto 0)
		 );
	end component;

	-- Synchronizer Component
	component synchronizer is
		 port (
			  clk   : in std_ulogic;
			  async : in std_ulogic;
			  sync  : out std_ulogic
		 );
	end component;

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
			hps_led_control => False,
			base_period    => unsigned(base_period)(7 downto 0),
			led_reg        => std_ulogic_vector(LED_reg)(7 downto 0),
			led            => led
		);
	
	async_conditioner_inst : async_conditioner
    port map (
        clk    => clk,
        rst    => rst,
        async  => push_button,
        sync   => button_pulse
    );

	debouncer_inst : debouncer
    generic map (
        CLK_PERIOD => 20 ns,
        debounce_time => 70 ns
    )
    port map (
        clk       => clk,
        rst       => rst,
        input     => button_pulse,
        debounced => button_pulse
    );

	 one_pulse_inst : one_pulse
    port map (
        clk   => clk,
        rst   => rst,
        input => button_pulse,
        pulse => button_pulse
    );

	 led_pattern_gen_inst : LED_pattern_gen
    generic map (
        system_clk_period => 20 ns
    )
    port map (
        clk         => clk,
        rst         => rst,
        base_period => unsigned(base_period)(7 downto 0),
        pattern_sel => pattern_sel,
        pattern_gen => pattern_gen
    );

	 led_pattern_state_machine_inst : led_pattern_state_machine
    generic map (
        system_clk_period => 20 ns
    )
    port map (
        clk          => clk,
        rst          => rst,
        base_period  => unsigned(base_period)(7 downto 0),
        button_pulse => button_pulse,
        switches     => switches,
        pattern_gen  => pattern_gen,
        pattern_sel  => pattern_sel,
        led_pattern  => led
    );

	 synchronizer_inst : synchronizer
    port map (
        clk   => clk,
        async => push_button,
        sync  => button_pulse
    );

	
end architecture;
