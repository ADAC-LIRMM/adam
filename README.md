# ADAM - ADAptive Microcontroler

## Project Setup Guide

To achieve a functional copy of the ADAM project, adhere to the guide below:

### 1. Validate Base Software Dependencies

Initial Setup:

- **Operating System**: Utilize a modern x86-64 Linux distribution.
  The primary development was conducted on Debian 11.
- **Essential Software**: Ensure the installation and proper configuration of:
  - Python 3.9, along with `pip` and `virtualenv`
  - RISC-V GNU Toolchain

These base dependencies are sufficient to complete the initial setup and to
perform embedded software development for ADAM targets.

#### Miniconda Usage (Optional)

In instances where system software stack control is limited or difficulties
arise during installation, Miniconda offers an alternative for managing these
base software dependencies.

After Miniconda is installed, an environment for ADAM might be created and
configured with the necessary packages using the commands below:
```bash
conda create -n adam python=3.9
conda activate adam
conda install -c bdutrosv riscv-gnu-toolchain
```

### 2. Clone the Repository

Clone the repository with the following command:

```bash
git clone git@gite.lirmm.fr:adac/adam.git
```

### 3. Run ```setup.bash```

```bash
cd adam
./setup.bash
```

### 4. Additional Software Dependencies

- For a minimum bitstream flow execution, ensure the installation of Vivado.
- For other flows, ensure the installation of the following:
  - Xilinx Vivado
  - Siemens (MentorGraphics) Questa
  - Synopsys Design Compiler
  - Synopsys PrimePower
  - ST CMOS28FDSOI Technology Files

Remember to confirm that these tools are installed, PATH-included, and
licensed properly within your environment variables as applicable.

## Vivado

The ```vivado_flow.py``` script automates Vivado project generation and testing.

### Setting up Vivado

Before using the script, ensure your PATH variable points to your Vivado
installation:

```
$ export PATH=/tools/Xilinx/Vivado/2023.1/bin:$PATH
```

### Project Generation

To utilize the project generation functionality, run:

```
$ ./scripts/vivado_flow.py -t <target_name> project
```

### Testing

For testing an existing project, use:

```
$ ./scripts/vivado_flow.py -t <target_name> test
```

## TODO

- [adam_periph_spi] Timing diagram
- [All] Add inital blocks to verify parameter validity
- [adam_core_cv32e40p] Trigger hard falt on AXI-Lite error
- [adam_periphs] Implement pause
- [adam_axil_ram] Implement pause
- [adam_axil_xbar] Implement pause
- [adam_tb] Implement pause
- [adam_axil_ram] Implement pause
- [adam_axil_ram_tb] Implement pause
- [All] Set pause_ack to 1 on reset
## References

### Memory Interfaces

- [Buidilng an AXI-Lite slave the easy way](https://zipcpu.com/blog/2020/03/08/easyaxil.html)
- [AXI4-Lite Verification](https://zipcpu.com/formal/2018/12/28/axilite.html)
- [AXI4 Specification](http://www.gstitt.ece.ufl.edu/courses/fall15/eel4720_5721/labs/refs/AXI4_specification.pdf)
- [OBI Specification](https://github.com/openhwgroup/obi/blob/072d9173c1f2d79471d6f2a10eae59ee387d4c6f/OBI-v1.6.0.pdf)
- [APB Specification](https://documentation-service.arm.com/static/63fe2c1356ea36189d4e79f3?token=)

### Peripherals

- [Introduction to SPI Interface](https://www.analog.com/en/analog-dialogue/articles/introduction-to-spi-interface.html)