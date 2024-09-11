library ieee;
use ieee.std_logic_1164.all;

entity timed_counter is
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
end entity timed_counter;

architecture behavior of timed_counter is

    -- Internal signals and constants
    constant COUNTER_LIMIT : natural := count_time / clk_period;  -- Number of clock cycles to count
    signal counter : natural range 0 to COUNTER_LIMIT := 0;       -- Counter signal

begin
    counter_out <= counter;
    process(clk)
    begin
        if rising_edge(clk) then
            if enable = true then
                if counter < COUNTER_LIMIT then
                    counter <= counter + 1;
                    done <= false;  -- Not done counting yet
                else
                    counter <= 0;   -- Reset counter after reaching the limit
                    done <= true;   -- Assert done for one clock cycle
                end if;
            else
                counter <= 0;       -- Reset the counter if not enabled
                done <= false;      -- Done is false when not enabled
            end if;
        end if;
    end process;

end architecture behavior;
