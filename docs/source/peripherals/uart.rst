====
UART
====

Overview
========

UART (Universal Asynchronous Receiver-Transmitter) is a widely used
communication protocol that enables serial communication. This peripheral
supports the following features:

* Asynchronous, full-duplex communication;
* Configurable data length;
* Configurable parity;
* Configurable stop bit;
* Configurable baud rate;
* Interrupt generation.

Registers
=========

+-------+------+---------------------------+
| Index | Name | Description               |
+=======+======+===========================+
| 0x000 | DR   | Data Register             |
+-------+------+---------------------------+
| 0x001 | CR   | Control Register          |
+-------+------+---------------------------+
| 0x002 | SR   | Status Register           |
+-------+------+---------------------------+
| 0x003 | BRR  | Baud Rate Register        |
+-------+------+---------------------------+
| 0x004 | IER  | Interrupt Enable Register |
+-------+------+---------------------------+

Data Register (DR)
------------------

| **Index**: 0x000
| **Reset value**: 0x0000 0000

The Data Register is used for data transmission and reception. Writing to this
register initiates data transmission, while reading from it retrieves the
received data.

Control Register (CR)
---------------------

| **Index**: 0x001
| **Reset value**: 0x0000 0000

The Control Register allows configuration of various parameters for the
peripheral.

:CR[11:8]: 
   | Data Length (DL)
   | Specifies the length of the data frame.

:CR[7:6]:
   | Reserved.

:CR[5]: 
   | Stop Bits (SB)
   | Specifies the number of stop bits.
   | 0: 1 stop bit
   | 1: 2 stop bits

:CR[4]: 
   | Parity Select (PS)
   | Specifies odd or even parity.
   | 0: Even parity.
   | 1: Odd parity.

:CR[3]:
   | Parity Control (PC)
   | Controls parity bit generation and checking.
   | 0: Parity bit is disabled.
   | 1: Parity bit is enabled.
  
:CR[2]: 
   | Receive Enable (RE)
   | Controls the reception operation of the UART.
   | 0: Reception is disabled.
   | 1: Reception is enabled.

:CR[1]:
   | Transmit Enable (TE)
   | Controls the transmission operation of the UART.
   | 0: Transmission is disabled.
   | 1: Transmission is enabled.
  
:CR[0]:
   | Peripheral Enable (PE)
   | Controls the operation of the peripheral.
   | 0: Peripheral is disabled.
   | 1: Peripheral is enabled.

Status Register (SR)
--------------------

| **Index**: 0x002
| **Reset value**: 0x0000 0000

The Status Register provides information about the current status of the
peripheral:

:SR[1]:
   | Receive Buffer Full (RBF)
   | Indicates whether the receive buffer is full and contains new data.
   | 0: Not full.
   | 1: Full.

:SR[0]: 
   | Transmit Buffer Empty (TBE)
   | Indicates whether the transmit buffer is empty and ready for new data.
   | 0: Not empty.
   | 1: Empty.   


Baud Rate Register (BRR)
------------------------

| **Index**: 0x003
| **Reset value**: 0x0000 0000

The Baud Rate Register sets the communication baud rate, which determines the
rate of data transmission. The specific configuration of this register depends
on the desired baud rate and the system clock frequency.

Interrupt Enable Register (IER)
-------------------------------

| **Index**: 0x004
| **Reset value**: 0x0000 0000

The Interrupt Enable Register allows enabling/disabling peripheral interrupts.

:IER[1]: 
   | Receive Buffer Full Interrupt Enable (RBFIE)
   | 0: Interrupt disabled.
   | 1: Generates interrupt if RBF = 1.

:IER[0]:
   | Transmit Buffer Empty Interrupt Enable (TBEIE)
   | 0: Interrupt disabled.
   | 1: Generates interrupt if TBE = 1.
