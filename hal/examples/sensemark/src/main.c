#include <stdint.h>

#include "adam_ral.h"

static uint32_t mhartid();
static void hw_init(void);
static void print(const char * str);

int main()
{
    volatile int init_guard = 1;
    while(init_guard); // Change its value in debug!

    hw_init();

    print("IM ALIVE [CPU]\r\n");

    //Resume LPMEM
    RAL.SYSCFG->LPMEM.MR = 1;
    while(RAL.SYSCFG->LPMEM.MR);

    //Resume LPU0
    RAL.SYSCFG->LPCPU.MR = 1;
    while(RAL.SYSCFG->LPCPU.MR);

    while (1) {
        // mem_log(SLEEP_START);
        //sleep();
        // mem_log(SLEEP_END);
        
        //mem_log(CM_RUN_START);
        print("CM_RUN\r\n");
        //cm_run();
        //mem_log(CM_RUN_END);
    }

    return 0;
}

int main_lpu()
{
    int counter;

    print("IM ALIVE [LPU]\r\n");

    counter = 0;

    while(1) {
        print("test\r\n");

        asm volatile("wfi");

        while(!RAL.LSPA.SPI[0]->TBE);
        RAL.LSPA.SPI[0]->DR = 0xAB;  

        counter++;

        if (counter >= 44100) {
            counter = 0;
            while(!RAL.SYSCFG->CPU[0].MR);
            RAL.SYSCFG->CPU[0].MR = 1;
            while(RAL.SYSCFG->CPU[0].MR);
        }
    }

    //ee_printf("END [LPU]\n");

    return 0;
}

uint32_t mhartid()
{
    uint32_t hartid;
    asm volatile ("csrr %0, mhartid" : "=r"(hartid));
    return hartid;
}

void hw_init(void)
{
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

    // Set up UART0
    RAL.LSPA.UART[0]->BRR = 5208; // 9600 @ 50MHz 
    RAL.LSPA.UART[0]->CR  = 0x807; // No parity, 1 stop, 8 data

    // Set up UART1
    RAL.LSPA.UART[1]->BRR = 5208; // 9600 @ 50MHz 
    RAL.LSPA.UART[1]->CR  = 0x807; // No parity, 1 stop, 8 data

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

    // Enable all interrupts for LPU
    RAL.SYSCFG->LPCPU.IER = ~0;
}

void __attribute__((interrupt)) default_handler(void)
{
    RAL.LSPA.TIMER[0]->ER = ~0;
}

void print(const char *str) {
    ral_uart_t *uart;

    uart = (mhartid() == 0) ? RAL.LSPA.UART[0] : RAL.LSPA.UART[1];

    while(*str != '\0') {
        while(!uart->TBE);
        uart->DR = *str;
        str++;
    }
}

