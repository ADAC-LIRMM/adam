# Clock =======================================================================

set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 10 -waveform {0 5} [get_ports clk]

# Switches ====================================================================

# set_property PACKAGE_PIN V17 [get_ports {sw[0]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {sw[0]}]
# set_property PACKAGE_PIN V16 [get_ports {sw[1]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {sw[1]}]
# set_property PACKAGE_PIN W16 [get_ports {sw[2]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {sw[2]}]
# set_property PACKAGE_PIN W17 [get_ports {sw[3]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {sw[3]}]
# set_property PACKAGE_PIN W15 [get_ports {sw[4]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {sw[4]}]
# set_property PACKAGE_PIN V15 [get_ports {sw[5]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {sw[5]}]
# set_property PACKAGE_PIN W14 [get_ports {sw[6]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {sw[6]}]
# set_property PACKAGE_PIN W13 [get_ports {sw[7]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {sw[7]}]
# set_property PACKAGE_PIN V2 [get_ports {sw[8]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {sw[8]}]
# set_property PACKAGE_PIN T3 [get_ports {sw[9]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {sw[9]}]
# set_property PACKAGE_PIN T2 [get_ports {sw[10]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {sw[10]}]
# set_property PACKAGE_PIN R3 [get_ports {sw[11]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {sw[11]}]
# set_property PACKAGE_PIN W2 [get_ports {sw[12]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {sw[12]}]
# set_property PACKAGE_PIN U1 [get_ports {sw[13]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {sw[13]}]
# set_property PACKAGE_PIN T1 [get_ports {sw[14]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {sw[14]}]
# set_property PACKAGE_PIN R2 [get_ports {sw[15]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {sw[15]}]

# LEDs ========================================================================

