
#include "timer.h"
#include "print.h"

void timer_init(ral_timer_t  *timer, uint32_t presc, uint32_t val, uint32_t reload)
{
    timer->PR  = presc;
    timer->VR  = val;
    timer->ARR = reload;
    timer->ER  = ~0;
    timer->IER = ~0;
}

void timer_start(ral_timer_t  *timer)
{
    timer->PE = 1;
    while(timer->PE != 1);
}

void timer_stop(ral_timer_t  *timer)
{
    timer->PE = 0;
    while(timer->PE != 0);
}

void timer_wait(ral_timer_t *timer)
{
    while(timer->ARE != 1);
    timer->ARE = 1;
}

void delay_ms(ral_timer_t  *timer, uint32_t ms)
{
    timer->PE = 0;
    timer->PR = 49999;
    timer->VR = 0;
    timer->ARR = ms;
    timer->IER = ~0;
    timer->PE = 1;
    while(timer->PE != 1);
    timer_wait(timer);
}


unsigned int get_timer_value(ral_timer_t  *timer)
{
    return timer->VR;
}

void timer_reset_value(ral_timer_t  *timer)
{
    timer->VR = 0;
}