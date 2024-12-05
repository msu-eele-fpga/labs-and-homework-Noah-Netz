library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rgb_led_controller is
    port (
        clk           : in std_logic;
        rst           : in std_logic;
        avs_read      : in std_logic;
        avs_write     : in std_logic;
        avs_address   : in std_logic_vector(3 downto 0);
        avs_readdata  : out std_logic_vector(31 downto 0);
        avs_writedata : in std_logic_vector(31 downto 0);
        red_pwm       : out std_logic;
        green_pwm     : out std_logic;
        blue_pwm      : out std_logic
    );
end entity rgb_led_controller;

architecture rgb_led_controller_arch of rgb_led_controller is

    constant CLK_PERIOD : time := 20 ns;

    -- Register Signals
    signal period_reg      : unsigned(7 downto 0) := (others => '0'); -- PWM period
    signal red_duty_cycle  : unsigned(24 downto 0) := (others => '0'); -- Duty cycle for red
    signal green_duty_cycle: unsigned(24 downto 0) := (others => '0'); -- Duty cycle for green
    signal blue_duty_cycle : unsigned(24 downto 0) := (others => '0'); -- Duty cycle for blue

    -- Avalon Memory-Mapped Interface Signals
    signal readdata        : std_logic_vector(31 downto 0);

    -- Component Declaration
    component pwm_controller is
        generic (
            CLK_PERIOD : time := 20 ns
        );
        port (
            clk        : in std_logic;
            rst        : in std_logic;
            period     : in unsigned(7 downto 0);
            duty_cycle : in unsigned(24 downto 0);
            output     : out std_logic
        );
    end component;

    -- Internal Signals for PWM Outputs
    signal red_pwm_int   : std_logic;
    signal green_pwm_int : std_logic;
    signal blue_pwm_int  : std_logic;

begin

    avalon_read_process : process (clk)
    begin
        if rising_edge(clk) and avs_read = '1' then
            case avs_address is
                when "0000" => avs_readdata <= std_logic_vector(period_reg);
                when "0001" => avs_readdata <= std_logic_vector(red_duty_cycle);
                when "0010" => avs_readdata <= std_logic_vector(green_duty_cycle);
                when "0011" => avs_readdata <= std_logic_vector(blue_duty_cycle);
                when others => avs_readdata <= (others => '0');
            end case;
        end if;
    end process;

    avalon_write_process : process (clk)
    begin
        if rising_edge(clk) and avs_write = '1' then
            case avs_address is
                when "0000" => period_reg <= unsigned(avs_writedata(7 downto 0));
                when "0001" => red_duty_cycle <= unsigned(avs_writedata(24 downto 0));
                when "0010" => green_duty_cycle <= unsigned(avs_writedata(24 downto 0));
                when "0011" => blue_duty_cycle <= unsigned(avs_writedata(24 downto 0));
                when others => null;
            end case;
        end if;
    end process;

    -- Instantiate PWM Controllers
    red_pwm_inst : pwm_controller
        generic map (
            CLK_PERIOD => CLK_PERIOD
        )
        port map (
            clk        => clk,
            rst        => rst,
            period     => period_reg,
            duty_cycle => red_duty_cycle,
            output     => red_pwm_int
        );

    green_pwm_inst : pwm_controller
        generic map (
            CLK_PERIOD => CLK_PERIOD
        )
        port map (
            clk        => clk,
            rst        => rst,
            period     => period_reg,
            duty_cycle => green_duty_cycle,
            output     => green_pwm_int
        );

    blue_pwm_inst : pwm_controller
        generic map (
            CLK_PERIOD => CLK_PERIOD
        )
        port map (
            clk        => clk,
            rst        => rst,
            period     => period_reg,
            duty_cycle => blue_duty_cycle,
            output     => blue_pwm_int
        );

    -- Assign External Outputs
    red_pwm   <= red_pwm_int;
    green_pwm <= green_pwm_int;
    blue_pwm  <= blue_pwm_int;

end architecture;
