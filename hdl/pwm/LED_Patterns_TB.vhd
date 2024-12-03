library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity led_patterns_tb is
    -- Testbench entity has no ports
end entity;

architecture tb_arch of led_patterns_tb is

    -- Component Declaration for the Unit Under Test (UUT)
    component led_patterns is
        generic (
            system_clock_period : time := 1 ms
        );
        port (
            clk             : in std_ulogic;
            rst             : in std_ulogic;
            push_button     : in std_ulogic;
            switches        : in std_ulogic_vector(3 downto 0);
            hps_led_control : in boolean;
            base_period     : in unsigned(7 downto 0);
            led_reg         : in std_ulogic_vector(7 downto 0);
            led             : out std_ulogic_vector(7 downto 0)
        );
    end component;

    -- Signals for the testbench
    signal clk             : std_ulogic := '0';
    signal rst             : std_ulogic := '0';
    signal push_button     : std_ulogic := '0';
    signal switches        : std_ulogic_vector(3 downto 0) := "0000";
    signal hps_led_control : boolean := false;  -- Always set to false for this lab
    signal base_period     : unsigned(7 downto 0) := (others => '0');
    signal led_reg         : std_ulogic_vector(7 downto 0) := (others => '0');
    signal led             : std_ulogic_vector(7 downto 0);

    -- Clock generation
    constant CLK_PERIOD : time := 1 ms;

begin

    -- Instantiate the Unit Under Test (UUT)
    UUT: led_patterns
        generic map (
            system_clock_period => CLK_PERIOD
        )
        port map (
            clk             => clk,
            rst             => rst,
            push_button     => push_button,
            switches        => switches,
            hps_led_control => hps_led_control,  -- Always false, no HPS control
            base_period     => base_period,
            led_reg         => led_reg,          -- Not used, since HPS control is disabled
            led             => led
        );

    -- Clock Generation Process
    clk_process: process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- Stimulus Process
    stim_proc: process
    begin
        -- Initialize Inputs
        rst <= '1';
        push_button <= '0';
        switches <= "0000";
        base_period <= to_unsigned(10, 8);  -- Base period for timing
        led_reg <= "00000000";              -- Not used for this lab
        wait for 100 ns;

        -- Release Reset
        rst <= '0';
        wait for 100 ns;

        -- Scenario: State Machine Control (HPS Control Disabled)

        -- Press Button to Change State to ShowSwitches
        push_button <= '1';
        wait for 100 ms;
        push_button <= '0';
        wait for 2 sec;

        -- Set Switches to "0001" and simulate button press to move to S1
        switches <= "0001";
        push_button <= '1';
        wait for 100 ms;
        push_button <= '0';
        wait for 2 sec;

        -- Set Switches to "0010" and simulate button press to move to S2
        switches <= "0010";
        push_button <= '1';
        wait for 100 ms;
        push_button <= '0';
        wait for 2 sec;

        -- Set Switches to "0011" and simulate button press to move to S3
        switches <= "0011";
        push_button <= '1';
        wait for 100 ms;
        push_button <= '0';
        wait for 2 sec;

        -- Set Switches to "0100" and simulate button press to move to S4
        switches <= "0100";
        push_button <= '1';
        wait for 100 ms;
        push_button <= '0';
        wait for 2 sec;

        -- Test Invalid Switch Value ("1111"), Should Return to Previous State
        switches <= "1111";
        push_button <= '1';
        wait for 100 ms;
        push_button <= '0';
        wait for 2 sec;

        -- Finish Simulation
        wait;
    end process;

end architecture;

