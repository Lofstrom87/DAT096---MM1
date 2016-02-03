restart -f -nowave
add wave clk areset data overflow delay_output delay_input

force clk 0 0, 1 5ns -repeat 10ns

force areset 1
run 10 ns
force areset 0

force data 2#111111111100
run 7ns
force data 1

run 100ns
