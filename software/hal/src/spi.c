
#include "spi.h"

/*
    SPI Init Function with doxygen comments
*/

/**
  * @brief  Initializes the SPI peripheral according to the specified parameters in the SPI_Init_t.
  * @param  SPIx: pointer to an SPI_t structure that contains the configuration information for the specified SPI peripheral.
  * @param  SPI_Init: pointer to an SPI_Init_t structure that contains the configuration information for the specified SPI peripheral.
  * @retval None
**/

void SPI_Init(SPI_t *SPIx, SPI_Init_t *SPI_Init)
{
    // Check Parameters 
    assert_param(IS_SPI_PERIPHERAL_ENABLE(SPI_Init->PeripheralEnable));
    assert_param(IS_SPI_TRANSMIT_ENABLE(SPI_Init->TransmitEnable));
    assert_param(IS_SPI_RECEIVE_ENABLE(SPI_Init->ReceiveEnable));
    assert_param(IS_SPI_MODE(SPI_Init->ModeSelect));
    assert_param(IS_SPI_CLOCK_PHASE(SPI_Init->ClockPhase));
    assert_param(IS_SPI_CLOCK_POLARITY(SPI_Init->ClockPolarity));
    assert_param(IS_SPI_DATA_ORDER(SPI_Init->DataOrder));
    assert_param(IS_SPI_DATA_LENGTH(SPI_Init->DataLength));
    assert_param(IS_SPI_BAUDRATE(SPI_Init->BaudRate));

    // Configure the SPI peripheral
    SPIx->CR = (SPI_Init->PeripheralEnable << SPI_CR_PE_Pos) |
               (SPI_Init->TransmitEnable << SPI_CR_TE_Pos) |
               (SPI_Init->ReceiveEnable << SPI_CR_RE_Pos) |
               (SPI_Init->ModeSelect << SPI_CR_MS_Pos) |
               (SPI_Init->ClockPhase << SPI_CR_CPHA_Pos) |
               (SPI_Init->ClockPolarity << SPI_CR_CPOL_Pos) |
               (SPI_Init->DataOrder << SPI_CR_DO_Pos) |
               (SPI_Init->DataLength << SPI_CR_DATA_LENGTH_Pos);

    // Configure the SPI baud rate
    SPIx->BRR = SPI_Init->BaudRate;
}

/*
    Function to receive data from SPI peripheral
*/

/**
  * @brief  Receives data from the SPI peripheral.
  * @param  SPIx: pointer to an SPI_t structure that contains the configuration information for the specified SPI peripheral.
  * @retval Received data
  * @note   This function is blocking and will wait until data is received.
**/
uint32_t SPI_ReceiveData(SPI_t *SPIx)
{
    // Wait until the receive buffer is full
    while (!(SPIx->SR & (1U << SPI_SR_RBF_Pos)));
    // Return the received data
    return SPIx->DR;
}


