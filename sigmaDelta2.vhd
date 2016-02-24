-- DAT096 - Embedded project, Team MM1
-- Second order Sigma Delta converter

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL; 

ENTITY sigmaDelta IS
	PORT (
		clk : IN STD_LOGIC;
		areset : IN STD_LOGIC;
		data : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
		overflow: OUT STD_LOGIC	
	);
END ENTITY sigmaDelta;

ARCHITECTURE arch_sigma_delta OF sigmaDelta IS

COMPONENT ripple_adder_subtracter_saturate IS
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
END COMPONENT ripple_adder_subtracter_saturate;

COMPONENT FF_reg_delay IS
   PORT(
      clk, areset: IN STD_LOGIC;
	  input : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
      output: OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
   );
END COMPONENT FF_reg_delay;

SIGNAL delay_output1 : STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL delay_input1  : STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL delay_output2 : STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL times_two	: STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL sub_output	: STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL delay_clk 	: STD_LOGIC;
CONSTANT delay_const: INTEGER := 625;   -- Constant for clock-divider.
										-- Put X = (100 MHz)/(OSR*sclk) here.

BEGIN

-- This clock-divider lowers the 100 MHz internal clock of the FPGA to whatever frequency we need.
-- Just change the delay_const constant according to the commented equation.
clk_div: PROCESS(clk, areset)
	variable counter : INTEGER := 0;
	BEGIN
		IF (areset = '1') THEN
			delay_clk <= '0';
		ELSIF rising_edge(clk) THEN
			IF (counter = delay_const) THEN
				delay_clk <= NOT(delay_clk);
				counter := 0;
			ELSE
				counter := (counter + 1);
			END IF;
		END IF;
END PROCESS clk_div;

-- This is the adder, which adds the new data to the last data
-- and outputs the overflow bit. It is configured for addition and wrap-around.
adder:	ripple_adder_subtracter_saturate	  
				GENERIC MAP(12)
				PORT MAP(
					A => data,
					B => sub_output,
					add_sub => '1',
					saturate => '0',
					y => delay_input1,
					overflow => overflow
				);

-- This is the first delay register (flip-flop). It will output the delayed data to both the second
-- delay register and the left shift (x2 GAIN).
delay1:	FF_reg_delay
				PORT MAP(
					clk => delay_clk,
					areset => areset,
					input => delay_input1,
					output => delay_output1					
				);

-- This is the second delay register (flip-flop). It delays the data an additional
-- cycle before subtracting it with the x2 multiplied data from the next cycle.
delay2: FF_reg_delay
				PORT MAP(
					clk => delay_clk,
					areset => areset,
					input => delay_output1,
					output => delay_output2					
				);

-- This is the x2 multiplication, just a logical left shift.
times_two <= STD_LOGIC_VECTOR(UNSIGNED(delay_output1) SLL 1);

-- This is the subtractor, which subtracts the x2 multiplied data with the second delay register data
-- and outputs the result to the adders B port. It is configured for subtraction and wrap-around.
adder2: ripple_adder_subtracter_saturate
				GENERIC MAP(12)
				PORT MAP(
					A => times_two,
					B => delay_output2,
					add_sub => '0',
					saturate => '0',
					y => sub_output
				);


END ARCHITECTURE arch_sigma_delta;