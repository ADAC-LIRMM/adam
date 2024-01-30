
.. _tutorial_setup:

==============
Setup Tutorial
==============

Welcome to the first step in your journey with ADAM!
This tutorial will guide you through setting up your development environment.
By the end of this guide, you'll have all the necessary tools installed and be
ready to dive into software or hardware development with ADAM.

Prerequisites
=============

This section describes the prerequisites for ADAM.
For the software developers, you will only need Docker.
For the hardware developers, you will also need Vivado and ModelSim.

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

2. Export the ``XILINX_PATH`` environment variable to the Xilinx folder
   containing the Vivado installation. For example:

.. code-block:: bash

   $ export XILINX_PATH=/tools/Xilinx

This is usually done in the ``.bashrc`` file, like the following:

.. code-block:: bash

   echo "export XILINX_PATH=/tools/Xilinx" >> ~/.bashrc

ModelSim
--------

.. note::

   The Student Edition of ModelSim by Intel is also suitable.
   
1. Go to the 
   `ModelSim <https://eda.sw.siemens.com/en-US/ic/modelsim/>`_ 
   website and follow the instructions to install ModelSim on your system.

2. Export the ``MODELSIM_PATH`` environment variable to the ModelSim folder
   containing the ModelSim installation. For example:

.. code-block:: bash

   $ export MODELSIM_PATH=/opt/ModelSim

This is usually done in the ``.bashrc`` file, like the following:

.. code-block:: bash

   echo "export MODELSIM_PATH=/opt/ModelSim" >> ~/.bashrc

Cloning the ADAM Repository
===========================

With the prerequisites in place, proceed to clone ADAM's Git Repository:

.. code-block:: bash

   git clone git@gite.lirmm.fr:adac/adam.git
   cd adam

Building the Docker Image
=========================

Build the ADAM Docker image using the provided script for a consistent
development environment:

.. code-block:: bash

   ./scripts/docker.bash --build

This script not only builds the Docker image but also automatically launches
an interactive container session, denoted by the prompt ``(adam) ~ $``.
Note that using the ``--build`` flag forces a rebuild of the Docker image,
which can be time-consuming.
For future sessions, simply entering the environment is as easy as running
the script without the ``--build`` flag. 
:ref:`Read more <docker_bash>`. 

To exit the interactive Docker container session, type ``exit`` at the
command prompt.

Setup
=====

.. warning::

   It's crucial to re-run the setup script after any major changes,
   such as switching branches, to ensure that all dependencies are
   correctly configured.

To configure ADAM and its dependencies, especially after significant changes
like branch switches, run the setup script within your Docker container. 
:ref:`Read more <setup_bash>`.

.. code-block:: bash

   (adam) ~ $ setup.bash --no-venv

Verifying the Installation
==========================

.. warning::

   Ensure you are operating within the interactive Docker container session
   for the following verification steps.

To confirm your setup is correct, perform the following checks:

1. **adam.py**: Ensure you can run the :ref:`adam_py` script by executing the
   following command:

   .. code-block:: bash

      adam.py --help

   You should see the script's help message.

2. **Vivado**: For hardware developers, verify Vivado installation by checking
   its version. 

   .. code-block:: bash

      vivado -version

   This command should display the Vivado version, confirming its availability.

3. **ModelSim**: For hardware developers, verify ModelSim installation by
   checking its version. 

   .. code-block:: bash

      vsim -version

   This command should display the ModelSim version,
   confirming its availability.

What's Next?
============

With your environment now ready, you can move on to the next tutorial that
aligns with your interests.

Happy developing!