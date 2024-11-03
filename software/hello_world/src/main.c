#include "system.h"

static void hw_init(void);

volatile int timer_interrupt_occurred = 0;
volatile int pin_state = 1;

void __attribute__((interrupt)) default_handler(void)
{
    // Clear timer interrupt
    RAL.LSPA.TIMER[0]->ER = ~0;
    // Flag the interrupt
    timer_interrupt_occurred = 1;
}

int main() {
  volatile unsigned char c;
  c = 0;
  // Resume Hardware Modules (Stopped by default)
  hw_init();
  // Initialize UART0 at 115200 baud rate
  uart_init(RAL.LSPA.UART[0], 115200);
  ee_printf("======================");
  ee_printf("=====ADAM Online!=====");
  ee_printf("======================");
  gpio_write(RAL.LSPA.GPIO[0], 0, 1);
  while (1)
  {
    gpio_write(RAL.LSPA.GPIO[0], c, pin_state);
    delay_ms(RAL.LSPA.TIMER[0], 1000);
    if (c == 8) {
      c = 0;
      pin_state = !pin_state;
    }
    else c++;
  }
}

void hw_init(void) {
  // Resume LPMEM
  RAL.SYSCFG->LPMEM.MR = 1;
  while (RAL.SYSCFG->LPMEM.MR);

  // Resume MEMs
  for (int i = 0; i < 3; i++) {
    RAL.SYSCFG->MEM[i].MR = 1;
    while (RAL.SYSCFG->MEM[i].MR);
  }

  // Resume UART0
  RAL.SYSCFG->LSPA.UART[0].MR = 1;
  while (RAL.SYSCFG->LSPA.UART[0].MR);

  // Resume TIMER0
  RAL.SYSCFG->LSPA.TIMER[0].MR = 1;
  while (RAL.SYSCFG->LSPA.TIMER[0].MR);

  // Resume GPIO0
  RAL.SYSCFG->LSPA.GPIO[0].MR = 1;
  while (RAL.SYSCFG->LSPA.GPIO[0].MR);

  // Resume SPI
  RAL.SYSCFG->LSPA.SPI[0].MR = 1;
  while (RAL.SYSCFG->LSPA.SPI[0].MR);

  // Enable CPU Interrupt
  RAL.SYSCFG->CPU[0].IER = ~0;
}
