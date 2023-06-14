/*
 * ============================================================================
 * ADAM - mem_map.h
 * ============================================================================
 *
 * This header was auto-generated using mem_map_gen.py.
 *
 * Date   : 2023-08-25 13:23:17 UTC
 * Commit : e6abb2635c617bbd51f1908801ab9a16d0dde151
 * 
 * Parameters : 
 *   data_width : 32
 *   gpio_width : 16
 *   no_mems    : 3
 *   no_gpios   : 4
 *   no_spis    : 1
 *   no_timers  : 1
 *   no_uarts   : 1
 *   no_cpus    : 1
 *   no_lpus    : 1
 *
 * Modification of this file is not recommended. 
 * ============================================================================
 */

#ifndef MEM_MAP_H
#define MEM_MAP_H

typedef volatile unsigned int reg_t;

typedef struct {
    const reg_t reserved0[256];
    union {
        reg_t MSR0;
        struct {
            reg_t MSR0_P : 1;
            reg_t MSR0_S : 1;
        };
    };
    reg_t MCR0;
    reg_t MMR0;
    union {
        reg_t MSR1;
        struct {
            reg_t MSR1_P : 1;
            reg_t MSR1_S : 1;
        };
    };
    reg_t MCR1;
    reg_t MMR1;
    union {
        reg_t MSR2;
        struct {
            reg_t MSR2_P : 1;
            reg_t MSR2_S : 1;
        };
    };
    reg_t MCR2;
    reg_t MMR2;
    const reg_t reserved1[247];
    union {
        reg_t PSR_SYSCTRL;
        struct {
            reg_t PSR_SYSCTRL_P : 1;
            reg_t PSR_SYSCTRL_S : 1;
        };
    };
    reg_t PCR_SYSCTRL;
    reg_t PMR_SYSCTRL;
    union {
        reg_t PSR_GPIO0;
        struct {
            reg_t PSR_GPIO0_P : 1;
            reg_t PSR_GPIO0_S : 1;
        };
    };
    reg_t PCR_GPIO0;
    reg_t PMR_GPIO0;
    union {
        reg_t PSR_GPIO1;
        struct {
            reg_t PSR_GPIO1_P : 1;
            reg_t PSR_GPIO1_S : 1;
        };
    };
    reg_t PCR_GPIO1;
    reg_t PMR_GPIO1;
    union {
        reg_t PSR_GPIO2;
        struct {
            reg_t PSR_GPIO2_P : 1;
            reg_t PSR_GPIO2_S : 1;
        };
    };
    reg_t PCR_GPIO2;
    reg_t PMR_GPIO2;
    union {
        reg_t PSR_GPIO3;
        struct {
            reg_t PSR_GPIO3_P : 1;
            reg_t PSR_GPIO3_S : 1;
        };
    };
    reg_t PCR_GPIO3;
    reg_t PMR_GPIO3;
    union {
        reg_t PSR_SPI0;
        struct {
            reg_t PSR_SPI0_P : 1;
            reg_t PSR_SPI0_S : 1;
        };
    };
    reg_t PCR_SPI0;
    reg_t PMR_SPI0;
    union {
        reg_t PSR_TIMER0;
        struct {
            reg_t PSR_TIMER0_P : 1;
            reg_t PSR_TIMER0_S : 1;
        };
    };
    reg_t PCR_TIMER0;
    reg_t PMR_TIMER0;
    union {
        reg_t PSR_UART0;
        struct {
            reg_t PSR_UART0_P : 1;
            reg_t PSR_UART0_S : 1;
        };
    };
    reg_t PCR_UART0;
    reg_t PMR_UART0;
    const reg_t reserved2[488];
    union {
        reg_t CSR_CPU0;
        struct {
            reg_t CSR_CPU0_C : 1;
            reg_t CSR_CPU0_S : 1;
        };
    };
    reg_t CCR_CPU0;
    reg_t CMR_CPU0;
    reg_t BAR_CPU0;
    union {
        reg_t IER_CPU0;
        struct {
            reg_t IER_CPU0_IE0 : 1;
            reg_t IER_CPU0_IE1 : 1;
            reg_t IER_CPU0_IE2 : 1;
            reg_t IER_CPU0_IE3 : 1;
            reg_t IER_CPU0_IE4 : 1;
            reg_t IER_CPU0_IE5 : 1;
            reg_t IER_CPU0_IE6 : 1;
            reg_t IER_CPU0_IE7 : 1;
        };
    };
    union {
        reg_t CSR_LPU0;
        struct {
            reg_t CSR_LPU0_C : 1;
            reg_t CSR_LPU0_S : 1;
        };
    };
    reg_t CCR_LPU0;
    reg_t CMR_LPU0;
    reg_t BAR_LPU0;
    union {
        reg_t IER_LPU0;
        struct {
            reg_t IER_LPU0_IE0 : 1;
            reg_t IER_LPU0_IE1 : 1;
            reg_t IER_LPU0_IE2 : 1;
            reg_t IER_LPU0_IE3 : 1;
            reg_t IER_LPU0_IE4 : 1;
            reg_t IER_LPU0_IE5 : 1;
            reg_t IER_LPU0_IE6 : 1;
            reg_t IER_LPU0_IE7 : 1;
        };
    };
} SYSCTRL_t;

