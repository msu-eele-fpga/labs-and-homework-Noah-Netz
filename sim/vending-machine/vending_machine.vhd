library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vending_machine is
port (
        clk      : in  std_ulogic;
        rst      : in  std_ulogic;
        nickel   : in  std_ulogic;
        dime     : in  std_ulogic;
        dispense : out std_ulogic;
        amount   : out natural range 0 to 15
);
end entity vending_machine;

architecture Behavioral of vending_machine is
    -- Define the states corresponding to 0, 5, 10, and 15 cents
    type state_type is (S0, S5, S10, S15);
    signal state, next_state : state_type;
    signal current_amount : natural range 0 to 15 := 0;
    signal dispense_reg : std_ulogic := '0';

begin
    -- State transition logic with asynchronous reset
    process(clk, rst)
    begin
        if rst = '1' then
            state <= S0; -- Start at state S0
        elsif rising_edge(clk) then
            state <= next_state;
        end if;
    end process;

    -- Next State Logic
    process(state, nickel, dime,clk)
    begin
        --if rising_edge(clk) then
	case state is
            when S0 => -- 0 cents     
                if dime = '1' then
                    next_state <= S10; -- Transition to 10 cents     
		elsif nickel = '1' then
                    next_state <= S5; -- Transition to 5 cents
                else
                    next_state <= S0; -- Stay in 0 cents
                end if;

            when S5 => -- 5 cents      
                if dime = '1' then
                    next_state <= S15; -- Transition to 15 cents  
		elsif nickel = '1' then
                    next_state <= S10; -- Transition to 10 cents
                else
                    next_state <= S5; -- Stay in 5 cents
                end if;

            when S10 => -- 10 cents
                if (nickel = '1' or dime = '1') then
                    next_state <= S15; -- Transition to 15 cents
                else
                    next_state <= S10; -- Stay in 10 cents
                end if;

            when S15 => -- 15 cents (dispense)
                next_state <= S0; -- After dispensing, go back to 0 cents

            when others =>
                next_state <= S0;
        end case;
	--end if;
    end process;

    -- Output Logic
    process(state)
    begin
	case state is
	    when S0 =>
		current_amount <=0;
		dispense_reg <= '0';
	    when S5 =>
		current_amount <=5;
		dispense_reg <= '0';
	    when S10 =>
		current_amount <=10;
		dispense_reg <= '0';
	    when S15 =>
		current_amount <=15;
		dispense_reg <= '1';
	end case;
    end process;

    -- Assign outputs
    amount <= current_amount;
    dispense <= dispense_reg;

end architecture Behavioral;

