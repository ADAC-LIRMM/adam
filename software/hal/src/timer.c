
#include "timer.h"

void TIMER_Init(TIMER_t  *TIMERx, TIMER_Init_t *TIMER_Init)
{
    TIMERx->PR = TIMER_Init->Presc;
    TIMERx->VR = TIMER_Init->Val;
    TIMERx->ARR = TIMER_Init->Reload;
}

void TIMER_DeInit(TIMER_t  *TIMERx)
{
    TIMERx->PR = 0;
    TIMERx->VR = 0;
    TIMERx->ARR = 0;
}

void TIMER_Start(TIMER_t  *TIMERx)
{
    TIMERx->PE = 1;
    while(TIMERx->PE != 1);
}

void TIMER_Stop(TIMER_t  *TIMERx)
{
    TIMERx->PE = 0;
    while(TIMERx->PE != 0);
}

void TIMER_Wait(TIMER_t  *TIMERx)
{
    while(TIMERx->ARE != 1);
    TIMERx->ARE = 1;
}

void TIMER_Reset_val(TIMER_t  *TIMERx)
{
    TIMERx->VR = 0;
}

void delay_ms(TIMER_t  *TIMERx, uint32_t ms)
{
    TIMER_Stop(TIMERx);
    TIMERx->PR = 50000;
    TIMERx->VR = 0;
    TIMERx->ARR = ms;
    TIMER_Start(TIMERx);
    TIMER_Wait(TIMERx);
}

void set_timer_ms(TIMER_t  *TIMERx, uint32_t ms)
{
    TIMER_Stop(TIMERx);
    TIMERx->PR = 50000;
    TIMERx->VR = 0;
    TIMERx->ARR = ms;
    TIMERx->IER = 1;
    TIMER_Start(TIMERx);
}

void set_timer_ns(TIMER_t  *TIMERx, uint32_t ns)
{
    TIMER_Stop(TIMERx);
    TIMERx->PR = 5;
    TIMERx->VR = 0;
    TIMERx->ARR = ns;
    TIMERx->IER = 1;
    TIMER_Start(TIMERx);
}
