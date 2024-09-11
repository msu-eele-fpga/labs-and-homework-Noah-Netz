library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vending_machine is
port (
	clk : in std_ulogic;
	rst : in std_ulogic;
	nickel : in std_ulogic;
	dime : in std_ulogic;
	dispense : out std_ulogic;
	amount : out natural range 0 to 15
);
end entity vending_machine;
