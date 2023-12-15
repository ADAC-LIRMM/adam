======
SYSCFG
======

Overview
========
The System Configuration (SYSCFG) is a purpose-built peripheral specifically
designed to effectively manage the power, clock, and boot configurations of
ADAM.

Maestro
=======

The Maestros offer precise and secure power state management for system
components. They allow for the following actions:

- **Resume**: This action starts/resumes a component from its paused or
  stopped state.

- **Pause**: This places the component into an sleep mode while retaining its
  current state.

- **Stop**: A sleep mode that, upon resume, will not retain the previous state,
  resulting in a reset.

- **Reset**: Essentially a Stop followed by a Resume. This action may not be
  vital for memory and peripherals, but it enables a core to self-reset.
  Without it, the core couldn't autonomously wake itself.

When SYSCFG experiences a reset, every maestro transitions to a special state.
Within this state, the component's soft reset line remains high, regardless of
whether it's "pause_req" and "pause_ack" signals are asserted or not.

Typically, a component set to "stop" mode will use less energy than if it were
set to "pause" mode.

It's worth noting that the energy-saving approach—be it through clock gating,
power gating, or power gating with non-volatile registers—relies on the
component's design specifics. In scenarios where a action is unsuitable, such
as trying to deactivate the SYSCFG, it will be ignored on a best-effort basis.

For each component, whether a memory bank, peripheral, or core, the Maestro
Registers can trigger the appropriate power management action. To initiate an
action, one simply writes the corresponding value to the respective register.
Post completion of the action, the hardware will autonomously reset the
register to its default state.

Maestro register values and their associated actions:

+-------+---------------------+
| Value | Description         |
+=======+=====================+
| 0     | No action (default) |
+-------+---------------------+
| 1     | Resume              |
+-------+---------------------+
| 2     | Pause               |
+-------+---------------------+
| 3     | Stop                |
+-------+---------------------+
| 4     | Reset               |
+-------+---------------------+

Registers
=========

+------------+------+--------------------------------+
| Index      | Name | Description                    |
+============+======+================================+
| 0x100 + 3x | MSRx | Memory Status Register x       |
+------------+------+--------------------------------+
| 0x101 + 3x | MCRx | Memory Control Register x      |
+------------+------+--------------------------------+
| 0x102 + 3x | MMRx | Memory Maestro Register x      |
+------------+------+--------------------------------+
| ...        | ...  | ...                            |
+------------+------+--------------------------------+
| 0x200 + 3x | PSRx | Peripheral Status Register x   |
+------------+------+--------------------------------+
| 0x201 + 3x | PCRx | Peripheral Control Register x  |
+------------+------+--------------------------------+
| 0x202 + 3x | PMRx | Peripheral Maestro Register x  |
+------------+------+--------------------------------+
| ...        | ...  | ...                            |
+------------+------+--------------------------------+
| 0x400 + 5x | CSRx | Core Status Register x         |
+------------+------+--------------------------------+
| 0x401 + 5x | CCRx | Core Control Register x        |
+------------+------+--------------------------------+
| 0x402 + 5x | CMRx | Core Maestro Register x        |
+------------+------+--------------------------------+
| 0x403 + 5x | BARx | Boot Address Register x        |
+------------+------+--------------------------------+
| 0x404 + 5x | IERx | Interrupt Enable Register x    |
+------------+------+--------------------------------+
| ...        | ...  | ...                            |
+------------+------+--------------------------------+

Memory Status Register x (MSRx)
-------------------------------

| **Index**: 0x100 + 3x
| **Reset value**: 0x0000 0000

The Memory Status Register x provides information about the status of
memory bank x. Multiple instances of this register may exist, indexed by x.

:MSRx[1]:
   | Stopped (S)
   | Indicates whether the memory bank x is in a stopped state. 
   | 1: Stopped 
   | 0: Not Stopped 

