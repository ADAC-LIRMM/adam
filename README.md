# ADAM - ADAptive Microcontroler

## Setting Up ADAM

To have a working copy of the project, follow these steps:

### 1. Clone the Repository

```
$ git clone git@github.com:alencar-felipe/adam.git
```

### 2. Run ```setup.bash```

```
$ cd adam
$ ./setup.bash
```

#### Observation:

If you're working on an outdated system and encounter issues related to Python
versions, consider using Miniconda to create an environment with Python 3.9.
This will ensure you have a compatible version for running ADAM.

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