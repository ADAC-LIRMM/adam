#pragma once

// #define CFG_LPCPU
// #define CFG_DEEP_SLEEP

#define CFG_SAMPLE_RATE 16000
#define CFG_FEATURE_SIZE 40
#define CFG_FEATURE_COUNT 49
#define CFG_FEATURE_STRIDE_MS 20
#define CFG_FEATURE_DURATION_MS 30

#define CFG_AUDIO_THRESHOLD 0
#define CFG_AUDIO_HPF 32511

#define CFG_FEATURE_ELEMENT_COUNT \
    (CFG_FEATURE_SIZE * CFG_FEATURE_COUNT)
#define CFG_AUDIO_DURATION_COUNT \
    (CFG_FEATURE_DURATION_MS * CFG_SAMPLE_RATE / 1000)
#define CFG_AUDIO_STRIDE_COUNT \
    (CFG_FEATURE_STRIDE_MS * CFG_SAMPLE_RATE / 1000)
#define CFG_AUDIO_DATA_SIZE \
    ((CFG_FEATURE_COUNT - 1) * CFG_AUDIO_STRIDE_COUNT \
    + CFG_AUDIO_DURATION_COUNT)

#ifdef CFG_LPCPU
    #define LPMEM_TEXT __attribute__((section(".lpmem.text")))
    #define LPMEM_DATA __attribute__((section(".lpmem.data")))
#else
    #define LPMEM_TEXT
    #define LPMEM_DATA
#endif
