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

#!/usr/bin/env python3

import argparse
import csv
import logging
import matplotlib.pyplot as plt
import numpy as np
import re
import sys

from pathlib import Path, PosixPath

def waveform_parser(file_path):
    with open(file_path, 'r') as file:
        for line in file:
            try:
                line = line.strip()
                
                # Check for empty line
                if not line:
                    continue

                # Check for comment
                if line.startswith(';'):
                    continue

                parts = line.split()
                
                # Check for directive
                if parts[0].startswith('.'):
                    name = parts[0][1:]
                    args = parts[1:]
                    yield ('directive', (name, args))

                # Check for time
                elif len(parts) == 1:
                    time = int(parts[0])
                    yield ('time', (time,))

                # Check for value
                elif len(parts) == 2:
                    index = int(parts[0])
                    value = float(parts[1])
                    yield ('value', (index, value))

                # Check for invalid line
                else:
                    raise RuntimeError('Invalid line.')

            except Exception:
                logging.error(f'Unsupported syntax: {line}')


def index_parser(args):
    if len(args) != 3:
        raise RuntimeError('Wrong number of arguments.')
    
    name = args[0]

    index = int(args[1])

    if args[2] != 'Pc':
        raise RuntimeError('args[2] != \'Pc\'')

    return name, index


def power_linker(waveform_path,start_time, interval, output_path, targets):
    target_data = {}
    for name, module in targets:
        csv_path = output_path / f'{name}.csv'
        csv_file = open(csv_path, 'w', newline='')
        csv_writer = csv.writer(csv_file)
        
        # Write CSV header
        csv_writer.writerow(['time [ns]', 'total [nW]', 'leakage [nW]',
            'internal [nW]', 'switching [nW]'])

        target_data[name] = {
            'module' : module,
            'total' : None,
            'leakage' : None,
            'internal' : None,
            'switching' : None,
            'csv_file' : csv_file,
            'csv_writer' : csv_writer
        }

        values = {} 

    curr_time = 0

    for entry_type, data in waveform_parser(waveform_path):
        if entry_type == 'directive':
            directive, args = data

            try:
                if directive == 'time_resolution':
                    if args != ['1']:
                        raise RuntimeError('Unsupported time_resolution')

                elif directive == 'hier_separator':
                    if args != ['/']:
                        raise RuntimeError('Unsupported hier_separator')

                elif directive == 'index':
                    trace_name, trace_index = index_parser(args)

                    for target, data in target_data.items():
                        module = data['module']
                        if trace_name == f'Pc({module})':
                            data['total'] = trace_index
                            values[trace_index] = None
                        elif trace_name == f'Pc({module}_leakage)':
                            data['leakage'] = trace_index
                            values[trace_index] = None
                        elif trace_name == f'Pc({module}_internal)':
                            data['internal'] = trace_index
                            values[trace_index] = None
                        elif trace_name == f'Pc({module}_switching)':
                            data['switching'] = trace_index
                            values[trace_index] = None

                else:
                    raise RuntimeError('Unsupported directive.')
            
            except Exception as e:
                logging.error(f'Exception on {name} directive: {e}')

        elif entry_type == 'time':
            next_time, = data

            while next_time > curr_time:
                for target, data in target_data.items():
                    row = [curr_time,
                        values[data['total']],
                        values[data['leakage']],
                        values[data['internal']],
                        values[data['switching']]]
                    
                    data['csv_writer'].writerow(row)

                curr_time += interval

            logging.info(f'Time: {curr_time}')

        elif entry_type == 'value':
            index, value = data

            if index in values:
                values[index] = value

        else:
            logging.error(f'Unsupported entry type: {entry_type}')


def setup_log(log_path):
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)

    formatter = logging.Formatter('%(levelname)s: %(message)s')

    stdout_handler = logging.StreamHandler(sys.stdout)
    stdout_handler.setFormatter(formatter)
    logger.addHandler(stdout_handler)

    file_handler = logging.FileHandler(log_path, mode='w')
    file_handler.setFormatter(formatter)    
    logger.addHandler(file_handler)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=
        'Power Linker computes the final power flow outputs.')

    parser.add_argument('waveform', type=Path,
        help='PrimePower waveform path.')
    parser.add_argument('interval', type=float,
        help='PrimePower waveform interval [ps]')
    #parser.add_argument('start_time', type=float,
    #    help='PrimePower waveform start_time [ns]')
    parser.add_argument('-o', '--output', type=Path,
        help='Output directory path.')
    parser.add_argument('-t', '--targets', nargs='+', type=str, default=[],
        help='<name>:<module>')

    args = parser.parse_args()
    
    waveform_path = args.waveform
    interval = args.interval
    start_time = 0
    output_path = args.output
    targets = [arg.split(':') for arg in args.targets]

    if not output_path:
        output_path = Path('.')

    output_path.mkdir(parents=True, exist_ok=True)

    log_path = output_path / 'power_linker.log'

    setup_log(log_path)

    logging.info(f'Starting power_linker.py')

    power_linker(waveform_path, start_time, interval, output_path, targets)

