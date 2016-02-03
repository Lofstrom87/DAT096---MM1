-- DAT096 - Embedded project, Team MM1
-- Ripple-carry adder

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY RCA_ovf IS
	GENERIC (n:INTEGER:=4);
	PORT(
		A, B 	: in std_logic_vector(n-1 downto 0);
		SUM	: out std_logic_vector(n-1 downto 0);
		OVF	: out std_logic
	);
END RCA_ovf;

ARCHITECTURE dataflow OF RCA_ovf IS
	COMPONENT FullAdder
	PORT(
		c_in, a, b 	: in std_logic;
		c_out, s_out	: out std_logic
	);
	END COMPONENT;

	SIGNAL carry: std_logic_vector (n downto 0);
begin
	carry(0)<='0';

	create_RCA: FOR bitnumber IN 0 TO (n-1) GENERATE
	RCA: ENTITY work.FullAdder(dataflow)
		PORT MAP(
			c_in=>carry(bitnumber),
			a=>A(bitnumber),
			b=>B(bitnumber),
			c_out=>carry(bitnumber+1),
			s_out=>SUM(bitnumber)
		);
	END GENERATE create_RCA;

	OVF<=carry(n);

END dataflow;
