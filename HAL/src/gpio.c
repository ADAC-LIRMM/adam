
#include "gpio.h"

// TODO:
// Make it adaptive to GPIO lenght (here 16)
// Interrupt Eneble support ?
// Check deinit reset values
// Check FSR[0] + make it generic
// Move assert def to general

/**
 * @brief  Initialize the GPIOx peripheral according to the specified parameters in the GPIO_Init.
 * @param  GPIOx where x can be (0,1,2, ...) to select the GPIO peripheral
 * @param  GPIO_Init pointer to a GPIO_Init_t structure that contains the configuration information for the specified GPIO peripheral.
 * @retval None
 */
void GPIO_Init(GPIO_t  *GPIOx, GPIO_Init_t *GPIO_Init)
{
  uint32_t position = 0x00u;
  uint32_t iocurrent;

  /* Check the parameters */
  assert_param(IS_GPIO_PIN(GPIO_Init->Pin));
  assert_param(IS_GPIO_MODE(GPIO_Init->Mode));
  assert_param(IS_GPIO_OTYPE(GPIO_Init->Otype));
  assert_param(IS_GPIO_FUNC(GPIO_Init->Func));

  /* Configure the port pins */
  while (((GPIO_Init->Pin) >> position) != 0x00u)
  {
    /* Get current io position */
    iocurrent = (GPIO_Init->Pin) & (1UL << position);

    if (iocurrent != 0x00u)
    {
      /*--------------------- GPIO Output Type Configuration ------------------------*/
      GPIOx->OTYPER &= ~(GPIO_OTYPE_Mask << position);
      GPIOx->OTYPER |= (GPIO_Init->Otype << position);

      /*--------------------- GPIO Function Configuration ------------------------*/
      GPIOx->FSR[0] &= ~(GPIO_FUNCSEL_Mask << (position * 2u));
      GPIOx->FSR[0] |= (GPIO_Init->Func << (position * 2u));

      /*--------------------- GPIO Mode Configuration ------------------------*/
      GPIOx->MODER &= ~(GPIO_MODE_Mask << position);
      GPIOx->MODER |= (GPIO_Init->Mode << position);
    }
    position++;
  }
}


/**
  * @brief  De-initialize the GPIOx peripheral registers to their default reset values.
  * @param  GPIOx where x can be (0,1,2, ...) to select the GPIO peripheral
  * @param  GPIO_Pin specifies the selected port bit to be deinit.
  * @retval None
  */
void GPIO_DeInit(GPIO_t  *GPIOx, uint32_t GPIO_Pin)
{
  uint32_t position = 0x00u;
  uint32_t iocurrent;

  /* Configure the port pins */
  while (((GPIO_Pin) >> position) != 0x00u)
  {
    /* Get current io position */
    iocurrent = (GPIO_Pin) & (1UL << position);

    if (iocurrent != 0x00u)
    {
      /*--------------------- GPIO Output Type reset ------------------------*/
      GPIOx->OTYPER &= ~(GPIO_OTYPE_Mask << position);

      /*--------------------- GPIO Function reset ------------------------*/
      GPIOx->FSR[0] &= ~(GPIO_FUNCSEL_Mask << (position * 2u));

      /*--------------------- GPIO Mode reset ------------------------*/
      GPIOx->MODER &= ~(GPIO_MODE_Mask << position);
    }
    position++;
  }
}


/**
  * @brief  Read the specified input port pin.
  * @param  GPIOx where x can be (0,1,2, ...) to select the GPIO peripheral
  * @param  GPIO_Pin specifies the port bit to read. This parameter can be GPIO_PIN_x where x can be (0..15).
  * @retval The input port pin value.
  */
GPIO_PinState GPIO_ReadPin(GPIO_t* GPIOx, uint16_t GPIO_Pin)
{
  GPIO_PinState bitstatus;

  /* Check the parameters */
  assert_param(IS_GPIO_PIN(GPIO_Pin));

  if ((GPIOx->IDR & GPIO_Pin) != (uint32_t)GPIO_PIN_RESET)
  {
    bitstatus = GPIO_PIN_SET;
  }
  else
  {
    bitstatus = GPIO_PIN_RESET;
  }
  return bitstatus;
  }


/**
  * @brief  Set or clear the selected data port bit.
  * @param  GPIOx where x can be (0,1,2, ...) to select the GPIO peripheral
  * @param  GPIO_Pin specifies the port bit to be written. This parameter can be one of GPIO_PIN_x where x can be (0..15).
  * @param  PinState specifies the value to be written to the selected bit.
  *          This parameter can be one of the GPIO_PinState enum values:
  *            @arg GPIO_PIN_RESET: to clear the port pin
  *            @arg GPIO_PIN_SET: to set the port pin
  * @retval None
  */
void GPIO_WritePin(GPIO_t* GPIOx, uint16_t GPIO_Pin, GPIO_PinState PinState)
{
  /* Check the parameters */
  assert_param(IS_GPIO_PIN(GPIO_Pin));
  assert_param(IS_GPIO_PIN_ACTION(PinState));

  if (PinState != GPIO_PIN_RESET)
  {
    GPIOx->ODR |= GPIO_Pin;
  }
  else
  {
    GPIOx->ODR &= (~GPIO_Pin);
  }
}


/**
  * @brief  Toggle the specified GPIO pin.
  * @param  GPIOx where x can be (0,1,2, ...) to select the GPIO peripheral
  * @param  GPIO_Pin specifies the pin to be toggled. This parameter can be one of GPIO_PIN_x where x can be (0..15).
  * @retval None
  */
void GPIO_TogglePin(GPIO_t* GPIOx, uint16_t GPIO_Pin)
{
  /* Check the parameters */
  assert_param(IS_GPIO_PIN(GPIO_Pin));

  /* Toggle selected pin */
  GPIOx->ODR ^= GPIO_Pin;
}
