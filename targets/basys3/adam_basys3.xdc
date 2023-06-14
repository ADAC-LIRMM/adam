# Basys3

# Clock signal
set_property PACKAGE_PIN W5 [get_ports clk100]
set_property IOSTANDARD LVCMOS33 [get_ports clk100]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk100]

# Switches
set_property PACKAGE_PIN V17 [get_ports {sw[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[0]}]
set_property PACKAGE_PIN V16 [get_ports {sw[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[1]}]
set_property PACKAGE_PIN W16 [get_ports {sw[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[2]}]
set_property PACKAGE_PIN W17 [get_ports {sw[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[3]}]
set_property PACKAGE_PIN W15 [get_ports {sw[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[4]}]
set_property PACKAGE_PIN V15 [get_ports {sw[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[5]}]
set_property PACKAGE_PIN W14 [get_ports {sw[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[6]}]
set_property PACKAGE_PIN W13 [get_ports {sw[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[7]}]
set_property PACKAGE_PIN V2 [get_ports {sw[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[8]}]
set_property PACKAGE_PIN T3 [get_ports {sw[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[9]}]
set_property PACKAGE_PIN T2 [get_ports {sw[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[10]}]
set_property PACKAGE_PIN R3 [get_ports {sw[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[11]}]
set_property PACKAGE_PIN W2 [get_ports {sw[12]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[12]}]
set_property PACKAGE_PIN U1 [get_ports {sw[13]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[13]}]
set_property PACKAGE_PIN T1 [get_ports {sw[14]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[14]}]
set_property PACKAGE_PIN R2 [get_ports {sw[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[15]}]

# LEDs
set_property PACKAGE_PIN U16 [get_ports {led[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]
set_property PACKAGE_PIN E19 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[1]}]
set_property PACKAGE_PIN U19 [get_ports {led[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[2]}]
set_property PACKAGE_PIN V19 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[3]}]
set_property PACKAGE_PIN W18 [get_ports {led[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[4]}]
set_property PACKAGE_PIN U15 [get_ports {led[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[5]}]
set_property PACKAGE_PIN U14 [get_ports {led[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[6]}]
set_property PACKAGE_PIN V14 [get_ports {led[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[7]}]
set_property PACKAGE_PIN V13 [get_ports {led[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[8]}]
set_property PACKAGE_PIN V3 [get_ports {led[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[9]}]
set_property PACKAGE_PIN W3 [get_ports {led[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[10]}]
set_property PACKAGE_PIN U3 [get_ports {led[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[11]}]
set_property PACKAGE_PIN P3 [get_ports {led[12]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[12]}]
set_property PACKAGE_PIN N3 [get_ports {led[13]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[13]}]
set_property PACKAGE_PIN P1 [get_ports {led[14]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[14]}]
set_property PACKAGE_PIN L1 [get_ports {led[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[15]}]

# Buttons
set_property PACKAGE_PIN U18 [get_ports btn_c]
set_property IOSTANDARD LVCMOS33 [get_ports btn_c]
set_property PACKAGE_PIN T18 [get_ports btn_u]
set_property IOSTANDARD LVCMOS33 [get_ports btn_u]
set_property PACKAGE_PIN W19 [get_ports btn_l]
set_property IOSTANDARD LVCMOS33 [get_ports btn_l]
set_property PACKAGE_PIN T17 [get_ports btn_r]
set_property IOSTANDARD LVCMOS33 [get_ports btn_r]
set_property PACKAGE_PIN U17 [get_ports btn_d]
set_property IOSTANDARD LVCMOS33 [get_ports btn_d]

# Header JA
#Sch name = JA1
set_property PACKAGE_PIN J1 [get_ports {header_ja[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {header_ja[0]}]
#Sch name = JA2
set_property PACKAGE_PIN L2 [get_ports {header_ja[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {header_ja[1]}]
#Sch name = JA3
set_property PACKAGE_PIN J2 [get_ports {header_ja[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {header_ja[2]}]
#Sch name = JA4
set_property PACKAGE_PIN G2 [get_ports {header_ja[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {header_ja[3]}]
#Sch name = JA7
set_property PACKAGE_PIN H1 [get_ports {header_ja[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {header_ja[4]}]
#Sch name = JA8
set_property PACKAGE_PIN K2 [get_ports {header_ja[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {header_ja[5]}]
#Sch name = JA9
set_property PACKAGE_PIN H2 [get_ports {header_ja[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {header_ja[6]}]
#Sch name = JA10
set_property PACKAGE_PIN G3 [get_ports {header_ja[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {header_ja[7]}]

# Header JB
#Sch name = JB1
set_property PACKAGE_PIN A14 [get_ports {header_jb[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {header_jb[0]}]
#Sch name = JB2
set_property PACKAGE_PIN A16 [get_ports {header_jb[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {header_jb[1]}]
#Sch name = JB3
set_property PACKAGE_PIN B15 [get_ports {header_jb[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {header_jb[2]}]
#Sch name = JB4
set_property PACKAGE_PIN B16 [get_ports {header_jb[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {header_jb[3]}]
#Sch name = JB7
set_property PACKAGE_PIN A15 [get_ports {header_jb[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {header_jb[4]}]
#Sch name = JB8
set_property PACKAGE_PIN A17 [get_ports {header_jb[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {header_jb[5]}]
#Sch name = JB9
set_property PACKAGE_PIN C15 [get_ports {header_jb[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {header_jb[6]}]
#Sch name = JB10
set_property PACKAGE_PIN C16 [get_ports {header_jb[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {header_jb[7]}]

# Header JC
#Sch name = JC1
set_property PACKAGE_PIN K17 [get_ports {header_jc[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {header_jc[0]}]
#Sch name = JC2
set_property PACKAGE_PIN M18 [get_ports {header_jc[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {header_jc[1]}]
#Sch name = JC3
set_property PACKAGE_PIN N17 [get_ports {header_jc[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {header_jc[2]}]
#Sch name = JC4
set_property PACKAGE_PIN P18 [get_ports {header_jc[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {header_jc[3]}]
#Sch name = JC7
set_property PACKAGE_PIN L17 [get_ports {header_jc[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {header_jc[4]}]
#Sch name = JC8
set_property PACKAGE_PIN M19 [get_ports {header_jc[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {header_jc[5]}]
#Sch name = JC9
set_property PACKAGE_PIN P17 [get_ports {header_jc[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {header_jc[6]}]
#Sch name = JC10
set_property PACKAGE_PIN R18 [get_ports {header_jc[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {header_jc[7]}]

# UART
set_property PACKAGE_PIN B18 [get_ports uart_rx]
set_property IOSTANDARD LVCMOS33 [get_ports uart_rx]
set_property PACKAGE_PIN A18 [get_ports uart_tx]
set_property IOSTANDARD LVCMOS33 [get_ports uart_tx]