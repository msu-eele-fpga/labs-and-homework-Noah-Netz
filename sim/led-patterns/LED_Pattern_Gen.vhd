library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity LED_pattern_gen is
    generic (
        system_clk_period : time := 20 ns
    );
    port (
        clk             : in  std_ulogic;
        rst             : in  std_ulogic;
        base_period     : in  unsigned(7 downto 0);
        pattern_sel     : in  std_ulogic_vector(2 downto 0);
        pattern_gen     : out std_ulogic_vector(7 downto 0)
    );
end entity;

architecture LED_pattern_gen_mod of LED_pattern_gen is
    
    signal sel_signal      : std_ulogic_vector(2 downto 0);

    signal msb_toggle      : std_ulogic;
    signal pattern_0       : unsigned(6 downto 0);
    signal pattern_1       : unsigned(6 downto 0);
    signal pattern_2       : unsigned(6 downto 0);
    signal pattern_3       : unsigned(6 downto 0);
    signal pattern_4       : unsigned(6 downto 0);

    constant sec_count     : natural := 1000000000 ns / system_clk_period;
    signal counter_limit   : natural;

    signal cycle_count     : natural := 0;
    signal clk_div_vector  : unsigned(4 downto 0);

begin

    -- State Descriptions:
    -- State 0: One LED shifting right at half the base period
    -- State 1: Two LEDs shifting left at a quarter of the base period
    -- State 2: 7-bit up counter at double the base period rate
    -- State 3: 7-bit down counter at one-eighth of the base period rate
    -- State 4: Custom alternating LED pattern 

    -- Clock Divider Process
    process (clk, rst, cycle_count, clk_div_vector) is
    begin
        if rst = '1' then
            cycle_count <= 0;
            clk_div_vector <= to_unsigned(0, 5);
        elsif rising_edge(clk) then
            counter_limit <= (sec_count * to_integer(base_period)) / 16;
            if cycle_count >= counter_limit / 8 then
                clk_div_vector <= clk_div_vector + to_unsigned(1, 5);
                cycle_count <= 0;
            else
                cycle_count <= cycle_count + 1;
            end if;
        end if;
    end process;

    -- LED Pattern Generation
    process (clk_div_vector, rst, base_period, pattern_0, pattern_1, pattern_2, pattern_3, pattern_4, pattern_sel) is
    begin
        if rst = '1' then
            sel_signal <= "000";
    
            msb_toggle <= '0';
            pattern_0 <= to_unsigned(1, 7);   -- Initial pattern for State 0
            pattern_1 <= to_unsigned(3, 7);   -- Initial pattern for State 1
            pattern_2 <= to_unsigned(0, 7);   -- Initial value for up-counter
            pattern_3 <= to_unsigned(0, 7);   -- Initial value for down-counter
            pattern_4 <= "1010101";           -- Initial alternating pattern

        else
            sel_signal <= pattern_sel;

            -- Pattern 3: Down Counter
            if rising_edge(clk_div_vector(0)) then
                pattern_3 <= pattern_3 - to_unsigned(1, 7);
            end if;

            -- Pattern 1: Two LEDs Shifting Left
    		-- Pattern 4: Alternating between two patterns
            if rising_edge(clk_div_vector(1)) then
                pattern_1 <= rotate_left(pattern_1, 1);
                pattern_4 <= not pattern_4;   -- Pattern 4 Alternating Effect
            end if;

            -- Pattern 0: One LED Shifting Right
            if rising_edge(clk_div_vector(2)) then
                pattern_0 <= rotate_right(pattern_0, 1);
                msb_toggle <= not msb_toggle;
            end if;

            -- Pattern 2: Up Counter
            if rising_edge(clk_div_vector(4)) then
                pattern_2 <= pattern_2 + to_unsigned(1, 7);
            end if;
        end if;
    end process;

    -- Pattern Selector
    with sel_signal select pattern_gen <=
        msb_toggle & std_ulogic_vector(pattern_0) when "000",
        msb_toggle & std_ulogic_vector(pattern_1) when "001",
        msb_toggle & std_ulogic_vector(pattern_2) when "010",
        msb_toggle & std_ulogic_vector(pattern_3) when "011",
        msb_toggle & std_ulogic_vector(pattern_4) when "100",
        "00000000"                                 when others;

end architecture;
