#include "system.h"

static void hw_init(void);

volatile int timer_interrupt_occurred = 0;

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
    timer_init(RAL.LSPA.TIMER[0], 49999, 0, UINT32_MAX);
    int pin = 0;

    while (1) {
        gpio_write(RAL.LSPA.GPIO[0], pin, 1);
        timer_start(RAL.LSPA.TIMER[0]);
        for(int j = 0; j < 1000000; j++) {
            __asm__("nop");
        }
        for(int j = 0; j < 1000000; j++) {
            __asm__("nop");
        }
        timer_stop(RAL.LSPA.TIMER[0]);
        int timer_value = get_timer_value(RAL.LSPA.TIMER[0]);
        timer_reset_value(RAL.LSPA.TIMER[0]);
        ee_printf("Elapsed time: %d\r\n", timer_value);
        gpio_write(RAL.LSPA.GPIO[0], pin, 0);
        delay_ms(RAL.LSPA.TIMER[0], 1000);
        ee_printf("Delay done\r\n");
        if (pin < 7) {
            pin++;
        } else {
            pin = 0;
        }
    }
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

    RAL.SYSCFG->CPU[0].IER = ~0;
}

void __attribute__((interrupt)) default_handler(void)
{
    // Clear timer interrupt
    RAL.LSPA.TIMER[0]->ER = ~0;
    // Flag the interrupt
    timer_interrupt_occurred = 1;
}