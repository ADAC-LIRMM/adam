set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

# Clock =======================================================================
set_property -dict {PACKAGE_PIN W5 IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk]

# Switches ====================================================================
# set_property -dict {PACKAGE_PIN V17 IOSTANDARD LVCMOS33} [get_ports {sw[0]}]
# set_property -dict {PACKAGE_PIN V16 IOSTANDARD LVCMOS33} [get_ports {sw[1]}]
# set_property -dict {PACKAGE_PIN W16 IOSTANDARD LVCMOS33} [get_ports {sw[2]}]
# set_property -dict {PACKAGE_PIN W17 IOSTANDARD LVCMOS33} [get_ports {sw[3]}]
# set_property -dict {PACKAGE_PIN W15 IOSTANDARD LVCMOS33} [get_ports {sw[4]}]
# set_property -dict {PACKAGE_PIN V15 IOSTANDARD LVCMOS33} [get_ports {sw[5]}]
# set_property -dict {PACKAGE_PIN W14 IOSTANDARD LVCMOS33} [get_ports {sw[6]}]
# set_property -dict {PACKAGE_PIN W13 IOSTANDARD LVCMOS33} [get_ports {sw[7]}]
# set_property -dict {PACKAGE_PIN V2 IOSTANDARD LVCMOS33} [get_ports {sw[8]}]
# set_property -dict {PACKAGE_PIN T3 IOSTANDARD LVCMOS33} [get_ports {sw[9]}]
# set_property -dict {PACKAGE_PIN T2 IOSTANDARD LVCMOS33} [get_ports {sw[10]}]
# set_property -dict {PACKAGE_PIN R3 IOSTANDARD LVCMOS33} [get_ports {sw[11]}]
# set_property -dict {PACKAGE_PIN W2 IOSTANDARD LVCMOS33} [get_ports {sw[12]}]
# set_property -dict {PACKAGE_PIN U1 IOSTANDARD LVCMOS33} [get_ports {sw[13]}]
# set_property -dict {PACKAGE_PIN T1 IOSTANDARD LVCMOS33} [get_ports {sw[14]}]
# set_property -dict {PACKAGE_PIN R2 IOSTANDARD LVCMOS33} [get_ports {sw[15]}]

# LEDs ========================================================================
set_property -dict {PACKAGE_PIN U16 IOSTANDARD LVCMOS33} [get_ports {gpio_io[0]}]
set_property -dict {PACKAGE_PIN E19 IOSTANDARD LVCMOS33} [get_ports {gpio_io[1]}]
set_property -dict {PACKAGE_PIN U19 IOSTANDARD LVCMOS33} [get_ports {gpio_io[2]}]
set_property -dict {PACKAGE_PIN V19 IOSTANDARD LVCMOS33} [get_ports {gpio_io[3]}]
set_property -dict {PACKAGE_PIN W18 IOSTANDARD LVCMOS33} [get_ports {gpio_io[4]}]
set_property -dict {PACKAGE_PIN U15 IOSTANDARD LVCMOS33} [get_ports {gpio_io[5]}]
set_property -dict {PACKAGE_PIN U14 IOSTANDARD LVCMOS33} [get_ports {gpio_io[6]}]
set_property -dict {PACKAGE_PIN V14 IOSTANDARD LVCMOS33} [get_ports {gpio_io[7]}]
set_property -dict {PACKAGE_PIN V13 IOSTANDARD LVCMOS33} [get_ports {gpio_io[8]}]
set_property -dict {PACKAGE_PIN V3 IOSTANDARD LVCMOS33} [get_ports {gpio_io[9]}]
set_property -dict {PACKAGE_PIN W3 IOSTANDARD LVCMOS33} [get_ports {gpio_io[10]}]
set_property -dict {PACKAGE_PIN U3 IOSTANDARD LVCMOS33} [get_ports {gpio_io[11]}]
set_property -dict {PACKAGE_PIN P3 IOSTANDARD LVCMOS33} [get_ports {gpio_io[12]}]
set_property -dict {PACKAGE_PIN N3 IOSTANDARD LVCMOS33} [get_ports {gpio_io[13]}]
set_property -dict {PACKAGE_PIN P1 IOSTANDARD LVCMOS33} [get_ports {gpio_io[14]}]
set_property -dict {PACKAGE_PIN L1 IOSTANDARD LVCMOS33} [get_ports {gpio_io[15]}]

