-- DAT096 - Embedded Project - Team MM1
-- 
-- D flipflop register
-- 2016-02-01

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY reg IS
   PORT(
      clk, areset, input: IN STD_LOGIC;
      output: OUT STD_LOGIC
   );
END reg;
 
ARCHITECTURE arch_reg OF reg IS
BEGIN
   PROCESS(clk) IS
   BEGIN
      IF(areset = '1') THEN
	    output <= '0';
      ELSIF(rising_edge(clk)) THEN 
        output <= input;
      END IF;
   END PROCESS;
END ARCHITECTURE arch_reg;
