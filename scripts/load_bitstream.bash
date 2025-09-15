#!/bin/bash
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

set -e  # Exit on error

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <device> <bitstream.bit>"
  echo "Example: $0 xilinx_tcf/Digilent/210276B7D0A4B design.bit"
  exit 1
fi

DEVICE="$1"
BITSTREAM="$2"

# Check if bitstream file exists
if [ ! -f "$BITSTREAM" ]; then
  echo "Error: Bitstream file '$BITSTREAM' not found."
  exit 1
fi

trap 'echo "Cleaning up..."; pkill -f hw_server' EXIT

vivado -mode tcl <<EOF
open_hw_manager
connect_hw_server
open_hw_target [get_hw_targets *$DEVICE]
current_hw_device [lindex [get_hw_devices] 0]
set_property PROGRAM.FILE {$BITSTREAM} [current_hw_device]
program_hw_devices [current_hw_device]
exit
EOF
