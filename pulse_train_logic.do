-- Header
vsim work.pulse_train_logic
add wave clk input reset current_state next_state
radix -decimal
view wave

-- Simulation Commands
force clk 0 0ns, 1 5ns -repeat 10ns
force reset 0
force input 0

run 10000ns

wave zoom full