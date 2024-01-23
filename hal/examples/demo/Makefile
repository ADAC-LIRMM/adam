# Authors: Soriano Theo; Felipe Alencar

AS  = riscv32-unknown-elf-as
CC  = riscv32-unknown-elf-gcc
CXX = riscv32-unknown-elf-g++
LD  = riscv32-unknown-elf-g++
OBJCOPY = riscv32-unknown-elf-objcopy
OBJDUMP = riscv32-unknown-elf-objdump

# ============================================================================ #

ADAM_DIR = $(shell realpath ../../../)

CODE_LOADER = $(ADAM_DIR)/scripts/code_loader.py
MEM_MAP_GEN = $(ADAM_DIR)/scripts/mem_map_gen.py
ROM_GEN     = $(ADAM_DIR)/scripts/rom_gen.py

# ============================================================================ #

BUILD_DIR = build
OBJ_DIR = $(BUILD_DIR)/obj
DEP_DIR = $(BUILD_DIR)/dep
TARGET_DIR = $(BUILD_DIR)/target

PROJECT = demo

BIN_TARGET  = $(TARGET_DIR)/$(PROJECT).bin
ELF_TARGET  = $(TARGET_DIR)/$(PROJECT).elf
DUMP_TARGET = $(TARGET_DIR)/$(PROJECT).dump
MAP_TARGET 	= $(TARGET_DIR)/$(PROJECT).map
ROM_TARGET 	= $(TARGET_DIR)/$(PROJECT).sv

# ============================================================================ #

SRCS = \
	src/startup.s \
	$(wildcard $(ADAM_DIR)/HAL/src/*.c) \
	src/main.c

INCS = \
	$(ADAM_DIR)/HAL/inc \
	inc

LDSCRIPT = link.ld

# ============================================================================ #

GFLAGS   = -march=rv32i_zicsr -mabi=ilp32
CFLAGS   = -Wall -Wextra -static -mcmodel=medany -ffunction-sections \
	-fdata-sections -O3 -fstrict-volatile-bitfields
CXXFLAGS = -Wall -Wextra -static -mcmodel=medany -ffunction-sections \
	-fdata-sections -O3 -fstrict-volatile-bitfields
LDFLAGS  = -Wl,--gc-sections -Wl,-Map=$(MAP_TARGET) -nostdlib \
	-nostartfiles

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
	$(BIN_TARGET)  \
	$(ELF_TARGET)  \
	$(DUMP_TARGET) \
	$(MAP_TARGET)  \
	$(ROM_TARGET)

# ============================================================================ #

$(OBJ_DIR)/%.o: %.s
	@mkdir -p $(dir $@)
	$(AS) $< -o $@ -c $(GFLAGS)

$(OBJ_DIR)/%.o: %.c
	@mkdir -p $(dir $@)
	$(CC) $< -o $@ -c -MMD -MP $(GFLAGS) $(CFLAGS) $(addprefix -I, $(INCS))

$(OBJ_DIR)/%.o: %.cpp
	@mkdir -p $(dir $@)
	$(CXX) $< -o $@ -c -MMD -MP $(GFLAGS) $(CXXFLAGS) $(addprefix -I, $(INCS))

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
	$(ROM_GEN) $< -o $@ -f sverilog -m $(PROJECT)

# ============================================================================ #

.PHONY: load
load: $(ELF_TARGET)
	$(CODE_LOADER) $(ELF_TARGET) -p $(PORT)

.PHONY: clean
clean:
	rm -r $(BUILD_DIR)
