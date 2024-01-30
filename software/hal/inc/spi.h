#ifndef __SPI_H__
#define __SPI_H__

#include "mem_map.h"
#include "types.h"
#include "utils.h"

typedef struct
{
    uint32_t PeripheralEnable;
    uint32_t TransmitEnable;
    uint32_t ReceiveEnable;
    uint32_t ModeSelect;
    uint32_t ClockPhase;
    uint32_t ClockPolarity;
    uint32_t DataOrder;
    uint32_t DataLength;
    uint32_t BaudRate;
    uint32_t TransmitBufferEmptyInterruptEnable;
    uint32_t ReceiveBufferFullInterruptEnable;
} SPI_Init_t;

#define SPI_CR_DATA_LENGTH_Pos             0x8U
#define SPI_CR_DATA_LENGTH_Mask            0xFFU

#define SPI_CR_DO_Pos                      0x6U
#define SPI_CR_DO_Mask                     0x1U

#define SPI_CR_CPOL_Pos                    0x5U
#define SPI_CR_CPOL_Mask                   0x1U

#define SPI_CR_CPHA_Pos                    0x4U
#define SPI_CR_CPHA_Mask                   0x1U

#define SPI_CR_MS_Pos                      0x3U
#define SPI_CR_MS_Mask                     0x1U

#define SPI_CR_RE_Pos                      0x2U
#define SPI_CR_RE_Mask                     0x1U

#define SPI_CR_TE_Pos                      0x1U
#define SPI_CR_TE_Mask                     0x1U

#define SPI_CR_PE_Pos                      0x0U
#define SPI_CR_PE_Mask                     0x1U

#define SPI_SR_RBF_Pos                     0x1U
#define SPI_SR_RBF_Mask                    0x1U

#define SPI_SR_TBE_Pos                     0x0U
#define SPI_SR_TBE_Mask                    0x1U

#define SPI_IER_RBFIE_Pos                  0x1U
#define SPI_IER_RBFIE_Mask                 0x1U

#define SPI_IER_TBEIE_Pos                  0x0U
#define SPI_IER_TBEIE_Mask                 0x1U


#define IS_SPI_DATA_LENGTH(__DATALENGTH__)  (((((uint32_t)__DATALENGTH__) & SPI_CR_DATA_LENGTH_Mask) != 0x00U) &&\
                                             ((((uint32_t)__DATALENGTH__) & ~SPI_CR_DATA_LENGTH_Mask) == 0x00U))

#define IS_SPI_DO(__DO__)                   (((__DO__) == 0x0U) ||\
                                             ((__DO__) == 0x1U))

#define IS_SPI_CPOL(__CPOL__)               (((__CPOL__) == 0x0U) ||\
                                             ((__CPOL__) == 0x1U))
                                             
#define IS_SPI_CPHA(__CPHA__)               (((__CPHA__) == 0x0U) ||\
                                             ((__CPHA__) == 0x1U))

#define IS_SPI_MS(__MS__)                   (((__MS__) == 0x0U) ||\
                                             ((__MS__) == 0x1U))

#define IS_SPI_RE(__RE__)                   (((__RE__) == 0x0U) ||\
                                             ((__RE__) == 0x1U))

#define IS_SPI_TE(__TE__)                   (((__TE__) == 0x0U) ||\
                                             ((__TE__) == 0x1U))

#define IS_SPI_PE(__PE__)                   (((__PE__) == 0x0U) ||\
                                             ((__PE__) == 0x1U))

#define IS_SPI_RBF(__RBF__)                 (((__RBF__) == 0x0U) ||\
                                             ((__RBF__) == 0x1U))

#define IS_SPI_TBE(__TBE__)                 (((__TBE__) == 0x0U) ||\
                                             ((__TBE__) == 0x1U))

#define IS_SPI_RBFIE(__RBFIE__)             (((__RBFIE__) == 0x0U) ||\
                                             ((__RBFIE__) == 0x1U))

#define IS_SPI_TBEIE(__TBEIE__)             (((__TBEIE__) == 0x0U) ||\
                                             ((__TBEIE__) == 0x1U))

#define IS_SPI_BAUDRATE(__BAUDRATE__)       (((__BAUDRATE__) == 0x0U) ||\
                                             ((__BAUDRATE__) == 0x1U) ||\
                                             ((__BAUDRATE__) == 0x2U) ||\
                                             ((__BAUDRATE__) == 0x3U) ||\
                                             ((__BAUDRATE__) == 0x4U) ||\
                                             ((__BAUDRATE__) == 0x5U) ||\
                                             ((__BAUDRATE__) == 0x6U) ||\
                                             ((__BAUDRATE__) == 0x7U) ||\
                                             ((__BAUDRATE__) == 0x8U) ||\
                                             ((__BAUDRATE__) == 0x9U) ||\
                                             ((__BAUDRATE__) == 0xAU) ||\
                                             ((__BAUDRATE__) == 0xBU) ||\
                                             ((__BAUDRATE__) == 0xCU) ||\
                                             ((__BAUDRATE__) == 0xDU) ||\
                                             ((__BAUDRATE__) == 0xEU) ||\
                                             ((__BAUDRATE__) == 0xFU))

#define IS_SPI_MODE(__MODE__)               (((__MODE__) == 0x0U) ||\
                                             ((__MODE__) == 0x1U))

#define IS_SPI_CLOCK_PHASE(__CPHA__)        (((__CPHA__) == 0x0U) ||\
                                             ((__CPHA__) == 0x1U))

#define IS_SPI_CLOCK_POLARITY(__CPOL__)     (((__CPOL__) == 0x0U) ||\
                                             ((__CPOL__) == 0x1U))

#define IS_SPI_DATA_ORDER(__DATAORDER__)    (((__DATAORDER__) == 0x0U) ||\
                                             ((__DATAORDER__) == 0x1U))

#define IS_SPI_PERIPHERAL_ENABLE(__PE__)    (((__PE__) == 0x0U) ||\
                                             ((__PE__) == 0x1U))

#define IS_SPI_TRANSMIT_ENABLE(__TE__)      (((__TE__) == 0x0U) ||\
                                             ((__TE__) == 0x1U))

#define IS_SPI_RECEIVE_ENABLE(__RE__)       (((__RE__) == 0x0U) ||\
                                             ((__RE__) == 0x1U))

#define IS_SPI_TRANSMIT_BUFFER_EMPTY_INTERRUPT_ENABLE(__TBEIE__)  (((__TBEIE__) == 0x0U) ||\
                                                                    ((__TBEIE__) == 0x1U))

#define IS_SPI_RECEIVE_BUFFER_FULL_INTERRUPT_ENABLE(__RBFIE__)    (((__RBFIE__) == 0x0U) ||\
                                                                    ((__RBFIE__) == 0x1U))

#define IS_SPI_INTERRUPT_TYPE(__INTERRUPT__) (((__INTERRUPT__) == SPI_IER_TBEIE) ||\
                                               ((__INTERRUPT__) == SPI_IER_RBFIE))


/*
    SPI Functions
*/

void SPI_Init(SPI_t *SPIx, SPI_Init_t *SPI_Init);
uint32_t SPI_ReceiveData(SPI_t *SPIx);


#endif
