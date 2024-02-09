#ifndef __PRINT_H__
#define __PRINT_H__

// #include "core_portme.h"

#include <stdint.h>
#include <stdlib.h>

#include "adam_ral.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef signed short   ee_s16;
typedef unsigned short ee_u16;
typedef signed int     ee_s32;
typedef double         ee_f32;
typedef unsigned char  ee_u8;
typedef unsigned int   ee_u32;
typedef ee_u32         ee_ptr_int;
typedef size_t         ee_size_t;
#define NULL ((void *)0)

int ee_printf(const char *fmt, ...);

#ifdef __cplusplus
}
#endif

#endif
