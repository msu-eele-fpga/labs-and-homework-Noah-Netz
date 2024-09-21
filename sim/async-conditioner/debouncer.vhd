library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity debouncer is
    generic (
        CLK_PERIOD     : time := 20 ns;
        debounce_time  : time
    );
    port (
        clk        : in  std_logic;
        rst        : in  std_logic;
        input      : in  std_logic;
        debounced  : out std_logic
    );
end debouncer;

architecture Behavioral of debouncer is
    signal clock_count : unsigned(31 downto 0) := (others => '0');  -- Counter to measure debounce time
    signal enable      : boolean := true;                           -- Enable signal to allow changes
    signal prev_input  : std_logic := '0';                          -- Previous input for edge detection
    signal wait_clocks : unsigned(31 downto 0);                     -- Number of clock cycles to debounce
begin
    -- Calculate the number of clock cycles for debounce time
    wait_clocks <= to_unsigned(integer(debounce_time / CLK_PERIOD), 32);

    process(clk, rst)
    begin
        if rst = '1' then
            enable <= true;
            clock_count <= (others => '0');
            debounced <= '0';
            prev_input <= '0';
        elsif rising_edge(clk) then
            -- Store the previous input for edge detection
            prev_input <= input;

            if enable then
                -- Detect rising edge (input goes from 0 to 1)
                if input = '1' and prev_input = '0' then
                    debounced <= '1';
                    enable <= false;  -- Start debouncing
                -- Detect falling edge (input goes from 1 to 0)
                elsif input = '0' and prev_input = '1' then
                    debounced <= '0';
                    enable <= false;  -- Start debouncing
                end if;

            elsif not enable then
                -- Debounce counter
                if clock_count = wait_clocks - 2 then
                    clock_count <= (others => '0');
                    enable <= true;  -- Enable input changes after debounce time
                else
                    clock_count <= clock_count + 1;
                end if;
            end if;
        end if;
    end process;
end Behavioral;

