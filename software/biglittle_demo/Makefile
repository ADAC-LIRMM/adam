# Authors: Soriano Theo; Felipe Alencar; Bruno Lovison Franco

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
MEM_MAP_GEN = $(ADAM_DIR)/scripts/mem_map_gen.py

# ============================================================================ #

BUILD_DIR = build
OBJ_DIR = $(BUILD_DIR)/obj
DEP_DIR = $(BUILD_DIR)/dep
TARGET_DIR = $(BUILD_DIR)/target

PROJECT = biglittle_demo

BIN_TARGET  = $(TARGET_DIR)/$(PROJECT).bin
ELF_TARGET  = $(TARGET_DIR)/$(PROJECT).elf
DUMP_TARGET = $(TARGET_DIR)/$(PROJECT).dump
MAP_TARGET 	= $(TARGET_DIR)/$(PROJECT).map
ROM_TARGET 	= $(TARGET_DIR)/instr_rom.sv

# ============================================================================ #

MACROS = NDEBUG 


KISSFFT_SRCS := \
		kissfft/kiss_fft.c \
		kissfft/tools/kiss_fftr.c

KISSFFT_INCS := \
	kissfft \
	kissfft/tools \

# ============================================================================ #

SRCS =	\
	src/startup.s \
	src/sleep.s \
	$(wildcard ../hal/src/*.c) \
	$(wildcard src/*.c) \
	$(wildcard src/*.cpp) \
	$(KISSFFT_SRCS)

INCS := \
	inc \
	$(ADAM_DIR)/software/hal/inc\
	$(KISSFFT_INCS)

LDSCRIPT = link.ld

# ============================================================================ #

C_FLAGS		= \
	-static -mcmodel=medany \
	-ffunction-sections -fdata-sections -O3 -fstrict-volatile-bitfields

CXX_FLAGS	= \
	-static -mcmodel=medany \
	-ffunction-sections -fdata-sections -O3 -fstrict-volatile-bitfields\
	-fno-use-cxa-atexit \
	-fno-rtti \
	-fno-exceptions 

CFLAGS		= $(addprefix -D, $(MACROS)) $(C_FLAGS)
CXXFLAGS	= $(addprefix -D, $(MACROS)) $(CXX_FLAGS)

GFLAGS		= -march=rv32imfc_zicsr -mabi=ilp32f

LDFLAGS		= -Wl,--gc-sections -Wl,-Map=$(MAP_TARGET) -nostdlib -nostartfiles \
						-lm \
						-lstdc++

# ============================================================================ #

OBJS =	$(patsubst %.c,$(OBJ_DIR)/%.o,$(filter %.c,$(SRCS))) \
				$(patsubst %.cpp,$(OBJ_DIR)/%.o,$(filter %.cpp,$(SRCS))) \
				$(patsubst %.cc,$(OBJ_DIR)/%.o,$(filter %.cc,$(SRCS))) \
				$(patsubst %.s,$(OBJ_DIR)/%.o,$(filter %.s,$(SRCS)))

DEPS =	$(patsubst %.c,$(DEP_DIR)/%.d,$(filter %.c,$(SRCS))) \
				$(patsubst %.cpp,$(DEP_DIR)/%.d,$(filter %.cpp,$(SRCS))) \
				$(patsubst %.cc,$(DEP_DIR)/%.d,$(filter %.cc,$(SRCS)))


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

$(OBJ_DIR)/%.o: %.cc
	@mkdir -p $(dir $@)
	$(CXX) $< -o $@ -c -MMD -MP $(GFLAGS) $(CXXFLAGS) $(addprefix -I, $(INCS))

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

$(DEP_DIR)/%.d: %.cc
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) $(addprefix -I, $(INCS)) -MM -MT \
		'$(patsubst %.cc,$(OBJ_DIR)/%.o,$<)' $< -MF $@

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
	$(GEN_ROM) $< -o $@ -f sverilog -m instr_rom
	@cp $(BUILD_DIR)/target/instr_rom.sv $(ADAM_DIR)/rtl/instr_rom.sv



# ============================================================================ #

.PHONY: load
load: $(ELF_TARGET)
	$(CODE_LOADER) $(ELF_TARGET) -p $(PORT)

.PHONY: clean
clean:
	rm -r $(BUILD_DIR)
