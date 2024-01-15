set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO        [current_design]

# clock ===============================================================================================================

set_property -dict {PACKAGE_PIN R4 IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -add -name clk -period 10.00 -waveform {0 5} [get_ports clk]

# reset ===============================================================================================================

set_property -dict {PACKAGE_PIN G4 IOSTANDARD LVCMOS15} [get_ports {rstn}]

# jtag ================================================================================================================

set_property -dict {PACKAGE_PIN Y6  IOSTANDARD LVCMOS33} [get_ports tms]
set_property -dict {PACKAGE_PIN AA6 IOSTANDARD LVCMOS33} [get_ports tdi]
set_property -dict {PACKAGE_PIN AA8 IOSTANDARD LVCMOS33} [get_ports tdo]
set_property -dict {PACKAGE_PIN AB8 IOSTANDARD LVCMOS33} [get_ports tck]

create_clock -period 100.000 -name tck -waveform {0.000 50.000} [get_ports tck]
set_input_jitter tck 1.000
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets tck]

set_input_delay  -clock tck -clock_fall 5.000 [get_ports tdi]
set_input_delay  -clock tck -clock_fall 5.000 [get_ports tms]
set_output_delay -clock tck             5.000 [get_ports tdo]

set_max_delay 20.000 -datapath_only \
    -from [get_pins adam/adam_debug/dmi_jtag/i_dmi_cdc/i_cdc_resp/i_src/data_src_q_reg*/C] \
    -to   [get_pins adam/adam_debug/dmi_jtag/i_dmi_cdc/i_cdc_resp/i_dst/data_dst_q_reg*/D]
set_max_delay 20.000 -datapath_only \
    -from [get_pins adam/adam_debug/dmi_jtag/i_dmi_cdc/i_cdc_resp/i_src/req_src_q_reg/C] \
    -to   [get_pins adam/adam_debug/dmi_jtag/i_dmi_cdc/i_cdc_resp/i_dst/req_dst_q_reg/D]
set_max_delay 20.000 -datapath_only \
    -from [get_pins adam/adam_debug/dmi_jtag/i_dmi_cdc/i_cdc_req/i_dst/ack_dst_q_reg/C] \
    -to   [get_pins adam/adam_debug/dmi_jtag/i_dmi_cdc/i_cdc_req/i_src/ack_src_q_reg/D]