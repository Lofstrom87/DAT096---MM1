LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY ripple_adder_subtracter_saturate IS

	GENERIC (
		WIDTH:INTEGER:=8
	);
	PORT(
		A		:IN STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
		B		:IN STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
		add_sub		:IN STD_LOGIC;
		saturate	:IN STD_LOGIC;
		y		:OUT STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
		overflow	:OUT STD_LOGIC
	);
END ripple_adder_subtracter_saturate;

ARCHITECTURE dataflow OF ripple_adder_subtracter_saturate IS
	COMPONENT FullAdder
	PORT(
		c_in, a, b 	: in std_logic;
		c_out, s_out	: out std_logic
	);
	END COMPONENT;

	SIGNAL carry: std_logic_vector(WIDTH downto 0);
	
	SIGNAL g_A, g_B, g_SUM: std_logic_vector(WIDTH-1 downto 0);

	SIGNAL g_OVF: std_logic;

begin
	carry(0)<='0' when add_sub='1' ELSE '1';

	g_B<=B WHEN add_sub='1' ELSE NOT B;

	g_A<=A;

	create_RCA: FOR bitnumber IN 0 TO (WIDTH-1) GENERATE
	RCA: ENTITY work.FullAdder(dataflow)
		PORT MAP(
			c_in=>carry(bitnumber),
			a=>g_A(bitnumber),
			b=>g_B(bitnumber),
			c_out=>carry(bitnumber+1),
			s_out=>g_SUM(bitnumber)
		);
	END GENERATE create_RCA;

	g_OVF<=((carry(WIDTH))XOR(carry(WIDTH-1)));
	overflow<=g_OVF;

	y(WIDTH-1) <= ((A(WIDTH-1))) WHEN ((g_OVF AND saturate)='1')
	ELSE
	g_SUM(WIDTH-1);

	y(WIDTH-2 downto 0) <= (others=>(NOT(A(WIDTH-1)))) WHEN ((g_OVF AND saturate)='1')
	ELSE
	g_SUM(WIDTH-2 downto 0);


END dataflow;
