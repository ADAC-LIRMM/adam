#include <errno.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <unistd.h>

#include "cfg.h"
#include "hal.h"
#include "inference.h"

#define TIC() \
    do { t0 = hal_timer1_read(); } while (0)

#define TOC(label) \
    do { \
        uint32_t t1 = hal_timer1_read(); \
        printf("%s: %d cycles\n", (label), (int) (t1 - t0)); \
    } while (0)

static volatile int16_t audio_buffer[CFG_AUDIO_DATA_SIZE];
static volatile int16_t * volatile LPMEM_DATA audio_ptr = audio_buffer;
static volatile uint32_t t0;

int main() {
    volatile int result;

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

    printf("I'm alive.\n");

    TIC();
    inference_preproc_init();
    TOC("inference_preproc_init");

    TIC();
    inference_speech_init();
    TOC("inference_speech_init");

    context_backup_periph();
    context_backup();
    context_restore_periph();

    TIC();
    hal_timer0_start();
    while(1) {

#ifdef CFG_DEEP_SLEEP
        deep_sleep();
#elif !defined(CFG_LPCPU)
        asm volatile("wfi");
#endif

        if (audio_ptr == audio_buffer + CFG_AUDIO_DATA_SIZE) {
            TOC("recording");

            TIC();
            inference_preproc_run((int16_t *) audio_buffer,
                                  CFG_AUDIO_DATA_SIZE);
            TOC("inference_preproc_run");

            TIC();
            result = inference_speech_run();
            TOC("inference_speech_run");

            printf("result: %d\n", result);

            audio_ptr = audio_buffer;

            TIC();
            hal_timer0_start();
        }
    }

    return 0;
}

void LPMEM_TEXT main_lpcpu(void)
{
    while(1) {
        asm volatile("wfi");
        // RAL.LSPA.UART[0]->DR = '@';
    }
}

// IRQ ========================================================================

void __attribute__((interrupt)) LPMEM_TEXT
#ifdef CFG_LPCPU
    lpcpu_handler(void)
#else
    default_handler(void)
#endif
{
    if(!RAL.LSPA.TIMER[0]->ER) return;
    RAL.LSPA.TIMER[0]->ER = ~0;

    static int16_t LPMEM_DATA prev_in = 0;
    static int32_t LPMEM_DATA prev_out = 0;
    static int64_t LPMEM_DATA power_sum = 0;

    int16_t in = hal_spi0_read();

    // High-pass filter: y[n] = x[n] - x[n-1] + R*y[n-1]
    int32_t out = (int32_t)(in - prev_in) + ((prev_out * CFG_AUDIO_HPF) >> 15);
    prev_in = in;
    prev_out = out;

    if (out > 32767) out = 32767;
    if (out < -32768) out = -32768;

    if (audio_ptr != audio_buffer + CFG_AUDIO_DATA_SIZE) {
        int16_t s = (int16_t)out;
        *audio_ptr++ = in;
        power_sum += (int64_t)s * s;

        if (audio_ptr == audio_buffer + CFG_AUDIO_DATA_SIZE) {
            if (power_sum >= CFG_AUDIO_THRESHOLD) {
                hal_timer0_stop();
#ifdef CFG_LPCPU
                hal_cpu0_resume();
#endif
            } else {
                audio_ptr = audio_buffer;
            }
            // Reset for next collection
            power_sum = 0;
            prev_in = 0;
            prev_out = 0;
        }
    }
}
