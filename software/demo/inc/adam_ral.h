/*
 * ============================================================================
 * ADAM Register Access Layer (RAL)
 * ============================================================================
 *
 * This header was auto-generated using gen_ral.py.
 *
 * Date   : 2024-02-15 10:34:01 UTC
 * Target : adam_nexys_video
 * Branch : fabric
 * Commit : dcf25be3fe56c9cae8cfb63749ee1d0440da26b8 (dirty)
 *
 * It is not recommended to modify this this file. 
 * ============================================================================
 */

#pragma once

typedef volatile unsigned int ral_data_t;

typedef struct {
    struct {
        union {
            const ral_data_t SR;
            struct {
                const ral_data_t P : 1;
                const ral_data_t S : 1;
            };
        };
        union {
            ral_data_t MR;
            struct {
                ral_data_t ACTION : 4;
            };
        };
        const ral_data_t reserved0;
        const ral_data_t reserved1;
    } LSDOM;
    struct {
        union {
            const ral_data_t SR;
            struct {
                const ral_data_t P : 1;
                const ral_data_t S : 1;
            };
        };
        union {
            ral_data_t MR;
            struct {
                ral_data_t ACTION : 4;
            };
        };
        const ral_data_t reserved0;
        const ral_data_t reserved1;
    } HSDOM;
    struct {
        union {
            const ral_data_t SR;
            struct {
                const ral_data_t P : 1;
                const ral_data_t S : 1;
            };
        };
        union {
            ral_data_t MR;
            struct {
                ral_data_t ACTION : 4;
            };
        };
        const ral_data_t reserved0;
        const ral_data_t reserved1;
    } FAB_LSDOM;
    struct {
        union {
            const ral_data_t SR;
            struct {
                const ral_data_t P : 1;
                const ral_data_t S : 1;
            };
        };
        union {
            ral_data_t MR;
            struct {
                ral_data_t ACTION : 4;
            };
        };
        const ral_data_t reserved0;
        const ral_data_t reserved1;
    } FAB_HSDOM;
    struct {
        union {
            const ral_data_t SR;
            struct {
                const ral_data_t P : 1;
                const ral_data_t S : 1;
            };
        };
        union {
            ral_data_t MR;
            struct {
                ral_data_t ACTION : 4;
            };
        };
        const ral_data_t reserved0;
        const ral_data_t reserved1;
    } FAB_LSPA;
    struct {
        union {
            const ral_data_t SR;
            struct {
                const ral_data_t P : 1;
                const ral_data_t S : 1;
            };
        };
        union {
            ral_data_t MR;
            struct {
                ral_data_t ACTION : 4;
            };
        };
        ral_data_t BAR;
        ral_data_t IER;
    } LPCPU;
    struct {
        union {
            const ral_data_t SR;
            struct {
                const ral_data_t P : 1;
                const ral_data_t S : 1;
            };
        };
        union {
            ral_data_t MR;
            struct {
                ral_data_t ACTION : 4;
            };
        };
        const ral_data_t reserved0;
        const ral_data_t reserved1;
    } LPMEM;
    struct {
        union {
            const ral_data_t SR;
            struct {
                const ral_data_t P : 1;
                const ral_data_t S : 1;
            };
        };
        union {
            ral_data_t MR;
            struct {
                ral_data_t ACTION : 4;
            };
        };
        ral_data_t BAR;
        ral_data_t IER;
    } CPU[1];
    struct {
        union {
            const ral_data_t SR;
            struct {
                const ral_data_t P : 1;
                const ral_data_t S : 1;
            };
        };
        union {
            ral_data_t MR;
            struct {
                ral_data_t ACTION : 4;
            };
        };
        const ral_data_t reserved0;
        ral_data_t IER;
    } DMA[1];
    struct {
        union {
            const ral_data_t SR;
            struct {
                const ral_data_t P : 1;
                const ral_data_t S : 1;
            };
        };
        union {
            ral_data_t MR;
            struct {
                ral_data_t ACTION : 4;
            };
        };
        const ral_data_t reserved0;
        const ral_data_t reserved1;
    } MEM[2];
    struct {
        struct {
            union {
                const ral_data_t SR;
                struct {
                    const ral_data_t P : 1;
                    const ral_data_t S : 1;
                };
            };
            union {
                ral_data_t MR;
                struct {
                    ral_data_t ACTION : 4;
                };
            };
            const ral_data_t reserved0;
            const ral_data_t reserved1;
        } GPIO[1];
        struct {
            union {
                const ral_data_t SR;
                struct {
                    const ral_data_t P : 1;
                    const ral_data_t S : 1;
                };
            };
            union {
                ral_data_t MR;
                struct {
                    ral_data_t ACTION : 4;
                };
            };
            const ral_data_t reserved0;
            const ral_data_t reserved1;
        } SPI[1];
        struct {
            union {
                const ral_data_t SR;
                struct {
                    const ral_data_t P : 1;
                    const ral_data_t S : 1;
                };
            };
            union {
                ral_data_t MR;
                struct {
                    ral_data_t ACTION : 4;
                };
            };
            const ral_data_t reserved0;
            const ral_data_t reserved1;
        } TIMER[1];
        struct {
            union {
                const ral_data_t SR;
                struct {
                    const ral_data_t P : 1;
                    const ral_data_t S : 1;
                };
            };
            union {
                ral_data_t MR;
                struct {
                    ral_data_t ACTION : 4;
                };
            };
            const ral_data_t reserved0;
            const ral_data_t reserved1;
        } UART[2];
    } LSPA;
    struct {
    } LSPB;
} ral_syscfg_t;

