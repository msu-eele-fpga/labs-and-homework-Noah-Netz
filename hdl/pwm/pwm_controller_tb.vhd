library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm_controller_tb is
end entity;

architecture pwm_controller_tb_arch of pwm_controller_tb is

    constant CLK_PERIOD : time := 20 ns;

    signal clk_tb        : std_logic := '0';
    signal rst_tb        : std_logic := '0';
    signal period_tb     : unsigned(7 downto 0) := "00000100";
    signal duty_cycle_tb : unsigned(24 downto 0) := "0100000000000000000000000";
    signal output_tb     : std_logic;

    component pwm_controller is
        generic
        (
            CLK_PERIOD : time := 20 ns
        );
        port
        (
            clk        : in  std_logic;
            rst        : in  std_logic;
            period     : in  unsigned(7 downto 0);  -- u8.2
            duty_cycle : in  unsigned(24 downto 0); -- u25.24
            output     : out std_logic
        );
    end component;

begin

    -- DUT: Device Under Test
    DUT : pwm_controller
        generic map
        (
            CLK_PERIOD => CLK_PERIOD
        )
        port map
        (
            clk        => clk_tb,
            rst        => rst_tb,
            period     => period_tb,
            duty_cycle => duty_cycle_tb,
            output     => output_tb
        );

    -- Clock generation process
    CLOCK_GEN : process
    begin
        while true loop
            clk_tb <= '1';
            wait for CLK_PERIOD / 2;
            clk_tb <= '0';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- Stimulus process
    STIMULUS : process
    begin
        -- Reset the DUT
        rst_tb <= '1';
        wait for CLK_PERIOD * 5;
        rst_tb <= '0';

        -- End of simulation
        wait;
    end process;

end architecture;
