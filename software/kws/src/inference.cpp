#include <algorithm>
#include <cstdint>
#include <iterator>
#include <cstdio>

#include "tensorflow/lite/core/c/common.h"
#include "tensorflow/lite/micro/micro_interpreter.h"
#include "tensorflow/lite/micro/micro_log.h"
#include "tensorflow/lite/micro/micro_mutable_op_resolver.h"

#include "audio_preprocessor_int8_tflite.h"
#include "micro_speech_quantized_tflite.h"

#include "inference.h"

// Number of categories and labels
constexpr int kCategoryCount = 4;
constexpr const char* kCategoryLabels[kCategoryCount] = {
  "silence",
  "unknown",
  "yes",
  "no",
};

// Separate arenas for each interpreter
constexpr size_t kPreprocArenaSize = 28584;
constexpr size_t kSpeechArenaSize = 28584;
alignas(16) static uint8_t g_preproc_arena[kPreprocArenaSize];
alignas(16) static uint8_t g_speech_arena[kSpeechArenaSize];

using Features = int8_t[CFG_FEATURE_COUNT][CFG_FEATURE_SIZE];
static Features g_features;

using PreprocessorOpResolver = tflite::MicroMutableOpResolver<18>;
using SpeechOpResolver = tflite::MicroMutableOpResolver<4>;

static PreprocessorOpResolver g_preproc_op_resolver;
static SpeechOpResolver g_speech_op_resolver;

static tflite::MicroInterpreter* g_preproc_interpreter = nullptr;
static tflite::MicroInterpreter* g_speech_interpreter = nullptr;

#define RETURN_IF_ERROR(expr) \
  do { \
    TfLiteStatus _status = (expr); \
    if (_status != kTfLiteOk) return _status; \
  } while (0)

static TfLiteStatus RegisterPreprocessorOps(PreprocessorOpResolver& resolver) {
  RETURN_IF_ERROR(resolver.AddReshape());
  RETURN_IF_ERROR(resolver.AddCast());
  RETURN_IF_ERROR(resolver.AddStridedSlice());
  RETURN_IF_ERROR(resolver.AddConcatenation());
  RETURN_IF_ERROR(resolver.AddMul());
  RETURN_IF_ERROR(resolver.AddAdd());
  RETURN_IF_ERROR(resolver.AddDiv());
  RETURN_IF_ERROR(resolver.AddMinimum());
  RETURN_IF_ERROR(resolver.AddMaximum());
  RETURN_IF_ERROR(resolver.AddWindow());
  RETURN_IF_ERROR(resolver.AddFftAutoScale());
  RETURN_IF_ERROR(resolver.AddRfft());
  RETURN_IF_ERROR(resolver.AddEnergy());
  RETURN_IF_ERROR(resolver.AddFilterBank());
  RETURN_IF_ERROR(resolver.AddFilterBankSquareRoot());
  RETURN_IF_ERROR(resolver.AddFilterBankSpectralSubtraction());
  RETURN_IF_ERROR(resolver.AddPCAN());
  RETURN_IF_ERROR(resolver.AddFilterBankLog());
  return kTfLiteOk;
}

static TfLiteStatus RegisterSpeechOps(SpeechOpResolver& resolver) {
  RETURN_IF_ERROR(resolver.AddReshape());
  RETURN_IF_ERROR(resolver.AddFullyConnected());
  RETURN_IF_ERROR(resolver.AddDepthwiseConv2D());
  RETURN_IF_ERROR(resolver.AddSoftmax());
  return kTfLiteOk;
}

extern "C" void inference_preproc_init(void) {
  // Initialize preprocessor interpreter
  const tflite::Model* preproc_model = tflite::GetModel(__audio_preprocessor_int8_tflite);
  if (preproc_model->version() != TFLITE_SCHEMA_VERSION) {
    printf("Preprocessor model version mismatch\n");
    return;
  }
  RegisterPreprocessorOps(g_preproc_op_resolver);
  g_preproc_interpreter = new tflite::MicroInterpreter(
      preproc_model, g_preproc_op_resolver, g_preproc_arena, kPreprocArenaSize);
  if (g_preproc_interpreter->AllocateTensors() != kTfLiteOk) {
    printf("Failed to allocate preprocessor tensors\n");
    return;
  }
}

extern "C" void inference_speech_init(void) {
  // Initialize speech inference interpreter
  const tflite::Model* speech_model = tflite::GetModel(__micro_speech_quantized_tflite);
  if (speech_model->version() != TFLITE_SCHEMA_VERSION) {
    printf("Speech model version mismatch\n");
    return;
  }
  RegisterSpeechOps(g_speech_op_resolver);
  g_speech_interpreter = new tflite::MicroInterpreter(
      speech_model, g_speech_op_resolver, g_speech_arena, kSpeechArenaSize);
  if (g_speech_interpreter->AllocateTensors() != kTfLiteOk) {
    printf("Failed to allocate speech tensors\n");
    return;
  }
}

extern "C" void inference_preproc_run(int16_t* audio_data, const size_t audio_data_size) {
  if (!g_preproc_interpreter) {
    printf("Interpreter not initialized\n");
    return;
  }

  // Generate features
  size_t remaining = audio_data_size;
  size_t offset = 0;
  int feature_idx = 0;
  while (remaining >= CFG_AUDIO_DURATION_COUNT && feature_idx < CFG_FEATURE_COUNT) {
    TfLiteTensor* in = g_preproc_interpreter->input(0);
    std::copy_n(audio_data + offset, CFG_AUDIO_DURATION_COUNT,
                tflite::GetTensorData<int16_t>(in));
    if (g_preproc_interpreter->Invoke() != kTfLiteOk) {
      printf("Preprocessor invoke failed\n");
      return;
    }
    TfLiteTensor* out = g_preproc_interpreter->output(0);
    std::copy_n(tflite::GetTensorData<int8_t>(out), CFG_FEATURE_SIZE,
                g_features[feature_idx]);
    offset += CFG_AUDIO_STRIDE_COUNT;
    remaining -= CFG_AUDIO_STRIDE_COUNT;
    feature_idx++;
  }
}

extern "C" int inference_speech_run(void) {
  if (!g_speech_interpreter) {
    printf("Interpreter not initialized\n");
    return -1;
  }

  // Run speech inference
  TfLiteTensor* speech_in = g_speech_interpreter->input(0);
  std::copy_n(&g_features[0][0], CFG_FEATURE_ELEMENT_COUNT,
              tflite::GetTensorData<int8_t>(speech_in));
  if (g_speech_interpreter->Invoke() != kTfLiteOk) {
    printf("Speech inference failed\n");
    return -1;
  }

  // Decode output
  TfLiteTensor* speech_out = g_speech_interpreter->output(0);
  float scale = speech_out->params.scale;
  int zero_point = speech_out->params.zero_point;
  float best_score = -1e6f;
  int best_index = 0;
  const int8_t* out_data = tflite::GetTensorData<int8_t>(speech_out);
  for (int i = 0; i < kCategoryCount; ++i) {
    float score = (out_data[i] - zero_point) * scale;
    if (score > best_score) {
      best_score = score;
      best_index = i;
    }
  }

  return best_index;
}
