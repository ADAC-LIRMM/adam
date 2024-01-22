
#ifndef __TIMER_H__
#define	__TIMER_H__

#include "mem_map.h"
#include "types.h"

typedef struct
{
  uint32_t Presc;
  uint32_t Val;
  uint32_t Reload;
}TIMER_Init_t;

void              TIMER_Init(TIMER_t  *TIMERx, TIMER_Init_t *TIMER_Init);
void              TIMER_DeInit(TIMER_t  *TIMERx);

void              TIMER_Start(TIMER_t  *TIMERx);
void              TIMER_Stop(TIMER_t  *TIMERx);
void              TIMER_Wait(TIMER_t  *TIMERx);
void              TIMER_Reset_val(TIMER_t  *TIMERx);

void              delay_ms(TIMER_t  *TIMERx, uint32_t ms);
void              set_timer_ms(TIMER_t  *TIMERx, uint32_t ms);
void              set_timer_ns(TIMER_t  *TIMERx, uint32_t ns);
#endif
