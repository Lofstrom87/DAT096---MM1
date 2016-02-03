-- Signal generator
-- Used to generate signals to test sigma delta output
-- 2016-02-03

--TODO FIX comments

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
use ieee.std_logic_arith.all;


ENTITY signal_generator IS
	generic(N: integer := 12); 
	port(
		clk,reset: IN STD_LOGIC;
		sawTooth, squareWave, sineWave: OUT STD_LOGIC_VECTOR(N-1 downto 0)
	);
END signal_generator;

ARCHITECTURE signal_generator_architecture OF signal_generator IS
	type waveArray is array (0 to 31) of STD_LOGIC_VECTOR(N-1 downto 0); -- Array for lookuptable for sinewave
	
	CONSTANT MAX_VALUE: INTEGER := 4096;
	CONSTANT VALUE_STEP: INTEGER := 10;
	CONSTANT RESET_ACTIVE: STD_LOGIC := '1';
	CONSTANT FREQUENCY_COUNT_MAX: INTEGER := 5000; --  = 100MHZ/DesiredFreq
BEGIN

PROCESS(clk, reset) -- Generate SineWave
Variable sineWaveArray: waveArray := (x"800",x"98f",x"b0f",x"c71",x"da7",x"ea6",x"f63",x"fd8",x"fff",x"fd8",x"f63",x"ea6",x"da7",x"c71",x"b0f",x"98f",x"800",x"671",x"4f1",x"38f",x"259",x"15a",x"09d",x"028",x"001",x"028",x"09d",x"15a",x"259",x"38f",x"4f1",x"671");
Variable frequencyCounterSinewave: integer := 0;
Variable arrayIndexer: integer := 0;
BEGIN
	IF(RESET = RESET_ACTIVE) THEN
		sineWave <= (others => '0');
	ELSIF(rising_edge(clk)) THEN
		IF(frequencyCounterSinewave = FREQUENCY_COUNT_MAX/32) THEN
			IF(arrayIndexer <= 31) THEN
				sineWave <= sineWaveArray(arrayIndexer);
				arrayIndexer := arrayIndexer+1;
			ELSE
				arrayIndexer := 0;
			END IF;
			frequencyCounterSinewave := 0;
		ELSE
			frequencyCounterSinewave := frequencyCounterSinewave+1;
		END IF;
	END IF;

END PROCESS;

PROCESS(clk,reset) -- Generate sawtooth
Variable sawToothValue: integer := 0;
Variable frequencyCounterSawtooth: integer := 0;
BEGIN
	IF(RESET = RESET_ACTIVE) THEN
		sawTooth <= (others=>'0');
	ELSIF(rising_edge(clk))THEN
		IF(frequencyCounterSawtooth = (FREQUENCY_COUNT_MAX/(MAX_VALUE/VALUE_STEP))) THEN
			sawTooth <= conv_std_logic_vector(sawToothValue, N);
			IF(sawToothValue < MAX_VALUE+VALUE_STEP) THEN
				sawToothValue := sawToothValue+VALUE_STEP;
			ELSE
				sawToothValue := 0;
			END IF;
			frequencyCounterSawtooth := 0;
		ELSE
			frequencyCounterSawtooth := frequencyCounterSawtooth+1;
		END IF;
	END IF;
END PROCESS;

PROCESS(clk,reset) -- Generate squarewave
Variable frequencyCounterSquare: integer := 0;
Variable outPrev: STD_LOGIC := '0';
BEGIN
	IF(RESET = RESET_ACTIVE) THEN
		squareWave <= (others=>'0');
	ELSIF(rising_edge(clk))THEN
		IF(frequencyCounterSquare = FREQUENCY_COUNT_MAX/2) THEN
			IF(outPrev = '0')THEN
				squareWave <= (others => '1');
				outPrev := '1';
			ELSE
				squareWave <= (others => '0');
				outPrev := '0';
			END IF;
			frequencyCounterSquare := 0;
		ELSE
			frequencyCounterSquare := frequencyCounterSquare+1;
		END IF;
	END IF;
END PROCESS;

END signal_generator_architecture;