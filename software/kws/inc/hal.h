#pragma once

#include <stdint.h>
#include <stddef.h>
#include "adam_ral.h"
#include "cfg.h"

extern void deep_sleep(void);
extern void lpcpu_start(void);

// UART[0] ====================================================================

static inline void hal_uart0_init(void)
{
    RAL.SYSCFG->LSPA.UART[0].MR = 1;
    while (RAL.SYSCFG->LSPA.UART[0].MR);

    RAL.LSPA.UART[0]->BRR = SYSTEM_CLOCK / 115200;

    RAL.LSPA.UART[0]->TE = 1;
    RAL.LSPA.UART[0]->RE = 1;
    RAL.LSPA.UART[0]->DL = 8;

    RAL.LSPA.UART[0]->PE = 1;
}

static inline void hal_uart0_write(const char *buf, size_t len)
{
    for (size_t i = 0; i < len; i++) {
        while(!RAL.LSPA.UART[0]->TBE);
        RAL.LSPA.UART[0]->DR = *buf++;
    }
}

// SPI[0] =====================================================================

static inline void hal_spi0_init(void)
{
    RAL.SYSCFG->LSPA.SPI[0].MR = 1;
    while (RAL.SYSCFG->LSPA.SPI[0].MR);

    RAL.LSPA.SPI[0]->MS = 1;
    RAL.LSPA.SPI[0]->CPHA = 0;
    RAL.LSPA.SPI[0]->CPOL = 0;
    RAL.LSPA.SPI[0]->DO = 1;
    RAL.LSPA.SPI[0]->DL = 15;

    RAL.LSPA.SPI[0]->BRR = SYSTEM_CLOCK / 1000000;

    RAL.LSPA.SPI[0]->PE = 1;
    RAL.LSPA.SPI[0]->TE = 1;
    RAL.LSPA.SPI[0]->RE = 1;
}

static inline int32_t hal_spi0_read(void)
{
    while(!RAL.LSPA.SPI[0]->TBE);
    RAL.LSPA.SPI[0]->DR = 0xFF;

    while(!RAL.LSPA.SPI[0]->RBF);
    return RAL.LSPA.SPI[0]->DR;
}

// TIMER[0] ===================================================================

static inline void hal_timer0_init(void)
{
    RAL.SYSCFG->LSPA.TIMER[0].MR = 1;
    while (RAL.SYSCFG->LSPA.TIMER[0].MR);

    RAL.LSPA.TIMER[0]->PR = SYSTEM_CLOCK / CFG_SAMPLE_RATE;
    RAL.LSPA.TIMER[0]->VR = 0;
    RAL.LSPA.TIMER[0]->ARR = 0;
    RAL.LSPA.TIMER[0]->IER = 1;
}

static inline void hal_timer0_start(void)
{
    RAL.LSPA.TIMER[0]->VR = 0;
    RAL.LSPA.TIMER[0]->PE = 1;
}

static inline void hal_timer0_stop(void)
{
    RAL.LSPA.TIMER[0]->PE = 0;
}

void hal_timer0_callback(void);

// TIMER[1] ===================================================================

static inline void hal_timer1_init(void)
{
    RAL.SYSCFG->LSPA.TIMER[1].MR = 1;
    while (RAL.SYSCFG->LSPA.TIMER[1].MR);

    RAL.LSPA.TIMER[1]->PR = 0;
    RAL.LSPA.TIMER[1]->VR = 0;
    RAL.LSPA.TIMER[1]->ARR = ~0;
    RAL.LSPA.TIMER[1]->IER = 0;

    RAL.LSPA.TIMER[1]->PE = 1;
}

static inline uint32_t hal_timer1_read(void)
{
    return RAL.LSPA.TIMER[1]->VR;
}

// LPMEM ======================================================================

static inline void hal_lpmem_init(void)
{
    RAL.SYSCFG->LPMEM.MR = 1;
    while (RAL.SYSCFG->LPMEM.MR);
}

// CPU ========================================================================

static inline void hal_cpu0_resume(void)
{
    while (!RAL.SYSCFG->CPU[0].SR);

    RAL.SYSCFG->CPU[0].MR = 1;
    while (RAL.SYSCFG->CPU[0].MR);
}

static inline void hal_cpu0_enable_irq(void)
{
    RAL.SYSCFG->CPU[0].IER = ~0;
}

// LPCPU ======================================================================

static inline void hal_lpcpu_resume(void)
{
    RAL.SYSCFG->LPCPU.BAR = (uint32_t) lpcpu_start;
    RAL.SYSCFG->LPCPU.MR = 1;
    while (RAL.SYSCFG->LPCPU.MR);
}

static inline void hal_lpcpu_enable_irq(void)
{
    RAL.SYSCFG->LPCPU.IER = ~0;
}