:MSRx[0]:
   | Paused (P)
   | Indicates whether the memory bank x is in a paused state. 
   | 1: Paused 
   | 0: Not Paused 

Memory Control Register x (MCRx)
--------------------------------

| **Index**: 0x101 + 3x
| **Reset value**: 0x0000 0000

The Memory Control Register x allows control and configuration of specific
functionalities and features for memory bank x.

:MCRx[31:0]:
   | Reserved.

Memory Maestro Register x (MMRx)
--------------------------------

| **Index**: 0x102 + 3x
| **Reset value**: 0x0000 0000

The Memory Maestro Register x provides the ability to trigger power
management actions for memory bank x.
For details, refer to the "Maestro Registers" section.

Peripheral Status Register x (PSRx)
-----------------------------------

| **Index**: 0x200 + 3x
| **Reset value**: 0x0000 0000

The Peripheral Status Register x provides information about the status of
peripheral x. Multiple instances of this register may exist, indexed by x.

:PSRx[1]:
   | Stopped (S)
   | Indicates whether the peripheral x is in a stopped state. 
   | 1: Stopped 
   | 0: Not Stopped 

:PSRx[0]:
   | Paused (P)
   | Indicates whether the peripheral x is in a paused state. 
   | 1: Paused 
   | 0: Not Paused 

Peripheral Control Register x (PCRx)
------------------------------------

| **Index**: 0x201 + 3x
| **Reset value**: 0x0000 0000

The Peripheral Control Register x allows control and configuration of
specific functionalities and features for peripheral x.

:PCRx[31:0]:
   | Reserved.

Peripheral Maestro Register x (PMRx)
------------------------------------

| **Index**: 0x202 + 3x
| **Reset value**: 0x0000 0000

The Peripheral Maestro Register x provides the ability to trigger power
management actions for peripheral x.
For details, refer to the "Maestro Registers" section.

Core Status Register x (CSRx)
-----------------------------

| **Index**: 0x400 + 5x
| **Reset value**: 0x0000 0000

The Core Status Register x provides information about the status of
core x. Multiple instances of this register may exist, indexed by x.

:CSRx[1]:
   | Stopped (S)
   | Indicates whether the peripheral x is in a stopped state. 
   | 1: Stopped 
   | 0: Not Stopped 

:CSRx[0]:
   | Paused (P)
   | Indicates whether the peripheral x is in a paused state. 
   | 1: Paused 
   | 0: Not Paused 

Core Control Register x (CCRx)
------------------------------

| **Index**: 0x401 + 5x
| **Reset value**: 0x0000 0000

The Core Control Register x allows control and configuration of
specific functionalities and features for core x.

:CCRx[31:0]:
   | Reserved.

Core Maestro Register x (CMRx)
------------------------------

| **Index**: 0x402 + 5x
| **Reset value**: 0x0000 0000

The Core Maestro Register x provides the ability to trigger power
management actions for core x.
For details, refer to the "Maestro Registers" section.

Boot Address Register x (BARx)
------------------------------

| **Index**: 0x403 + 5x
| **Reset value**: Value of ``rst_boot_addr``.

The Boot Address Register determines the boot address for core x.
On reset, the value is defined by the ``rst_boot_addr`` hardware signal. 
Typically, this points to the start of ROM.
Initially, only one core is active post-reset, which can customize BARx values
for other cores as needed.

Interrupt Enable Register x (IERx)
----------------------------------

| **Index**: 0x404 + 5x
| **Reset value**: 0x0000 0000

The Interrupt Enable Register allows enabling or disabling interrupts for
specific peripherals associated with a core x. Each bit within this
register corresponds to a particular peripheral, allowing fine-grained control 
over interrupt handling. By setting a bit to 1, the corresponding peripheral's
interrupt is enabled, allowing the core to respond to the associated event or
request. Conversely, setting a bit to 0 disables the interrupt for that
peripheral. Multiple instances of this register may exist, indexed by x.
