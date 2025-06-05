# Authors: Felipe Alencar

AS  = riscv32-unknown-elf-as
CC  = riscv32-unknown-elf-gcc
CXX = riscv32-unknown-elf-g++
LD  = riscv32-unknown-elf-g++
OBJCOPY = riscv32-unknown-elf-objcopy
OBJDUMP = riscv32-unknown-elf-objdump

# ============================================================================ #

ADAM_DIR = $(shell realpath ../../)

CODE_LOADER = $(ADAM_DIR)/scripts/code_loader.py
GEN_ROM     = $(ADAM_DIR)/scripts/gen_rom.py

# ============================================================================ #

BUILD_DIR = build
OBJ_DIR = $(BUILD_DIR)/obj
DEP_DIR = $(BUILD_DIR)/dep
TARGET_DIR = $(BUILD_DIR)/target

PROJECT = hello_world

HEX_TARGET  = $(TARGET_DIR)/$(PROJECT).hex
BIN_TARGET  = $(TARGET_DIR)/$(PROJECT).bin
ELF_TARGET  = $(TARGET_DIR)/$(PROJECT).elf
DUMP_TARGET = $(TARGET_DIR)/$(PROJECT).dump
MAP_TARGET 	= $(TARGET_DIR)/$(PROJECT).map
ROM_TARGET 	= $(TARGET_DIR)/instr_rom.sv

# ============================================================================ #

BASE_SRCS = \
    src/startup.s \
	src/main.c \
	src/hawkeye.c

SRCS = $(BASE_SRCS) $(FAST_SRCS)

INCS = \
	inc \
	$(ADAM_DIR)/software/hal/inc \

LDSCRIPT = link.ld

# ============================================================================ #

BASE_GFLAGS = -march=rv32imc_zicsr \
              -mabi=ilp32

FAST_GFLAGS = -march=rv32imfc_zicsr \
              -mabi=ilp32f

CFLAGS   = -g \
		   -O0 \
           -Wall \
           -Wextra \
           -static \
           -mcmodel=medany \
           -ffunction-sections \
           -fdata-sections \
           -fstrict-volatile-bitfields \
           $(DEFS)

CXXFLAGS = -g \
           -O0 \
           -Wall \
           -Wextra \
           -static \
           -mcmodel=medany \
           -ffunction-sections \
           -fdata-sections \
           -fstrict-volatile-bitfields \
           $(DEFS)

LDFLAGS  =	-Wl,--gc-sections \
			-Wl,-Map=$(MAP_TARGET) \
			-nostdlib \
			-nostartfiles \
			-lgcc \
			-lc_nano \
			-lnosys \
			-lsupc++ \

# ============================================================================ #

OBJS = \
	$(patsubst %.c,$(OBJ_DIR)/%.o,$(filter %.c,$(SRCS))) \
    $(patsubst %.cpp,$(OBJ_DIR)/%.o,$(filter %.cpp,$(SRCS))) \
    $(patsubst %.s,$(OBJ_DIR)/%.o,$(filter %.s,$(SRCS)))

DEPS = \
	$(patsubst %.c,$(DEP_DIR)/%.d,$(filter %.c,$(SRCS))) \
	$(patsubst %.cpp,$(DEP_DIR)/%.d,$(filter %.cpp,$(SRCS)))

# ============================================================================ #

all: \
	$(HEX_TARGET)  \
	$(BIN_TARGET)  \
	$(ELF_TARGET)  \
	$(DUMP_TARGET) \
	$(MAP_TARGET)  \
	$(ROM_TARGET)

# ============================================================================ #

$(OBJ_DIR)/%.o: %.s
	@mkdir -p $(dir $@)
ifeq ($(findstring $<,$(FAST_SRCS)),)
	$(AS) $< -o $@ -c $(FAST_GFLAGS)
else
	$(AS) $< -o $@ -c $(BASE_GFLAGS)
endif

$(OBJ_DIR)/%.o: %.c
	@mkdir -p $(dir $@)
ifeq ($(findstring $<,$(FAST_SRCS)),)
	$(CC) $< -o $@ -c -MMD -MP $(FAST_GFLAGS) $(CFLAGS) $(addprefix -I, $(INCS))
else
	$(CC) $< -o $@ -c -MMD -MP $(BASE_GFLAGS) $(CFLAGS) $(addprefix -I, $(INCS))
endif

$(OBJ_DIR)/%.o: %.cpp
	@mkdir -p $(dir $@)
ifeq ($(findstring $<,$(FAST_SRCS)),)
	$(CXX) $< -o $@ -c -MMD -MP $(FAST_GFLAGS) $(addprefix -I, $(INCS))
else
	$(CXX) $< -o $@ -c -MMD -MP $(BASE_GFLAGS) $(addprefix -I, $(INCS))
endif

# ============================================================================ #

# Include dependency files
-include $(DEPS)

# Create dependency files for C sources
$(DEP_DIR)/%.d: %.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $(addprefix -I, $(INCS)) -MM -MT \
		'$(patsubst %.c,$(OBJ_DIR)/%.o,$<)' $< -MF $@

# Create dependency files for C++ sources
$(DEP_DIR)/%.d: %.cpp
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) $(addprefix -I, $(INCS)) -MM -MT \
		'$(patsubst %.cpp,$(OBJ_DIR)/%.o,$<)' $< -MF $@

# ============================================================================ #

$(HEX_TARGET): $(ELF_TARGET)
	@mkdir -p $(dir $@)
	$(OBJCOPY) $< -O ihex $@

$(BIN_TARGET): $(ELF_TARGET)
	@mkdir -p $(dir $@)
	$(OBJCOPY) $< -O binary $@

$(ELF_TARGET): $(OBJS) $(LDSCRIPT)
	@mkdir -p $(dir $@)
	$(LD) $(OBJS) -o $@ $(GFLAGS) $(LDFLAGS) -T $(LDSCRIPT)

$(DUMP_TARGET): $(ELF_TARGET)
	@mkdir -p $(dir $@)
	$(OBJDUMP) -S -D $^ > $@

$(MAP_TARGET): $(ELF_TARGET)
#	EMPTY

$(ROM_TARGET): $(ELF_TARGET)
	@mkdir -p $(dir $@)
	$(GEN_ROM) $< -o $@ -f sverilog -m instr_rom
	@cp $(BUILD_DIR)/target/instr_rom.sv $(ADAM_DIR)/rtl/instr_rom.sv
# ============================================================================ #

.PHONY: load
load: $(ELF_TARGET)
	$(CODE_LOADER) $(ELF_TARGET) -p $(PORT)

.PHONY: clean
clean:
	rm -r $(BUILD_DIR)
