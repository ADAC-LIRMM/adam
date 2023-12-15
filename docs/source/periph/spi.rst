===
SPI
===

Overview
========

SPI is a bidirectional, synchronized communication interface allowing
simultaneous data transmission between a main node (master) and a subnode 
(slave), commonly implemented as a 4-wire configuration.

Timing
======

TODO

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

:CR[15:8]: 
   | Data Length (DL)
   | Controls the length of the data frame.

:CR[7]:
   | Reserved.

:CR[6]: 
   | Data Order (DO)
   | Controls data transmission order.
   | 0: LSB first.
   | 1: MSB first.

:CR[5]: 
   | Clock Polarity (CPOL)
   | Controls the idle state of the clock signal.
   | 0: The clock is low in the idle state.
   | 1: The clock is high in the idle state.

:CR[4]:
   | Clock Phase (CPHA)
   | Controls in which clock edge the data is sampled.
   | 0: Data is sampled on the leading edge.
   | 1: Data is sampled on the trailing edge.

:CR[3]:
   | Mode Select (MS)
   | Controls the SPI mode: Master or Slave.
   | 0: Slave mode.
   | 1: Master mode.
  
:CR[2]: 
   | Receive Enable (RE)
   | Controls the reception operation of the SPI.
   | 0: Reception is disabled.
   | 1: Reception is enabled.

:CR[1]:
   | Transmit Enable (TE)
   | Controls the transmission operation of the SPI.
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
