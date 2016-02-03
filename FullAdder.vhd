-- DAT096 - Embedded project, Team MM1
-- Full adder

library ieee;
use ieee.std_logic_1164.all;

entity fulladder is
	port(
		c_in, a, b : in std_logic;
		c_out, s_out: out std_logic
	);
end fulladder;

architecture dataflow of fulladder is
begin
	c_out <= ((b AND(c_in XOR a))OR(c_in AND a));
	s_out <= b XOR (c_in XOR a);
end dataflow;
