library ieee;
use ieee.std_logic_1164.all;
use work.print_pkg.all;
use work.assert_pkg.all;
use work.tb_pkg.all;

entity timed_counter_tb is
end entity timed_counter_tb;

architecture testbench of timed_counter_tb is

    -- Component Declaration for the Timed Counter
    component timed_counter is
        generic (
            clk_period : time;
            count_time : time
        );
        port (
            clk : in std_ulogic;
            enable : in boolean;
            done : out boolean;
            counter_out : out natural
        );
    end component timed_counter;

    -- Signal Declarations for the 100 ns Counter
    signal clk_tb : std_ulogic := '0';
    signal enable_100ns_tb : boolean := false;
    signal done_100ns_tb : boolean;
    signal counter_100ns_TB : natural;
    constant HUNDRED_NS : time := 100 ns;

    -- Signal Declarations for the 240 ns Counter
    signal enable_240ns_tb : boolean := false;
    signal done_240ns_tb : boolean;
    signal counter_240ns_TB : natural;
    constant TWOHUNDRED_FORTY_NS : time := 240 ns;

    -- Test procedure to check the done signal
    procedure predict_counter_done (
        constant count_time : in time;
        signal enable : in boolean;
        signal done : in boolean;
        constant count_iter : in natural
    ) is
    begin
        if enable then
            if count_iter < (count_time / CLK_PERIOD) then
                assert_false(done, "counter not done");
            else
                assert_true(done, "counter is done");
            end if;
        else
            assert_false(done, "counter not enabled");
        end if;
    end procedure predict_counter_done;

begin

    -- Instantiate the timed_counter with a 100 ns count_time
    dut_100ns_counter : timed_counter
        generic map (
            clk_period => CLK_PERIOD,
            count_time => HUNDRED_NS
        )
        port map (
            clk => clk_tb,
            enable => enable_100ns_tb,
            done => done_100ns_tb,
            counter_out => counter_100ns_TB
        );

    -- Instantiate the timed_counter with a 240 ns count_time
    dut_240ns_counter : timed_counter
        generic map (
            clk_period => CLK_PERIOD,
            count_time => TWOHUNDRED_FORTY_NS
        )
        port map (
            clk => clk_tb,
            enable => enable_240ns_tb,
            done => done_240ns_tb,
            counter_out => counter_240ns_TB
        );

    -- Clock generation process
    clk_tb <= not clk_tb after CLK_PERIOD / 2;

    -- Stimuli and Checker Process for 100 ns Counter
    stimuli_and_checker_100ns : process is
    begin
        -- Test case 1: 100ns timer when enabled
        print("Testing 100 ns timer: enabled");
        wait_for_clock_edge(clk_tb);
        enable_100ns_tb <= true;

        for i in 0 to (HUNDRED_NS / CLK_PERIOD) loop
            wait_for_clock_edge(clk_tb);
            predict_counter_done(HUNDRED_NS, enable_100ns_tb, done_100ns_tb, i);
        end loop;

        -- Test case 2: Ensure done isn't asserted when disabled for two count_time periods
        print("Testing 100 ns timer: disabled");
        wait_for_clock_edge(clk_tb);
        enable_100ns_tb <= false;

        for i in 0 to 2 * (HUNDRED_NS / CLK_PERIOD) loop
            wait_for_clock_edge(clk_tb);
            predict_counter_done(HUNDRED_NS, enable_100ns_tb, done_100ns_tb, i);
        end loop;

        -- Test case 3: Multiple periods with enable
        print("Testing 100 ns timer: enabled for multiple periods");
        wait_for_clock_edge(clk_tb);
        enable_100ns_tb <= true;

        for j in 0 to 2 loop
            for i in 0 to (HUNDRED_NS / CLK_PERIOD) loop
                wait_for_clock_edge(clk_tb);
                predict_counter_done(HUNDRED_NS, enable_100ns_tb, done_100ns_tb, i);
            end loop;
        end loop;

        -- Test case 1: 240ns timer when enabled
        print("Testing 240 ns timer: enabled");
        wait_for_clock_edge(clk_tb);
        enable_240ns_tb <= true;

        for i in 0 to (TWOHUNDRED_FORTY_NS / CLK_PERIOD) loop
            wait_for_clock_edge(clk_tb);
            predict_counter_done(TWOHUNDRED_FORTY_NS, enable_240ns_tb, done_240ns_tb, i);
        end loop;

        -- Test case 2: Ensure done isn't asserted when disabled for two count_time periods
        print("Testing 240 ns timer: disabled");
        wait_for_clock_edge(clk_tb);
        enable_240ns_tb <= false;

        for i in 0 to 2 * (TWOHUNDRED_FORTY_NS / CLK_PERIOD) loop
            wait_for_clock_edge(clk_tb);
            predict_counter_done(TWOHUNDRED_FORTY_NS, enable_240ns_tb, done_240ns_tb, i);
        end loop;

        -- Test case 3: Multiple periods with enable
        print("Testing 240 ns timer: enabled for multiple periods");
        wait_for_clock_edge(clk_tb);
        enable_240ns_tb <= true;

        for j in 0 to 2 loop
            for i in 0 to (TWOHUNDRED_FORTY_NS / CLK_PERIOD) loop
                wait_for_clock_edge(clk_tb);
                predict_counter_done(TWOHUNDRED_FORTY_NS, enable_240ns_tb, done_240ns_tb, i);
            end loop;
        end loop;
	std.env.finish;
    end process;

end architecture testbench;

