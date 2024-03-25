#SBE
SHELL = /bin/bash
WORK_DIR	= ./temp
YAML		= ps_adam_tb
TB 			= ps_adam_tb
WAVE		= "do ../wave/wave_adam_ps.do"
SDF_FILE	= ../powerflow/scripts/adam_unwrap.sdf
RUNTIME		= "run 80 us"
CMOS28FDSOI_DIR = /tools/DKits/ST/cmos28fdsoi_10a
OPTION 		= -novopt
# List of source files
SOURCES := $(shell python ./yaml_parser.py $(YAML) | head -n 1)
INCLUDES := $(shell python ./yaml_parser.py $(YAML) | tail -n 1)
PKG_SOURCES = $(filter %_pkg.sv, $(SOURCES))
NON_PKG_SOURCES = $(filter-out %_pkg.sv, $(SOURCES))
INC_DIRS := $(foreach dir,$(INCLUDES),+incdir+$(dir))

#RUN
run_all : init rtl run
test : 
	@for file in $(PKG_SOURCES); do echo $$file; \
    done

run :
	@echo '*********'
	@echo '** RUN **'
	@echo '*********'
	vlog -force_refresh
	vsim -printsimstats $(OPTION) -suppress 12027 -suppress 2732 -suppress 8884 -suppress 2912 -suppress 13181 -suppress 12003 -L work -gui -do $(WAVE) -do $(RUNTIME) work.$(TB) &
	
#INIT
init :
	@echo '**********'
	@echo '** INIT **'
	@echo '**********'
	@pkill vsim || true
	mkdir -p $(WORK_DIR)
	vlib $(WORK_DIR)/work
	vmap work $(WORK_DIR)/work
	
	# Technology Setup
	# =============================================================================
	vlog -work work $(CMOS28FDSOI_DIR)/C28SOI_SC_12_CORE_LL/5.1-05/behaviour/verilog/C28SOI_SC_12_CORE_LL.v
#RTL
rtl :
	@echo '*********'
	@echo '** RTL **'
	@echo '*********'
	vlog -work work $(PKG_SOURCES)
	vlog -work work $(INC_DIRS) $(NON_PKG_SOURCES)

#CLEAN
clean :
	@echo '***********'
	@echo '** CLEAN **'
	@echo '***********'
	@rm -rf $(WORK_DIR) transcript *.wlf modelsim.ini *.vstf
	@rm -rf wl*