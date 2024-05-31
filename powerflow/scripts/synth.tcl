# =============================================================================
# This is a sample script for Synopsys Design Compiler
# Start : dc_shell -f <script_name>
# =============================================================================
set proj {{ proj_path }}
set work {{ work_path }}

# Define directories
set dirs        [list "./work" "../reports" "../src"]
# Iterate over directories
foreach dir $dirs {
    if {[file exists $dir]} {
        # puts "Directory $dir already exists. Do you want to delete it? (yes/no)"
        # gets stdin response
        # if {$response eq "yes"} {
        file delete -force -- $dir
        file mkdir $dir
        # } else {
        #     puts "Directory $dir was not deleted."
        # }
    } else {
        file mkdir $dir
    }
}

# Technology Setup
# =============================================================================
set CMOS28FDSOI_DIR $env(CMOS28FDSOI_DIR)
set SYN_PATH $env(SNPS_SYN_PATH)
set search_path	". $SYN_PATH/libraries/syn $SYN_PATH/dw/sim_ver \\
  $CMOS28FDSOI_DIR/C28SOI_SC_12_CORE_LR/5.1-03/libs "
set target_library "C28SOI_SC_12_CORE_LR_tt28_0.90V_25C.db"
# set symbol_library "C28SOI_SC_12_CORE_LL.sdb"
# set synthetic_library dw_foundation.sldb 
set link_library "* $target_library "

# Directory where DC places intermediate files
define_design_lib work -path ./work

# Parse YAML Files
# =============================================================================
set rtl_proj adam_synth
set output [exec python yaml_parser.py $rtl_proj]
set lines [split $output "\n"]

# Get the sources and includes from the output of the Python script
set SOURCES [lindex $lines 0]
set INCLUDES [lindex $lines 1]
set PATHS ""
set FILES ""
foreach source $SOURCES {
    set path [file dirname $source]
    set filename [file tail $source]
    append PATHS "$path "
    append FILES "$filename "
}
# Convert the PATHS string to a list
set PATHS_LIST [split $PATHS]

# Convert the INCLUDES string to a list
set INCLUDES_LIST [split $INCLUDES]

# Append the INCLUDES list to the PATHS list
set PATHS_LIST [concat $PATHS_LIST $INCLUDES_LIST]

# Remove duplicates from the list
set PATHS_LIST [lsort -unique $PATHS_LIST]

# Convert the list back to a string if necessary
set PATHS [join $PATHS_LIST " "]

# Tcl doesn't have a direct equivalent to Makefile's $(filter ...) function,
# but you can use a foreach loop and string matching to achieve the same result.
set PKG_SOURCES ""
set NON_PKG_SOURCES ""
foreach source $FILES {
    if {[string match "*_pkg.sv" $source]} {
        append PKG_SOURCES "$source "
    } else {
        append NON_PKG_SOURCES "$source "
    }
}
## Include Directories
# =============================================================================
set search_path [concat $search_path $PATHS]

## Source Files : 
# ====================================
set my_verilog_files [list $PKG_SOURCES $NON_PKG_SOURCES]

## Set top module of the design : 
set my_toplevel adam_unwrap

## Set the clock period in ps / 20ns => 50 MHz
set CLK_PERIOD 20000

## Setting the port of the clock
set HS_CLOCK_INPUT hsdom_seq_clk
set LS_CLOCK_INPUT lsdom_seq_clk

## Load Source Files : 
# ====================================

# Translate HDL to intermediate format
foreach file $my_verilog_files {
    analyze -f sverilog "$file"
}

# Build generic technology database
elaborate $my_toplevel

# Designate the design to synthesize
current_design $my_toplevel

#######################################
# Verilog (?) Compiler settings       #
#######################################

# to make DC not use the assign statement in its output netlist
set verilogout_no_tri true

# assume this means DC will ignore the case of the letters in net and module names
#set verilogout_ignore_case true

# unconnected nets will be marked by adding a prefix to its name
set verilogout_unconnected_prefix "UNCONNECTED"

# show unconnected pins when creating module ports
set verilogout_show_unconnected_pins true

# make sure that vectored ports don't get split up into single bits
set verilogout_single_bit false

# generate a netlist without creating an EDIF schematic
set edifout_netlist_only true


#######################################
# Define constraints                  #
#######################################
# setting the approximate skew
# set CLK_SKEW [expr 0.025 * $CLK_PERIOD]

# constraint design area units depends on the technology library
# set MAX_AREA 20000.0
# set_max_area $MAX_AREA

# power constraints
# set MAX_LEAKAGE_POWER 0.0
# set_max_leakage_power $MAX_LEAKAGE_POWER
# set MAX_DYNAMIC_POWER 0.0
# set_max_dynamic_power $MAX_DYNAMIC_POWER

