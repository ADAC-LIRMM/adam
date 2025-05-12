#!/usr/bin/env python3
"""
code-loader is a command-line tool used for loading code onto a target device.
This version sends the ELF file in blocks similar to gen_rom.py.
Usage:
    code-loader.py <elf_file> [options]
Options:
    -p, --port <port>        Serial port to use (default: /dev/ttyUSB0).
    -b, --baud-rate <rate>   Baud rate for serial communication (default: 115200).
    -h, --help              Show this help message and exit.
"""

import argparse
import serial
from elftools.elf.elffile import ELFFile
from elftools.elf.constants import SH_FLAGS
from serial.serialutil import SerialException
from struct import calcsize, pack, unpack
from tqdm import tqdm

PHATIC = 0x11

ACK = 0x06
NAK = 0x15

WRITE_CMD = 0x00
READ_CMD  = 0x01
BOOT_CMD  = 0x02

def perform_with_retry(func, *args, attempts=10, **kwargs):
    for i in range(attempts):
        try:
            return func(*args, **kwargs)
        except RuntimeError as e:
            tqdm.write(f'\033[91m{str(e)}\033[0m')
    raise RuntimeError('Retry limit exceeded. Task aborted.')

def code_loader(elf_path, serial_port, baud_rate=115200):
    # Open the ELF file and parse it
    with open(elf_path, 'rb') as f:
        elf_file = ELFFile(f)
        blocks = build_blocks(elf_file)  # Process ELF file into memory blocks
        boot_addr = 0x02008000  # Entry point for booting

    # Setup serial communication
    ser = serial.Serial(serial_port, baud_rate, timeout=1)
    ser.flushInput()

    # Wait for phatic response from device
    while True:
        data = ser.read(1)
        if data == bytes([PHATIC]):
            break
        try:
            print(data.decode(), end='')
        except:
            pass
    print()

    print('Writing.')
    send_struct(ser, '<BB', PHATIC, READ_CMD)

    for addr, data in tqdm(blocks, leave=False): 
        actual =(perform_with_retry(read_cmd, ser, addr, len(data)))  # Read initial data
        # print(f'Actual: {actual.hex()}')
        # print(f'Verifying {addr:#x}')
        break
    
    # Write data in blocks
    for addr, data in tqdm(blocks[:-1], leave=False): 
        send_struct(ser, '<BB', PHATIC, WRITE_CMD)
        perform_with_retry(write_cmd, ser, addr, data)
    number_of_errors = 0
    print('Verifying.')
    # Verify written data
    for addr, data in tqdm(blocks[:-1], leave=False):
        send_struct(ser, '<BB', PHATIC, READ_CMD)
        actual = perform_with_retry(read_cmd, ser, addr, len(data))
        # print(f'Verifying {addr:#x}')
        # print(f'Expected: {data.hex()}')
        # print(f'Actual:   {actual.hex()}')
        
        if data != actual:
            print(f'Verifying {addr:#x} failed. Retrying...')
            send_struct(ser, '<BB', PHATIC, WRITE_CMD)
            # print(f'addr: {addr:#x}')
            # print(f'Writing {addr:#x} again.')
            perform_with_retry(write_cmd, ser, addr, data)
            # print(f'Verifying {addr:#x}')
            send_struct(ser, '<BB', PHATIC, READ_CMD)
            actual = perform_with_retry(read_cmd, ser, addr, len(data))
            # print(f'Expected: {data.hex()}')
            # print(f'Actual:   {actual.hex()}')
            number_of_errors += 1 
    print(f'Number of errors: {number_of_errors}')

    print('Resetting.')
    perform_with_retry(boot_cmd, ser, boot_addr)

    print('Receiving data...')
    try:
        while True:
            data = ser.read(ser.in_waiting or 1)
            if data:
                print(data.decode(errors='replace'), end='', flush=True)
    except KeyboardInterrupt:
        print('\nStopped receiving data.')
    finally:
        ser.close()

def build_blocks(elf_file):
    blocks = []

    for segment in elf_file.iter_segments():
        if segment['p_type'] != 'PT_LOAD':  # Only process loadable segments
            continue

        data = segment.data()
        addr = segment['p_paddr']  # Use the segment's physical address
        size = segment['p_filesz']  # Size of the segment in the file
        # Skip segments with no data
        if not data:
            continue
        if size == 0:
            continue
        # Adjust address to start at RAM base (0x02008000)
        addr = 0x02008000 + (addr & 0xFFFFF)

        # Align the address to 4-byte boundaries
        addr = (addr + 3) & ~3
        aligned_size = (size + 3) & ~3
        data = data.ljust(aligned_size, b'\x00')

        # Split data into 16-byte blocks
        for i in range(0, aligned_size, 16):
            block_data = data[i:i + 16]
            if len(block_data) < 16:
                block_data = block_data.ljust(16, b'\x00')
            block_addr = addr + i
            blocks.append((block_addr, block_data))

    return blocks

def write_cmd(ser, addr, data):
    send_struct(ser, '<IH', addr, len(data))  # Send address and length
    # print(f'Writing {addr:#x}...')
    # print(f'Data: {data.hex()}')

    ser.write(data)  # Send the data block

def read_cmd(ser, addr, length):
    send_struct(ser, '<IH', addr, length)  # Send address and length
    data = recv_bytes(ser, length)
    return data

def boot_cmd(ser, addr):
    send_struct(ser, '<BB', PHATIC, BOOT_CMD)  # Send boot command
    send_struct(ser, '<I', addr)  # Send boot address

def send_struct(ser, format_string, *values):
    data = pack(format_string, *values)
    # print(f'Sending: {data.hex()}')
    send_bytes(ser, data)

def recv_struct(ser, format_string):
    data = recv_bytes(ser, calcsize(format_string))
    return unpack(format_string, data)

def send_bytes(ser, data):
    ser.write(data)

def recv_bytes(ser, n):
    data = ser.read(n)
    if len(data) != n:
        raise RuntimeError('Serial timeout error.')
    return data

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__.strip())
    parser.add_argument('file', help='ELF file path.')
    parser.add_argument('-p', '--port', help='Serial port.')
    parser.add_argument('-b', '--baud-rate', type=int, default=115200, help='Serial baud rate.')

    args = parser.parse_args()
    elf_path = args.file
    serial_port = args.port
    baud_rate = args.baud_rate

    try:
        code_loader(elf_path, serial_port, baud_rate)
        print('\033[92mSuccess!\033[0m')
    except (RuntimeError, SerialException) as e:
        print(f'\033[91m{str(e)}\033[0m')
