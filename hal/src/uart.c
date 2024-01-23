
#include "uart.h"

/**
  * @brief  Initializes the UART peripheral.
  * @param  UARTx: Pointer to the UART peripheral (e.g., UART1, UART2, etc.).
  * @param  UART_Init: Pointer to the structure containing UART initialization parameters.
  * @retval None
  */
void UART_Init(UART_t  *UARTx, UART_Init_t *UART_Init)
{
    /* Check the parameters */
    assert_param(IS_UART_STATE(UART_Init->State));
    assert_param(IS_UART_MODE(UART_Init->Mode));
    assert_param(IS_UART_PARITY(UART_Init->Parity));
    assert_param(IS_UART_STOPBIT(UART_Init->Stopbit));
    assert_param(IS_UART_DATALENGTH(UART_Init->Datalength));

    /*--------------------- UART Mode Configuration ------------------------*/
    UARTx->CR &= ~(UART_CR_MODE_Mask << UART_CR_MODE_Pos);
    UARTx->CR |= (UART_Init->Mode << UART_CR_MODE_Pos);

    /*--------------------- UART Parity Configuration ------------------------*/
    UARTx->CR &= ~(UART_CR_PARITY_Mask << UART_CR_PARITY_Pos);
    UARTx->CR |= (UART_Init->Parity << UART_CR_PARITY_Pos);

    /*--------------------- UART Stopbit Configuration ------------------------*/
    UARTx->SB = UART_Init->Stopbit;

    /*--------------------- UART Datalength Configuration ------------------------*/
    UARTx->DL = UART_Init->Datalength;

    /*--------------------- UART Baudrate Configuration ------------------------*/
    UARTx->BRR = UART_Init->Baudrate;

    /*--------------------- UART Enable Configuration ------------------------*/
    UARTx->PE = UART_Init->State;
}

/**
  * @brief  Deinitializes the UART peripheral.
  * @param  UARTx: Pointer to the UART peripheral (e.g., UART1, UART2, etc.).
  * @retval None
  */
void UART_DeInit(UART_t  *UARTx)
{
    /*--------------------- UART Mode reset ------------------------*/
    UARTx->CR &= ~(UART_CR_MODE_Mask << UART_CR_MODE_Pos);

    /*--------------------- UART Parity reset ------------------------*/
    UARTx->CR &= ~(UART_CR_PARITY_Mask << UART_CR_PARITY_Pos);

    /*--------------------- UART Stopbit reset ------------------------*/
    UARTx->SB = 0;

    /*--------------------- UART Datalength reset ------------------------*/
    UARTx->DL = 0;

    /*--------------------- UART Baudrate reset ------------------------*/
    UARTx->BRR = 0;

    /*--------------------- UART Enable reset ------------------------*/
    UARTx->PE = 0;
}

/**
  * @brief  Sends a single character via UART.
  * @param  c: Character to be sent.
  * @retval None
  */
void send_char(const char c)
{
	while(!UART0.TBE);
    UART0.DR = c;
}

/**
  * @brief  Sends a string of characters via UART.
  * @param  str: Pointer to the null-terminated string.
  * @retval None
  */
void send_str(const char *str)
{
    while(*str != '\0') {
        while(!UART0.TBE);
        UART0.DR = *str;
        str++;
    }
}
