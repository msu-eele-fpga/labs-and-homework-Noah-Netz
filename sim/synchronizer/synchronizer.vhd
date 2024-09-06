library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- Entity declaration
entity synchronizer is
    port (
        clk   : in std_ulogic;     -- Clock signal
        async : in std_ulogic;     -- Asynchronous input signal
        sync  : out std_ulogic     -- Synchronized output signal
    );
end entity synchronizer;

-- Architecture
architecture behavior of synchronizer is
    signal sync_ff1, sync_ff2 : std_ulogic;  -- Internal flip-flop signals
begin
    -- Synchronizer process
    process (clk)
    begin
        if rising_edge(clk) then
            sync_ff1 <= async;   -- First flip-flop samples the async signal
            sync_ff2 <= sync_ff1; -- Second flip-flop samples the first one
        end if;
    end process;

    -- Assign the final synchronized output
    sync <= sync_ff2;

end architecture behavior;
