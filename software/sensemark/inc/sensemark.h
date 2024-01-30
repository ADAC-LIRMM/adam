#pragma once

#define TOTAL_DATA_SIZE 2*1000

#include <stdint.h>

#include "adam_ral.h"
#include "coremark.h"

extern void sleep(void);

static inline uint32_t mhartid()
{
    uint32_t value;
    asm volatile ("csrr %0, mhartid" : "=r"(value));
    return value;
}