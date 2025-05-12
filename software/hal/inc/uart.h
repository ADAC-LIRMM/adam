#ifndef __UART_H__
#define	__UART_H__

#include "adam_ral.h"
#include "types.h"

void uart_init(ral_uart_t *uart, uint32_t baudrate);
void uart_putc(ral_uart_t *uart, uint8_t c);
uint8_t uart_getc(ral_uart_t *uart);
#endif