# Buttons =====================================================================
set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports rstn]
# set_property -dict {PACKAGE_PIN T18 IOSTANDARD LVCMOS33} [get_ports btn_u]
# set_property -dict {PACKAGE_PIN W19 IOSTANDARD LVCMOS33} [get_ports btn_l]
# set_property -dict {PACKAGE_PIN T17 IOSTANDARD LVCMOS33} [get_ports btn_r]
# set_property -dict {PACKAGE_PIN U17 IOSTANDARD LVCMOS33} [get_ports btn_d]

# Pmod Header JA ==============================================================

# set_property -dict {PACKAGE_PIN J1 IOSTANDARD LVCMOS33} [get_ports {JA[0]}]
# set_property -dict {PACKAGE_PIN L2 IOSTANDARD LVCMOS33} [get_ports {JA[1]}]
# set_property -dict {PACKAGE_PIN J2 IOSTANDARD LVCMOS33} [get_ports {JA[2]}]
# set_property -dict {PACKAGE_PIN G2 IOSTANDARD LVCMOS33} [get_ports {JA[3]}]
# set_property -dict {PACKAGE_PIN H1 IOSTANDARD LVCMOS33} [get_ports {JA[4]}]
# set_property -dict {PACKAGE_PIN K2 IOSTANDARD LVCMOS33} [get_ports {JA[5]}]
# set_property -dict {PACKAGE_PIN H2 IOSTANDARD LVCMOS33} [get_ports {JA[6]}]
# set_property -dict {PACKAGE_PIN G3 IOSTANDARD LVCMOS33} [get_ports {JA[7]}]

# Pmod Header JB ==============================================================

# set_property -dict {PACKAGE_PIN A14 IOSTANDARD LVCMOS33} [get_ports {JB[0]}]
# set_property -dict {PACKAGE_PIN A16 IOSTANDARD LVCMOS33} [get_ports {JB[1]}]
# set_property -dict {PACKAGE_PIN B15 IOSTANDARD LVCMOS33} [get_ports {JB[2]}]
# set_property -dict {PACKAGE_PIN B16 IOSTANDARD LVCMOS33} [get_ports {JB[3]}]
# set_property -dict {PACKAGE_PIN A15 IOSTANDARD LVCMOS33} [get_ports {JB[4]}]
# set_property -dict {PACKAGE_PIN A17 IOSTANDARD LVCMOS33} [get_ports {JB[5]}]
# set_property -dict {PACKAGE_PIN C15 IOSTANDARD LVCMOS33} [get_ports {JB[6]}]
# set_property -dict {PACKAGE_PIN C16 IOSTANDARD LVCMOS33} [get_ports {JB[7]}]

# Pmod Header JC (JTAG) =======================================================
set_property -dict {PACKAGE_PIN K17 IOSTANDARD LVCMOS33} [get_ports jtag_tms]
set_property -dict {PACKAGE_PIN M18 IOSTANDARD LVCMOS33} [get_ports jtag_tdo]
set_property -dict {PACKAGE_PIN N17 IOSTANDARD LVCMOS33} [get_ports jtag_tdi]
set_property -dict {PACKAGE_PIN P18 IOSTANDARD LVCMOS33} [get_ports jtag_tck]

create_clock -period 100.000 -name jtag_tck -waveform {0.000 50.000} [get_ports jtag_tck]
set_input_jitter jtag_tck 1.000
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets jtag_tck]

set_input_delay -clock jtag_tck -clock_fall 5.000 [get_ports jtag_tdi]
set_input_delay -clock jtag_tck -clock_fall 5.000 [get_ports jtag_tms]
set_output_delay -clock jtag_tck 5.000 [get_ports jtag_tdo]

set_max_delay -datapath_only -from [get_pins adam/adam_debug/dmi_jtag/i_dmi_cdc/i_cdc_resp/i_src/data_src_q_reg*/C] -to [get_pins adam/adam_debug/dmi_jtag/i_dmi_cdc/i_cdc_resp/i_dst/data_dst_q_reg*/D] 20.000
set_max_delay -datapath_only -from [get_pins adam/adam_debug/dmi_jtag/i_dmi_cdc/i_cdc_resp/i_src/req_src_q_reg/C] -to [get_pins adam/adam_debug/dmi_jtag/i_dmi_cdc/i_cdc_resp/i_dst/req_dst_q_reg/D] 20.000
set_max_delay -datapath_only -from [get_pins adam/adam_debug/dmi_jtag/i_dmi_cdc/i_cdc_req/i_dst/ack_dst_q_reg/C] -to [get_pins adam/adam_debug/dmi_jtag/i_dmi_cdc/i_cdc_req/i_src/ack_src_q_reg/D] 20.000

