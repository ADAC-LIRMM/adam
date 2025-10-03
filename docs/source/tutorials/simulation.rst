
.. _tutorial_simulation:

===================
Simulation Tutorial
===================

Simulation is a crucial step in the development of hardwar for ADAM.
It allows you to test your designs and code before deploying them to the
actual hardware.
In ADAM, you can perform simulation using various testbenches to ensure the 
correct functionality of the design.

One essential tool for simulation and verification in ADAM is
`VUnit <http://vunit.github.io/>`_.
An open-source framework widely used for verification of VHDL and
SystemVerilog designs. 
It simplifies the process of creating, managing, and running testbenches,
making it an essential tool for verifying hardware designs.

How to Run All Testbenches
==========================

To run all testbenches for a given target in ADAM,
you can use the ``test_flow`` from :ref:`adam_py`:

.. code-block:: bash

   (adam) ~ $ adam.py test_flow

This command will run all tests against the default target.

If you want to test for a specific target,
you can specify the target using the ``-t`` flag.
For example, to test for the ``nexys_video`` target,
you can use the following command:

.. code-block:: bash

   (adam) ~ $ adam.py -t nexys_video test_flow

This allows you to focus your testing on a particular target, ensuring that
tests are run in the context of that specific configuration.

How to Run a Single Testbench 
=============================

Running a single testbench in ADAM allows you to focus your testing and
debugging efforts on a specific module or functionality within your
hardware design.
Here's how you can do it for the ``test`` test case in the
``adam_periph_uart_tx_tb`` testbench:

.. code-block:: bash

   (adam) ~ $ adam.py test_flow --top adam_periph_uart_tx_tb.test

Incremental Compilation
=======================

When developing new testbenches or making iterative changes to your code,
you can use the ``--dirty`` flag to enable iterative compilation without
cleaning the previous build.
This speeds up the development process. 
Example:

.. code-block:: bash

   (adam) ~ $ adam.py --dirty test_flow --top adam_periph_uart_tx_tb.test

Visualizing Traces
==================

To view traces and view simulation results for the specific testbench,
you can use the ``-g`` flag.
This opens the testbench in the graphical interface,
making it easy to inspect traces and debug issues.
Example:

.. code-block:: bash

   (adam) ~ $ adam.py --dirty -g test_flow --top adam_periph_uart_tx_tb.test
