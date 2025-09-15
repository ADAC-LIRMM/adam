#!/usr/bin/env python3
# Copyright 2025 LIRMM
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
`include "adam/macros.svh"

module {{ module_name }} #(
    `ADAM_CFG_PARAMS
) (
    ADAM_SEQ.Slave seq,

    input  logic  req,
    input  ADDR_T addr,
    input  logic  we,
    input  STRB_T be,
    input  DATA_T wdata,
    output DATA_T rdata
);

	localparam SIZE = {{ size }};

    localparam UNALIGNED_WIDTH = $clog2(STRB_WIDTH);         
    localparam ALIGNED_WIDTH   = ADDR_WIDTH - UNALIGNED_WIDTH;
    localparam ALIGNED_SIZE    = SIZE / STRB_WIDTH;

    // (* RAM_STYLE="BLOCK" *)
    DATA_T mem [ALIGNED_SIZE-1:0];
    
    logic [ALIGNED_WIDTH-1:0] aligned;

    initial begin
        for (int i = 0; i < ALIGNED_SIZE; i++) begin 
{%- for word in words %}
			mem[{{ loop.index - 1 }}] = 32'h{{ '{:08X}'.format(word) }};
{%- endfor %}
        end       
    end

    assign aligned = addr[ADDR_WIDTH-1:UNALIGNED_WIDTH];

    always_ff @(posedge seq.clk) begin
        for (int i = 0; i < STRB_WIDTH; i++) begin
            if (!req || aligned > ALIGNED_SIZE) begin
                rdata[i*8 +: 8] <= '0;
            end
            else if (we && be[i]) begin
                //mem[aligned][i*8 +: 8] <= wdata[i*8 +: 8]; 
                rdata[i*8 +: 8]        <= wdata[i*8 +: 8];
            end
            else begin
                rdata[i*8 +: 8] <= mem[aligned][i*8 +: 8];
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
