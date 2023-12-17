======
SYSCFG
======

Overview
========
The System Configuration (SYSCFG) is a purpose-built peripheral specifically
designed to effectively manage the power, clock, and boot configurations of
ADAM.

Although categorized as a peripheral, SYSCFG's direct connection to the Low
Power Domain Crossbar and its control signals to almost all other components
sets it apart.
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

Registers Table
===============

+------------+--------------+---------------------------------+
| Index      | Name         | Description                     |
+============+==============+=================================+
| 0x000      | LSDOM_SR     | LSDOM Status Register           |
+------------+--------------+---------------------------------+
| 0x001      | LSDOM_MR     | LSDOM Maestro Register          |
+------------+--------------+---------------------------------+
| 0x002      | HSDOM_SR     | HSDOM Status Register           |
+------------+--------------+---------------------------------+
| 0x003      | HSDOM_MR     | HSDOM Maestro Register          |
+------------+--------------+---------------------------------+
| 0x004      | FAB_LSDOM_SR | Fabric LSDOM Status Register    |
+------------+--------------+---------------------------------+
| 0x005      | FAB_LSDOM_MR | Fabric LSDOM Maestro Register   |
+------------+--------------+---------------------------------+
| 0x006      | FAB_HSDOM_SR | Fabric HSDOM Status Register    |
+------------+--------------+---------------------------------+
| 0x007      | FAB_HSDOM_MR | Fabric HSDOM Maestro Register   |
+------------+--------------+---------------------------------+
| 0x008      | FAB_LSBP_SR  | Fabric LSBP Status Register     |
+------------+--------------+---------------------------------+
| 0x009      | FAB_LSBP_MR  | Fabric LSBP Maestro Register    |
+------------+--------------+---------------------------------+
| 0x00A      | FAB_LSIP_SR  | Fabric LSIP Status Register     |
+------------+--------------+---------------------------------+
| 0x00B      | FAB_LSIP_MR  | Fabric LSIP Maestro Register    |
+------------+--------------+---------------------------------+
| 0x00C      | FAB_HSBP_SR  | Fabric HSBP Status Register     |
+------------+--------------+---------------------------------+
| 0x00D      | FAB_HSBP_MR  | Fabric HSBP Maestro Register    |
+------------+--------------+---------------------------------+
| 0x00E      | FAB_HSIP_SR  | Fabric HSIP Status Register     |
+------------+--------------+---------------------------------+
| 0x00F      | FAB_HSIP_MR  | Fabric HSIP Maestro Register    |
+------------+--------------+---------------------------------+
| 0x010      | LPCPU_SR     | LPCPU Status Register           |
+------------+--------------+---------------------------------+
| 0x011      | LPCPU_MR     | LPCPU Maestro Register          |
+------------+--------------+---------------------------------+
| 0x012      | LPCPU_BAR    | LPCPU Boot Address Register     |
+------------+--------------+---------------------------------+
| 0x013      | LPCPU_IER    | LPCPU Interrupt Enable Register |
+------------+--------------+---------------------------------+
| 0x014      | LPMEM_SR     | LPMEM Status Register           |
+------------+--------------+---------------------------------+
| 0x015      | LPMEM_MR     | LPMEM Maestro Register          |
+------------+--------------+---------------------------------+
| ...        | ...          | ...                             |
+------------+--------------+---------------------------------+
| 0x100 + 4x | CPUx_SR      | CPU x Status Register           |
+------------+--------------+---------------------------------+
| 0x101 + 4x | CPUx_MR      | CPU x Maestro Register          |
+------------+--------------+---------------------------------+
| 0x102 + 4x | CPUx_BAR     | CPU x Boot Address Register     |
+------------+--------------+---------------------------------+
| 0x104 + 4x | CPUx_IER     | CPU x Interrupt Enable Register |
+------------+--------------+---------------------------------+
| ...        | ...          | ...                             |
+------------+--------------+---------------------------------+
| 0x200 + 3x | DMAx_SR      | DMA x Status Register           |
+------------+--------------+---------------------------------+
| 0x201 + 3x | DMAx_MR      | DMA x Maestro Register          |
+------------+--------------+---------------------------------+
| 0x202 + 3x | DMAx_IR      | DMA x Interrupt Register        |
+------------+--------------+---------------------------------+
| ...        | ...          | ...                             |
+------------+--------------+---------------------------------+
| 0x300 + 2x | MEMx_SR      | Memory x Status Register        |
+------------+--------------+---------------------------------+
| 0x302 + 2x | MEMx_MR      | Memory x Maestro Register       |
+------------+--------------+---------------------------------+
| ...        | ...          |                                 |
+------------+--------------+---------------------------------+
| 0x400 + 2x | LSBPx_SR     | LSBP x Status Register          |
+------------+--------------+---------------------------------+
| 0x401 + 2x | LSBPx_MR     | LSBP x Maestro Register         |
+------------+--------------+---------------------------------+
| ...        | ...          |                                 |
+------------+--------------+---------------------------------+
| 0x500 + 2x | LSIPx_SR     | LSIP x Status Register          |
+------------+--------------+---------------------------------+
| 0x501 + 2x | LSIPx_MR     | LSIP x Maestro Register         |
+------------+--------------+---------------------------------+
| ...        | ...          |                                 |
+------------+--------------+---------------------------------+
| 0x600 + 2x | HSIPx_SR     | HSIP x Status Register          |
+------------+--------------+---------------------------------+
| 0x601 + 2x | HSIPx_MR     | HSIP x Maestro Register         |
+------------+--------------+---------------------------------+
| ...        | ...          |                                 |
+------------+--------------+---------------------------------+

