#ifndef __UART_H__
#define	__UART_H__

#include "mem_map.h"
#include "types.h"
#include "utils.h"

typedef struct
{
  uint32_t State;
  uint32_t Mode;
  uint32_t Parity;
  uint32_t Stopbit;
  uint32_t Datalength;
  uint32_t Baudrate;
}UART_Init_t;

#define UART_CR_DATA_LENGTH_Pos                0x8U 
#define UART_CR_DATA_LENGTH_Mask               0xFU

#define UART_CR_STOPBITS_Pos                   0x5U 
#define UART_CR_STOPBITS_Mask                  0x1U 
#define UART_CR_STOPBITS_1                     0x0U        /*!< UART frame with 1 stop bit    */
#define UART_CR_STOPBITS_2                     0x1U        /*!< UART frame with 2 stop bits   */

#define UART_CR_PARITY_Pos                     0x3U 
#define UART_CR_PARITY_Mask                    0x3U 
#define UART_CR_PARITY_NONE                    0x0U        /*!< No parity   */
#define UART_CR_PARITY_EVEN                    0x1U        /*!< Even parity */
#define UART_CR_PARITY_ODD                     0x3U        /*!< Odd parity  */

#define UART_CR_MODE_Pos                       0x1U 
#define UART_CR_MODE_Mask                      0x3U 
#define UART_CR_MODE_TX                        0x1U        /*!< RX enable        */
#define UART_CR_MODE_RX                        0x2U        /*!< TX enable        */
#define UART_CR_MODE_TX_RX                     0x3U        /*!< RX and TX enable */

#define UART_CR_STATE_Pos                      0x0U 
#define UART_CR_STATE_Mask                     0x1U 
#define UART_CR_STATE_DISABLE                  0x0U        /*!< UART disabled  */
#define UART_CR_STATE_ENABLE                   0x1U        /*!< UART enabled   */

#define IS_UART_STATE(__STATE__)            (((__STATE__) == UART_CR_STATE_DISABLE) ||\
                                             ((__STATE__) == UART_CR_STATE_ENABLE))

#define IS_UART_MODE(__MODE__)              (((__MODE__) == UART_CR_MODE_TX) ||\
                                             ((__MODE__) == UART_CR_MODE_RX) ||\
                                             ((__MODE__) == UART_CR_MODE_TX_RX))

#define IS_UART_PARITY(__PARITY__)          (((__PARITY__) == UART_CR_PARITY_NONE) ||\
                                             ((__PARITY__) == UART_CR_PARITY_EVEN) ||\
                                             ((__PARITY__) == UART_CR_PARITY_ODD))

#define IS_UART_STOPBIT(__STOPBIT__)        (((__STOPBIT__) == UART_CR_STOPBITS_1) ||\
                                             ((__STOPBIT__) == UART_CR_STOPBITS_2))

#define IS_UART_DATALENGTH(__DATALENGTH__)  (((((uint32_t)__DATALENGTH__) & UART_CR_DATA_LENGTH_Mask) != 0x00U) &&\
                                             ((((uint32_t)__DATALENGTH__) & ~UART_CR_DATA_LENGTH_Mask) == 0x00U))

void              UART_Init(UART_t  *UARTx, UART_Init_t *UART_Init);
void              UART_DeInit(UART_t  *UARTx);

void              send_char(const char c);
void              send_str(const char *str);

#endif
