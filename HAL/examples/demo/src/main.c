
#include "system.h"
#define AUDIO_BUFFER_SIZE 64000
static int timer_flag = 0;
uint32_t circularBuffer[AUDIO_BUFFER_SIZE];
uint32_t circularBufferIndex = 0;

void timer_cb(void){
    GPIO0.ODR = ~GPIO0.ODR;
    // Perform a read operation
    uint32_t receivedData = SPI_ReceiveData(&SPI0);
    // Store received Data in a circular buffer of 64KB
    circularBuffer[circularBufferIndex] = receivedData;
    circularBufferIndex = (circularBufferIndex + 1);
    // myprintf("circularBufferIndex: %d\n", circularBufferIndex);
    if (circularBufferIndex == AUDIO_BUFFER_SIZE)
    {
        timer_flag = 1;
    }
}

void external_irq_handler(void) __attribute__((interrupt));
void external_irq_handler(void) {
    if(TIMER0.ER){
        TIMER0.ER = 1;
        timer_cb();
    }
}

int main()
{
    // Initialize SPI peripheral
    SPI_Init_t spiInit;

    // Resume GPIO0
    SYSCTRL.PMR_GPIO0 = 1;
    while(SYSCTRL.PMR_GPIO0);

    // Resume GPIO1
    SYSCTRL.PMR_GPIO1 = 1;
    while(SYSCTRL.PMR_GPIO1);

    // Resume TIMER0
    SYSCTRL.PMR_TIMER0 = 1;
    while(SYSCTRL.PMR_TIMER0);

    // Resume UART0
    SYSCTRL.PMR_UART0 = 1;
    while(SYSCTRL.PMR_UART0);

    // Resume UART0
    SYSCTRL.PMR_SPI0= 1;
    while(SYSCTRL.PMR_SPI0);

    UART_Init_t UART0_Conf = {  .State = UART_CR_STATE_ENABLE, \
                                .Mode = UART_CR_MODE_TX_RX, \
                                .Parity = UART_CR_PARITY_NONE, \
                                .Stopbit = UART_CR_STOPBITS_1, \
                                .Datalength = 8, \
                                .Baudrate = 434 };

    GPIO_Init_t GPIO0_Conf = {      .Pin = GPIO_PIN_0 | GPIO_PIN_1 | GPIO_PIN_2 | GPIO_PIN_3 | GPIO_PIN_4 | GPIO_PIN_5 | GPIO_PIN_6 | GPIO_PIN_7, \
                                    .Mode = GPIO_MODE_OUTPUT, \
                                    .Otype = GPIO_OTYPE_PP, \
                                    .Func = GPIO_FUNCSEL_GPIO };

    GPIO_Init_t GPIO1_Conf = {      .Pin = GPIO_PIN_0 | GPIO_PIN_1 | GPIO_PIN_2 | GPIO_PIN_3 | GPIO_PIN_4 | GPIO_PIN_5 | GPIO_PIN_6 | GPIO_PIN_7, \
                                    .Mode = GPIO_MODE_INPUT, \
                                    .Otype = GPIO_OTYPE_PP, \
                                    .Func = GPIO_FUNCSEL_GPIO };

    UART_Init(&UART0, &UART0_Conf);
    GPIO_Init(&GPIO0, &GPIO0_Conf);
    GPIO_Init(&GPIO1, &GPIO1_Conf);

    
    
    // Set up SPI initialization parameters for temperature sensor (receiver)
    spiInit.PeripheralEnable = 1;   // Enable SPI peripheral
    spiInit.TransmitEnable = 0;     // Disable transmission
    spiInit.ReceiveEnable = 1;      // Enable reception
    spiInit.ModeSelect = 1;         // Set to master mode
    spiInit.ClockPhase = 1;         // Set clock phase to 1 - SPI Mode 3
    spiInit.ClockPolarity = 1;      // Set clock polarity to 1 - SPI Mode 3
    spiInit.DataOrder = 1;          // Set data order to MSB first
    spiInit.DataLength = 16;         // Set data length to 8 bits
    spiInit.BaudRate = 50;          // Main Clock = 50 MHz, SCLK between 1MHZ and 4 MHz

    
    // Initialize SPI
    SPI_Init(&SPI0, &spiInit);
   
    set_timer_ns(&TIMER0, 625);
    SYSCTRL_TIMER0_INTERUPT(1);

    GPIO0.ODR = 0x55;
    
    while(1) {
        do {
			_WFI();
		} while(!timer_flag);
		timer_flag = 0;
        SYSCTRL_TIMER0_INTERUPT(0);
        // print the circular buffer 
        for(int i = 0; i < AUDIO_BUFFER_SIZE; i++){
            myprintf("%d\n", circularBuffer[i]);
        }
        // Print the received data
        // myprintf("Received Data: %d\n", receivedData);
    }

    return 0;
}
