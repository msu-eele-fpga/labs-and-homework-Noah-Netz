library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity led_pattern_state_machine_tb is
    -- Test bench has no ports
end entity;

architecture tb_arch of led_pattern_state_machine_tb is

    -- Component Declaration for the Unit Under Test (UUT)
    component led_pattern_state_machine is
        generic (
            system_clk_period : time := 1 ms
        );
        port (
            clk          : in  std_logic;
            rst          : in  std_logic;
            base_period  : in  unsigned(7 downto 0);
            button_pulse : in  std_logic;
            switches     : in  std_ulogic_vector(3 downto 0);
            pattern_gen  : in  std_ulogic_vector(7 downto 0);
            pattern_sel  : out std_logic_vector(2 downto 0);
            led_pattern  : out std_ulogic_vector(7 downto 0)
        );
    end component;

    -- Test Bench Signals
    signal clk          : std_logic := '0';
    signal rst          : std_logic := '0';
    signal base_period  : unsigned(7 downto 0) := (others => '0');
    signal button_pulse : std_logic := '0';
    signal switches     : std_ulogic_vector(3 downto 0) := "0000";
    signal pattern_gen  : std_ulogic_vector(7 downto 0) := (others => '0');
    signal pattern_sel  : std_logic_vector(2 downto 0);
    signal led_pattern  : std_ulogic_vector(7 downto 0);

    -- Clock generation process
    constant CLK_PERIOD : time := 1 ms;

begin

    -- Instantiate the Unit Under Test (UUT)
    UUT: led_pattern_state_machine
        generic map (
            system_clk_period => CLK_PERIOD
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

    -- Clock Generation
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
        button_pulse <= '0';
        switches <= "0000";
        pattern_gen <= "00000000";
        wait for 100 ns;

        -- Release reset
        rst <= '0';
        wait for 100 ns;

        -- Apply button pulse to transition to ShowSwitches state
        button_pulse <= '1';
        wait for CLK_PERIOD;
        button_pulse <= '0';
        wait for 2 sec; -- Allow time to transition to S5 and wait for 1 second

        -- Set switches to "0001" and simulate button press to move to S1
        switches <= "0001";
        button_pulse <= '1';
        wait for CLK_PERIOD;
        button_pulse <= '0';
        wait for 2 sec; -- Allow time to transition to S5 and wait for 1 second

        -- Set switches to "0010" and simulate button press to move to S2
        switches <= "0010";
        button_pulse <= '1';
        wait for CLK_PERIOD;
        button_pulse <= '0';
        wait for 2 sec; -- Allow time to transition to S5 and wait for 1 second

        -- Set switches to "0011" and simulate button press to move to S3
        switches <= "0011";
        button_pulse <= '1';
        wait for CLK_PERIOD;
        button_pulse <= '0';
        wait for 2 sec; -- Allow time to transition to S5 and wait for 1 second

        -- Set switches to "0100" and simulate button press to move to S4
        switches <= "0100";
        button_pulse <= '1';
        wait for CLK_PERIOD;
        button_pulse <= '0';
        wait for 2 sec; -- Allow time to transition to S5 and wait for 1 second

        -- Test invalid switch value, should return to the previous state
        switches <= "1111";
        button_pulse <= '1';
        wait for CLK_PERIOD;
        button_pulse <= '0';
        wait for 2 sec; -- Allow time to see what happens when invalid switches are set

        -- Finish the simulation
        wait;
    end process;

end architecture;
