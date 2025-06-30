cmake_minimum_required(VERSION 3.15)

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR riscv)

set(TOOLCHAIN_PREFIX "/opt/riscv/bin/riscv64-unknown-elf-"
  CACHE PATH "Prefix for RISC-V tools")

set(CMAKE_C_COMPILER   "${TOOLCHAIN_PREFIX}gcc"     CACHE FILEPATH "")
set(CMAKE_CXX_COMPILER "${TOOLCHAIN_PREFIX}g++"     CACHE FILEPATH "")
set(CMAKE_OBJCOPY      "${TOOLCHAIN_PREFIX}objcopy" CACHE FILEPATH "")
set(CMAKE_OBJDUMP      "${TOOLCHAIN_PREFIX}objdump" CACHE FILEPATH "")
set(CMAKE_SIZE         "${TOOLCHAIN_PREFIX}size"    CACHE FILEPATH "")

set(ADAM_TARGET_NAME default
  CACHE STRING "")
set(ADAM_ROOT_DIR   ${CMAKE_SOURCE_DIR}/..
  CACHE FILEPATH "")
set(ADAM_TARGET_DIR ${ADAM_ROOT_DIR}/work/${ADAM_TARGET_NAME}
  CACHE FILEPATH "")

set(ADAM_SCRIPTS_DIR ${ADAM_ROOT_DIR}/scripts)
set(ADAM_ATGEN_DIR   ${ADAM_TARGET_DIR}/atgen)
set(ADAM_CODE_LOADER ${ADAM_SCRIPTS_DIR}/code_loader.py)
set(ADAM_ROM_GEN     ${ADAM_SCRIPTS_DIR}/gen_rom.py)

# =============================================================================

project(adam-software LANGUAGES C CXX ASM)

# =============================================================================

add_library(riscv_base INTERFACE)

target_compile_options(riscv_base INTERFACE
  -g
  -O3
  -mcmodel=medany
  -static
  -Wall
  -Wextra
  -fdata-sections
  -ffunction-sections
  -fstrict-volatile-bitfields
)

target_link_options(riscv_base INTERFACE
  -Wl,--gc-sections
  -nostdlib
)

# =============================================================================

add_library(riscv_stdlib INTERFACE)

target_link_libraries(riscv_stdlib INTERFACE riscv_base)

target_link_options(riscv_stdlib INTERFACE
  -lc_nano
  -lnosys
)

# =============================================================================

function(add_riscv_interface tgt)
  set(_flags ${ARGN})

  add_library(${tgt} INTERFACE)
  target_link_libraries(${tgt} INTERFACE riscv_base)
  target_compile_options(${tgt} INTERFACE ${_flags})
  target_link_options(${tgt} INTERFACE ${_flags})
endfunction()

add_riscv_interface(rv32i    -march=rv32i_zicsr    -mabi=ilp32)
add_riscv_interface(rv32im   -march=rv32im_zicsr   -mabi=ilp32)
add_riscv_interface(rv32imc  -march=rv32imc_zicsr  -mabi=ilp32)
add_riscv_interface(rv32imfc -march=rv32imfc_zicsr -mabi=ilp32f)

# =============================================================================

function(adam_add_executable tgt)
  add_executable(${tgt} ${ARGN})

  add_custom_command(TARGET ${tgt} POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} $<TARGET_FILE:${tgt}>
      -O binary ${CMAKE_CURRENT_BINARY_DIR}/${tgt}.bin
    COMMAND ${CMAKE_OBJCOPY} $<TARGET_FILE:${tgt}>
      -O ihex ${CMAKE_CURRENT_BINARY_DIR}/${tgt}.hex
    COMMAND ${CMAKE_OBJDUMP} -S -D $<TARGET_FILE:${tgt}>
      > ${CMAKE_CURRENT_BINARY_DIR}/${tgt}.dump
    COMMAND ${ADAM_ROM_GEN} $<TARGET_FILE:${tgt}>
      -f sverilog -m ${tgt}_rom -o ${CMAKE_CURRENT_BINARY_DIR}/${NAME}_rom.sv
    VERBATIM
  )

  target_link_libraries(${tgt} PRIVATE riscv_base)

  target_link_options(${tgt} PRIVATE
    -Wl,-Map=${CMAKE_CURRENT_BINARY_DIR}/${tgt}.map
  )

  add_custom_target(${tgt}_load
    COMMAND ${ADAM_CODE_LOADER} $<TARGET_FILE:${tgt}> -p ${ADAM_PORT}
    DEPENDS ${tgt}
  )
endfunction()

if(ADAM_TARGET_NAME MATCHES "hawkeye")
  add_subdirectory(hawkeye)
else()
  add_subdirectory(hal)
  add_subdirectory(bootloader)
  add_subdirectory(hello_world)
  if(ADAM_TARGET_NAME MATCHES "_gmsv")
    add_subdirectory(gemmini_sv)
  endif()
endif()
