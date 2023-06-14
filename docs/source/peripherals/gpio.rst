====
GPIO
====

Overview
========
The General Purpose Input/Output (GPIO) peripheral is a hardware module
offering configurable digital Inputs/Outputs (IOs). These IOs are instrumental
in interfacing with sensors, LEDs, switches, and other integrated circuits,
making them a crucial part of microcontroller-based systems.

Registers
=========

+-------+--------+---------------------------+
| Index | Name   | Description               |
+=======+========+===========================+
| 0x000 | IDR    | Input Data Register       |
+-------+--------+---------------------------+
| 0x001 | ODR    | Output Data Register      |
+-------+--------+---------------------------+
| 0x002 | MODER  | Mode Register             |
+-------+--------+---------------------------+
| 0x003 | OTYPER | Output Type Register      |
+-------+--------+---------------------------+
| 0x004 | FSR    | Function Select Register  |
+-------+--------+---------------------------+
| 0x005 | IER    | Interrupt Enable Register |
+-------+--------+---------------------------+

Input Data Register (IDR)
-------------------------

| **Index**: 0x000
| **Reset value**: 0x0000 0000

The Input Data Register (IDR) reflects the input state of each specific IO with
each bit. A bit at 0 corresponds to a LOW state, and a bit at 1 corresponds to
a HIGH state.

Whether this register is updated when in output mode depends on the specific 
IO driver implementation.

Output Data Register (ODR)
--------------------------

| **Index**: 0x001
| **Reset value**: 0x0000 0000

The Output Data Register (ODR) determines the output state. Each bit
corresponds to a specific IO. Assigning a 0 to a bit sets the corresponding IO
to a LOW state, and assigning a 1 sets it to a HIGH state.

Mode Register (MODER)
----------------------

| **Index**: 0x002
| **Reset value**: 0x0000 0000

The Mode Register (MODER) defines an IO's mode of operation. Assigning a 0 to a
bit configures the corresponding IO as an input, and assigning a 1 configures
it as an output.

Output Type Register (OTYPER)
-----------------------------

| **Index**: 0x003
| **Reset value**: 0x0000 0000

The Output Type Register (OTYPER) determines the output behavior. Assigning a 0
to a bit configures the corresponding IO to operate as push-pull, while
assigning a 1 configures it to operate as open-drain.

This setting has no effect when an IO is configured as an input.

Function Select Register (FSR)
------------------------------

| Index: 0x004
| Reset value: 0x0000 0000

The Function Selection Register (FSR) provides control over the system's
Input/Output (IO) multiplexer. This register is two words wide.

This register's primary function is the mapping of alternate functionalities, 
often corresponding to specific peripherals, onto the IOs. However, it's
crucial to remember that not every IO might support an alternate function, or
have one connected.

To ensure accurate configuration of the IO multiplexers, a detailed mapping
table specifying the correlation between the alternate functions and
peripherals for each IO indispensable.

:FSRx[1+2x:0+2x]:
   | Function Select x (FSx).
   | 0: GPIO.
   | 1: Alternate 1.
   | 2: Alternate 2.
   | 3: Alternate 3.

Interrupt Enable Register (IER)
-------------------------------

| **Index**: 0x006
| **Reset value**: 0x0000 0000

The Interrupt Enable Register (IER) determines whether an IO can request
interrupts. Assigning a 0 to a bit disables the interrupts for the
corresponding IO, and assigning a 1 enables it.

Furthermore, interrupt requests are made based on the input value. The
possibility of requesting interrupts by assigning values to an IO in output
mode depends on the specific IO driver implementation.
