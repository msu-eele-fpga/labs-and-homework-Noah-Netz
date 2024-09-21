library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.tb_pkg.all;      -- Required for testbench utilities
use work.assert_pkg.all;  -- Required for assertions

entity one_pulse_tb is
end entity one_pulse_tb;

architecture Behavioral of one_pulse_tb is
    signal clk_tb       : std_ulogic := '0';
    signal rst_tb       : std_ulogic := '0';
    signal input_tb     : std_ulogic := '0';
    signal pulse_tb     : std_ulogic;

    constant CLK_PERIOD : time := 20 ns;

begin
    -- Instantiate the one_pulse component
    uut: entity work.one_pulse
        port map (
            clk   => clk_tb,
            rst   => rst_tb,
            input => input_tb,
            pulse => pulse_tb
        );

    -- Clock generation process
    clk_process : process
    begin
        while true loop
            clk_tb <= '0';
            wait for CLK_PERIOD / 2;
            clk_tb <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- Test stimulus: Apply input signals without using wait_for_clock_edge
    stim_proc : process
    begin
        -- Initial reset
        rst_tb <= '1';
        wait for 40 ns;
        rst_tb <= '0';

        -- First input pulse (input high for 3 clock cycles)
        input_tb <= '1';
        wait for 3 * CLK_PERIOD;
        input_tb <= '0';
        wait for 5 * CLK_PERIOD;

        -- Second input pulse (input high for 5 clock cycles)
        input_tb <= '1';
        wait for 5 * CLK_PERIOD;
        input_tb <= '0';
        wait for 5 * CLK_PERIOD;

        -- End of simulation
        report "End of simulation" severity note;
		std.env.finish;
    end process;

    -- Expected output generation and checking
    expected_output_proc : process
    variable pulse_expected : std_ulogic;  -- Expected output for assertion checks
    begin
        -- Initialize expected output
        pulse_expected := '0';

        -- Check the pulse signal after input rises (First Input Pulse)
        wait_for_clock_edges(clk_tb, 3); -- Delay one clock cycle for pulse generation
        pulse_expected := '1';  -- Pulse expected after input rises
        assert_eq(pulse_tb, pulse_expected, "First pulse should be 1");

        -- Pulse should return to 0 in the next clock cycle
        wait_for_clock_edge(clk_tb);
        pulse_expected := '0';
        assert_eq(pulse_tb, pulse_expected, "First pulse should return to 0");

        -- Second Input Pulse Check
        wait_for_clock_edges(clk_tb, 7);
        pulse_expected := '1';  -- Pulse expected again after input rises
        assert_eq(pulse_tb, pulse_expected, "Second pulse should be 1");

        wait_for_clock_edge(clk_tb);
        pulse_expected := '0';
        assert_eq(pulse_tb, pulse_expected, "Second pulse should return to 0");

        -- End process
        wait_for_clock_edges(clk_tb, 10);
        report "End of expected output generation" severity note;
        wait;
    end process;

end Behavioral;

