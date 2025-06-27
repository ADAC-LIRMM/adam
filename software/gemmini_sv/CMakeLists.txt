file(GLOB GEMMINI_SV_SRCS
  "${CMAKE_CURRENT_SOURCE_DIR}/src/*.c"
  "${CMAKE_CURRENT_SOURCE_DIR}/src/*.s"
)

adam_add_executable(gemmini_sv ${GEMMINI_SV_SRCS})

target_include_directories(gemmini_sv PRIVATE
  "${CMAKE_CURRENT_SOURCE_DIR}/inc"
)

target_link_libraries(gemmini_sv PRIVATE riscv_stdlib hal rv32imc)

target_link_options(gemmini_sv PRIVATE
  -T "${CMAKE_CURRENT_SOURCE_DIR}/link.ld"
)
