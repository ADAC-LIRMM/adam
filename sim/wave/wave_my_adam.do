onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -divider SEQ
add wave -hex   /my_adam_tb/dut/adam_unwrap/lsdom_seq_clk
add wave -hex   /my_adam_tb/dut/adam_unwrap/lsdom_seq_rst
add wave -hex   /my_adam_tb/dut/adam_unwrap/hsdom_seq_clk
add wave -hex   /my_adam_tb/dut/adam_unwrap/hsdom_seq_rst
add wave -divider SYSCFG
add wave -hex   /my_adam_tb/dut/adam_unwrap/adam/adam_syscfg/*
add wave -divider CPU_Maestro
add wave -hex   /my_adam_tb/dut/adam_unwrap/adam/adam_syscfg/genblk14[7]/tgt_cpu/*
add wave -divider CPU_INSTR
add wave -hex   /my_adam_tb/dut/adam_unwrap/adam/hsdom_cpu_axil[0]/ar_addr
add wave -hex   /my_adam_tb/dut/adam_unwrap/adam/hsdom_cpu_axil[0]/ar_valid
add wave -hex   /my_adam_tb/dut/adam_unwrap/adam/hsdom_cpu_axil[0]/ar_ready
add wave -hex   /my_adam_tb/dut/adam_unwrap/adam/hsdom_cpu_axil[0]/r_data
add wave -hex   /my_adam_tb/dut/adam_unwrap/adam/hsdom_cpu_axil[0]/r_valid
add wave -hex   /my_adam_tb/dut/adam_unwrap/adam/hsdom_cpu_axil[0]/r_resp
add wave -hex   /my_adam_tb/dut/adam_unwrap/adam/hsdom_cpu_axil[0]/r_ready
add wave -hex   /my_adam_tb/dut/adam_unwrap/adam/genblk4[0]/hsdom_cpu/cv32e40p_top/core_i/id_stage_i/register_file_i/mem
add wave -hex   /my_adam_tb/dut/adam_unwrap/adam/genblk4[0]/hsdom_cpu/cv32e40p_top/core_i/id_stage_i/register_file_i/mem_fp
add wave -divider CPU_DATA
add wave -hex   /my_adam_tb/dut/adam_unwrap/adam/hsdom_cpu_axil[1]/*
add wave -divider MEMDATA
add wave -hex   /my_adam_tb/genblk3[1]/adam_mem/*
add wave -divider LPU_INSTR
add wave -hex   /my_adam_tb/dut/adam_unwrap/adam/lsdom_lpcpu_axil[0]/ar_addr
add wave -hex   /my_adam_tb/dut/adam_unwrap/adam/lsdom_lpcpu_axil[0]/ar_valid
add wave -hex   /my_adam_tb/dut/adam_unwrap/adam/lsdom_lpcpu_axil[0]/ar_ready
add wave -hex   /my_adam_tb/dut/adam_unwrap/adam/lsdom_lpcpu_axil[0]/r_data
add wave -hex   /my_adam_tb/dut/adam_unwrap/adam/lsdom_lpcpu_axil[0]/r_valid
add wave -hex   /my_adam_tb/dut/adam_unwrap/adam/lsdom_lpcpu_axil[0]/r_resp
add wave -hex   /my_adam_tb/dut/adam_unwrap/adam/lsdom_lpcpu_axil[0]/r_ready
add wave -hex   /my_adam_tb/dut/adam_unwrap/adam/genblk1/lsdom_lpcpu/cv32e40p_top/core_i/id_stage_i/register_file_i/mem

add wave -divider GPIO_UART
add wave -hex /my_adam_tb/dut/lspa_gpio_io[0]/o
add wave -hex /my_adam_tb/dut/lspa_gpio_io[1]/o
add wave -hex /my_adam_tb/dut/lspa_gpio_io[2]/o
add wave -hex /my_adam_tb/dut/lspa_gpio_io[3]/o
add wave -hex /my_adam_tb/dut/lspa_gpio_io[4]/o
add wave -hex /my_adam_tb/dut/lspa_gpio_io[5]/o
add wave -hex /my_adam_tb/dut/lspa_gpio_io[6]/o
add wave -hex /my_adam_tb/dut/lspa_gpio_io[7]/o
add wave -hex /my_adam_tb/dut/lspa_uart_tx[0]/o

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