typedef struct {
    union {
        reg_t IDR;
        struct {
            reg_t ID0 : 1;
            reg_t ID1 : 1;
            reg_t ID2 : 1;
            reg_t ID3 : 1;
            reg_t ID4 : 1;
            reg_t ID5 : 1;
            reg_t ID6 : 1;
            reg_t ID7 : 1;
            reg_t ID8 : 1;
            reg_t ID9 : 1;
            reg_t ID10 : 1;
            reg_t ID11 : 1;
            reg_t ID12 : 1;
            reg_t ID13 : 1;
            reg_t ID14 : 1;
            reg_t ID15 : 1;
        };
    };
    union {
        reg_t ODR;
        struct {
            reg_t OD0 : 1;
            reg_t OD1 : 1;
            reg_t OD2 : 1;
            reg_t OD3 : 1;
            reg_t OD4 : 1;
            reg_t OD5 : 1;
            reg_t OD6 : 1;
            reg_t OD7 : 1;
            reg_t OD8 : 1;
            reg_t OD9 : 1;
            reg_t OD10 : 1;
            reg_t OD11 : 1;
            reg_t OD12 : 1;
            reg_t OD13 : 1;
            reg_t OD14 : 1;
            reg_t OD15 : 1;
        };
    };
    union {
        reg_t MODER;
        struct {
            reg_t MODE0 : 1;
            reg_t MODE1 : 1;
            reg_t MODE2 : 1;
            reg_t MODE3 : 1;
            reg_t MODE4 : 1;
            reg_t MODE5 : 1;
            reg_t MODE6 : 1;
            reg_t MODE7 : 1;
            reg_t MODE8 : 1;
            reg_t MODE9 : 1;
            reg_t MODE10 : 1;
            reg_t MODE11 : 1;
            reg_t MODE12 : 1;
            reg_t MODE13 : 1;
            reg_t MODE14 : 1;
            reg_t MODE15 : 1;
        };
    };
    union {
        reg_t OTYPER;
        struct {
            reg_t OTYPE0 : 1;
            reg_t OTYPE1 : 1;
            reg_t OTYPE2 : 1;
            reg_t OTYPE3 : 1;
            reg_t OTYPE4 : 1;
            reg_t OTYPE5 : 1;
            reg_t OTYPE6 : 1;
            reg_t OTYPE7 : 1;
            reg_t OTYPE8 : 1;
            reg_t OTYPE9 : 1;
            reg_t OTYPE10 : 1;
            reg_t OTYPE11 : 1;
            reg_t OTYPE12 : 1;
            reg_t OTYPE13 : 1;
            reg_t OTYPE14 : 1;
            reg_t OTYPE15 : 1;
        };
    };
    union {
        reg_t FSR[2];
        struct {
            reg_t FS0 : 2;
            reg_t FS1 : 2;
            reg_t FS2 : 2;
            reg_t FS3 : 2;
            reg_t FS4 : 2;
            reg_t FS5 : 2;
            reg_t FS6 : 2;
            reg_t FS7 : 2;
            reg_t FS8 : 2;
            reg_t FS9 : 2;
            reg_t FS10 : 2;
            reg_t FS11 : 2;
            reg_t FS12 : 2;
            reg_t FS13 : 2;
            reg_t FS14 : 2;
            reg_t FS15 : 2;
        };
    };
    union {
        reg_t IER;
        struct {
            reg_t IE0 : 1;
            reg_t IE1 : 1;
            reg_t IE2 : 1;
            reg_t IE3 : 1;
            reg_t IE4 : 1;
            reg_t IE5 : 1;
            reg_t IE6 : 1;
            reg_t IE7 : 1;
            reg_t IE8 : 1;
            reg_t IE9 : 1;
            reg_t IE10 : 1;
            reg_t IE11 : 1;
            reg_t IE12 : 1;
            reg_t IE13 : 1;
            reg_t IE14 : 1;
            reg_t IE15 : 1;
        };
    };
} GPIO_t;

