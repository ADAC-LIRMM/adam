#pragma once

#include "cfg.h"

#ifdef __cplusplus
extern "C" {
#endif

void inference_preproc_init(void);
void inference_speech_init(void);
void inference_preproc_run(int16_t* audio_data, const size_t audio_data_size);
int inference_speech_run(void);

#ifdef __cplusplus
}
#endif
