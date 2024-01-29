
.. _adam_py:

=======
adam.py
=======

The ``adam.py`` script is the ADAM orchestration tool,
designed to automate and streamline the hardware design and verification
process.
It integrates with vendor-specific tools like ModelSim for simulation,
Synopsys Design Compiler for ASIC Synthesis,
and Xilinx Vivado for FPGA bitstream generation.

Utilizing ``adam.yml`` for project configuration and 
Jinja2 templates for dynamic code generation,
``adam.py`` offers a flexible and adaptable workflow.
Its modular design not only simplifies the complex flows but also ensures easy
extension and adaptation to new tools.
Catering to ADAM's evolving requirements.

Tasks and Flows
===============

To achieve all this functionality and extensibility, ``adam.py`` has the
concepts of `tasks` and `flows`.

- **Task**: An individual operation ``adam.py`` executes, such as code
  generation ``atgen``, simulation ``vunit``,
  or bitstream generation ``bitst``. 

- **Flow**: A *flow* enables the execution of a sequence of *tasks*
  through a single command,
  ensuring consistency and efficiency in the development process.

Implemented Tasks
-----------------

- ``atgen``: Generates necessary code files using predefined
  templates and configurations, tailored to the specific needs of a project.

- ``vunit``: Integrates with VUnit for running simulations on the
  hardware design, facilitating design verification.

- ``bitst``: Generates a bitstream file for FPGA deployment using
  Xilinx Vivado, preparing the design for hardware implementation.

Implemented Flows
-----------------

- ``test_flow``: Targeted at design verification, this flow combines ``atgen``,
  and ``vunit``.
    
- ``fpga_flow``: Targeted at FPGA deployment, this flow combines ``atgen``,
  and ``bitst``.

.. note::

   Bits and pieces of the ``power_flow`` are still present within the script.
   However, due to significant changes and extensive refactoring required to
   align with the project's current direction, it wont run without considerable
   refactoring.

Command Line Flags
==================

- ``-p, --project``: Specifies the project directory containing configuration
  files and source code.
    
- ``-w, --work``: Sets the work directory where all generated 
  output files will be stored.

- ``-t, --target``: Selects the target from the adam.yml file.
  
- ``-d, --dry-run``: Performs a trial run without executing any tasks,
  useful for verifying configurations and command line options.
   
- ``-y, --assume-yes``: Automatically confirms any prompts during execution,
  automating operations that would otherwise require user interaction.
    
- ``-g, --gui``: Opens graphical interfaces of external tools, if supported,
  for tasks that have a GUI option.
   
- ``--dirty``: Prevents cleaning of the work directories before starting a
  new task, useful for enabling iterative compilation in some *tasks*.

- ``--help``: Displays a help message listing all command-line options and
  their descriptions.

Task/Flow Specific Flags
------------------------

- ``--top``: Used with ``vunit`` or ``test_flow`` to run a specific testbench
  or a test case within a testbench.
  Format: ``<testbench name>`` or ``<testbench name>.<test case>``.

- ``--help``: Displays detailed help information for the specified task or
  flow, outlining available options and usage instructions.
  