onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -divider Top_level
add wave -hex /adam_zybo_tb/*
add wave -divider CPU_INSTR
add wave -hex /adam_zybo_tb/dut/adam/hsdom_cpu_axil[0]/ar_addr
add wave -hex /adam_zybo_tb/dut/adam/hsdom_cpu_axil[0]/ar_prot 
add wave -hex /adam_zybo_tb/dut/adam/hsdom_cpu_axil[0]/ar_valid 
add wave -hex /adam_zybo_tb/dut/adam/hsdom_cpu_axil[0]/ar_ready 
add wave -hex /adam_zybo_tb/dut/adam/hsdom_cpu_axil[0]/r_data
add wave -hex /adam_zybo_tb/dut/adam/hsdom_cpu_axil[0]/r_resp 
add wave -hex /adam_zybo_tb/dut/adam/hsdom_cpu_axil[0]/r_valid 
add wave -hex /adam_zybo_tb/dut/adam/hsdom_cpu_axil[0]/r_ready
add wave -divider aaaa
add wave -hex /adam_zybo_tb/dut/lsdom_seq/*
add wave -hex /adam_zybo_tb/dut/lspa_gpio_io[0]/o
add wave -hex /adam_zybo_tb/dut/lspa_gpio_io[1]/o
add wave -hex /adam_zybo_tb/dut/lspa_gpio_io[2]/o
add wave -hex /adam_zybo_tb/dut/lspa_gpio_io[3]/o


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