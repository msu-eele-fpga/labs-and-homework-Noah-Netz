library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity one_pulse is
    port (
        clk   : in std_ulogic;
        rst   : in std_ulogic;
        input : in std_ulogic;
        pulse : out std_ulogic
    );
end entity one_pulse;

architecture Behavioral of one_pulse is
    type state_type is (Start, High, Low);
    signal state, next_state : state_type;
begin
    -- State transition process
    process(clk, rst)
    begin
        if rst = '1' then
            state <= Start;
        elsif rising_edge(clk) then
            state <= next_state;
        end if;
    end process;

    -- Next state and output logic
    process(state, input)
    begin
        pulse <= '0';  -- Default output

        case state is
            when Start =>
                pulse <= '0';
                if input = '1' then
                    next_state <= High;
                else
                    next_state <= Start;
                end if;

            when High =>
                pulse <= '1';
                next_state <= Low;

            when Low =>
                pulse <= '0';
                if input = '1' then
                    next_state <= Low;
                else
                    next_state <= Start;
                end if;

            when others =>
                next_state <= Start;
        end case;
    end process;

end Behavioral;

