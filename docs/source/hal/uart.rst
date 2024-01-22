============
UART Driver
============

Overview
--------

The UART (Universal Asynchronous Receiver-Transmitter) driver provides a set of functions for initializing and interacting with the UART peripheral. This driver supports asynchronous, full-duplex communication, and various configurable parameters such as data length, parity, stop bits, and baud rate.

Header File: `uart.h`
----------------------

The header file `uart.h` defines the interface for the UART driver. It includes structures, macros, and function prototypes needed for UART configuration and communication.

Functions
---------

1. ``void UART_Init(UART_t *UARTx, UART_Init_t *UART_Init)``
   - Initializes the UART peripheral based on the provided configuration parameters.
   - **Parameters:**

    - ``UARTx``: Pointer to the UART peripheral (e.g., UART1, UART2, etc.).
    - ``UART_Init``: Pointer to the structure containing UART initialization parameters.

2. ``void UART_DeInit(UART_t *UARTx)``
   - Deinitializes the UART peripheral, resetting its configuration.

3. ``void send_char(const char c)``
   - Sends a single character via UART.
   - **Parameters:**

    - ``c``: Character to be sent.

4. ``void send_str(const char *str)``
   - Sends a null-terminated string of characters via UART.
   - **Parameters:**

     - ``str``: Pointer to the null-terminated string.

Usage
-----

1. **Initialization:**

   - Include the `uart.h` header file in your application.
   - Define an instance of the ``UART_Init_t`` structure and configure the desired UART settings.
   - Call the ``UART_Init`` function with the UART peripheral and configuration structure.

    .. code-block:: c

        UART_Init_t uartConfig = {
            .State = UART_CR_STATE_ENABLE,
            .Mode = UART_CR_MODE_TX_RX,
            .Parity = UART_CR_PARITY_NONE,
            .Stopbit = UART_CR_STOPBITS_1,
            .Datalength = 8,
            .Baudrate = 9600 /* TO BE MODIFIED */
        };

        UART_t *uartInstance = /* Specify the UART instance */;

        UART_Init(uartInstance, &uartConfig);

2. **Sending Data:**

   - Use the ``send_char`` function to send a single character.
   - Use the ``send_str`` function to send a string.

    .. code-block:: c

        send_char('A');
        send_str("Hello, UART!");

3. **Deinitialization:**

   - To release resources and reset the UART peripheral, call the ``UART_DeInit`` function.

    .. code-block:: c

        UART_DeInit(uartInstance);


Note: Make sure to configure the system clock and pin mappings appropriately for UART communication.

Registers
---------

The UART driver interacts with UART registers defined in the microcontroller's memory map. Refer to the specific microcontroller datasheet for detailed information on register usage.

Contributors
------------

- Aymen
- Theo

Version History
---------------

- [Version Number] - [Date]: Initial release of the UART driver.
