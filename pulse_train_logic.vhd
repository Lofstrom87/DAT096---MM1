-- Pulse train logic
-- Used to generate pulse train signal for nMOS and pMOS transistors.
-- 2016-01-27

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
	-- Clock pulses to stay in specific sections, for values see matlab script in: "DAT096 - Embedded project\Digital\Calculations\Pulse train logic\countvalues.m"
	CONSTANT CLOCK_PULSES_INACTIVE: INTEGER := 30;  	-- Number of clock pulses necesary to make sure that both transistors are not on at the same time.
	CONSTANT CLOCK_PULSES_ACTIVE: INTEGER := 30; 		-- Number of clock pulses necesary to make sure that an activated signal reaches the output.
	CONSTANT CLOCK_PULSES_OUTPUT_RATE: INTEGER := 188; 	-- Number of clock pulses to wait in OVF state, this sets the output frequency to the transistors.
	-- State machine
	type state_type is (INIT_STATE, CHECK_OVF_STATE, nMOS_ACTIVE_STATE, nMOS_INACTIVE_STATE, pMOS_ACTIVE_STATE, pMOS_INACTIVE_STATE);  --type of state machine.
	signal current_state, next_state: state_type;  --current and next state declaration.

BEGIN

PROCESS(clk, reset) -- Change state
BEGIN
	IF(reset = RESET_ACTIVE) THEN
		current_state <= INIT_STATE;
	ELSIF(rising_edge(clk)) THEN
		current_state <= next_state;
	END IF;
END PROCESS;

PROCESS(current_state, clk)
	VARIABLE count: INTEGER RANGE 0 TO 511 := 32; -- Variable used to count time signals are low and high. 
BEGIN
	CASE current_state IS
		WHEN INIT_STATE =>
			nMOS_out <= not nMOS_ACTIVE;	-- Deactivate both nMOS and pMOS transistors.
			pMOS_out <= not pMOS_ACTIVE;
			count := 0;
			
			next_state <= CHECK_OVF_STATE; 	-- Go to check overflow state.
		WHEN CHECK_OVF_STATE =>
			IF(count = CLOCK_PULSES_OUTPUT_RATE) THEN -- Used to set frequency for the output to the transistors
				IF(input = '1') THEN -- If input is high pMOS should be activated, ow nMOS activated.
					next_state <= pMOS_ACTIVE_STATE;
				ELSE
					next_state <= nMOS_ACTIVE_STATE;
				END IF;
				count := 0;
			ELSE
				count := count+1;
			END IF;
		WHEN pMOS_ACTIVE_STATE =>			-- pMOS on
			nMOS_out <= not nMOS_ACTIVE; 	-- Redundancy, just to make sure that we never fry any transistors.
			pMOS_out <= pMOS_ACTIVE;
			
			IF(count = CLOCK_PULSES_ACTIVE) THEN -- Has the pMOS been active long enough? If yes then change state, ow count++.
				next_state <= pMOS_INACTIVE_STATE;
				count := 0;
			ELSE
				count := count+1;
			END IF;
		WHEN pMOS_INACTIVE_STATE =>
			nMOS_out <= not nMOS_ACTIVE; -- Deactivate both nMOS and pMOS transistors.
			pMOS_out <= not pMOS_ACTIVE;
			
			IF(count = CLOCK_PULSES_INACTIVE) THEN -- Has the pMOS been deactivated long enough? If yes then change state, ow count++.
				next_state <= CHECK_OVF_STATE;
				count := 0;
			ELSE
				count := count+1;
			END IF;
		WHEN nMOS_ACTIVE_STATE =>
			pMOS_out <= not pMOS_ACTIVE; -- Redundancy, just to make sure that we never fry any transistors.
			nMOS_out <= nMOS_ACTIVE;
			
			IF(count = CLOCK_PULSES_ACTIVE) THEN --Has the pMOS been active long enough? If yes then change state, ow count++.
				next_state <= nMOS_INACTIVE_STATE;
				count := 0;
			ELSE
				count := count+1;
			END IF;
		WHEN nMOS_INACTIVE_STATE =>
			nMOS_out <= not nMOS_ACTIVE; -- Deactivate both nMOS and pMOS transistors.
			pMOS_out <= not pMOS_ACTIVE;

			IF(count = CLOCK_PULSES_INACTIVE) THEN -- Has the nMOS been deactivated long enough? If yes then change state, ow count++.
				next_state <= CHECK_OVF_STATE;
				count := 0;
			ELSE
				count := count+1;
			END IF;
		WHEN OTHERS =>
			next_state <= INIT_STATE;
	END CASE;
END PROCESS;

END pulse_train_logic_architecture;