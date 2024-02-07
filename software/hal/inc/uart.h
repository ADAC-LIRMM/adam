#ifndef __UART_H__
#define	__UART_H__

#include "adam_ral.h"
#include "types.h"

void uart_init(ral_uart_t *uart, int baud_rate);
void uart_send_char(ral_uart_t *uart, char data);
void uart_send_str(ral_uart_t *uart, const char *str);
uint32_t calculate_baudrate(int baud_rate);

#endif
