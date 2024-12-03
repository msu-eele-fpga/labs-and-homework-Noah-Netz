library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity LED_pattern_gen_tb is
-- No ports needed for a test bench
end entity;

architecture Behavioral of LED_pattern_gen_tb is

    signal clk          : std_ulogic := '0';
    signal rst          : std_ulogic := '1'; -- Start with reset active
    signal base_period  : unsigned(7 downto 0) := to_unsigned(1, 8); -- Base period for testing
    signal pattern_sel  : std_ulogic_vector(2 downto 0) := "000"; -- Select initial pattern
    signal pattern_gen  : std_ulogic_vector(7 downto 0); -- Output pattern

    -- Clock period constant
    constant clk_period : time := 1 ms;

    -- Instantiate the UUT (Unit Under Test)
    component LED_pattern_gen
        generic (
            system_clk_period : time := 1 ms
        );
        port (
            clk             : in  std_ulogic;
            rst             : in  std_ulogic;
            base_period     : in  unsigned(7 downto 0);
            pattern_sel     : in  std_ulogic_vector(2 downto 0);
            pattern_gen     : out std_ulogic_vector(7 downto 0)
        );
    end component;

begin

    -- Instantiate the LED_pattern_gen in the testbench
    UUT: LED_pattern_gen
        generic map (
            system_clk_period => clk_period
        )
        port map (
            clk          => clk,
            rst          => rst,
            base_period  => base_period,
            pattern_sel  => pattern_sel,
            pattern_gen  => pattern_gen
        );

    -- Clock process to generate a clock signal
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Test stimulus process to apply different test inputs
    stimulus_process : process
    begin
        -- Hold reset for 100 ns and then release
        wait for 100 ns;
        rst <= '0'; -- De-assert reset

        -- Let the design run for some time with pattern 0
        wait for 500 ms;
        
        -- Change pattern selector to 001 (Pattern 1)
        pattern_sel <= "001";
        wait for 2 sec;

        -- Change pattern selector to 010 (Pattern 2)
        --pattern_sel <= "010";
        wait for 2 sec;

        -- Change pattern selector to 011 (Pattern 3)
        --pattern_sel <= "011";
        wait for 2 sec;

        -- Change pattern selector to 100 (Pattern 4)
        --pattern_sel <= "100";
        wait for 2 sec;

		std.env.finish;

        -- Change the base period value
        base_period <= to_unsigned(2, 8);
        wait for 1000 ns;

        -- Add more pattern transitions if needed, or finish simulation
        wait;

    end process;

end architecture;
