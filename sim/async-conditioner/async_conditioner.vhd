library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity async_conditioner is
    port (
        clk   : in  std_ulogic;
        rst   : in  std_ulogic;
        async : in  std_ulogic;
        sync  : out std_ulogic
    );
end entity async_conditioner;

architecture async_conditioner_arch of async_conditioner is
	component synchronizer is
    port (
        clk   : in std_ulogic;     -- Clock signal
        async : in std_ulogic;     -- Asynchronous input signal
        sync  : out std_ulogic     -- Synchronized output signal
    );
	end component synchronizer;

	component debouncer is
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
	end component debouncer;

	component one_pulse is
    port (
        clk   : in std_ulogic;
        rst   : in std_ulogic;
        input : in std_ulogic;
        pulse : out std_ulogic
    );
	end component one_pulse;

    -- Internal signals for connecting components
    signal debounced_signal : std_ulogic;
    signal pulse_signal     : std_ulogic;
    signal sync_signal      : std_ulogic;
    
begin
    -- Instantiation of the synchronizer
    synchronizer_inst : entity work.synchronizer
        port map (
            clk => clk,
            async => async,
            sync => sync_signal
        );

    -- Instantiation of the debouncer
    debouncer_inst : entity work.debouncer
        generic map (
            CLK_PERIOD => 20 ns,       -- Clock period
            debounce_time => 70 ns   -- Debounce time
        )
        port map (
            clk => clk,
            rst => rst,
            input => sync_signal,     -- Debounced input from synchronizer
            debounced => debounced_signal
        );

    -- Instantiation of the one-pulse generator
    one_pulse_inst : entity work.one_pulse
        port map (
            clk => clk,
            rst => rst,
            input => debounced_signal,
            pulse => sync
        );

end architecture;
