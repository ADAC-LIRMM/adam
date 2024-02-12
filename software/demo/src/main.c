#include "system.h"

static void hw_init(void);

int main()
{
    // volatile int init_guard = 1;
    // while(init_guard); // Change its value in debug!

    hw_init();

    // Initialize UART 0 with a baud rate of 9600
    uart_init(RAL.LSPA.UART[0], 9600);

    ee_printf("IM ALIVE!\r\n");

    int i = 35;
    float f = 3.15;
    ee_printf("i = %d\r\n", i);
    ee_printf("f = %.2f\r\n", f);

    ee_printf("Starting timer\r\n");
    int pin = 0;

    while (1) {
        gpio_write(RAL.LSPA.GPIO[0], pin, 1);
        delay_ms(RAL.LSPA.TIMER[0], 1000);
        gpio_write(RAL.LSPA.GPIO[0], pin, 0);
        delay_ms(RAL.LSPA.TIMER[0], 1000);
        if (pin < 7) {
            pin++;
        } else {
            pin = 0;
        }
    }
    return 0;
}

int main_lpu()
{
    return 0;
}

void hw_init(void)
{
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

    // Resume TIMER0
    RAL.SYSCFG->LSPA.TIMER[0].MR = 1;
    while(RAL.SYSCFG->LSPA.TIMER[0].MR);

    // Resume GPIO0
    RAL.SYSCFG->LSPA.GPIO[0].MR = 1;
    while(RAL.SYSCFG->LSPA.GPIO[0].MR);

    // Why we don't need this command 
    // if it is not the LPCPU we're using?
    // Enable all interrupts for LPCPU
    RAL.SYSCFG->LPCPU.IER = ~0;
}

void __attribute__((interrupt)) default_handler(void)
{
    RAL.LSPA.TIMER[0]->ER = ~0;
}