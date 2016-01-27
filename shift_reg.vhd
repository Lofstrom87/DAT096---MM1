-- Generic shift register.
-- Used in I2S
-- 2016-01-27
-- Samples signals and shifts register values every clock pulse (serial clock).
-- When word_select changes value the value in the shift registry is sent to the parallel_out

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY shift_reg IS
	generic(N: integer := 12); -- Number of registers used.
	port(
		serial_in, clk, reset, word_select: IN STD_LOGIC;
		parallel_out: OUT STD_LOGIC_VECTOR (N-1 downto 0)
	);
END shift_reg;

ARCHITECTURE shift_reg_architecture OF shift_reg IS
	-- Constants
	CONSTANT RESET_ACTIVE: STD_LOGIC := '1'; -- Choose if reset is active high or low.

	-- Signals
	SIGNAL s_interconnect_register: STD_LOGIC_VECTOR(N downto 0); -- Signal that interconnects the registers.
COMPONENT FF_REG IS
   PORT(
      clk 	 : IN STD_LOGIC;
      areset : IN STD_LOGIC;   
      d 	 : IN STD_LOGIC;
      q 	 : OUT STD_LOGIC
   );
END COMPONENT;

BEGIN

registers: for i in 0 to N-1 generate
		mux_i_bit: FF_REG port map(
			clk => clk,
			areset => reset,
			d => s_interconnect_register(i),
			q => s_interconnect_register(i+1)
		);
	END generate;

PROCESS(word_select, reset)
BEGIN
	if(reset = RESET_ACTIVE) then
		parallel_out <= (others => '0'); -- Reset parallel output.
	elsif(word_select'event) then
		parallel_out <= s_interconnect_register(N downto 1); -- Output the values from the shift registers to the parallel output.
	END if;
END PROCESS;

END shift_reg_architecture;