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
  my_printf("======================\n\r");
  my_printf("=====ADAM Online!=====\n\r");
  my_printf("======================\n\r");
  gpio_write(RAL.LSPA.GPIO[0], 0, 1);
  while (1)
  {
    gpio_write(RAL.LSPA.GPIO[0], c, pin_state);
    timer0_delay(600000, 1);
    //delay_ms(RAL.LSPA.TIMER[0], 1000);
    if (c == 16) {
      c = 0;
      pin_state = !pin_state;
    }
    else c++;
  }
}

void hw_init(void) {
  // Resume UART0
  RAL.SYSCFG->LSPA.UART[0].MR = 1;
  while (RAL.SYSCFG->LSPA.UART[0].MR);

  // Resume TIMER0
  RAL.SYSCFG->LSPA.TIMER[0].MR = 1;
  while (RAL.SYSCFG->LSPA.TIMER[0].MR);

  // Resume GPIO0
  RAL.SYSCFG->LSPA.GPIO[0].MR = 1;
  while (RAL.SYSCFG->LSPA.GPIO[0].MR);

  // Enable CPU Interrupt
  RAL.SYSCFG->CPU[0].IER = ~0;
}
