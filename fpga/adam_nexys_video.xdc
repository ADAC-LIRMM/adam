set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO        [current_design]

# clock ===============================================================================================================

set_property -dict {PACKAGE_PIN R4 IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

# reset ===============================================================================================================

set_property -dict {PACKAGE_PIN G4 IOSTANDARD LVCMOS15} [get_ports {cpu_resetn}]

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

# cdc =================================================================================================================

set_max_delay 20.000 \
    -from [get_pins {*cdc_2phase/async_req}] \
    -to   [get_pins {*cdc_2phase/i_dst/async_req_i}]
set_max_delay 20.000 \
    -from [get_pins {*cdc_2phase/async_ack}] \
    -to   [get_pins {*cdc_2phase/i_src/async_ack_i}]
set_max_delay 20.000 \
    -from [get_pins {*cdc_2phase/async_data}] \
    -to   [get_pins {*cdc_2phase/i_dst/async_data_i}]

# set_max_delay -datapath_only \
#     -from [get_pins adam/adam_debug/dmi_jtag/i_dmi_cdc/i_cdc_resp/i_src/data_src_q_reg*/C] \
#     -to   [get_pins adam/adam_debug/dmi_jtag/i_dmi_cdc/i_cdc_resp/i_dst/data_dst_q_reg*/D] \
#     20.000
# set_max_delay -datapath_only \
#     -from [get_pins adam/adam_debug/dmi_jtag/i_dmi_cdc/i_cdc_resp/i_src/req_src_q_reg/C] \
#     -to   [get_pins adam/adam_debug/dmi_jtag/i_dmi_cdc/i_cdc_resp/i_dst/req_dst_q_reg/D] \
#     20.000
# set_max_delay -datapath_only \
#     -from [get_pins adam/adam_debug/dmi_jtag/i_dmi_cdc/i_cdc_req/i_dst/ack_dst_q_reg/C] \
#     -to   [get_pins adam/adam_debug/dmi_jtag/i_dmi_cdc/i_cdc_req/i_src/ack_src_q_reg/D] \
#     20.000

# set multicycle path on reset, on the FPGA we do not care about the reset anyway
#set_multicycle_path -from [get_pins {i_rstgen_main/i_rstgen_bypass/synch_regs_q_reg[3]/C}] 4
#set_multicycle_path -hold -from [get_pins {i_rstgen_main/i_rstgen_bypass/synch_regs_q_reg[3]/C}] 3