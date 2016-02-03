-- DAT096 - Embedded Project - Team MM1
-- 
-- D flipflop register
-- 2016-02-01

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY FF_reg_delay IS
   PORT(
      clk, areset: IN STD_LOGIC;
	  input : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
      output: OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
   );
END FF_reg_delay;
 
ARCHITECTURE arch_FF_reg_delay OF FF_reg_delay IS
BEGIN
   PROCESS(clk) IS
   BEGIN
      IF(areset = '1') THEN
	    output <= "000000000000";
      ELSIF(rising_edge(clk)) THEN 
        output <= input;
      END IF;
   END PROCESS;
END ARCHITECTURE arch_FF_reg_delay;