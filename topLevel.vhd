-- DAT096 - Embedded Project - Team MM1
-- 
-- Top level module, digital part of converter.
-- 2016-02-03

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY topLevel IS
	PORT (
		s_clk	: IN STD_LOGIC;
		sys_clk	: IN STD_LOGIC;
		ws		: IN STD_LOGIC;
		s_data	: IN STD_LOGIC;
		areset	: IN STD_LOGIC;
		pMOS_out: OUT STD_LOGIC;
		nMOS_out: OUT STD_LOGIC	
	);
END ENTITY topLevel;

ARCHITECTURE arch_topLevel OF topLevel IS


COMPONENT sigmaDelta2 IS
	PORT (
		clk : IN STD_LOGIC;
		areset : IN STD_LOGIC;
		data : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
		overflow: OUT STD_LOGIC	
	);
END COMPONENT sigmaDelta2;

COMPONENT shift_reg IS
	generic(N: integer := 12); -- Number of registers used.
	port(
		serial_in, clk, reset, word_select: IN STD_LOGIC;
		parallel_out: OUT STD_LOGIC_VECTOR (N-1 downto 0)
	);
END COMPONENT shift_reg;

COMPONENT pulse_train_logic IS
	generic(N: integer := 12); -- Number of registers used.
	port(
		input, clk, reset: IN STD_LOGIC;
		nMOS_out, pMOS_out: OUT STD_LOGIC
	);
END COMPONENT pulse_train_logic;

SIGNAL decoder_out : STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL converter_out : STD_LOGIC;

BEGIN

--decoder: shift_reg PORT MAP(
--							serial_in => s_data,
--							clk => s_clk,
--							reset => areset,
--							word_select => ws,
--							parallel_out => decoder_out
--							);

decoder_out <= "100000000000";							

converter: sigmaDelta2 PORT MAP(
							   clk => sys_clk,
							   areset => areset,
							   data => decoder_out,
							   overflow => converter_out
							   );
							   
output: pulse_train_logic PORT MAP(
								   input => converter_out,
								   clk => sys_clk,
								   reset => areset,
								   nMOS_out => nMOS_out,
								   pMOS_out => pMOS_out
								   );
								   
END ARCHITECTURE arch_topLevel;