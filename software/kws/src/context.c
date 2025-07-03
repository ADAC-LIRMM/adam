#include "hal.h"

static uint8_t timer0_pe = 0;

void context_backup_periph(void)
{
    RAL.SYSCFG->LPCPU.MR = 3;
    while (RAL.SYSCFG->LPCPU.MR);

    timer0_pe = RAL.LSPA.TIMER[0]->PE;

    RAL.LSPA.TIMER[0]->PE = 0;
}

void context_restore_periph(void)
{
    hal_uart0_init();
    hal_spi0_init();
    hal_timer0_init();
    hal_timer1_init();

#ifdef CFG_LPCPU
    hal_lpmem_init();
    hal_lpcpu_resume();
    hal_lpcpu_enable_irq();
#else
    hal_cpu0_enable_irq();
#endif

    RAL.LSPA.TIMER[0]->PE = timer0_pe;
}



