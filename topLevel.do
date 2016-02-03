vsim work.topLevel
add wave sys_clk areset converter_out pMOS_out nMOS_out
add wave -position end  sim:/toplevel/converter/delay/input
add wave -position end  sim:/toplevel/converter/delay/output

force sys_clk 0 0, 1 5ns -repeat 10ns

force areset 1
run 10 ns
force areset 0


run 100000ns
