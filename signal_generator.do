-- Header
vsim work.signal_generator
add wave clk reset squareWave 
add wave -format analog-step -min -0 -max 4096 -height 74 squareWave
add wave -format analog-step -min -0 -max 4096 -height 74 sawTooth
add wave -format analog-step -min -0 -max 4096 -height 74 sineWave
radix -unsigned
view wave

-- Simulation Commands
force clk 0 0ns, 1 5ns -repeat 10ns
force reset 0

run 500000ns

wave zoom full