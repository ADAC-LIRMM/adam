=====
TIMER
=====

Overview
========
The Timer peripheral is a hardware module that provides precise timing
functionality. It is essential for tasks requiring accurate timing and
synchronization in various applications such as real-time systems, measurement
devices, and control systems.

Registers
=========

+-------+------+---------------------------+
| Index | Name | Description               |
+=======+======+===========================+
| 0x000 | CR   | Control Register          |
+-------+------+---------------------------+
| 0x001 | PR   | Prescaler Register        |
+-------+------+---------------------------+
| 0x002 | VR   | Value Register            |
+-------+------+---------------------------+
| 0x003 | ARR  | Auto Reload Register      |
+-------+------+---------------------------+
| 0x004 | ER   | Event Register            |
+-------+------+---------------------------+
| 0x005 | IER  | Interrupt Enable Register |
+-------+------+---------------------------+

Control Register (CR)
---------------------

| **Index**: 0x000
| **Reset value**: 0x0000 0000

The Control Register allows configuration of various parameters for the
peripheral.

:CR[0]:
   | Peripheral Enable (PE)
   | Controls the operation of the peripheral.
   | 0: Peripheral is disabled.
   | 1: Peripheral is enabled.

Prescaler Register (PR)
-----------------------

| **Index**: 0x001
| **Reset value**: 0x0000 0000

The Prescaler Register sets the frequency at which the timer increments.

Value Register (VR)
-------------------

| **Index**: 0x002
| **Reset value**: 0x0000 0000

The Value Register is incremented with each cycle of the prescaled clock.

Auto Reload Register (ARR)
--------------------------

| **Index**: 0x003
| **Reset value**: 0x0000 0000

When the timer value matches the value in the Auto Reload Register, a 
Auto Reload event occurs.

Event Register (ER)
-----------------------

| **Index**: 0x004
| **Reset value**: 0x0000 0000

The Event Register is designed to store flags for various events. When a event
occurs, the corresponding flag is set. To clear it, write a value of 1.

:ER[0]:
   | Auto Reload Event (ARE)

Interrupt Enable Register (IER)
-------------------------------

| **Index**: 0x005
| **Reset value**: 0x0000 0000

The Interrupt Enable Register allows enabling/disabling peripheral interrupts.
  
:IER[0]:
   | Auto Reload Event Interrupt Enable (AREIE)