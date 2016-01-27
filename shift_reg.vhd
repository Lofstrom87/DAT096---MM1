-- Generic shift register.
-- Used in I2S
-- 2016-01-27

library ieee;
use ieee.STD_LOGIC_1164.all;

entity SHIFT_REG is
	generic(N: integer := 12);
	port(
		serial_in, clk, reset, word_select: in STD_LOGIC;
		parallel_out: out STD_LOGIC_VECTOR (N-1 downto 0)
	);
end SHIFT_REG;

architecture SHIFT_REG_architecture of  SHIFT_REG is
	CONSTANT RESET_ACTIVE: STD_LOGIC := '1'; --Choose if reset is active high or low.

	SIGNAL s_interconnect_register: STD_LOGIC_VECTOR(N downto 0);
COMPONENT FF_REG IS
   PORT(
      clk 	 : IN STD_LOGIC;
      areset : IN STD_LOGIC;   
      d 	 : IN STD_LOGIC;
      q 	 : OUT STD_LOGIC
   );
end COMPONENT;

begin

registers: for i in 0 to N-1 generate
		mux_i_bit: FF_REG port map(
			clk => clk,
			areset => reset,
			d => s_interconnect_register(i),
			q => s_interconnect_register(i+1)
		);
	end generate;

process(word_select, reset)
begin
	if(reset = RESET_ACTIVE) then
		parallel_out <= (others => '0');
	elsif(word_select'event) then
		parallel_out <= s_interconnect_register(N downto 1);
	end if;
end process;

end SHIFT_REG_architecture;