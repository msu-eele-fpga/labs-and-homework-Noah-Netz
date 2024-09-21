library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.assert_pkg.all;
use work.print_pkg.all;
use work.tb_pkg.all;

entity async_conditioner_tb is
end entity async_conditioner_tb;

architecture async_conditioner_tb_arch of async_conditioner_tb is

    -- Declare signals for clock, reset, async input, and sync output
    signal clk_tb       : std_ulogic := '0';
    signal rst_tb       : std_ulogic := '0';
    signal async_tb     : std_ulogic := '0';    -- Asynchronous input signal
    signal sync_tb      : std_ulogic := '0';    -- Synchronized, debounced, conditioned output


    -- Define constant for clock period
    constant CLK_PERIOD : time := 20 ns;

    -- Component declaration for async_conditioner
    component async_conditioner
        port (
            clk   : in std_ulogic;
            rst   : in std_ulogic;
            async : in std_ulogic;
            sync  : out std_ulogic
        );
    end component;

begin
    -- Instantiate the async_conditioner component
    uut: entity work.async_conditioner
        port map (
            clk   => clk_tb,
            rst   => rst_tb,
            async => async_tb,
            sync  => sync_tb
        );

    -- Clock generation process
    clk_process : process
    begin
        clk_tb <= not clk_tb;
        wait for CLK_PERIOD / 2;
    end process;

    -- Test stimulus: Apply async input signals and make it self-checking
    stim_proc : process
    begin
        -- Initial reset
        rst_tb <= '1';
        wait for 20 ns;
        rst_tb <= '0';

        -- First simulated asynchronous bouncing input
        async_tb <= '0';
        wait for 5.3 * CLK_PERIOD;
        async_tb <= '1';
        wait for 3.6 * CLK_PERIOD;
        async_tb <= '0';
        wait for 2.1 * CLK_PERIOD;
        async_tb <= '1';
        wait for 1.8 * CLK_PERIOD;
        async_tb <= '0';
        wait for 1.3 * CLK_PERIOD;
        async_tb <= '0';

        -- Second simulated asynchronous bouncing input (simulating second button press)
        wait for 5 * CLK_PERIOD;  -- Wait before simulating another button press

        async_tb <= '0';
        wait for 3.2 * CLK_PERIOD;
        async_tb <= '1';
        wait for 3.6 * CLK_PERIOD;
        async_tb <= '0';
        wait for 2.1 * CLK_PERIOD;
        async_tb <= '1';
        wait for 1.8 * CLK_PERIOD;
        async_tb <= '0';
        wait for 1.3 * CLK_PERIOD;
        async_tb <= '0';

        -- Return to 0 (debounced, clean signal)
        async_tb <= '0';  -- Steady low
        wait for 5 * CLK_PERIOD;

        -- End of simulation
        report "End of simulation" severity note;
        std.env.finish;
    end process;

    -- Expected output generation and checking
    expected_output_proc : process
    variable expected_sync : std_ulogic := '0';
    begin
        -- First pulse expected after input stabilizes
        wait_for_clock_edges(clk_tb, 11);
		print("One pulse here at time " & time'image(now));
        expected_sync := '1';  -- Expect the output to pulse high
        assert_eq(sync_tb, expected_sync, "First pulse: Sync signal should be high after input stabilizes");

        wait_for_clock_edge(clk_tb);
        expected_sync := '0';  -- Sync should return to low
        assert_eq(sync_tb, expected_sync, "Sync signal should return to low after pulse");

        -- Second pulse expected after second input stabilizes
        wait_for_clock_edges(clk_tb, 16);
		print("One pulse here at time " & time'image(now));
        expected_sync := '1';
        assert_eq(sync_tb, expected_sync, "Second pulse: Sync signal should be high after input stabilizes");

        wait_for_clock_edge(clk_tb);
        expected_sync := '0';  -- Sync should return to low after second pulse
        assert_eq(sync_tb, expected_sync, "Sync signal should return to low after second pulse");

        wait_for_clock_edges(clk_tb, 10);
        report "End of expected output generation" severity note;
        wait;
    end process;

end architecture;

