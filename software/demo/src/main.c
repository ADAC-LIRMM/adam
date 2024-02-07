#include "system.h"

static void hw_init(void);

int main()
{
    hw_init();

    uart_init(RAL.LSPA.UART[0], 9600);

    uart_send_str(RAL.LSPA.UART[0], "Hello, World!\r\n");

    while(1) {
    };

    return 0;
}

int main_lpu()
{
    return 0;
}

void hw_init(void)
{
    // // Stop LPCPU
    // RAL.SYSCFG->LPCPU.MR = 3;
    // while(RAL.SYSCFG->LPCPU.MR);

    // Resume LPMEM
    RAL.SYSCFG->LPMEM.MR = 1;
    while(RAL.SYSCFG->LPMEM.MR);

    // Resume MEMs
    for (int i = 0; i < 3; i++) {
        RAL.SYSCFG->MEM[i].MR = 1;
        while(RAL.SYSCFG->MEM[i].MR);
    }

    // Resume UART0
    RAL.SYSCFG->LSPA.UART[0].MR = 1;
    while(RAL.SYSCFG->LSPA.UART[0].MR);

    // Resume UART1
    RAL.SYSCFG->LSPA.UART[1].MR = 1;
    while(RAL.SYSCFG->LSPA.UART[1].MR);

    // Resume SPI0
    RAL.SYSCFG->LSPA.SPI[0].MR = 1;
    while(RAL.SYSCFG->LSPA.UART[0].MR);

    // Resume TIMER0
    RAL.SYSCFG->LSPA.TIMER[0].MR = 1;
    while(RAL.SYSCFG->LSPA.TIMER[0].MR);

    // Set up SPI0
    RAL.LSPA.SPI[0]->TE   = 1;
    RAL.LSPA.SPI[0]->RE   = 0;
    RAL.LSPA.SPI[0]->MS   = 1;
    RAL.LSPA.SPI[0]->CPHA = 0;
    RAL.LSPA.SPI[0]->CPOL = 0;
    RAL.LSPA.SPI[0]->DO   = 0;
    RAL.LSPA.SPI[0]->DL   = 8;
    RAL.LSPA.SPI[0]->BRR  = 50; // 1MHz @ 50 MHz
    RAL.LSPA.SPI[0]->PE   = 1;

    // Set up TIMER0
    RAL.LSPA.TIMER[0]->PR  = 0; // 50MHz @ 50MHz
    RAL.LSPA.TIMER[0]->VR  = 0;
    RAL.LSPA.TIMER[0]->ARR = 1134; // 44100 Hz
    RAL.LSPA.TIMER[0]->ER  = ~0;
    RAL.LSPA.TIMER[0]->IER = ~0;
    RAL.LSPA.TIMER[0]->PE  = 1;

    // Enable all interrupts for LPCPU
    RAL.SYSCFG->LPCPU.IER = ~0;
}
