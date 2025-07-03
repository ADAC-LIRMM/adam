file(GLOB KWS_SRCS
  "${CMAKE_CURRENT_SOURCE_DIR}/src/*.c"
  "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp"
  "${CMAKE_CURRENT_SOURCE_DIR}/src/*.s"
)

adam_add_executable(kws ${KWS_SRCS})

target_include_directories(kws PRIVATE
  ${ADAM_ATGEN_DIR}
  "${CMAKE_CURRENT_SOURCE_DIR}/inc"
)

target_link_libraries(kws PRIVATE rv32imc riscv_stdlib tflm)

target_link_options(kws PRIVATE
  -T "${CMAKE_CURRENT_SOURCE_DIR}/link.ld"
)
