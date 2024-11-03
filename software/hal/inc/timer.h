
#ifndef __TIMER_H__
#define	__TIMER_H__

#include "adam_ral.h"
#include "types.h"

void timer_init(ral_timer_t  *timer, uint32_t presc, uint32_t val, uint32_t reload);
void timer_start(ral_timer_t  *timer);
void timer_stop(ral_timer_t  *timer);
void delay_ms(ral_timer_t  *timer, uint32_t ms);
void delay_us(ral_timer_t  *timer, uint32_t us);
unsigned int get_timer_value(ral_timer_t  *timer);
void timer_reset_value(ral_timer_t  *timer);
void delay_16K(ral_timer_t *timer);
void set_timer_ms(ral_timer_t  *TIMERx, uint32_t ms);
void set_timer_us(ral_timer_t  *TIMERx, uint32_t ms);
void set_timer_16k(ral_timer_t  *TIMERx);
void timer0_delay(uint32_t PSC, uint32_t ARR);


#endif
