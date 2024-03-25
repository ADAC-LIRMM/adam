#include "system.h"

static void hw_init(void);

volatile int timer_interrupt_occurred = 0;

int main ()
{
    hw_init();
    
    uart_init(RAL.LSPA.UART[0], 9600);
    
    volatile unsigned char cpu_led_on = 0;
    while (1) {

            cpu_led_on = !cpu_led_on;   
            for (int i = 0; i < 4; i++)
            {
                gpio_write(RAL.LSPA.GPIO[0], i, cpu_led_on);
                //delay_us(RAL.LSPA.TIMER[0], 10);
            }
            // if LPU is asleep wake it up
            if(RAL.SYSCFG->LPCPU.SR == 3){
                RAL.SYSCFG->LPCPU.MR = 1;
                while(RAL.SYSCFG->LPCPU.MR);
            }
            sleep();
            __asm__ volatile("nop");
        }
    return 0;
}

int main_lpu() 
{
    volatile unsigned char lpu_led_on = 0;
    while (1)
    {
        while (RAL.SYSCFG->CPU[0].SR == 3) // When the CPU is Paused
        {
            lpu_led_on = !lpu_led_on;
            for (int i = 4; i < 8; i++)
            {
                gpio_write(RAL.LSPA.GPIO[0], i, lpu_led_on);
                //delay_us(RAL.LSPA.TIMER[0], 10);
            }
            // Wake CPU
            RAL.SYSCFG->CPU[0].MR = 1;
            while(RAL.SYSCFG->CPU[0].MR);
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
    
    // Enable LPU Interrupt
    RAL.SYSCFG->LPCPU.IER = ~0;
}

void __attribute__((interrupt)) default_handler(void)
{
    // Clear timer interrupt
    RAL.LSPA.TIMER[0]->ER = ~0;
    // Flag the interrupt
    timer_interrupt_occurred = 1;
}