set_property PACKAGE_PIN U16 [get_ports {gpio_io[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {gpio_io[0]}]
set_property PACKAGE_PIN E19 [get_ports {gpio_io[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {gpio_io[1]}]
set_property PACKAGE_PIN U19 [get_ports {gpio_io[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {gpio_io[2]}]
set_property PACKAGE_PIN V19 [get_ports {gpio_io[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {gpio_io[3]}]
set_property PACKAGE_PIN W18 [get_ports {gpio_io[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {gpio_io[4]}]
set_property PACKAGE_PIN U15 [get_ports {gpio_io[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {gpio_io[5]}]
set_property PACKAGE_PIN U14 [get_ports {gpio_io[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {gpio_io[6]}]
set_property PACKAGE_PIN V14 [get_ports {gpio_io[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {gpio_io[7]}]
set_property PACKAGE_PIN V13 [get_ports {gpio_io[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {gpio_io[8]}]
set_property PACKAGE_PIN V3 [get_ports {gpio_io[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {gpio_io[9]}]
set_property PACKAGE_PIN W3 [get_ports {gpio_io[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {gpio_io[10]}]
set_property PACKAGE_PIN U3 [get_ports {gpio_io[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {gpio_io[11]}]
set_property PACKAGE_PIN P3 [get_ports {gpio_io[12]}]
set_property IOSTANDARD LVCMOS33 [get_ports {gpio_io[12]}]
set_property PACKAGE_PIN N3 [get_ports {gpio_io[13]}]
set_property IOSTANDARD LVCMOS33 [get_ports {gpio_io[13]}]
set_property PACKAGE_PIN P1 [get_ports {gpio_io[14]}]
set_property IOSTANDARD LVCMOS33 [get_ports {gpio_io[14]}]
set_property PACKAGE_PIN L1 [get_ports {gpio_io[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {gpio_io[15]}]

# 7 segment display ===========================================================

# set_property PACKAGE_PIN W7 [get_ports {seg[0]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {seg[0]}]
# set_property PACKAGE_PIN W6 [get_ports {seg[1]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {seg[1]}]
# set_property PACKAGE_PIN U8 [get_ports {seg[2]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {seg[2]}]
# set_property PACKAGE_PIN V8 [get_ports {seg[3]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {seg[3]}]
# set_property PACKAGE_PIN U5 [get_ports {seg[4]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {seg[4]}]
# set_property PACKAGE_PIN V5 [get_ports {seg[5]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {seg[5]}]
# set_property PACKAGE_PIN U7 [get_ports {seg[6]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {seg[6]}]
# set_property PACKAGE_PIN V7 [get_ports dp]
# set_property IOSTANDARD LVCMOS33 [get_ports dp]
# set_property PACKAGE_PIN U2 [get_ports {an[0]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {an[0]}]
# set_property PACKAGE_PIN U4 [get_ports {an[1]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {an[1]}]
# set_property PACKAGE_PIN V4 [get_ports {an[2]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {an[2]}]
# set_property PACKAGE_PIN W4 [get_ports {an[3]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {an[3]}]

# Buttons =====================================================================

set_property PACKAGE_PIN U18 [get_ports rstn]
set_property IOSTANDARD LVCMOS33 [get_ports rstn]
# set_property PACKAGE_PIN T18 [get_ports btn_u]
# set_property IOSTANDARD LVCMOS33 [get_ports btn_u]
# set_property PACKAGE_PIN W19 [get_ports btn_l]
# set_property IOSTANDARD LVCMOS33 [get_ports btn_l]
# set_property PACKAGE_PIN T17 [get_ports btn_r]
# set_property IOSTANDARD LVCMOS33 [get_ports btn_r]
# set_property PACKAGE_PIN U17 [get_ports btn_d]
# set_property IOSTANDARD LVCMOS33 [get_ports btn_d]

# Pmod Header JA ==============================================================

## sch name = JA1
#set_property PACKAGE_PIN J1 [get_ports {JA[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JA[0]}]
## sch name = JA2
#set_property PACKAGE_PIN L2 [get_ports {JA[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JA[1]}]
## sch name = JA3
#set_property PACKAGE_PIN J2 [get_ports {JA[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JA[2]}]
## sch name = JA4
#set_property PACKAGE_PIN G2 [get_ports {JA[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JA[3]}]
## sch name = JA7
#set_property PACKAGE_PIN H1 [get_ports {JA[4]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JA[4]}]
## sch name = JA8
#set_property PACKAGE_PIN K2 [get_ports {JA[5]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JA[5]}]
## sch name = JA9
#set_property PACKAGE_PIN H2 [get_ports {JA[6]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JA[6]}]
## sch name = JA10
#set_property PACKAGE_PIN G3 [get_ports {JA[7]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JA[7]}]

# Pmod Header JB ==============================================================

## sch name = JB1
#set_property PACKAGE_PIN A14 [get_ports {JB[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JB[0]}]
## sch name = JB2
#set_property PACKAGE_PIN A16 [get_ports {JB[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JB[1]}]
## sch name = JB3
#set_property PACKAGE_PIN B15 [get_ports {JB[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JB[2]}]
## sch name = JB4
#set_property PACKAGE_PIN B16 [get_ports {JB[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JB[3]}]
## sch name = JB7
#set_property PACKAGE_PIN A15 [get_ports {JB[4]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JB[4]}]
## sch name = JB8
#set_property PACKAGE_PIN A17 [get_ports {JB[5]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JB[5]}]
## sch name = JB9
#set_property PACKAGE_PIN C15 [get_ports {JB[6]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JB[6]}]
## sch name = JB10
#set_property PACKAGE_PIN C16 [get_ports {JB[7]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JB[7]}]

# # Pmod Header JC (JTAG) =======================================================

# # sch name = JC1
# set_property PACKAGE_PIN K17 [get_ports jtag_tms]
# set_property IOSTANDARD LVCMOS33 [get_ports jtag_tms]
# # sch name = JC2
# set_property PACKAGE_PIN M18 [get_ports jtag_tdo]
# set_property IOSTANDARD LVCMOS33 [get_ports jtag_tdo]
# # sch. name = JC3
# set_property PACKAGE_PIN N17 [get_ports jtag_tdi]
# set_property IOSTANDARD LVCMOS33 [get_ports jtag_tdi]
# # sch. name = JC4
# set_property PACKAGE_PIN P18 [get_ports jtag_tck]
# set_property IOSTANDARD LVCMOS33 [get_ports jtag_tck]

## sch name = JC7
#set_property PACKAGE_PIN L17 [get_ports {JC[4]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JC[4]}]
## sch name = JC8
#set_property PACKAGE_PIN M19 [get_ports {JC[5]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JC[5]}]
## sch name = JC9
#set_property PACKAGE_PIN P17 [get_ports {JC[6]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JC[6]}]
## sch name = JC10
#set_property PACKAGE_PIN R18 [get_ports {JC[7]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JC[7]}]

# create_clock -period 10.000 -name jtag_tck -waveform {0.000 5.000} [get_ports jtag_tck]
# set_input_jitter jtag_tck 1.000
# set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets jtag_tck]

# set_input_delay -clock jtag_tck -clock_fall 5.000 [get_ports jtag_tdi]
# set_input_delay -clock jtag_tck -clock_fall 5.000 [get_ports jtag_tms]
# set_output_delay -clock jtag_tck 5.000 [get_ports jtag_tdo]

# set_max_delay -datapath_only -from [get_pins adam/adam_debug/dmi_jtag/i_dmi_cdc/i_cdc_resp/i_src/data_src_q_reg*/C] -to [get_pins adam/adam_debug/dmi_jtag/i_dmi_cdc/i_cdc_resp/i_dst/data_dst_q_reg*/D] 20.000
# set_max_delay -datapath_only -from [get_pins adam/adam_debug/dmi_jtag/i_dmi_cdc/i_cdc_resp/i_src/req_src_q_reg/C] -to [get_pins adam/adam_debug/dmi_jtag/i_dmi_cdc/i_cdc_resp/i_dst/req_dst_q_reg/D] 20.000
# set_max_delay -datapath_only -from [get_pins adam/adam_debug/dmi_jtag/i_dmi_cdc/i_cdc_req/i_dst/ack_dst_q_reg/C] -to [get_pins adam/adam_debug/dmi_jtag/i_dmi_cdc/i_cdc_req/i_src/ack_src_q_reg/D] 20.000

# Pmod Header JXADC ===========================================================

## sch name = XA1_P
#set_property PACKAGE_PIN J3 [get_ports {JXADC[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JXADC[0]}]
## sch name = XA2_P
#set_property PACKAGE_PIN L3 [get_ports {JXADC[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JXADC[1]}]
## sch name = XA3_P
#set_property PACKAGE_PIN M2 [get_ports {JXADC[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JXADC[2]}]
## sch name = XA4_P
#set_property PACKAGE_PIN N2 [get_ports {JXADC[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JXADC[3]}]
## sch name = XA1_N
#set_property PACKAGE_PIN K3 [get_ports {JXADC[4]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JXADC[4]}]
## sch name = XA2_N
#set_property PACKAGE_PIN M3 [get_ports {JXADC[5]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JXADC[5]}]
## sch name = XA3_N
#set_property PACKAGE_PIN M1 [get_ports {JXADC[6]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JXADC[6]}]
## sch name = XA4_N
#set_property PACKAGE_PIN N1 [get_ports {JXADC[7]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JXADC[7]}]

# VGA Connector ===============================================================

#set_property PACKAGE_PIN G19 [get_ports {vga_red[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {vga_red[0]}]
#set_property PACKAGE_PIN H19 [get_ports {vga_red[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {vga_red[1]}]
#set_property PACKAGE_PIN J19 [get_ports {vga_red[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {vga_red[2]}]
#set_property PACKAGE_PIN N19 [get_ports {vga_red[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {vga_red[3]}]
#set_property PACKAGE_PIN N18 [get_ports {vga_blue[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {vga_blue[0]}]
#set_property PACKAGE_PIN L18 [get_ports {vga_blue[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {vga_blue[1]}]
#set_property PACKAGE_PIN K18 [get_ports {vga_blue[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {vga_blue[2]}]
#set_property PACKAGE_PIN J18 [get_ports {vga_blue[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {vga_blue[3]}]
#set_property PACKAGE_PIN J17 [get_ports {vga_green[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {vga_green[0]}]
#set_property PACKAGE_PIN H17 [get_ports {vga_green[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {vga_green[1]}]
#set_property PACKAGE_PIN G17 [get_ports {vga_green[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {vga_green[2]}]
#set_property PACKAGE_PIN D17 [get_ports {vga_green[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {vga_green[3]}]
#set_property PACKAGE_PIN P19 [get_ports vga_hsync]
#set_property IOSTANDARD LVCMOS33 [get_ports vga_hsync]
#set_property PACKAGE_PIN R19 [get_ports vga_vsync]
#set_property IOSTANDARD LVCMOS33 [get_ports vga_vsync]

# USB-RS232 Interface ========================================================================================================

set_property PACKAGE_PIN B18 [get_ports rs_rx]
set_property IOSTANDARD LVCMOS33 [get_ports rs_rx]
set_property PACKAGE_PIN A18 [get_ports rs_tx]
set_property IOSTANDARD LVCMOS33 [get_ports rs_tx]

# USB HID (PS/2) =============================================================================================================

# set_property PACKAGE_PIN C17 [get_ports ps2_clk]
# set_property IOSTANDARD LVCMOS33 [get_ports ps2_clk]
# set_property PULLUP true [get_ports ps2_clk]
# set_property PACKAGE_PIN B17 [get_ports ps2_data]
# set_property IOSTANDARD LVCMOS33 [get_ports ps2_data]
# set_property PULLUP true [get_ports ps2_data]

# Quad SPI Flash =============================================================================================================
##Note that CCLK_0 cannot be placed in 7 series devices. You can access it using the
##STARTUPE2 primitive.

# set_property PACKAGE_PIN D18 [get_ports {qspi_db[0]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {qspi_db[0]}]
# set_property PACKAGE_PIN D19 [get_ports {qspi_db[1]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {qspi_db[1]}]
# set_property PACKAGE_PIN G18 [get_ports {qspi_db[2]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {qspi_db[2]}]
# set_property PACKAGE_PIN F18 [get_ports {qspi_db[3]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {qspi_db[3]}]
# set_property PACKAGE_PIN K19 [get_ports qspi_csn]
# set_property IOSTANDARD LVCMOS33 [get_ports qspi_csn]
