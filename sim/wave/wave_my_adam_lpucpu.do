onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -divider SEQ
add wave -hex   /my_adam_tb/dut/adam_unwrap/lsdom_seq_clk
add wave -hex   /my_adam_tb/dut/adam_unwrap/lsdom_seq_rst
add wave -divider SYSCFG
add wave -hex   /my_adam_tb/dut/adam_unwrap/adam/adam_syscfg/lpcpu_rst
add wave -hex   /my_adam_tb/dut/adam_unwrap/adam/adam_syscfg/fab_lspb_rst
add wave -hex   /my_adam_tb/dut/adam_unwrap/adam/adam_syscfg/fab_lspb_rst

add wave -divider CPU_Maestro
add wave -hex   /my_adam_tb/dut/adam_unwrap/adam/adam_syscfg/genblk14[7]/tgt_cpu/tgt_rst
add wave -hex   /my_adam_tb/dut/adam_unwrap/adam/adam_syscfg/genblk14[7]/tgt_cpu/tgt_boot_addr
add wave -hex   /my_adam_tb/dut/adam_unwrap/adam/adam_syscfg/genblk14[7]/tgt_cpu/mr
add wave -hex   /my_adam_tb/dut/adam_unwrap/adam/adam_syscfg/genblk14[7]/tgt_cpu/sr
add wave -hex   /my_adam_tb/dut/adam_unwrap/adam/adam_syscfg/genblk14[7]/tgt_cpu/paused
add wave -hex   /my_adam_tb/dut/adam_unwrap/adam/adam_syscfg/genblk14[7]/tgt_cpu/stopped
add wave -hex   /my_adam_tb/dut/adam_unwrap/adam/adam_syscfg/genblk14[7]/tgt_cpu/state

add wave -divider CPU_INSTR
add wave -hex   /my_adam_tb/dut/adam_unwrap/adam/hsdom_cpu_axil[0]/ar_addr
add wave -hex   /my_adam_tb/dut/adam_unwrap/adam/hsdom_cpu_axil[0]/ar_valid
add wave -hex   /my_adam_tb/dut/adam_unwrap/adam/hsdom_cpu_axil[0]/r_data
add wave -hex   /my_adam_tb/dut/adam_unwrap/adam/hsdom_cpu_axil[0]/r_valid
add wave -hex   /my_adam_tb/dut/adam_unwrap/adam/hsdom_cpu_axil[0]/r_resp
add wave -divider CPU_DATA
add wave -hex   /my_adam_tb/dut/adam_unwrap/adam/hsdom_cpu_axil[1]/*
add wave -divider LPU_INSTR
add wave -hex   /my_adam_tb/dut/adam_unwrap/adam/lsdom_lpcpu_axil[0]/ar_addr
add wave -hex   /my_adam_tb/dut/adam_unwrap/adam/lsdom_lpcpu_axil[0]/ar_valid
add wave -hex   /my_adam_tb/dut/adam_unwrap/adam/lsdom_lpcpu_axil[0]/ar_ready
add wave -hex   /my_adam_tb/dut/adam_unwrap/adam/lsdom_lpcpu_axil[0]/r_data
add wave -hex   /my_adam_tb/dut/adam_unwrap/adam/lsdom_lpcpu_axil[0]/r_valid
add wave -hex   /my_adam_tb/dut/adam_unwrap/adam/lsdom_lpcpu_axil[0]/r_resp

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
add wave -hex /my_adam_tb/dut/lspa_uart_rx[0]/i

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