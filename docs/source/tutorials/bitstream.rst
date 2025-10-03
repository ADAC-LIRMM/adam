
.. _tutorial_bitstream:

==================
Bitstream Tutorial
==================

In this tutorial, we will guide you through the process of generating a
bitstream for a given ADAM target.
The bitstream is the file you should load in the FPGA with your hardware
design. 
This tutorial should be followed within the ADAM Docker container.

Please note that ``nexys_video`` is used here as an example target.
You should replace it with the name of your desired target.

Generating the Bitstream
========================

To begin the bitstream generation process for your target FPGA,
use the FPGA *flow* of :ref:`adam_py` within ADAM's Docker container:

.. code-block:: bash

   (adam) ~ $ adam.py -t nexys_video fpga_flow

This initiates the bitstream generation for the ``nexys_video`` target.
After the process concludes, you can find the resulting bitstream at:

.. code-block::

   work/nexys_video/bitst/bitst.bit

For those looking to dive deeper, whether for debugging or exploration,
the Vivado project generated for the creation of the bitstream can be found at:

.. code-block::

   work/nexys_video/bitst/adam