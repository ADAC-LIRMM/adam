======
SYSCFG
======

Overview
========
The System Configuration (SYSCFG) is a purpose-built module specifically
designed to effectively manage the power, clock, and boot configurations of
ADAM.

SYSCFG's direct connection to the Low Power Domain Crossbar and its control
signals to almost all other components sets it apart from the usual
peripherals.
It is essentially in a class of its own, acting as both a peripheral and a
core part of ADAM.

.. _maestro:

Maestro
=======

The Maestros offer precise and safe power state management for system
components.
They allow for the following actions:

- **Resume**: This action starts/resumes a component from its paused or
  stopped state.

- **Pause**: This places the component into an sleep mode while retaining its
  current state.

- **Stop**: A sleep mode that, upon resume, will not retain the previous state,
  resulting in a reset.

- **Reset**: Essentially a Stop followed by a Resume. This action may not be
  vital for memory and peripherals, but it enables a core to self-reset.

When SYSCFG experiences a reset, every maestro transitions to a special state.
Within this state, the component's soft reset line remains high, regardless of
the state signaled by the :ref:`activity_pause_protocol` interface.

Typically, a component set to *stop* mode will use less energy than if it were
set to *pause* mode.

It's worth noting that the energy-saving approach (be it through clock gating,
power gating, or power gating with non-volatile registers) relies on the
component's design specifics.

For each component, whether a memory bank, peripheral, or core, the Maestro
Registers can trigger the appropriate power management action.
To initiate an action, one simply writes the corresponding value to the
respective register.
Post completion of the action, the hardware will autonomously set the register
to its default state.

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

Target
======

The SYSCFG consists of various components, termed *targets*.
These targets represent different system components, each with its own set of
configurable options.
The design of SYSCFG incorporates a modular approach, where the configuration
registers are organized into sections that are repeated for each target.
This structure allows for a uniform method of accessing and modifying the
settings of different targets.

It's important to note that while the register indexes are consistent across
targets, not all targets possess implement same set of registers, therefore
some a left reserved.
A table is provided outlining each target.


Register Table
--------------

+------------+------+---------------------------+
| Index      | Name | Description               |
+============+======+===========================+
| 0x000      | SR   | Status Register           |
+------------+------+---------------------------+
| 0x001      | MR   | Maestro Register          |
+------------+------+---------------------------+
| 0x002      | BAR  | Boot Address Register     |
+------------+------+---------------------------+
| 0x003      | IER  | Interrupt Enable Register |
+------------+------+---------------------------+

.. note::

  | Register Address = SYSCFG Base Address +
  | (4*Target Number + Register Index) * (Address Width / 8)

Register Description
--------------------

Status Register (SR)
~~~~~~~~~~~~~~~~~~~~

| **Index**: 0x000
| **Reset value**: 0x0000 0000

:SR[1]:
   | Stopped (S)
   | Indicates whether the peripheral x is in a stopped state. 
   | 1: Stopped 
   | 0: Not Stopped 

:SR[0]:
   | Paused (P)
   | Indicates whether the peripheral x is in a paused state. 
   | 1: Paused 
   | 0: Not Paused 

Maestro Register (MR)
~~~~~~~~~~~~~~~~~~~~~

| **Index**: 0x001
| **Reset value**: 0x0000 0000


For details, refer to the "Maestro Registers" section.

Boot Address Register (BAR)
~~~~~~~~~~~~~~~~~~~~~~~~~~~

| **Index**: 0x003
| **Reset value**: Value of ``rst_boot_addr``.

On reset, the value is defined by the ``rst_boot_addr`` hardware signal. 
Typically, this points to the start of ROM.
Futhermore, normaly, only one core is active post-reset, which can customize
BAR for other cores as needed.
Only implemented for CPU or LPCPU cores, otherwise is a reserved register.

Interrupt Enable Register (IER)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

| **Index**: 0x004
| **Reset value**: 0x0000 0000

The Interrupt Enable Register allows enabling or disabling interrupts.
Each bit within this register corresponds to a particular peripheral,
allowing fine-grained control over interrupt handling.
By setting a bit to 1, the corresponding peripheral's interrupt is enabled.
Conversely, setting a bit to 0 disables the peripheral interrupt.

Target Table
============

+----------+-----------+----------+----------+--------------------------------+
| Quantity | Name      | Has BAR? | Has IER? | Description                    |
+==========+===========+==========+==========+================================+
| 1        | LSDOM     | No       | No       | Low Speed Domain               |
+----------+-----------+----------+----------+--------------------------------+
| 1        | HSDOM     | No       | No       | High Speed Domain              |
+----------+-----------+----------+----------+--------------------------------+
| 1        | FAB_LSDOM | No       | No       | Low Speed Domain Fabric        |
+----------+-----------+----------+----------+--------------------------------+
| 1        | FAB_HSDOM | No       | No       | High Speed Domain Fabric       |
+----------+-----------+----------+----------+--------------------------------+
| EN_LSPA  | FAB_LSPA  | No       | No       | Low Speed Peripherals A Fabric |
+----------+-----------+----------+----------+--------------------------------+
| EN_LSPB  | FAB_LSPB  | No       | No       | Low Speed Peripherals B Fabric |
+----------+-----------+----------+----------+--------------------------------+
| EN_LPCPU | LPCPU     | Yes      | Yes      | Low Power CPU                  |
+----------+-----------+----------+----------+--------------------------------+
| EN_LPMEM | LPMEM     | No       | No       | Low Power Memory               |
+----------+-----------+----------+----------+--------------------------------+
| NO_CPUS  | CPUx      | Yes      | Yes      | CPU x                          |
+----------+-----------+----------+----------+--------------------------------+
| NO_DMAS  | DMAx      | No       | Yes      | Direct Memory Access x         |
+----------+-----------+----------+----------+--------------------------------+
| NO_MEMS  | MEMx      | No       | No       | Memory x                       |
+----------+-----------+----------+----------+--------------------------------+
| NO_LSPAS | LSPAx     | No       | No       | Low Speed Peripheral A x       |
+----------+-----------+----------+----------+--------------------------------+
| NO_LSPBS | LSPBx     | No       | No       | Low Speed Peripheral B x       |
+----------+-----------+----------+----------+--------------------------------+
| NO_HSPS  | HSPx      | No       | No       | High Speed Peripheral x        |
+----------+-----------+----------+----------+--------------------------------+