typedef struct {
    union {
        ral_data_t IDR;
        struct {
            ral_data_t ID0 : 1;
            ral_data_t ID1 : 1;
            ral_data_t ID2 : 1;
            ral_data_t ID3 : 1;
            ral_data_t ID4 : 1;
            ral_data_t ID5 : 1;
            ral_data_t ID6 : 1;
            ral_data_t ID7 : 1;
        };
    };
    union {
        ral_data_t ODR;
        struct {
            ral_data_t OD0 : 1;
            ral_data_t OD1 : 1;
            ral_data_t OD2 : 1;
            ral_data_t OD3 : 1;
            ral_data_t OD4 : 1;
            ral_data_t OD5 : 1;
            ral_data_t OD6 : 1;
            ral_data_t OD7 : 1;
        };
    };
    union {
        ral_data_t MODER;
        struct {
            ral_data_t MODE0 : 1;
            ral_data_t MODE1 : 1;
            ral_data_t MODE2 : 1;
            ral_data_t MODE3 : 1;
            ral_data_t MODE4 : 1;
            ral_data_t MODE5 : 1;
            ral_data_t MODE6 : 1;
            ral_data_t MODE7 : 1;
        };
    };
    union {
        ral_data_t OTYPER;
        struct {
            ral_data_t OTYPE0 : 1;
            ral_data_t OTYPE1 : 1;
            ral_data_t OTYPE2 : 1;
            ral_data_t OTYPE3 : 1;
            ral_data_t OTYPE4 : 1;
            ral_data_t OTYPE5 : 1;
            ral_data_t OTYPE6 : 1;
            ral_data_t OTYPE7 : 1;
        };
    };
    union {
        ral_data_t FSR[2];
        struct {
            ral_data_t FS0 : 2;
            ral_data_t FS1 : 2;
            ral_data_t FS2 : 2;
            ral_data_t FS3 : 2;
            ral_data_t FS4 : 2;
            ral_data_t FS5 : 2;
            ral_data_t FS6 : 2;
            ral_data_t FS7 : 2;
        };
    };
    union {
        ral_data_t IER;
        struct {
            ral_data_t IE0 : 1;
            ral_data_t IE1 : 1;
            ral_data_t IE2 : 1;
            ral_data_t IE3 : 1;
            ral_data_t IE4 : 1;
            ral_data_t IE5 : 1;
            ral_data_t IE6 : 1;
            ral_data_t IE7 : 1;
        };
    };
} ral_gpio_t;

