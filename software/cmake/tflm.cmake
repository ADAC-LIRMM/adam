set(TFLM_SRC_DIR ${ADAM_LIBS_DIR}/tflite-micro)
set(TFLM_TREE_DIR ${CMAKE_BINARY_DIR}/tflm-tree)

if(EXISTS ${TFLM_TREE_DIR}/tensorflow/lite/micro/micro_interpreter.h)
  message(WARNING
    "TFLM tree found; generation skipped. "
    "This may cause issues if the tree is stale."
  )
else()
  message(STATUS "Generating TFLM tree")
  execute_process(
    COMMAND ${Python3_EXECUTABLE}
            tensorflow/lite/micro/tools/project_generation/create_tflm_tree.py
            --makefile_options=TARGET=riscv32_generic
            ${TFLM_TREE_DIR}
    WORKING_DIRECTORY ${TFLM_SRC_DIR}
    RESULT_VARIABLE gen_result
  )

  if(gen_result EQUAL 0)
    message(STATUS "Generating TFLM tree - done")
  else()
    message(FATAL_ERROR "Generating TFLM tree - failed")
  endif()
endif()

file(GLOB_RECURSE TFLM_SRCS
  ${TFLM_TREE_DIR}/signal/*.cc
  ${TFLM_TREE_DIR}/signal/*.c
  ${TFLM_TREE_DIR}/tensorflow/*.cc
  ${TFLM_TREE_DIR}/tensorflow/*.c
  ${TFLM_TREE_DIR}/third_party/*.cc
  ${TFLM_TREE_DIR}/third_party/*.c
)

list(REMOVE_ITEM TFLM_SRCS
  ${TFLM_TREE_DIR}/third_party/kissfft/tools/kiss_fftr.c
)

add_library(tflm OBJECT ${TFLM_SRCS})

target_compile_definitions(tflm PUBLIC
  TF_LITE_STATIC_MEMORY
  TF_LITE_USE_GLOBAL_CMATH_FUNCTIONS
  TF_LITE_USE_GLOBAL_MAX
  TF_LITE_USE_GLOBAL_MIN
)

target_compile_options(tflm PRIVATE
  # -std=c++11
  -Wno-unused-parameter
)

target_include_directories(tflm PUBLIC
  ${TFLM_TREE_DIR}
  ${TFLM_TREE_DIR}/third_party
  ${TFLM_TREE_DIR}/third_party/eyalroz_printf/src
  ${TFLM_TREE_DIR}/third_party/flatbuffers/include
  ${TFLM_TREE_DIR}/third_party/gemmlowp
  ${TFLM_TREE_DIR}/third_party/kissfft
  # ${TFLM_TREE_DIR}/third_party/kissfft/tools
  ${TFLM_TREE_DIR}/third_party/ruy
)

target_link_libraries(tflm PRIVATE riscv_stdlib rv32imc)
