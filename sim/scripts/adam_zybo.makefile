# makefile -f adam.makefile > output.txt (clean)
#SBE
SHELL = /bin/bash
WORK_DIR	= ./temp
YAML		= adam_zybo_tb
TB 			= adam_zybo_tb
WAVE		= "do ../wave/wave_adam_zybo.do"
RUNTIME		= "run 2 ms"
OPTION 		= -voptargs=+acc
OUTPUT_DIR	= ../outputs

# List of source files
SOURCES := $(shell python ./yaml_parser.py $(YAML) | head -n 1)
INCLUDES := $(shell python ./yaml_parser.py $(YAML) | tail -n 1)
PKG_SOURCES = $(filter %_pkg.sv, $(SOURCES))
NON_PKG_SOURCES = $(filter-out %_pkg.sv, $(SOURCES))
INC_DIRS := $(foreach dir,$(INCLUDES),+incdir+$(dir))

#RUN
run_all : init rtl run

run :
	@echo '*********'
	@echo '** RUN **'
	@echo '*********'
	vlog -force_refresh
	vsim -printsimstats $(OPTION) -suppress 2912 -suppress 13181 -do $(WAVE) -gui -suppress 12003 -L work -do $(RUNTIME) work.$(TB) &
	
#INIT
init :
	@echo '**********'
	@echo '** INIT **'
	@echo '**********'
	@pkill vsim || true
	mkdir -p $(WORK_DIR)
	mkdir -p $(OUTPUT_DIR)
	vlib $(WORK_DIR)/work
	vmap work $(WORK_DIR)/work
	@echo $(SOURCES)
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
	@rm -rf $(WORK_DIR) transcript *.wlf modelsim.ini *.vstf *.log *.txt
	@rm -rf $(OUTPUT_DIR)