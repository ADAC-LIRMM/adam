#ifndef __SYSTEM_H__
#define __SYSTEM_H__

#ifdef __cplusplus
extern "C" {
#endif

#define EN_PRINTF 1

// Lib inc
#include <stddef.h>
#include <stdint.h>
#include <stdarg.h>

extern void sleep(void);

// Architecture definition inc
#include "adam_ral.h"

// Drivers inc
#include "gpio.h"
#include "uart.h"
#include "timer.h"

// Utils inc
#include "types.h"
#include "print.h"

// Application headers

int my_printf(const char *format, ...);

#ifdef __cplusplus
}
#endif

#endif