# make sure ports aren't connected together
set_fix_multiple_port_nets -all

# setting the port of clock
create_clock -period  $CLK_PERIOD $HS_CLOCK_INPUT
create_clock -period  $CLK_PERIOD $LS_CLOCK_INPUT
## Design Rule Constraints

# set DRIVINGCELL inv_1
# set DRIVE_PIN {Y}
# set input driving cell strength / Max fanout for all design
# set_driving_cell -lib_cell $DRIVINGCELL -pin $DRIVE_PIN [all_inputs]
# set_driving_cell -lib_cell $DRIVINGCELL [all_inputs]

# largest fanout allowed 
#set MAX_FANOUT 8
#set_max_fanout $MAX_FANOUT

# models load on output ports
#set MAX_OUTPUT_LOAD [load_of ssc_core/buf1a2/A]
#set_load $MAX_OUTPUT_load [all_outputs]
# set MAX_OUTPUT_load 57.462
# set_load $MAX_OUTPUT_load [all_outputs]

# incase of variable load at each output port
# set_load <loadvalue> [get_ports {<portnames>}] 


# set maximum and minimum capacitance 
# set_max_capacitance
# set_min_capacitance

# setting operating conditions if allowed by technology library 
# set_operating_conditions

# wireload models
# set_wireload_model
# set_wireload_mode 

# set MAX_INPUT_DELAY 0.9
# set MIN_INPUT_DELAY 0
# set OUTPUT_MAX_DELAY 0.4
# set OUTPUT_MIN_DELAY -0.4

# models the delay from signal source to design input port
# set_input_delay 2000 [all_inputs] -clock $CLOCK_INPUT

# models delay from design to output port
# set_output_delay 2000 [all_outputs] -clock $CLOCK_INPUT
# set_clock_unertainty -setup 500 -clock $CLOCK_INPUT

# used when you are translating some netlist from one technology to another
link

# used to generate separate instances within the netlist
# uniquify

#######################################
# Design Compiler settings            #
#######################################

# completely flatten the hierarchy to allow optimization to cross hierarchy boundaries
# ungroup -flatten -all

# check internal DC representation for design consistency
check_design -unint
define_name_rules verilog -preserve_struct_ports
change_names -hierarchy -rules verilog

# verifies timing setup is complete
check_timing

# enable DC ultra optimizations 
compile

# verifies timing setup is complete
check_timing

# report design size and object counts
report_area

# reports design database constraints attributes
report_timing_requirements

#######################################
# Output files                        #
#######################################

# save design
set filename [format "%s%s"  $my_toplevel ".ddc"]
write -format ddc -hierarchy -output ./reports/$my_toplevel

# save delay and parasitic data
set filename [format "%s%s"  $my_toplevel ".sdf"]
write_sdf -version 1.0 ../reports/$filename

# save synthesized verilog netlist
# set filename [format "%s%s"  $my_toplevel ".syn.v"]
# write -format verilog -hierarchy -output ../reports/$filename

write -format verilog -hierarchy -out ../src/adam_synth.v $my_toplevel

# this file is necessary for P&R with Encounter

set filename [format "%s%s"  $my_toplevel ".sdc"]
write_sdc ../reports/$filename

# write milkyway database
if {[shell_is_in_topographical_mode]} {
    write_milkyway -output $my_toplevel -overwrite
}

redirect [format "%s%s" ../reports/$my_toplevel  _design.repC] { report_design }
redirect [format "%s%s" ../reports/$my_toplevel  _area.repC] { report_area }
redirect -append [format "%s%s" ../reports/$my_toplevel  _area.repC] { report_reference }
redirect [format "%s%s" ../reports/$my_toplevel  _latches.repC] { report_register -level_sensitive }
redirect [format "%s%s" ../reports/$my_toplevel  _flops.repC] { report_register -edge }
redirect [format "%s%s" ../reports/$my_toplevel  _violators.repC] { report_constraint -all_violators }
redirect [format "%s%s" ../reports/$my_toplevel  _power.repC] { report_power }
redirect [format "%s%s" ../reports/$my_toplevel  _max_timing.repC] { report_timing -delay max -nworst 3 -max_paths 20 -greater_path 0 -path full -nosplit}
redirect [format "%s%s" ../reports/$my_toplevel  _min_timing.repC] { report_timing -delay min -nworst 3 -max_paths 20 -greater_path 0 -path full -nosplit}
redirect [format "%s%s" ../reports/$my_toplevel  _out_min_timing.repC] { report_timing -to [all_outputs] -delay min -nworst 3 -max_paths 1000000 -greater_path 0 -path full -nosplit}

quit
