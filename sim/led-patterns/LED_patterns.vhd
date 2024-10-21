library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity led_patterns is
	generic (
		system_clk_period : time := 20 ns
	);
	port (
		clk 			: in std_ulogic;
		rst 			: in std_ulogic;
		push_button 	: in std_ulogic;
		switches 		: in std_ulogic_vector(3 downto 0);
		hps_led_control : in boolean;
		base_period 	: in unsigned(7 downto 0);
		led_reg 		: in std_ulogic_vector(7 downto 0);
		led 			: out std_ulogic_vector(7 downto 0)
	);
end entity led_patterns;

architecture led_patterns_arch of led_patterns is

    -- Component Declarations

    -- Async Conditioner Component Declaration
    component async_conditioner is
        port (
            clk   : in  std_ulogic;
            rst   : in  std_ulogic;
            async : in  std_ulogic;
            sync  : out std_ulogic
        );
    end component;

    -- LED Pattern State Machine Component Declaration
    component led_pattern_state_machine is
        generic (
            system_clk_period : time := 20 ns
        );
        port (
            clk          : in  std_logic;
            rst          : in  std_logic;
            base_period  : in  unsigned(7 downto 0);
            button_pulse : in  std_logic;
            switches     : in  std_ulogic_vector(3 downto 0);
            pattern_gen  : in  std_ulogic_vector(6 downto 0);
            pattern_sel  : out std_ulogic_vector(2 downto 0);
            led_pattern  : out std_ulogic_vector(7 downto 0)
        );
    end component;

    -- LED Pattern Generator Component Declaration
    component LED_pattern_gen is
        generic (
            system_clk_period : time := 20 ns
        );
        port (
            clk         : in  std_ulogic;
            rst         : in  std_ulogic;
            base_period : in  unsigned(7 downto 0);
            pattern_sel : in  std_ulogic_vector(2 downto 0);
            pattern_gen : out std_ulogic_vector(6 downto 0)
        );
    end component;

    -- Signals for internal connections
    signal button_pulse   : std_ulogic;                           -- Conditioned button pulse signal
    signal pattern_sel    : std_ulogic_vector(2 downto 0);         -- State machine pattern select
    signal pattern_gen    : std_ulogic_vector(6 downto 0);        -- Generated LED pattern output
    signal led_pattern    : std_ulogic_vector(7 downto 0);        -- Final LED pattern output

begin

    -- Instantiate Async Conditioner for push button signal
    async_conditioner_inst : async_conditioner
        port map (
            clk    => clk,
            rst    => rst,
            async  => push_button,
            sync   => button_pulse  -- Conditioned push button signal (single pulse output)
        );

    -- Instantiate LED Pattern State Machine
    led_pattern_state_machine_inst : led_pattern_state_machine
        generic map (
            system_clk_period => system_clk_period
        )
        port map (
            clk          => clk,
            rst          => rst,
            base_period  => base_period,
            button_pulse => button_pulse,
            switches     => switches,
            pattern_gen  => pattern_gen,
            pattern_sel  => pattern_sel,
            led_pattern  => led_pattern
        );

    -- Instantiate LED Pattern Generator
    led_pattern_gen_inst : LED_pattern_gen
        generic map (
            system_clk_period => system_clk_period
        )
        port map (
            clk         => clk,
            rst         => rst,
            base_period => base_period,
            pattern_sel => pattern_sel,
            pattern_gen => pattern_gen
        );

    -- Control the LED output based on HPS control signal
    process(hps_led_control, led_pattern, led_reg)
    begin
        if hps_led_control = true then
            led <= led_reg;  -- If HPS control is enabled, use the register values
        else
            led <= led_pattern;  -- Otherwise, use the state machine generated pattern
        end if;
    end process;

end architecture led_patterns_arch;
