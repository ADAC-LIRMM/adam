#include "system.h"

static void hw_init(void);
void Spi_Setup();
void Spi_Test();

int counter = 0;
volatile int timer_interrupt_occurred = 0;
bool pin_state = false;
static int timer_flag = 0;

void timer_cb(void) { timer_flag = 1; }

void __attribute__((interrupt)) default_handler(void) {
  timer_cb();
  RAL.LSPA.TIMER[0]->ER = ~0;
  timer_interrupt_occurred = 1;
}

int main() {
  hw_init();

  set_timer_us(RAL.LSPA.TIMER[0], 5);
  while (!timer_interrupt_occurred)
    ; // Wait for the interrupt to occur

  while (1) {
    do {
      _WFI();
    } while (!timer_flag);
    timer_flag = 0;
    timer_interrupt_occurred = 0; // Reset the flag

    pin_state = ~pin_state;
    gpio_write(RAL.LSPA.GPIO[0], 0, pin_state);
  }

  return 0;
}

int main_lpu() { return 0; }

void hw_init(void) {
  // Resume LPMEM
  RAL.SYSCFG->LPMEM.MR = 1;
  while (RAL.SYSCFG->LPMEM.MR)
    ;

  // Resume MEMs
  for (int i = 0; i < 3; i++) {
    RAL.SYSCFG->MEM[i].MR = 1;
    while (RAL.SYSCFG->MEM[i].MR)
      ;
  }

  // Resume UART0
  RAL.SYSCFG->LSPA.UART[0].MR = 1;
  while (RAL.SYSCFG->LSPA.UART[0].MR)
    ;

  // Resume TIMER0
  RAL.SYSCFG->LSPA.TIMER[0].MR = 1;
  while (RAL.SYSCFG->LSPA.TIMER[0].MR)
    ;

  // Resume GPIO0
  RAL.SYSCFG->LSPA.GPIO[0].MR = 1;
  while (RAL.SYSCFG->LSPA.GPIO[0].MR)
    ;

  // Resume SPI
  RAL.SYSCFG->LSPA.SPI[0].MR = 1;
  while (RAL.SYSCFG->LSPA.SPI[0].MR)
    ;

  // Enable LPU Interrupt
  // RAL.SYSCFG->LPCPU.IER = ~0;

  // Enable CPU Interrupt
  RAL.SYSCFG->CPU[0].IER = ~0;
}

void Spi_Setup() {

  // Set up SPI initialization parameters for temperature sensor (receiver)
  ral_spi_t spiInit;
  spiInit.PE = 1;   // Enable SPI peripheral
  spiInit.TE = 0;   // Disable transmission
  spiInit.RE = 1;   // Enable reception
  spiInit.MS = 1;   // Set to master mode
  spiInit.CPHA = 1; // Set clock phase to 1 - SPI Mode 3
  spiInit.CPOL = 1; // Set clock polarity to 1 - SPI Mode 3
  spiInit.DO = 1;   // Set data order to MSB first
  spiInit.DL = 15;  // Set data length to 8 bits
  spiInit.BRR = 50; // Main Clock = 50 MHz, SCLK between 1MHZ and 4 MHz

  // Initialize SPI
  SPI_Init(&spiInit);
}

void Spi_Test() { delay_16K(RAL.LSPA.TIMER[0]); }