# Pmod Header JXADC ===========================================================
# set_property -dict {PACKAGE_PIN J3 IOSTANDARD LVCMOS33} [get_ports {JXADC[0]}]
# set_property -dict {PACKAGE_PIN L3 IOSTANDARD LVCMOS33} [get_ports {JXADC[1]}]
# set_property -dict {PACKAGE_PIN K3 IOSTANDARD LVCMOS33} [get_ports {JXADC[2]}]
# set_property -dict {PACKAGE_PIN M3 IOSTANDARD LVCMOS33} [get_ports {JXADC[3]}]
# set_property -dict {PACKAGE_PIN N3 IOSTANDARD LVCMOS33} [get_ports {JXADC[4]}]
# set_property -dict {PACKAGE_PIN P2 IOSTANDARD LVCMOS33} [get_ports {JXADC[5]}]
# set_property -dict {PACKAGE_PIN P1 IOSTANDARD LVCMOS33} [get_ports {JXADC[6]}]
# set_property -dict {PACKAGE_PIN N1 IOSTANDARD LVCMOS33} [get_ports {JXADC[7]}]

# VGA Connector ===============================================================
# set_property -dict {PACKAGE_PIN G19 IOSTANDARD LVCMOS33} [get_ports {vga_red[0]}]
# set_property -dict {PACKAGE_PIN F19 IOSTANDARD LVCMOS33} [get_ports {vga_red[1]}]
# set_property -dict {PACKAGE_PIN G18 IOSTANDARD LVCMOS33} [get_ports {vga_green[0]}]
# set_property -dict {PACKAGE_PIN F18 IOSTANDARD LVCMOS33} [get_ports {vga_green[1]}]
# set_property -dict {PACKAGE_PIN G17 IOSTANDARD LVCMOS33} [get_ports {vga_blue[0]}]
# set_property -dict {PACKAGE_PIN F17 IOSTANDARD LVCMOS33} [get_ports {vga_blue[1]}]
# set_property -dict {PACKAGE_PIN G16 IOSTANDARD LVCMOS33} [get_ports {vga_hsync}]
# set_property -dict {PACKAGE_PIN F16 IOSTANDARD LVCMOS33} [get_ports {vga_vsync}]

# USB-RS232 Interface ========================================================
set_property -dict {PACKAGE_PIN B18 IOSTANDARD LVCMOS33} [get_ports rs_rx]
set_property -dict {PACKAGE_PIN A18 IOSTANDARD LVCMOS33} [get_ports rs_tx]

# USB HID (PS/2) ==============================================================
# set_property -dict {PACKAGE_PIN C17 IOSTANDARD LVCMOS33} [get_ports ps2_clk]
# set_property -dict {PACKAGE_PIN B17 IOSTANDARD LVCMOS33} [get_ports ps2_data]

# Quad SPI Flash =============================================================
# set_property -dict {PACKAGE_PIN D18 IOSTANDARD LVCMOS33} [get_ports {qspi_db[0]}]
# set_property -dict {PACKAGE_PIN D19 IOSTANDARD LVCMOS33} [get_ports {qspi_db[1]}]
# set_property -dict {PACKAGE_PIN E18 IOSTANDARD LVCMOS33} [get_ports {qspi_db[2]}]
# set_property -dict {PACKAGE_PIN E17 IOSTANDARD LVCMOS33} [get_ports {qspi_db[3]}]
# set_property -dict {PACKAGE_PIN F18 IOSTANDARD LVCMOS33} [get_ports {qspi_db[4]}]
# set_property -dict {PACKAGE_PIN F17 IOSTANDARD LVCMOS33} [get_ports {qspi_db[5]}]
# set_property -dict {PACKAGE_PIN G18 IOSTANDARD LVCMOS33} [get_ports {qspi_db[6]}]
# set_property -dict {PACKAGE_PIN G17 IOSTANDARD LVCMOS33} [get_ports {qspi_db[7]}]
