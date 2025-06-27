file(GLOB HAL_SRCS
  "${CMAKE_CURRENT_SOURCE_DIR}/src/*.c"
  "${CMAKE_CURRENT_SOURCE_DIR}/src/*.s"
)

add_library(hal OBJECT ${HAL_SRCS})

target_include_directories(hal PUBLIC
  ${ADAM_ATGEN_DIR}
  "${CMAKE_CURRENT_SOURCE_DIR}/inc"
)

target_link_libraries(hal PRIVATE riscv_stdlib rv32imc)
