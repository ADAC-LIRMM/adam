#!/usr/bin/env python3
"""
code-loader is a command-line tool used for loading code onto a target device.
"""

import argparse
import serial

from elftools.elf.elffile import ELFFile
from elftools.elf.constants import SH_FLAGS
from serial.serialutil import SerialException
from struct import calcsize, pack, unpack
from tqdm import tqdm
from zlib import crc32

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

    with open(elf_path, 'rb') as f:
        elf_file = ELFFile(f)
        blocks = build_blocks(elf_file)
        boot_addr = elf_file.header.e_entry

    ser = serial.Serial(serial_port, baud_rate, timeout=1)
    ser.flushInput()

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
    for addr, data in tqdm(blocks, leave=False): 
        perform_with_retry(write_cmd, ser, addr, data)

    print('Verifying.')
    for addr, data in tqdm(blocks, leave=False):
        actual = perform_with_retry(read_cmd, ser, addr, len(data))
        
        if data != actual:
            raise RuntimeError('Verification failed.')

    print('Reseting.')
    perform_with_retry(boot_cmd, ser, boot_addr)

def build_blocks(elf_file):

    size = 256
    blocks = []
    addr = elf_file.header.e_entry

    for section in elf_file.iter_sections():

        if section['sh_type'] != 'SHT_PROGBITS':
            continue

        if ~section['sh_flags'] & SH_FLAGS.SHF_ALLOC:
            continue

        data = section.data()

        while data:
            blocks += [(addr, data[:size])]
            addr += len(data[:size])
            data = data[size:]
            
    return blocks


def write_cmd(ser, addr, data):

    send_struct(ser, '<BB', 
        PHATIC,
        WRITE_CMD
    )

    send_struct(ser, '<QH',
        addr,
        len(data),
        has_crc=True
    )

    if recv_struct(ser, '<B')[0] != ACK:
        raise RuntimeError('NAK received')

    ser.write(data)
    send_struct(ser, '<I', crc32(data))

    if recv_struct(ser, '<B')[0] != ACK:
        raise RuntimeError('NAK received')

def read_cmd(ser, addr, length):

    send_struct(ser, '<BB',
        PHATIC,
        READ_CMD
    )

    send_struct(ser, '<QH',
        addr,
        length,
        has_crc=True
    )

    if recv_struct(ser, '<B')[0] != ACK:
        raise RuntimeError('NAK received')

    data = recv_bytes(ser, length)
    crc = recv_struct(ser, '<I')[0]

    if crc != crc32(data):
        raise RuntimeError('Bad CRC received')

    return data


def boot_cmd(ser, addr):

    send_struct(ser, '<BB', 
        PHATIC,
        BOOT_CMD
    )

    send_struct(ser, '<Q',
        addr,
        has_crc=True
    )

    if recv_struct(ser, '<B')[0] != ACK:
        raise RuntimeError('NAK received')


def send_struct(ser, format_string, *values, has_crc=False):
    
    data = pack(format_string, *values)
    send_bytes(ser, data)

    if has_crc: 
        send_bytes(ser, pack('<I', crc32(data)))


def recv_struct(ser, format_string, has_crc=False):
    
    data = recv_bytes(ser, calcsize(format_string))
    
    values = unpack(format_string, data)

    if has_crc:
        crc_data = recv_bytes(ser, calcsize('<I')) 
        if crc32(data) != unpack('<I', crc_data):
            raise RuntimeError('Bad CRC.')

    return values


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
    parser.add_argument('-b', '--baud-rate', type=int, default=115200,
        help='Serial baud rate.')

    args = parser.parse_args()
    elf_path = args.file
    serial_port = args.port
    baud_rate = args.baud_rate

    try:
        code_loader(elf_path, serial_port, baud_rate)
        print('\033[92mSuccess!\033[0m')
    except (RuntimeError, SerialException) as e:
        print(f'\033[91m{str(e)}\033[0m')
