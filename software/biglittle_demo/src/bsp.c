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

#include "bsp.h"

#pragma optimize("", off)

void timer0_init(void)
{
    RAL.LSPA.TIMER[0]->CR = 1;
}

void timer0_start(void)
{
    // First, make sure timer is stopped
    RAL.LSPA.TIMER[0]->PE = 0; // Disable peripheral
    while(RAL.LSPA.TIMER[0]->PE != 0);

    // Set the counter to zero
    RAL.LSPA.TIMER[0]->VR = 0;

    // Then, set the prescaler to count every 0.1ms
    RAL.LSPA.TIMER[0]->PR = 499; // 50M/500 = 100kHz

    // Set the ARR to max value
    RAL.LSPA.TIMER[0]->ARR = 0xFFFF;

    // Enable the timer
    RAL.LSPA.TIMER[0]->PE = 1;
}

uint32_t timer0_stop(void)
{
    RAL.LSPA.TIMER[0]->PE = 0; // Disable peripheral
    while(RAL.LSPA.TIMER[0]->PE != 0);
    
    return RAL.LSPA.TIMER[0]->VR;
}

void led_toggle(uint8_t led)
{
    RAL.LSPA.GPIO[0]->ODR ^= (0x01 << led);
}

void led_on(uint8_t led)
{
    RAL.LSPA.GPIO[0]->ODR |= (0x01 << led);
}

void led_off(uint8_t led)
{
    RAL.LSPA.GPIO[0]->ODR &= 0xFF & (~(0x01 << led));
}

void all_leds_off(void)
{
    RAL.LSPA.GPIO[0]->ODR &= ~(0xFF);
}

void wakeup_lpu(void)
{
    while (RAL.SYSCFG->LPCPU.SR == 3) {
        RAL.SYSCFG->LPCPU.MR = 1;
        while(RAL.SYSCFG->LPCPU.MR);
    }
}

void wakeup_cpu(void)
{
    while (RAL.SYSCFG->CPU[0].SR == 3) {
        RAL.SYSCFG->CPU[0].MR = 1;
        while(RAL.SYSCFG->CPU[0].MR);
    }
}

#pragma optimize("", on)