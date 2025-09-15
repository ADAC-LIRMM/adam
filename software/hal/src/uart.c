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

void uart_putc(ral_uart_t *uart, uint8_t c)
{
    // Attendre que le buffer de transmission soit vide
    while (!(uart->TBE)); // TXE (Transmit data register empty)
    uart->DR = c;
}

uint8_t uart_getc(ral_uart_t *uart)
{
    // Attendre que des données soient reçues
    while (!(uart->RBF)); // RXNE (Read data register not empty)
    return (uint8_t)(uart->DR);
}
