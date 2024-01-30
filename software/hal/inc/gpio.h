
#ifndef __GPIO_H__
#define	__GPIO_H__

#include "mem_map.h"
#include "types.h"
#include "utils.h"

typedef struct
{
  uint32_t Pin;
  uint32_t Mode;
  uint32_t Otype;
  uint32_t Func;
}GPIO_Init_t;

typedef enum
{
  GPIO_PIN_RESET = 0U,
  GPIO_PIN_SET
}GPIO_PinState;

#define GPIO_PIN_0                 ((uint16_t)0x0001U)  /* Pin 0 selected    */
#define GPIO_PIN_1                 ((uint16_t)0x0002U)  /* Pin 1 selected    */
#define GPIO_PIN_2                 ((uint16_t)0x0004U)  /* Pin 2 selected    */
#define GPIO_PIN_3                 ((uint16_t)0x0008U)  /* Pin 3 selected    */
#define GPIO_PIN_4                 ((uint16_t)0x0010U)  /* Pin 4 selected    */
#define GPIO_PIN_5                 ((uint16_t)0x0020U)  /* Pin 5 selected    */
#define GPIO_PIN_6                 ((uint16_t)0x0040U)  /* Pin 6 selected    */
#define GPIO_PIN_7                 ((uint16_t)0x0080U)  /* Pin 7 selected    */
#define GPIO_PIN_8                 ((uint16_t)0x0100U)  /* Pin 8 selected    */
#define GPIO_PIN_9                 ((uint16_t)0x0200U)  /* Pin 9 selected    */
#define GPIO_PIN_10                ((uint16_t)0x0400U)  /* Pin 10 selected   */
#define GPIO_PIN_11                ((uint16_t)0x0800U)  /* Pin 11 selected   */
#define GPIO_PIN_12                ((uint16_t)0x1000U)  /* Pin 12 selected   */
#define GPIO_PIN_13                ((uint16_t)0x2000U)  /* Pin 13 selected   */
#define GPIO_PIN_14                ((uint16_t)0x4000U)  /* Pin 14 selected   */
#define GPIO_PIN_15                ((uint16_t)0x8000U)  /* Pin 15 selected   */
#define GPIO_PIN_All               ((uint16_t)0xFFFFU)  /* All pins selected */

#define GPIO_PIN_MASK              (0x0000FFFFU) /* PIN mask for assert test */

#define GPIO_MODE_Mask             (0x1U)
#define GPIO_MODE_INPUT            (0x0U)
#define GPIO_MODE_OUTPUT           (0x1U)

#define GPIO_OTYPE_Mask            (0x1U)
#define GPIO_OTYPE_PP              (0x0U)
#define GPIO_OTYPE_OD              (0x1U)

#define GPIO_FUNCSEL_Mask          (0x3U)
#define GPIO_FUNCSEL_GPIO          (0x0U)
#define GPIO_FUNCSEL_ALT1          (0x1U)
#define GPIO_FUNCSEL_ALT2          (0x2U)
#define GPIO_FUNCSEL_ALT3          (0x3U)

#define IS_GPIO_PIN_ACTION(ACTION)  (((ACTION) == GPIO_PIN_RESET) || ((ACTION) == GPIO_PIN_SET))

#define IS_GPIO_PIN(__PIN__)        (((((uint32_t)__PIN__) & GPIO_PIN_MASK) != 0x00U) &&\
                                     ((((uint32_t)__PIN__) & ~GPIO_PIN_MASK) == 0x00U))

#define IS_GPIO_MODE(__MODE__)      (((__MODE__) == GPIO_MODE_INPUT) ||\
                                     ((__MODE__) == GPIO_MODE_OUTPUT))

#define IS_GPIO_OTYPE(__OTYPE__)    (((__OTYPE__) == GPIO_OTYPE_PP) ||\
                                     ((__OTYPE__) == GPIO_OTYPE_OD))

#define IS_GPIO_FUNC(__FUNC__)      (((__FUNC__) == GPIO_FUNCSEL_GPIO) ||\
                                     ((__FUNC__) == GPIO_FUNCSEL_ALT1) ||\
                                     ((__FUNC__) == GPIO_FUNCSEL_ALT2) ||\
                                     ((__FUNC__) == GPIO_FUNCSEL_ALT3))

void              GPIO_Init(GPIO_t  *GPIOx, GPIO_Init_t *GPIO_Init);
void              GPIO_DeInit(GPIO_t  *GPIOx, uint32_t GPIO_Pin);
GPIO_PinState     GPIO_ReadPin(GPIO_t* GPIOx, uint16_t GPIO_Pin);
void              GPIO_WritePin(GPIO_t* GPIOx, uint16_t GPIO_Pin, GPIO_PinState PinState);
void              GPIO_TogglePin(GPIO_t* GPIOx, uint16_t GPIO_Pin);

#endif
