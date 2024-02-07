
#include "uart.h"

/**
  * @brief  Initializes the UART peripheral.
  * @param  uart: Pointer to the UART peripheral 
  * (e.g. RAL.LSPA.UART[0], RAL.LSPA.UART[1], etc).
  * @param  baud_rate: Baud rate to be used.
  * @retval None
  */
void uart_init(ral_uart_t *uart, int baud_rate) {
    // Disable UART peripheral
    uart->CR_BITS.PE = 0;
    
    // Configure data length, parity, stop bits, etc. (as needed)
    uart->CR_BITS.DL = 8; // 8-bit data length
    uart->CR_BITS.SB = 0; // 1 stop bit
    uart->CR_BITS.PS = 0; // Even parity
    uart->CR_BITS.PC = 0; // Parity control disabled
    uart->CR_BITS.RE = 1; // Receiver enabled
    uart->CR_BITS.TE = 1; // Transmitter enabled


    // Configure baud rate
    uart->BRR = calculate_baudrate(baud_rate);

    // Enable UART peripheral
    uart->CR_BITS.PE = 1;
}

/**
  * @brief  Sends a single character via UART.
  * @param  c: Character to be sent.
  * @retval None
  */
void uart_send_char(ral_uart_t *uart, char data) {
    // Wait until the transmit buffer is empty
    while (!uart->SR_BITS.TBE);

    // Send the data
    uart->DR = data;
}

/**
  * @brief  Sends a string of characters via UART.
  * @param  str: Pointer to the null-terminated string.
  * @retval None
  */
void uart_send_str(ral_uart_t *uart, const char *str) {
    while (*str != '\0') {
        uart_send_char(uart, *str);
        str++;
    }
}

/**
  * @brief  Calculates the baud rate register value for a 50MHz clock.
  * @param  baud_rate: Baud rate to be used.
  * @retval Baud rate register value.
  */
uint32_t calculate_baudrate(int baud_rate) {
    return (50000000 / baud_rate);
}
