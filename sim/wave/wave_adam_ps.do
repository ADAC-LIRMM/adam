onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -hex /ps_adam_tb/hsdom_seq/*
add wave -hex /ps_adam_tb/lsdom_seq/*
add wave -hex /ps_adam_tb/dut/adam_unwrap/lsdom_seq_rst
add wave -hex /ps_adam_tb/dut/adam_unwrap/adam/lsdom_lpcpu_rst 
add wave -hex /ps_adam_tb/dut/adam_unwrap/adam/lsdom_lpcpu_seq_rst 
add wave -hex /ps_adam_tb/dut/adam_unwrap/adam/\hsdom_cpu_rst[0]  
add wave -hex /ps_adam_tb/dut/adam_unwrap/adam/hsdom_cpu_seq_0__rst

add wave -hex /ps_adam_tb/genblk2[1]/adam_axil_to_mem/*
add wave -hex /ps_adam_tb/hsdom_mem_axil[1]/*

add wave -hex /ps_adam_tb/dut/adam_unwrap/adam/*
add wave -divider CPU 
add wave -hex /ps_adam_tb/dut/adam_unwrap/adam/genblk4_0__hsdom_cpu/*
add wave -divider SYSCFG
add wave -hex /ps_adam_tb/dut/adam_unwrap/adam/adam_syscfg/*
add wave -divider Fabric
add wave -hex /ps_adam_tb/dut/adam_unwrap/adam/adam_fabric/*

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