typedef struct {
    reg_t DR;
    union {
        reg_t CR;
        struct {
            reg_t PE : 1;
            reg_t TE : 1;
            reg_t RE : 1;
            reg_t MS : 1;
            reg_t CPHA : 1;
            reg_t CPOL : 1;
            reg_t DO : 1;
            reg_t : 1;
            reg_t DL : 4;
        };
    };
    union {
        reg_t SR;
        struct {
            reg_t TBE : 1;
            reg_t RBF : 1;
        };
    };
    reg_t BRR;
    union {
        reg_t IER;
        struct {
            reg_t RBFIE : 1;
            reg_t TBEIE : 1;
        };
    };
} SPI_t;

typedef struct {
    union {
        reg_t CR;
        struct {
            reg_t PE : 1;
        };
    };
    reg_t PR;
    reg_t VR;
    reg_t ARR;
    union {
        reg_t ER;
        struct {
            reg_t ARE : 1;
        };
    };
    union {
        reg_t IER;
        struct {
            reg_t AREIE : 1;
        };
    };
} TIMER_t;

typedef struct {
    reg_t DR;
    union {
        reg_t CR;
        struct {
            reg_t PE : 1;
            reg_t TE : 1;
            reg_t RE : 1;
            reg_t PC : 1;
            reg_t PS : 1;
            reg_t SB : 1;
            reg_t : 2;
            reg_t DL : 4;
        };
    };
    union {
        reg_t SR;
        struct {
            reg_t TBE : 1;
            reg_t RBF : 1;
        };
    };
    reg_t BRR;
    union {
        reg_t IER;
        struct {
            reg_t TBEIE : 1;
            reg_t RBFIE : 1;
        };
    };
} UART_t;

#define MEMS_BASE  (0x10000000)
#define PERIPHS_BASE (0x20000000)

#define MEM0_BASE (MEMS_BASE + 0x00000000)
#define MEM1_BASE (MEMS_BASE + 0x01000000)
#define MEM2_BASE (MEMS_BASE + 0x02000000)

#define SYSCTRL_BASE (PERIPHS_BASE + 0x00000000)
#define GPIO0_BASE   (PERIPHS_BASE + 0x00010000)
#define GPIO1_BASE   (PERIPHS_BASE + 0x00020000)
#define GPIO2_BASE   (PERIPHS_BASE + 0x00030000)
#define GPIO3_BASE   (PERIPHS_BASE + 0x00040000)
#define SPI0_BASE    (PERIPHS_BASE + 0x00050000)
#define TIMER0_BASE  (PERIPHS_BASE + 0x00060000)
#define UART0_BASE   (PERIPHS_BASE + 0x00070000)

#define SYSCTRL (*(SYSCTRL_t *) SYSCTRL_BASE)
#define GPIO0   (*(GPIO_t    *) GPIO0_BASE  )
#define GPIO1   (*(GPIO_t    *) GPIO1_BASE  )
#define GPIO2   (*(GPIO_t    *) GPIO2_BASE  )
#define GPIO3   (*(GPIO_t    *) GPIO3_BASE  )
#define SPI0    (*(SPI_t     *) SPI0_BASE   )
#define TIMER0  (*(TIMER_t   *) TIMER0_BASE )
#define UART0   (*(UART_t    *) UART0_BASE  )

#endif
