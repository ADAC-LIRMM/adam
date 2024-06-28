
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

void SPI_Init(ral_spi_t *SPI_Init)
{
    ral_spi_t *SPIx = RAL.LSPA.SPI[0];

    // Configure the SPI peripheral
    SPIx->CR = (SPI_Init->PE << SPI_CR_PE_Pos) |
               (SPI_Init->TE << SPI_CR_TE_Pos) |
               (SPI_Init->RE << SPI_CR_RE_Pos) |
               (SPI_Init->MS << SPI_CR_MS_Pos) |
               (SPI_Init->CPHA << SPI_CR_CPHA_Pos) |
               (SPI_Init->CPOL << SPI_CR_CPOL_Pos) |
               (SPI_Init->DO << SPI_CR_DO_Pos) |
               (SPI_Init->DL << SPI_CR_DATA_LENGTH_Pos);

    // Configure the SPI baud rate
    SPIx->BRR = SPI_Init->BRR;

    
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
uint32_t SPI_ReceiveData()
{
  uint32_t tmp = 0;
  if(RAL.LSPA.SPI[0]->RBF == 1){
    tmp = RAL.LSPA.SPI[0]->DR; 
  }
  return tmp;
}


