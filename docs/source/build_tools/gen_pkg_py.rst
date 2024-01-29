
.. _gen_pkg_py:

==========
gen_pkg.py
==========

The primary goal of ``gen_pkg.py`` is to automate the creation of a
SystemVerilog configuration package,
which encapsulates all of ADAM's parameters.
It accomplishes this by converting an intermediary YAML configuration file into
a SystemVerilog package.
Typically, this utility is not executed manually; instead, it is triggered
automatically by :ref:`adam_py` within the build process when compiling
particular configurations.
The requisite YAML configuration file for this script is likewise produced
automatically during the build process,
making it uncommon to run this script manually in typical project work.

Example Usage
=============

Although it is not common to call this script manually, here is an example of
how one would do it:

.. code-block:: bash

   (adam) ~/work/default/atgen $ gen_pkg.py target.yml -o adam_cfg_pkg.sv \
      -n adam_cfg_pkg -t default

In this example, ``target.yml`` is the input YAML configuration file,
``adam_cfg_pkg.sv`` is the desired output SystemVerilog file,
``adam_cfg_pkg`` is the SystemVerilog package name,
and ``default`` is the ADAM target.
This command demonstrates manual invocation of the script,
which may be useful for bug fixing or implementing additional features.