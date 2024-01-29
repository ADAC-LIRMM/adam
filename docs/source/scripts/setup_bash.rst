
.. _setup_bash:

==========
setup.bash
==========

The ``setup.bash`` script serves as a comprehensive project setup tool,
automating various tasks to prepare the project environment for development
and documentation generation.
It enables the user to clean the project by removing automatically generated 
files, sets up project submodules, and applies patches if needed.
Additionally, it creates a Python virtual environment to isolate
project-specific Python dependencies (optionally), installs required Python
packages, generates the documentation, and more.
This script streamlines the setup process, ensuring that the project
environment is ready for development with ease.

This script is a fundamental component in building the 
:ref:`Docker image <docker_bash>`. When executed within Docker, it is
recommended to run the script with the ``--no-venv`` option to disable the
virtual environment.
This prevents the inception of virtual environments, as the image itself serves
a similar purpose.

Enabling the virtual environment while running the script provides you the
flexibility to work on the project outside the container. 
Both options are available to accommodate your workflow preferences.
However, using the container is strongly recommended for a more controlled
and reproducible development environment. 
:ref:`Read more <docker_bash>`. 

Usage Example
=============

Inside the Docker container (recommended):

.. code-block:: bash

   (adam) ~ $ setup.bash --no-venv

Outside the Docker container (with virtual environment):

.. code-block:: bash

   $ ./setup.bash

After running the script successfully, you should see the following
success message:

.. code-block:: bash

   Setup finished

.. note::

    Remember to activate the virtual environment using 
    ``source ./venv/bin/activate`` if you opt to use it.