typedef struct {
    ral_data_t DR;
    union {
        ral_data_t CR;
        struct {
            ral_data_t PE : 1;
            ral_data_t TE : 1;
            ral_data_t RE : 1;
            ral_data_t MS : 1;
            ral_data_t CPHA : 1;
            ral_data_t CPOL : 1;
            ral_data_t DO : 1;
            ral_data_t : 1;
            ral_data_t DL : 4;
        };
    };
    union {
        ral_data_t SR;
        struct {
            ral_data_t TBE : 1;
            ral_data_t RBF : 1;
        };
    };
    ral_data_t BRR;
    union {
        ral_data_t IER;
        struct {
            ral_data_t RBFIE : 1;
            ral_data_t TBEIE : 1;
        };
    };
} ral_spi_t;

typedef struct {
    union {
        ral_data_t CR;
        struct {
            ral_data_t PE : 1;
        };
    };
    ral_data_t PR;
    ral_data_t VR;
    ral_data_t ARR;
    union {
        ral_data_t ER;
        struct {
            ral_data_t ARE : 1;
        };
    };
    union {
        ral_data_t IER;
        struct {
            ral_data_t AREIE : 1;
        };
    };
} ral_timer_t;

typedef struct {
    ral_data_t DR;
    union {
        ral_data_t CR;
        struct {
            ral_data_t PE : 1;
            ral_data_t TE : 1;
            ral_data_t RE : 1;
            ral_data_t PC : 1;
            ral_data_t PS : 1;
            ral_data_t SB : 1;
            ral_data_t : 2;
            ral_data_t DL : 4;
        };
    };
    union {
        ral_data_t SR;
        struct {
            ral_data_t TBE : 1;
            ral_data_t RBF : 1;
        };
    };
    ral_data_t BRR;
    union {
        ral_data_t IER;
        struct {
            ral_data_t TBEIE : 1;
            ral_data_t RBFIE : 1;
        };
    };
} ral_uart_t;

typedef struct {
    ral_data_t *LPMEM;
    ral_syscfg_t *SYSCFG;
    struct {
        ral_gpio_t *GPIO[1];
        ral_spi_t *SPI[1];
        ral_timer_t *TIMER[1];
        ral_uart_t *UART[2];
    } LSPA;
    struct {
        ral_gpio_t *GPIO[0];
        ral_spi_t *SPI[0];
        ral_timer_t *TIMER[0];
        ral_uart_t *UART[0];
    } LSPB;
    ral_data_t *MEM[2];
} ral_t;

static const ral_t RAL = {
    .LPMEM = (ral_data_t *) 0x00000000,
    .SYSCFG = (ral_syscfg_t *) 0x00008000,
    .LSPA = {
        .GPIO = {
            (ral_gpio_t *) 0x00010000,
        },
        .SPI = {
            (ral_spi_t *) 0x00010400,
        },
        .TIMER = {
            (ral_timer_t *) 0x00010800,
        },
        .UART = {
            (ral_uart_t *) 0x00010C00,
            (ral_uart_t *) 0x00011000,
        },
    },
    .LSPB = {},
    .MEM = {
        (ral_data_t *) 0x01000000,
        (ral_data_t *) 0x02000000,
    },
};

#define SYSCTRL_BASE (0x00008000)
#define GPIO0_BASE   (0x00010000)
#define SPI0_BASE    (0x00010400)
#define TIMER0_BASE  (0x00010800)
#define UART0_BASE   (0x00010C00)
#define UART1_BASE   (0x00011000)

#define SYSCTRL (*(ral_syscfg_t  *) SYSCTRL_BASE)
#define GPIO0   (*(ral_gpio_t    *) GPIO0_BASE  )
#define SPI0    (*(ral_spi_t     *) SPI0_BASE   )
#define TIMER0  (*(ral_timer_t   *) TIMER0_BASE )
#define UART0   (*(ral_uart_t    *) UART0_BASE  )
#define UART1   (*(ral_uart_t    *) UART1_BASE  )
