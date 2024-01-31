ADAM -- ADAptive Microcontroller
================================

`ADAM`_, an evolution of `ICOBS`_, is designed for IoT and Edge Computing,
being particularly suited for Intermittent Computing.
Its parametric nature allows for extensive customization, enabling users to
easily modify the number and types of CPUs, adjust memory configurations,
and comprehensively alter the memory map to suit specific application needs.
This adaptability, combined with the :ref:`activity_pause_protocol` for
efficient power management, positions ADAM as a versatile tool for developing
energy-efficient computing nodes.

The :ref:`adam_py` script and the :ref:`adam_yml <adam_py>` configuration file
improves the project management by automating various tasks, making the
development process more efficient.
This efficiency is further supported by the integration of an
HAL (Hardware Abstraction Layer) and an auto-generated
RAL (Register Abstraction Layer).

.. _ADAM: https://gite.lirmm.fr/adac/adam/

.. _ICOBS: https://gite.lirmm.fr/adac/icobs/

.. toctree::
   :maxdepth: 1
   :caption: Contents:
   
   tutorials/index
   configuration
   hal/index
   hardware/index
   scripts/index
   guidelines/index

Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
