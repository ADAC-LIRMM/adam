cmake_minimum_required(VERSION 3.14)
project(adam VERSION 1.0 LANGUAGES C CXX ASM)

set(CMAKE_ASM_COMPILER riscv32-unknown-elf-as)
set(CMAKE_C_COMPILER   riscv32-unknown-elf-gcc)
set(CMAKE_CXX_COMPILER riscv32-unknown-elf-g++)
set(CMAKE_OBJCOPY      riscv32-unknown-elf-objcopy)
set(CMAKE_OBJDUMP      riscv32-unknown-elf-objdump)

set(LINKER_SCRIPT "${CMAKE_CURRENT_SOURCE_DIR}/link.ld")

set(GLOBAL_FLAGS "-march=rv32imfc_zicsr -mabi=ilp32f")
set(CMAKE_C_FLAGS "${GLOBAL_FLAGS} -Wall -Wextra -static -mcmodel=medany -ffunction-sections -fdata-sections -O3 -fstrict-volatile-bitfields")
set(CMAKE_CXX_FLAGS "${GLOBAL_FLAGS} -Wall -Wextra -static -mcmodel=medany -ffunction-sections -fdata-sections -O3 -fstrict-volatile-bitfields")
set(CMAKE_EXE_LINKER_FLAGS "${GLOBAL_FLAGS} -T ${LINKER_SCRIPT} -nostdlib -nostartfiles -Wl,--gc-sections")

# HAL
#file(GLOB_RECURSE HAL_SOURCES "${CMAKE_SOURCE_DIR}/hal/src/*.c")
# include_directories("${CMAKE_SOURCE_DIR}/hal/inc")

# Sensemark
set(SENSEMARK_INCLUDE
    "${CMAKE_SOURCE_DIR}/sensemark/inc"
    "${CMAKE_SOURCE_DIR}/sensemark/coremark"
)
set(SENSEMARK_SOURCES
    "${CMAKE_SOURCE_DIR}/sensemark/src/startup.s"
    "${CMAKE_SOURCE_DIR}/sensemark/src/main.c"
    "${CMAKE_SOURCE_DIR}/sensemark/src/cvt.c"
    "${CMAKE_SOURCE_DIR}/sensemark/src/ee_printf.c"
    "${CMAKE_SOURCE_DIR}/sensemark/src/sleep.s"
    "${CMAKE_SOURCE_DIR}/sensemark/coremark/core_list_join.c"
    "${CMAKE_SOURCE_DIR}/sensemark/coremark/core_matrix.c"
    "${CMAKE_SOURCE_DIR}/sensemark/coremark/core_state.c"
    "${CMAKE_SOURCE_DIR}/sensemark/coremark/core_util.c"
)
add_executable(sensemark ${HAL_SOURCES} ${SENSEMARK_SOURCES})
target_include_directories(sensemark PRIVATE ${SENSEMARK_INCLUDE})
set_target_properties(sensemark PROPERTIES LINK_DEPENDS "${LINKER_SCRIPT}")


