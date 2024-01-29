
.. _gen_ral_py:

==========
gen_ral.py
==========

The primary goal of ``gen_ral.py`` is to automate the generation of a C header
file for the Register Access Layer (RAL) in ADAM projects. 
Typically, this utility is not executed manually; instead, it is triggered
automatically by :ref:`adam_py` within the build process when compiling
specific configurations.
The requisite YAML configuration file for this script is likewise produced
automatically during the build process, 
making it uncommon to run this utility manually in typical project work.
This command-line tool takes an input YAML configuration file,
typically generated during the build process,
to produce a specialized header file that defines the RAL interface.
The RAL header file plays a crucial role in ADAM project development,
enabling efficient access and control of hardware registers and peripherals.
By automatically generating this header file,
``gen_ral.py`` ensures that it accurately reflects the hardware configuration.

Example Usage
=============

Although it is not common to call this script manually, here is an example of
how one would do it:

.. code-block:: bash

   (adam) ~/work/default/atgen $ gen_ral.py target.yml -o adam_ral.h -t default

In this example, ``target.yml`` is the input YAML configuration file,
``adam_ral.h`` is the output file,
and ``default`` is the ADAM target.
This command demonstrates manual invocation of the script,
which may be useful for bug fixing or implementing additional features.