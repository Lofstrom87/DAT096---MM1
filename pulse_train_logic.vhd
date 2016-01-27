-- Pulse train logic
-- Used to generate pulse train signal for nMOS and pMOS transistors.
-- 2016-01-27

-- TODO fix count to CLOCK_PULSES_LOW before going from activated transistor state to the next iteration.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY pulse_train_logic IS
	generic(N: integer := 12); -- Number of registers used.
	port(
		input, clk, reset: IN STD_LOGIC;
		nMOS_out, pMOS_out: OUT STD_LOGIC
	);
END pulse_train_logic;

ARCHITECTURE pulse_train_logic_architecture OF pulse_train_logic IS
	-- Constants
	CONSTANT RESET_ACTIVE: STD_LOGIC := '1'; -- Choose if reset is active high or low.
	CONSTANT nMOS_ACTIVE: STD_LOGIC := '1';
	CONSTANT pMOS_ACTIVE: STD_LOGIC := '0';
	--CONSTANT CLOCK_PULSES_LOW: -- Number of clock pulses necesary to make sure that both transistors are not on at the same time.
	
	-- State machine
	type state_type is (INIT_STATE, CHECK_OVF_STATE, nMOS_ACTIVE_STATE, nMOS_INACTIVE_STATE, pMOS_ACTIVE_STATE, pMOS_INACTIVE_STATE);  --type of state machine.
	signal current_state, next_state: state_type;  --current and next state declaration.

	-- Internal signals
BEGIN

PROCESS(clk, reset) -- Change state
BEGIN
	IF(reset = RESET_ACTIVE) THEN
		current_state <= INIT_STATE;
	ELSIF(rising_edge(clk)) THEN
		current_state <= next_state;
	END IF;
END PROCESS;

PROCESS(current_state)
BEGIN
	CASE current_state IS
		WHEN INIT_STATE =>
			nMOS_out <= not nMOS_ACTIVE; -- Deactivate both nMOS and pMOS transistors.
			pMOS_out <= not pMOS_ACTIVE;
			
			next_state <= CHECK_OVF_STATE; -- Go to check overflow state.
		WHEN CHECK_OVF_STATE =>
			IF(input = '1') THEN -- If input is high pMOS should be activated, ow nMOS activated.
				next_state <= pMOS_ACTIVE_STATE;
			ELSE
				next_state <= nMOS_ACTIVE_STATE;
			END IF;
		WHEN pMOS_ACTIVE_STATE =>
			nMOS_out <= not nMOS_ACTIVE; -- Redundancy, just to make sure that we never fry any transistors. Should not be necesary.
			pMOS_out <= pMOS_ACTIVE;
			
			next_state <= pMOS_INACTIVE_STATE;
		WHEN pMOS_INACTIVE_STATE =>
			nMOS_out <= not nMOS_ACTIVE; -- Deactivate both nMOS and pMOS transistors.
			pMOS_out <= not pMOS_ACTIVE;
			
			next_state <= CHECK_OVF_STATE;
		WHEN nMOS_ACTIVE_STATE =>
			pMOS_out <= not pMOS_ACTIVE; -- Redundancy, just to make sure that we never fry any transistors. Should not be necesary.
			nMOS_out <= nMOS_ACTIVE;
			
			next_state <= nMOS_INACTIVE_STATE;
		WHEN nMOS_INACTIVE_STATE =>
			nMOS_out <= not nMOS_ACTIVE; -- Deactivate both nMOS and pMOS transistors.
			pMOS_out <= not pMOS_ACTIVE;

			next_state <= CHECK_OVF_STATE;
		WHEN OTHERS =>
			next_state <= INIT_STATE;
	END CASE;
END PROCESS;

END pulse_train_logic_architecture;