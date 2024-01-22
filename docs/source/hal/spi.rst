============
SPI Driver
============

Overview
--------

The SPI (Serial Peripheral Interface) driver provides a set of functions for initializing and interacting with the SPI peripheral. This driver supports configuration parameters such as peripheral enable, transmit and receive enable, mode select, clock phase, clock polarity, data order, data length, and baud rate.

Header File: `spi.h`
----------------------

The header file `spi.h` defines the interface for the SPI driver. It includes structures, macros, and function prototypes needed for SPI configuration and communication.

Functions
---------

1. ``void SPI_Init(SPI_t *SPIx, SPI_Init_t *SPI_Init)``
   - Initializes the SPI peripheral based on the provided configuration parameters.
   - **Parameters:**

    - ``SPIx``: Pointer to the SPI peripheral (e.g., SPI1, SPI2, etc.).
    - ``SPI_Init``: Pointer to the structure containing SPI initialization parameters.

2. ``uint32_t SPI_ReceiveData(SPI_t *SPIx)``
   - Receives data from the SPI peripheral.
   - **Parameters:**

    - ``SPIx``: Pointer to the SPI peripheral.

   - **Returns:**
   
    - Received data.

Usage
-----

1. **Initialization:**

   - Include the `spi.h` header file in your application.
   - Define an instance of the ``SPI_Init_t`` structure and configure the desired SPI settings.
   - Call the ``SPI_Init`` function with the SPI peripheral and configuration structure.

    .. code-block:: c

        SPI_Init_t spiConfig = {
            .PeripheralEnable = SPI_CR_ENABLE,
            .TransmitEnable = SPI_CR_TRANSMIT_ENABLE,
            .ReceiveEnable = SPI_CR_RECEIVE_ENABLE,
            .ModeSelect = SPI_CR_MASTER_MODE,
            .ClockPhase = SPI_CR_CLOCK_PHASE_1,
            .ClockPolarity = SPI_CR_CLOCK_POLARITY_LOW,
            .DataOrder = SPI_CR_MSB_FIRST,
            .DataLength = SPI_CR_DATA_LENGTH_8,
            .BaudRate = 1000000 /* TO BE MODIFIED */
        };

        SPI_t *spiInstance = /* Specify the SPI instance */;

        SPI_Init(spiInstance, &spiConfig);

2. **Receiving Data:**

   - Use the ``SPI_ReceiveData`` function to receive data from the SPI peripheral.

    .. code-block:: c

        uint32_t receivedData = SPI_ReceiveData(spiInstance);

Note: Make sure to configure the system clock and pin mappings appropriately for SPI communication.

Registers
---------

The SPI driver interacts with SPI registers defined in the microcontroller's memory map. Refer to the specific microcontroller datasheet for detailed information on register usage.

Contributors
------------

- Aymen
- Theo

Version History
---------------

- [1.0] - [21/12/2023]: Initial release of the SPI driver.
