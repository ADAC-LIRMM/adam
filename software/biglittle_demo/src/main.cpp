#include "system.h"
#include "bsp.h"
#include "kiss_fftr.h"

int main_lpu() asm ("main_lpu");
static void hw_init(void);

volatile int timer_interrupt_occurred;
volatile int lpu_event;
int curr_sample_index;
int running;

#define FFT_LEN 4
uint32_t waveform[FFT_LEN];
kiss_fft_cpx fft_out[FFT_LEN/2 + 1];

uint8_t mem_fft[2000];
size_t size_mem_fft;
kiss_fftr_cfg rfft;

int main()
{
    hw_init();
    timer0_init();
    all_leds_off();
    uart_init(RAL.LSPA.UART[0], 115200);
    led_on(0);

	rfft = kiss_fftr_alloc(FFT_LEN, 0, mem_fft, &size_mem_fft);
    wakeup_lpu();
    my_printf("CPU ready.\r\n");

    while (running) {
        sleep();
        if (lpu_event) {
            led_on(7);
            my_printf("Performing FFT... ");
            kiss_fftr(rfft, (float*)waveform, fft_out);
            my_printf("Done.\r\n");
            lpu_event = 0;
            led_off(7);
        }
    }
    led_on(1);
    while(1);
    return 0;
}

int main_lpu()
{
    led_on(1);
    my_printf("LPU started.\r\n");
    while (running) {
        /* Check for receive event */
        if (RAL.LSPA.UART[0]->RBF) {
            led_on(6);

            // Read received data clears status register
            char c = RAL.LSPA.UART[0]->DR;
            waveform[curr_sample_index] = c;
            my_printf("Received: waveform[%d] = %d\r\n", curr_sample_index, (uint8_t)(c));

            // Increment the sample index
            curr_sample_index = (curr_sample_index + 1) % FFT_LEN;

            if (curr_sample_index == 0) {
                lpu_event = 1;
                wakeup_cpu();
            }

            if (c == 'q') {
                running = 0;
                wakeup_cpu();
            }

            led_off(6);
        }
    }
    led_on(2);
    while(1);
    return 0;
}

void hw_init(void)
{
    // Resume LPMEM
    RAL.SYSCFG->LPMEM.MR = 1;
    while(RAL.SYSCFG->LPMEM.MR);

    // Resume MEMs
    for (int i = 0; i < 2; i++) {
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
    // RAL.SYSCFG->CPU[0].IER = ~0;

    // Init global variables
    timer_interrupt_occurred = 0;
    lpu_event = 0;
    curr_sample_index = 0;
    size_mem_fft = sizeof(mem_fft);
    running = 1;

}

void __attribute__((interrupt)) default_handler(void)
{
    // Clear timer interrupt
    RAL.LSPA.TIMER[0]->ER = ~0;
    // Flag the interrupt
    timer_interrupt_occurred = 1;
}