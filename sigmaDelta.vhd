-- DAT096 - Embedded project, Team MM1
-- Sigma Delta converter

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY sigmaDelta IS
	PORT (
		clk : IN STD_LOGIC;
		areset : IN STD_LOGIC;
		data : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
		overflow: OUT STD_LOGIC	
	);
END ENTITY sigmaDelta;

ARCHITECTURE arch_sigma_delta OF sigmaDelta IS

COMPONENT RCA_ovf IS
	GENERIC (n:INTEGER:=12);
	PORT(
		A, B 	: in std_logic_vector(n-1 downto 0);
		SUM	: out std_logic_vector(n-1 downto 0);
		OVF	: out std_logic
	);
END COMPONENT RCA_ovf;

COMPONENT FF_reg_delay IS
   PORT(
      clk, areset: IN STD_LOGIC;
	  input : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
      output: OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
   );
END COMPONENT FF_reg_delay;

SIGNAL delay_output : STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL delay_input  : STD_LOGIC_VECTOR(11 DOWNTO 0);

BEGIN

adder:	RCA_ovf	GENERIC MAP(12)
				PORT MAP(
					A => data,
					B => delay_output,
					SUM => delay_input,
					OVF => overflow
				);
				
delay:	FF_reg_delay
				PORT MAP(
					clk => clk,
					areset => areset,
					input => delay_input,
					output => delay_output					
				);

END ARCHITECTURE arch_sigma_delta;