Registers Description
=====================

Status Registers (\*_SR)
------------------------

| **Index**: Refer to the Registers Table.
| **Reset value**: Depends on initial System state.

Status Registers provide real-time status information about the corresponding
domain, fabric component, peripheral, .etc.

:\*_SR[1]:
  | Stopped (S)
  | Indicates whether the peripheral x is in a stopped state. 
  | 1: Stopped 
  | 0: Not Stopped 

:\*_SR[0]:
  | Paused (P)
  | Indicates whether the peripheral x is in a paused state. 
  | 1: Paused 
  | 0: Not Paused 

Maestro Registers (\*_MR)
-------------------------

| **Index**: Refer to the Registers Table.
| **Reset value**: 0x0000 0000

:\*_MR[2:0]:
  | Maestro Action

For details, refer to the :ref:`maestro` section.

Specific Considerations
=======================

1. **Domain-related Registers (LSDOM and HSDOM)**: 
   These registers are focused on the overall state of the low-speed and
   high-speed domains, respectively.
   The SYSCFG registers refering to these domains control the entire clock
   domain, automatically adjusting the activity state of all modules in the
   respective power domain.

2. **Fabric-related Registers (FAB\_\*)**:
   Provide status and control over the various components of the :ref:`fabric`.

3. **Register Indexing**:
   The "x" in certain register names (e.g., CPUx_SR) indicates indexing for
   multiple instances of the same register type.
   This allows for individual control and monitoring of each instance.
   In the automatically generated memory map C header file, these indexed
   register names can be replaced by the actual name of the instance.
   For example, LSBPx_SR could be specifically named ``LSBP_UART0_SR`` to
   represent the status register of the first UART module connected to the
   Low-Speed Base Peripheral (LSBP) interconnect.

4. **Reserved Registers**:
   If a specific component described in the register map is not included in a
   particular ADAM configuration, then the registers related to that component
   will be unimplemented (reserved).
   Interacting with these unimplemented registers will lead to undefined
   behavior. 
   This approach underscores the importance of verifying the presence of
   specific components within the ADAM instance before interacting with their
   corresponding registers.
