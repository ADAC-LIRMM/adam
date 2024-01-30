===============
Getting Started
===============

This document is a tutorial on how to start working with ADAM.

Prerequisites
=============

This section describes the prerequisites for ADAM.
For the software developers, you will only need to install Docker.
For the hardware developers, you will also need to install Vivado and 
ModelSIM.

Docker
------

1. Go to the `Docker <https://www.docker.com/>`_ website and follow the 
instructions to install Docker on your system.

2. Don't forget to follow the post installation steps. This will allow you to
run Docker without `sudo`. 
See the `guide <https://docs.docker.com/install/linux/linux-postinstall/>`_.

Vivado
------

1. Go to the `Xilinx <https://www.xilinx.com/>`_ website and follow the
instructions to install Vivado on your system.

2. Export the `XILINX_PATH` environment variable to the Xilinx folder containing
the Vivado installation. For example:

.. code-block:: bash

    $ export XILINX_PATH=/tools/Xilinx

This is usually done in the ``.bashrc`` file, like the following:

.. code-block:: bash

    echo "export XILINX_PATH=/tools/Xilinx" >> ~/.bashrc

ModelSIM
--------

1. Go to the 
`ModelSIM <https://eda.sw.siemens.com/en-US/ic/modelsim/>`_ 
website and follow the instructions to install ModelSIM on your system.

2. Export the ``MODELSIM_PATH`` environment variable to the ModelSIM folder
containing the ModelSIM installation. For example:

.. code-block:: bash

    $ export MODELSIM_PATH=/tools/ModelSIM

This is usually done in the ``.bashrc`` file, like the following:

.. code-block:: bash

    echo "export MODELSIM_PATH=/tools/ModelSIM" >> ~/.bashrc

Cloning the Repository
======================

The first step is to clone the ADAM repository. This can be done with the
following command:

.. code-block:: bash

    $ git clone git@gite.lirmm.fr:adac/adam.git
        
Then, go to the ADAM directory:

.. code-block:: bash

    $ cd adam

Docker Image
============

Build the ADAM docker image:
    
.. code-block:: bash

    $ ./scripts/docker.bash --build

Now you have a docker image running with ADAM installed. You can check it by:
    
.. code-block:: bash

    (adam) ~ $ flow.py --help


In the future, you can run the docker image without rebuilding by running:

.. code-block:: bash

    $ ./scripts/docker.bash


ADAM Setup
==========

In this section, we will setup ADAM by getting and seting up all the 
dependencies. 
This can be done running the following command:

.. code-block:: bash

    (adam) ~ $ setup.bash

Running Testbenches
===================

In this section, we will run the testbenches of the ADAM repository to ensure
your ADAM is well configured.
If you are only a software developer for ADAM, you can skip this section.
This can be done running the following command:

.. code-block:: bash

    (adam) ~ $ flow.py vunit

Running Software Applications
=============================

In this section, we will run a full software application demo on ADAM.
First, go to the demo directory:

.. code-block:: bash

    (adam) ~ $ cd examples/demo

Second, compile the software application:

.. code-block:: bash

    (adam) ~ $ make all

Third, load the software application on ADAM:

.. code-block:: bash

    (adam) ~ $ python3 ./scripts/code_loader.py ./build/target/demo.elf \
    -p /dev/ttyUSB2

The software application should be running on ADAM now.
You can check the UART output in this very terminal.
