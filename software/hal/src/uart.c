
#include "uart.h"

// #define SYSTEM_CLOCK 50000000 // Define your system clock frequency (e.g., 50MHz)

/**
  * @brief  Initializes the UART peripheral.
  * @param  uart: Pointer to the UART peripheral 
  * (e.g. RAL.LSPA.UART[0], RAL.LSPA.UART[1], etc).
  * @param  baud_rate: Baud rate to be used.
  * @retval None
  */

/* 
 * UART Configuration for PUTTY:
 * -----------------------------
 * Data Bits   : 8
 * Parity      : None
 * Stop Bits   : 1
 * Flow Control: None
 */

void uart_init(ral_uart_t *uart, uint32_t baudrate) {
    // Calculate the BRR value based on the system clock and desired baud rate
    uint32_t brr_value = SYSTEM_CLOCK / baudrate;

    // Set the Baud Rate Register (BRR)
    uart->BRR = brr_value;

    // Reset the Control Register (CR) to 0
    uart->CR = 0;

    // Configure the Control Register (CR) bit by bit
    uart->CR |= (1 << 0); // PE: Parity control disabled
    uart->CR |= (1 << 1); // TE: Transmitter enabled
    uart->CR |= (1 << 2); // RE: Receiver enabled
    // PC, PS, and SB are already 0 (parity disabled, even parity, 1 stop bit)
    uart->CR |= (8 << 8); // DL: 8 data bits
}