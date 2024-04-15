onerror {resume}
quietly WaveActivateNextPane {} 0
# add wave -divider GPIO_UART
# add wave -hex   /ps_adam_tb/dut/adam_unwrap/*
# add wave -hex   /ps_adam_tb/dut/hsdom_seq/*
add wave -divider HSDOM
add wave -hex   /ps_adam_tb/dut/lsdom_seq/*
add wave -hex   /ps_adam_tb/dut/adam_unwrap/adam/genblk1_lsdom_lpcpu/*
add wave -hex   /ps_adam_tb/dut/adam_unwrap/adam/adam_fabric/adam_fabric_lsdom/*

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {434910 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 258
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update