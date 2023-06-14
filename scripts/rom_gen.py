#!/usr/bin/env python3
"""
Generates ROM from an ELF file.
Supported formats: coe, btxt, htxt, sverilog.
"""

import argparse
import sys
import traceback

from elftools.elf.elffile import ELFFile
from elftools.elf.constants import SH_FLAGS
from jinja2 import Template
from math import log2, ceil

coe_template = Template("""
memory_initialization_radix = 16;
memory_initialization_vector = 
{%- for word in words %}
{{ '{:08X}'.format(word) }}
{%- endfor %}
""")

btxt_template = Template("""
{%- for word in words %}
{{ '{:032b}'.format(word) }}
{%- endfor %}
""")

htxt_template = Template("""
{%- for word in words %}
{{ '{:08X}'.format(word) }}
{%- endfor %}
""")
	
sverilog_template = Template("""
module {{ module_name }} (
    input logic clk,
    input logic rst,
    input logic test,

    input  logic pause_req,
    output logic pause_ack,

    AXI_LITE.Slave axil
);

	localparam ADDR_WIDTH = {{ addr_width }};
    localparam DATA_WIDTH = {{ data_width }};

    localparam SIZE = {{ size }};

    localparam STRB_WIDTH      = DATA_WIDTH/8;
    localparam UNALIGNED_WIDTH = $clog2(STRB_WIDTH);
    localparam ALIGNED_WIDTH   = ADDR_WIDTH - UNALIGNED_WIDTH;
    localparam ALIGNED_SIZE    = SIZE / STRB_WIDTH;

    typedef logic [ADDR_WIDTH-1:0] addr_t;
    typedef logic [DATA_WIDTH-1:0] data_t;
    typedef logic [STRB_WIDTH-1:0] strb_t;
    
    typedef logic [UNALIGNED_WIDTH-1:0] unaligned_t;
    typedef logic [ALIGNED_WIDTH-1:0]   aligned_t;

    // (* RAM_STYLE="BLOCK" *)
    data_t mem [ALIGNED_SIZE-1:0];

    addr_t raddr;

    // TODO: implement pause
    assign pause_ack = 0;

	always_comb begin
{%- for word in words %}
		mem[{{ loop.index - 1 }}] = 32'h{{ '{:08X}'.format(word) }};
{%- endfor %}
  	end

	always_comb begin
		axil.aw_ready = 1;
		axil.w_ready  = 1;
		axil.b_resp   = axi_pkg::RESP_DECERR;
		axil.b_valid  = 1;
	end

    always_ff @(posedge clk) begin
        automatic unaligned_t unaligned;
        automatic aligned_t   aligned;
        
        if (rst) begin
            axil.ar_ready = 1;
			axil.r_data   = 0;
            axil.r_resp   = 0;
            axil.r_valid  = 0;
        end
        else begin
            if(axil.r_valid && axil.r_ready) begin
                axil.r_valid = 0;
            end

            if(axil.ar_valid && axil.ar_ready) begin
                raddr = axil.ar_addr;
                axil.ar_ready = 0;
            end

            if(!axil.ar_ready && !axil.r_valid) begin
                unaligned = raddr[UNALIGNED_WIDTH-1:0];
                aligned   = raddr[DATA_WIDTH-1:UNALIGNED_WIDTH];

                if (unaligned == 0 && aligned < ALIGNED_SIZE) begin 
                    axil.r_data = mem[aligned];
                    axil.r_resp = axi_pkg::RESP_OKAY;
                end
                else begin
                    axil.r_data = 0;
                    axil.r_resp = axi_pkg::RESP_DECERR;
                end

                axil.r_valid  = 1;
                axil.ar_ready = 1;
            end
        end
    end

endmodule
""")

def rom_gen(input_path, output_path, output_format, module_name='rom'):

	elf = ELFFile(open(input_path, 'rb'))

	addr_width = 32
	data_width = elf.elfclass # Get the ELF address width (either 32 or 64)
    # endianess = elf.header['e_ident']['EI_DATA'] # Get the ELF endianness
	
	wl = data_width//8 # word length

	data = []
	for section in elf.iter_sections():
		if section['sh_type'] != 'SHT_PROGBITS':
			continue
		if ~section['sh_flags'] & SH_FLAGS.SHF_ALLOC:
			continue
		print(section.name, len(section.data()))
		data += section.data()
	data += b'\x00' * (wl - (len(data) % wl))
	
	words = []
	while data:
		word = int.from_bytes(data[:wl],
			byteorder='little', signed=False)
		words += [word]
		data = data[wl:]

	args = {
		'module_name' : module_name,
		'addr_width' : addr_width,
		'data_width' : data_width,
		'size' : len(words)*wl,
		'words' : words
	}

	if output_format == 'coe':
		output_raw = coe_template.render(**args)
	elif output_format == 'btxt':
		output_raw = btxt_template.render(**args)
	elif output_format == 'htxt':
		output_raw = htxt_template.render(**args)
	elif output_format == 'sverilog':
		output_raw = sverilog_template.render(**args)
	else:
		raise RuntimeError(f'Format not supported: {output_format}')
		
	with open(output_path, 'w') as file:
		file.write(output_raw)


def main():
	parser = argparse.ArgumentParser(description=__doc__.strip())
	parser.add_argument('input',
		type=str,
		help='input ELF file')
	parser.add_argument('-o', '--output',
	 	type=str, required=True,
		help='output file')
	parser.add_argument('-f', '--format',
	 	type=str, required=True,
		help='output file format')
	parser.add_argument('-m', '--module-name',
	 	type=str, required=False, default='rom',
		help='module name (sverilog)')
	
	args = parser.parse_args()

	rom_gen(
		input_path=args.input,
		output_path=args.output,
		output_format=args.format,
		module_name=args.module_name
	)


if __name__ == "__main__":
	main()
