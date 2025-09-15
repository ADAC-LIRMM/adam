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

#include "gpio.h"

/**
 * @brief  Initializes the GPIO peripheral.
 * @param  gpio: Pointer to the GPIO peripheral
 * @param  pin: Pin number to be initialized
 * @param  mode: Mode to be used (GPIO_MODE_INPUT or GPIO_MODE_OUTPUT)
 * @param  otype: Output type to be used (GPIO_OTYPE_PP or GPIO_OTYPE_OD)
 * @retval None
 * @note   This function is not working properly. It is just a placeholder.
*/
void gpio_init(ral_gpio_t *gpio, uint8_t pin, uint8_t mode, uint8_t otype)
{
  // Set the pin mode (input or output)
  gpio->MODER &= ~(GPIO_MODE_Mask << pin);
  gpio->MODER |= (mode << pin);
  // Set the pin type (push-pull or open-drain)
  gpio->OTYPER &= ~(GPIO_OTYPE_Mask << pin);
  gpio->OTYPER |= (otype << pin);
  // Set the function of the pin (gpio or alternate)
  gpio->FSR[0] &= ~(GPIO_FUNCSEL_Mask << (pin * 2));
  gpio->FSR[0] |= (0x00U << (pin * 2));
}

/**
 * @brief  Write to the specified GPIO pin.
 * @param  gpio: Pointer to the GPIO peripheral
 * @param  pin: Pin number to be written to
 * @param  value: Value to be written to the pin (0 or 1)
 * @retval None
*/
void gpio_write(ral_gpio_t *gpio, uint8_t pin, uint8_t value)
{
  if (value == 0)
  {
    gpio->ODR &= ~(1 << pin);
  }
  else
  {
    gpio->ODR |= (1 << pin);
  }
}
