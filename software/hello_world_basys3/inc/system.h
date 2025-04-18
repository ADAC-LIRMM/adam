#ifndef __SYSTEM_H__
#define __SYSTEM_H__


// Lib inc
#include <stddef.h>
#include <stdint.h>
#include <stdarg.h>

extern void sleep(void);

#define _WFI() {asm volatile("wfi");}

// Architecture definition inc
#include "adam_ral.h"

// Drivers inc
#include "gpio.h"
// #include "spi.h"
#include "uart.h"
#include "timer.h"
#include "sysctrl.h"

// Utils inc
#include "types.h"
#include "utils.h"
#include "print.h"

// Application headers


#endif
