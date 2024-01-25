set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO        [current_design]

# clock ===============================================================================================================

set_property -dict {PACKAGE_PIN R4 IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -add -name clk -period 10.00 -waveform {0 5} [get_ports clk]

# reset ===============================================================================================================

set_property -dict {PACKAGE_PIN G4 IOSTANDARD LVCMOS15} [get_ports rstn]

# uart ================================================================================================================
 
set_property -dict {PACKAGE_PIN AA19 IOSTANDARD LVCMOS33} [get_ports uart_tx];
set_property -dict {PACKAGE_PIN V18  IOSTANDARD LVCMOS33} [get_ports uart_rx];

# jtag ================================================================================================================

set_property -dict {PACKAGE_PIN Y6  IOSTANDARD LVCMOS33} [get_ports jtag_tms]
set_property -dict {PACKAGE_PIN AA6 IOSTANDARD LVCMOS33} [get_ports jtag_tdi]
set_property -dict {PACKAGE_PIN AA8 IOSTANDARD LVCMOS33} [get_ports jtag_tdo]
set_property -dict {PACKAGE_PIN AB8 IOSTANDARD LVCMOS33} [get_ports jtag_tck]

create_clock -period 100.000 -name jtag_tck -waveform {0.000 50.000} [get_ports jtag_tck]
set_input_jitter jtag_tck 1.000
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets jtag_tck]

set_input_delay  -clock jtag_tck -clock_fall 5.000 [get_ports jtag_tdi]
set_input_delay  -clock jtag_tck -clock_fall 5.000 [get_ports jtag_tms]
set_output_delay -clock jtag_tck             5.000 [get_ports jtag_tdo]

set_max_delay 20.000 -datapath_only \
    -from [get_pins adam/adam_debug/dmi_jtag/i_dmi_cdc/i_cdc_resp/i_src/data_src_q_reg*/C] \
    -to   [get_pins adam/adam_debug/dmi_jtag/i_dmi_cdc/i_cdc_resp/i_dst/data_dst_q_reg*/D]
set_max_delay 20.000 -datapath_only \
    -from [get_pins adam/adam_debug/dmi_jtag/i_dmi_cdc/i_cdc_resp/i_src/req_src_q_reg/C] \
    -to   [get_pins adam/adam_debug/dmi_jtag/i_dmi_cdc/i_cdc_resp/i_dst/req_dst_q_reg/D]
set_max_delay 20.000 -datapath_only \
    -from [get_pins adam/adam_debug/dmi_jtag/i_dmi_cdc/i_cdc_req/i_dst/ack_dst_q_reg/C] \
    -to   [get_pins adam/adam_debug/dmi_jtag/i_dmi_cdc/i_cdc_req/i_src/ack_src_q_reg/D]