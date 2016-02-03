-- Header
vsim work.shift_reg
add wave serial_in clk reset word_select parallel_out
radix -decimal
view wave

-- Simulation Commands
force clk 0 0ns, 1 5ns -repeat 10ns
force reset 0
force serial_in 1
force word_select 1

run 120ns
force word_select 0

wave zoom full