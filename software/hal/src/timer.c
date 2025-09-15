/*
 * Copyright 2025 LIRMM
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


#include "timer.h"
#include "print.h"
#include "gpio.h"
extern volatile int timer_interrupt_occurred;

void timer_init(ral_timer_t *timer, uint32_t presc, uint32_t val,
                uint32_t reload) {
  timer->PR = presc;
  timer->VR = val;
  timer->ARR = reload;
  timer->ER = ~0;
  timer->IER = ~0;
}

void set_timer_ms(ral_timer_t *TIMERx, uint32_t ms) {
  timer_stop(TIMERx);
  TIMERx->PR = 24999;
  TIMERx->VR = 0;
  TIMERx->ARR = ms;
  TIMERx->IER = 1;
  timer_start(TIMERx);
}

void set_timer_us(ral_timer_t *TIMERx, uint32_t us) {
  timer_stop(TIMERx);
  TIMERx->PR = 24;
  TIMERx->VR = 0;
  TIMERx->ARR = us;
  TIMERx->IER = 1;
  timer_start(TIMERx);
}

void set_timer_16k(ral_timer_t *TIMERx) {
  timer_stop(TIMERx);
  TIMERx->PR = 1562;
  TIMERx->VR = 0;
  TIMERx->ARR = 1;
  TIMERx->IER = 1;
  timer_start(TIMERx);
}

void timer_start(ral_timer_t *timer) {
  timer->PE = 1;
  while (timer->PE != 1);
}

void timer_stop(ral_timer_t *timer) {
  timer->PE = 0;
  while (timer->PE != 0);
}

void delay_ms(ral_timer_t *timer, uint32_t ms) {
  timer->PE = 0;
  timer->PR = 24999;
  timer->VR = 0;
  timer->ARR = ms;
  timer->IER = ~0;
  timer->PE = 1;
  while (timer->PE != 1);
  // Wait for timer to finish
  while (!timer_interrupt_occurred);
  // Reset the flag
  timer_interrupt_occurred = 0; 
}

void delay_us(ral_timer_t *timer, uint32_t us) {
  timer->PE = 0;
  timer->PR = 24;
  timer->VR = 0;
  timer->ARR = us;
  timer->IER = ~0;
  timer->PE = 1;
  while (timer->PE != 1);
  // Wait for timer to finish
  while (!timer_interrupt_occurred);
  // Reset the flag
  timer_interrupt_occurred = 0; 
}

void delay_16K(ral_timer_t *timer) {
  timer->PE = 0;
  timer->PR = 1399; // 1399
  timer->VR = 0;
  timer->ARR = 1;
  timer->IER = ~0;
  timer->PE = 1;
  while (timer->PE != 1);
  // Wait for timer to finish
  while (!timer_interrupt_occurred);
  // Reset the flag
  timer_interrupt_occurred = 0; 
}
void timer0_delay(uint32_t PSC, uint32_t ARR) {
  ral_timer_t *timer = (ral_timer_t *)RAL.LSPA.TIMER[0];
  timer->PE = 0;
  timer->PR = PSC;
  timer->VR = 0;
  timer->ARR = ARR;
  timer->IER = ~0;
  timer->PE = 1;
  while (timer->PE != 1);
  // Wait for timer to finish
  while (!timer_interrupt_occurred);
  // Reset the flag
  timer_interrupt_occurred = 0; 
}

unsigned int get_timer_value(ral_timer_t *timer) { return timer->VR; }

void timer_reset_value(ral_timer_t *timer) { timer->VR = 0; }