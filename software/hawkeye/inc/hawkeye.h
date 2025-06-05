#include <math.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>

#define NUM_CORE 1
#define LLC_SETS NUM_CORE*1024
#define LLC_WAYS 8
#define MAX_PCMAP 31
#define PCMAP_SIZE 1024

//Sampler components tracking cache history
#define SAMPLER_ENTRIES 2800
#define SAMPLER_HIST 8
#define SAMPLER_SETS 350 //(SAMPLER_ENTRIES/SAMPLER_HIST)
#define TIMER_SIZE 1024

//3-bit RRIP counter
#define MAXRRIP 7

#define OPTGEN_SIZE  128

uint8_t hawkeye(bool init, uint64_t paddr, uint32_t set, uint64_t pc, uint8_t way, uint8_t hit);
