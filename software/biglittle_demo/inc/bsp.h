#ifndef __BSP_H__
#define __BSP_H__

#ifdef __cplusplus  
extern "C" {
#endif

#include "system.h"

// timer functions
void        timer0_init (void);
void        timer0_start(void);
uint32_t    timer0_stop (void);

void led_toggle(uint8_t led);
void led_on(uint8_t led);
void led_off(uint8_t led);
void all_leds_off(void);

void wakeup_lpu(void);
void wakeup_cpu(void);

#ifdef __cplusplus
}
#endif

#endif // __BSP_H__