#include "system.h"
#define AUDIO_BUFFER_SIZE (64000)
#define SAMPLE 0
#define PRINT 1
#define IDLE 2

static void hw_init(void);
void Spi_Setup();

static int timer_flag = 0;
uint32_t circularBuffer[AUDIO_BUFFER_SIZE];
uint32_t circularBufferIndex = 0;
volatile int timer_interrupt_occurred = 0;
bool print = 0;

void timer_cb(void){
    timer_flag = 1;
}

void __attribute__((interrupt)) default_handler(void)
{
    timer_cb();
    RAL.LSPA.TIMER[0]->ER = ~0;
    timer_interrupt_occurred = 1;
}

int main ()
{
    hw_init();
    uart_init(RAL.LSPA.UART[0], 115200);
    Spi_Setup();

    int state = SAMPLE;

    set_timer_16k(RAL.LSPA.TIMER[0]);
    while(!timer_interrupt_occurred); // Wait for the interrupt to occur

    while(1) {
        do {
			_WFI();
		} while(!timer_flag);
		timer_flag = 0;
        timer_interrupt_occurred = 0; // Reset the flag
        switch(state){
            case SAMPLE:
                // Perform a read operation
                uint32_t receivedData = SPI_ReceiveData();
                // Store received Data in a circular buffer of 64KB
                circularBuffer[circularBufferIndex] = receivedData;
                circularBufferIndex = (circularBufferIndex + 1);
                if (circularBufferIndex == AUDIO_BUFFER_SIZE) {
                    state = PRINT;
                }
            break; 
            case PRINT:
                timer_interrupt_occurred = 0;
                for(int i = 0; i < AUDIO_BUFFER_SIZE; i++){
                    ee_printf("%d\r\n", circularBuffer[i]);
                }
                state = IDLE;
            break;
            case IDLE:
                while(1);
            break;
        }
    }

    return 0;
}

int main_lpu() 
{
    return 0;
}

void hw_init(void){
    // Resume LPMEM
    RAL.SYSCFG->LPMEM.MR = 1;
    while(RAL.SYSCFG->LPMEM.MR);

    // Resume MEMs
    for (int i = 0; i < 3; i++) {
        RAL.SYSCFG->MEM[i].MR = 1;
        while(RAL.SYSCFG->MEM[i].MR);
    }

    // Resume UART0
    RAL.SYSCFG->LSPA.UART[0].MR = 1;
    while(RAL.SYSCFG->LSPA.UART[0].MR);

    // Resume TIMER0
    RAL.SYSCFG->LSPA.TIMER[0].MR = 1;
    while(RAL.SYSCFG->LSPA.TIMER[0].MR);

    // Resume GPIO0
    RAL.SYSCFG->LSPA.GPIO[0].MR = 1;
    while(RAL.SYSCFG->LSPA.GPIO[0].MR);
        
    // Resume SPI 
    RAL.SYSCFG->LSPA.SPI[0].MR = 1;
    while(RAL.SYSCFG->LSPA.SPI[0].MR);

    // Enable LPU Interrupt
    // RAL.SYSCFG->LPCPU.IER = ~0;

    // Enable CPU Interrupt
    RAL.SYSCFG->CPU[0].IER = ~0;
}   

void Spi_Setup(){

    // Set up SPI initialization parameters for temperature sensor (receiver)
    ral_spi_t spiInit;
    spiInit.PE = 1;   // Enable SPI peripheral
    spiInit.TE = 0;     // Disable transmission
    spiInit.RE = 1;      // Enable reception
    spiInit.MS = 1;         // Set to master mode
    spiInit.CPHA = 1;         // Set clock phase to 1 - SPI Mode 3
    spiInit.CPOL = 1;      // Set clock polarity to 1 - SPI Mode 3
    spiInit.DO = 1;          // Set data order to MSB first
    spiInit.DL = 15;         // Set data length to 8 bits
    spiInit.BRR = 50;          // Main Clock = 50 MHz, SCLK between 1MHZ and 4 MHz
    
    // Initialize SPI
    SPI_Init(&spiInit);
}

//cd ../../ ; make clean ; make all -j32 ; cd build/target ; riscv32-unknown-elf-gdb demo.elf 
