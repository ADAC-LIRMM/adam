ADAM -- ADAptive Microcontroller
================================

`ADAM`_, an evolution of `ICOBS`_, is a parametric and extensible
microcontroller that aims to be state-of-the-art representative
for IoT and Edge Computing, while also enabling architectural explorations.

.. _ADAM: https://gite.lirmm.fr/adac/adam/
.. _ICOBS: https://gite.lirmm.fr/adac/icobs/

- **Parametric**:

  ADAM supports extensive customization via a configuration file,
  enabling users to:

  - Choose the number and types of peripherals, cores, and memory blocks.
  - Configure the memory map to match specific application requirements.

- **Extensible**:

  Designed to integrate other RISC-V cores easily through a generic core
  wrapper.

- **Suited for IoT and Edge Computing**:

  Implements the :ref:`activity_pause_protocol`, enabling fine-grained power
  management.
  This positions ADAM as a strong platform for developing energy-efficient
  computing nodes, especially for applications with intermittent computing.

- **Architectural Explorations**: *(work in progress)*

  A monitoring unit is being developed to:

  - Track power states of the microcontroller and memory access in real-time.
  - Enable power/performance profiling on FPGA platforms without disturbing
    program execution.

- **Tooling**:

  The :ref:`adam_py` script and the :ref:`adam.yml <adam_py>` configuration
  file improve project management by automating various tasks.
  This is complemented in software by a HAL (Hardware Abstraction Layer) and
  an auto-generated RAL (Register Abstraction Layer).

.. toctree::
   :maxdepth: 1
   :caption: Contents:

   tutorials/index
   configuration
   software/index
   hardware/index
   scripts/index
   guidelines/index

Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
