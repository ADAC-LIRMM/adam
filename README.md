# ADAM - ADAptive Microcontroller

ADAM is a flexible, modular microcontroller based on the RISC-V ISA. 
It's designed to allow for exploration of different hardware architectures. 
The key feature of ADAM is its core and peripheral modularity. 
In the future, a low power core will be implemented to work parallel to the main
core.

## Cores and Peripherals

ADAM supports different cores and peripheral configurations. 
Currently, the supported cores are Ibex and CV32. 
As for peripherals, you can add as many as you want. 
The options include GPIO, SPI, timer, and UART modules.

## Demo Project

In this repository, you'll find both the RTL and a demo project to run on the 
platform. 
The demo is a simple "Hello World" print with some LEDs blinking.

## Documentation

More detailed information about ADAM, including prerequisites, dependencies, 
installation, and setup instructions, can be found in the documentation. 
The documentation is generated using [Sphinx](https://www.sphinx-doc.org/) and 
can be found in the `docs` folder.

## Maintainers

The ADAM project is maintained by the ADAC team at the LIRMM laboratory.