#ifndef __TYPES_H__
#define	__TYPES_H__

#ifndef _SIZE_T_DECLARED
#define _SIZE_T_DECLARED
typedef unsigned int size_t;
#endif

#ifndef _CLOCK_T_DECLARED
#define _CLOCK_T_DECLARED
typedef int clock_t;
#endif

#ifndef _UINT8_T_DECLARED
#define _UINT8_T_DECLARED
typedef unsigned char uint8_t;
#endif

#ifndef _UINT16_T_DECLARED
#define _UINT16_T_DECLARED
typedef unsigned short uint16_t;
#endif

#ifndef _UINT32_T_DECLARED
#define _UINT32_T_DECLARED
typedef unsigned int uint32_t;
#endif

#ifndef _UINT64_T_DECLARED
#define _UINT64_T_DECLARED
typedef unsigned long long uint64_t;
#endif

#ifndef _INT8_T_DECLARED
#define _INT8_T_DECLARED
typedef signed char int8_t;
#endif

#ifndef _INT16_T_DECLARED
#define _INT16_T_DECLARED
typedef signed short int16_t;
#endif

#ifndef _INT32_T_DECLARED
#define _INT32_T_DECLARED
typedef signed int int32_t;
#endif

#ifndef _INT64_T_DECLARED
#define _INT64_T_DECLARED
typedef signed long long int64_t;
#endif

#if !defined(__cplusplus) && !defined(_BOOL_DECLARED)
#define _BOOL_DECLARED
typedef enum {false, true} bool;
#endif

#ifndef _REG32_T_DECLARED
#define _REG32_T_DECLARED
typedef volatile uint32_t reg32_t;
#endif

#ifndef _REG64_T_DECLARED
#define _REG64_T_DECLARED
typedef volatile uint64_t reg64_t;
#endif

#endif
