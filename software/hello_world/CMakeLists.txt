file(GLOB HELLO_WORLD_SRCS
  "${CMAKE_CURRENT_SOURCE_DIR}/src/*.c"
  "${CMAKE_CURRENT_SOURCE_DIR}/src/*.s"
)

adam_add_executable(hello_world ${HELLO_WORLD_SRCS})

target_include_directories(hello_world PRIVATE
  "${CMAKE_CURRENT_SOURCE_DIR}/inc"
)

target_link_libraries(hello_world PRIVATE rv32imc riscv_stdlib hal)

target_link_options(hello_world PRIVATE
  -T "${CMAKE_CURRENT_SOURCE_DIR}/link.ld"
)
