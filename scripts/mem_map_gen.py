#!/usr/bin/env python3

"""
mem_map_gen is a command-line tool that generates a human-friendly C header
file with a memory map of the architecture.
"""

import argparse
import os
import subprocess
import sys

from datetime import datetime

header_template = """
/*
 * ============================================================================
 * ADAM - {file_name}
 * ============================================================================
 *
 * This header was auto-generated using mem_map_gen.py.
 *
 * Date   : {date}
 * Commit : {commit}
 * 
 * Parameters : 
 *   data_width : {data_width}
 *   gpio_width : {gpio_width}
 *   no_mems    : {no_mems}
 *   no_gpios   : {no_gpios}
 *   no_spis    : {no_spis}
 *   no_timers  : {no_timers}
 *   no_uarts   : {no_uarts}
 *   no_cpus    : {no_cpus}
 *   no_lpus    : {no_lpus}
 *
 * Modification of this file is not recommended. 
 * ============================================================================
 */
"""

class Flag:
    def __init__(self, name, size=1):
        self.name = name
        self.size = size

class Register:
    def __init__(self, name, size=1, read_only=False):
        self.name = name
        self.size = size
        self.read_only = read_only if name else True
        self.flags = []

    def add(self, flag):
        self.flags += [flag]

class Peripheral:
    def __init__(self, name):
        self.name = name
        self.regs = []
    
    def add(self, reg):
        self.regs += [reg]

class CodeWritter:
    def __init__(self):
        self.content = ''
        self.indent = 0

    def put(self, line):
        self.content += 4*self.indent*' ' + line + '\n'

    def skip(self, num=1):
        self.content += num*'\n'

def build_sysctrl(
    no_mems=3,
    no_gpios=4,
    no_spis=1,
    no_timers=1,
    no_uarts=1,
    no_cpus=1,
    no_lpus=1
):   
    cpus = [f'CPU{i}' for i in range(no_cpus)]
    lpus = [f'LPU{i}' for i in range(no_lpus)]
    cores = cpus + lpus

    gpios = [f'GPIO{i}' for i in range(no_gpios)]
    spis = [f'SPI{i}' for i in range(no_spis)]
    timers = [f'TIMER{i}' for i in range(no_timers)]
    uarts = [f'UART{i}' for i in range(no_uarts)]
    periphs = ['SYSCTRL'] + gpios + spis + timers + uarts
    no_periphs = len(periphs)

    sysctrl = Peripheral('SYSCTRL')

    sysctrl.add(Register(None, 0x100))

    for x in range(no_mems):
        msrx = Register(f'MSR{x}')
        msrx.add(Flag(f'MSR{x}_P'))
        msrx.add(Flag(f'MSR{x}_S'))
        sysctrl.add(msrx)
    
        sysctrl.add(Register(f'MCR{x}'))
        sysctrl.add(Register(f'MMR{x}'))

    sysctrl.add(Register(None, 0x200 - (0x100 + 3*no_mems)))

    for x in periphs:
        psrx = Register(f'PSR_{x}')
        psrx.add(Flag(f'PSR_{x}_P'))
        psrx.add(Flag(f'PSR_{x}_S'))
        sysctrl.add(psrx)
    
        sysctrl.add(Register(f'PCR_{x}'))
        sysctrl.add(Register(f'PMR_{x}'))

    sysctrl.add(Register(None, 0x400 - (0x200 + 3*no_periphs)))

    for x in cores:
        csrx = Register(f'CSR_{x}')
        csrx.add(Flag(f'CSR_{x}_C'))
        csrx.add(Flag(f'CSR_{x}_S'))
        sysctrl.add(csrx)
    
        sysctrl.add(Register(f'CCR_{x}'))
        sysctrl.add(Register(f'CMR_{x}'))
        sysctrl.add(Register(f'BAR_{x}'))

        ierx = Register(f'IER_{x}')
        for y in range(no_periphs):
            ierx.add(Flag(f'IER_{x}_IE{y}'))    
        sysctrl.add(ierx)

    return sysctrl

def build_gpio(
    gpio_width=16
):
    gpio = Peripheral('GPIO')

    idr = Register('IDR')
    for x in range(gpio_width):
        idr.add(Flag(f'ID{x}'))
    gpio.add(idr)

    odr = Register('ODR')
    for x in range(gpio_width):
        odr.add(Flag(f'OD{x}'))
    gpio.add(odr)

    moder = Register('MODER')
    for x in range(gpio_width):
        moder.add(Flag(f'MODE{x}'))
    gpio.add(moder)
    
    otyper = Register('OTYPER')
    for x in range(gpio_width):
        otyper.add(Flag(f'OTYPE{x}'))
    gpio.add(otyper)

    fsr = Register('FSR', 2)
    for x in range(gpio_width):
        fsr.add(Flag(f'FS{x}', 2))
    gpio.add(fsr)

    ier = Register('IER')
    for x in range(gpio_width):
        ier.add(Flag(f'IE{x}'))
    gpio.add(ier)

    return gpio

def build_spi():
    spi = Peripheral('SPI')
    
    spi.add(Register('DR'))
    
    cr = Register('CR')
    cr.add(Flag('PE'))
    cr.add(Flag('TE'))
    cr.add(Flag('RE'))
    cr.add(Flag('MS'))
    cr.add(Flag('CPHA'))
    cr.add(Flag('CPOL'))
    cr.add(Flag('DO'))
    cr.add(Flag(None))
    cr.add(Flag('DL', 4))
    spi.add(cr)

    sr = Register('SR')
    sr.add(Flag('TBE'))
    sr.add(Flag('RBF'))
    spi.add(sr)

    spi.add(Register('BRR'))

    ier = Register('IER')
    ier.add(Flag('RBFIE'))
    ier.add(Flag('TBEIE'))
    spi.add(ier)

    return spi

def build_timer():
    timer = Peripheral('TIMER')

    cr = Register('CR')
    cr.add(Flag('PE'))
    timer.add(cr)

    timer.add(Register('PR'))
    timer.add(Register('VR'))
    timer.add(Register('ARR'))

    er = Register('ER')
    er.add(Flag('ARE'))
    timer.add(er)

    ier = Register('IER')
    ier.add(Flag('AREIE'))
    timer.add(ier)

    return timer

def build_uart():
    uart = Peripheral('UART')

    uart.add(Register('DR'))

    cr = Register('CR')
    cr.add(Flag('PE'))
    cr.add(Flag('TE'))
    cr.add(Flag('RE'))
    cr.add(Flag('PC'))
    cr.add(Flag('PS'))
    cr.add(Flag('SB'))
    cr.add(Flag(None, 2))
    cr.add(Flag('DL', 4))
    uart.add(cr)

    sr = Register('SR')
    sr.add(Flag('TBE'))
    sr.add(Flag('RBF'))
    uart.add(sr)

    uart.add(Register('BRR'))

    ier = Register('IER')
    ier.add(Flag('TBEIE'))
    ier.add(Flag('RBFIE'))
    uart.add(ier)

    return uart

def write_struct(prph, cw):
    reserved = 0
    rw_dtype = 'reg_t'
    ro_dtype = 'const reg_t'

    cw.put('typedef struct {')
    cw.indent += 1

    for reg in prph.regs:
        dtype = ro_dtype if reg.read_only else rw_dtype

        if not reg.name:
            reg.name = f'reserved{reserved}'
            reserved += 1

        if reg.flags:
            cw.put('union {')
            cw.indent += 1
            
            if reg.size == 1:
                cw.put(f'{dtype} {reg.name};')
            else:
                cw.put(f'{dtype} {reg.name}[{reg.size}];')

            cw.put('struct {')
            cw.indent += 1

            for flag in reg.flags:
                if flag.name:
                    cw.put(f'{dtype} {flag.name} : {flag.size};')
                else:
                    cw.put(f'{dtype} : {flag.size};')

            cw.indent -= 1
            cw.put('};')

            cw.indent -= 1
            cw.put('};')
           
        else:
            if reg.size == 1:
                cw.put(f'{dtype} {reg.name};')
            else:
                cw.put(f'{dtype} {reg.name}[{reg.size}];')

    cw.indent -= 1
    cw.put(f'{"}"} {prph.name}_t;')

def get_commit():
    cwd = os.path.dirname(os.path.abspath(__file__))
    try:
        out = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=cwd)
        return out.decode('utf-8').strip()
    except subprocess.CalledProcessError:
        return "Not a git repository or an error occurred."

def clog2(x):
    if x <= 0:
        raise ValueError("domain error")
    return (x-1).bit_length()

def ahex(x, w):
    return f'0x{x:0{w//4}X}'

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__.strip())
    
    parser.add_argument('-o', '--output', type=str, default='mem_map.h',
        help='output file')
    parser.add_argument('--data-width', type=int, default=32,
        help='data width')
    parser.add_argument('--gpio-width', type=int, default=16,
        help='GPI width')
    parser.add_argument('--no-mems', type=int, default=3,
        help='Number of memory banks')
    parser.add_argument('--no-gpios', type=int, default=4,
        help='Number of GPIOs')
    parser.add_argument('--no-spis', type=int, default=1,
        help='Number of SPIs')
    parser.add_argument('--no-timers', type=int, default=1,
        help='Number of Timers')
    parser.add_argument('--no-uarts', type=int, default=1,
        help='Number of UARTs')
    parser.add_argument('--no-cpus', type=int, default=1,
        help='Number of CPUs')
    parser.add_argument('--no-lpus', type=int, default=1,
        help='Number of LPUs')

    args = parser.parse_args()

    output     = args.output
    data_width = args.data_width
    gpio_width = args.gpio_width
    no_mems    = args.no_mems
    no_gpios   = args.no_gpios
    no_spis    = args.no_spis
    no_timers  = args.no_timers
    no_uarts   = args.no_uarts
    no_cpus    = args.no_cpus
    no_lpus    = args.no_lpus

    no_periphs = 1 + no_gpios + no_spis + no_timers + no_uarts

    dw = data_width

    cw = CodeWritter()

    sysctrl = build_sysctrl(
        no_mems=no_mems,
        no_gpios=no_gpios,
        no_spis=no_spis,
        no_timers=no_timers,
        no_uarts=no_uarts,
        no_cpus=no_cpus,
        no_lpus=no_lpus
    )

    gpio = build_gpio(
        gpio_width=gpio_width
    )
    
    spi = build_spi()
    timer = build_timer()
    uart = build_uart()

    strb_width = clog2(data_width//8)
    file_name = os.path.basename(args.output)
    guard = file_name.upper().replace('.', '_')
    date = datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S UTC')
    cmd = ' '.join(sys.argv)
    commit = get_commit()

    cw.put(header_template.strip().format(
        file_name=output,
        date=date,
        commit=commit,
        data_width=data_width,
        gpio_width=gpio_width,
        no_mems=no_mems,
        no_gpios=no_gpios,
        no_spis=no_spis,
        no_timers=no_timers,
        no_uarts=no_uarts,
        no_cpus=no_cpus,
        no_lpus=no_lpus
    ))
    cw.skip()

    cw.put(f'#ifndef {guard}')
    cw.put(f'#define {guard}')
    cw.skip()

    cw.put(f'typedef volatile unsigned int reg_t;')
    cw.skip()

    for prph in [sysctrl, gpio, spi, timer, uart]:
        write_struct(prph, cw)
        cw.skip(1)

    mems_base  = 0x0400_0000 << strb_width
    periphs_base = 0x0800_0000 << strb_width

    cw.put(f'#define MEMS_BASE  ({ahex(mems_base, dw)})')
    cw.put(f'#define PERIPHS_BASE ({ahex(periphs_base, dw)})')
    cw.skip()

    mems = [f'MEM{i}_BASE' for i in range(no_mems)]
    mem_pad = max([len(m) for m in mems])
    
    for i, m in enumerate(mems):
        offset = (0x0040_0000 << strb_width)*i
        cw.put(f'#define {m:{mem_pad}} (MEMS_BASE + {ahex(offset, dw)})')
    cw.skip()

    periphs = [('SYSCTRL', '')] + \
        [(f'GPIO', i) for i in range(no_gpios)] + \
        [(f'SPI', i) for i in range(no_spis)] + \
        [(f'TIMER', i) for i in range(no_timers)] + \
        [(f'UART', i) for i in range(no_uarts)]

    names = [f'{k}{i}' for k, i in periphs]
    types = [f'{k}_t' for k, i in periphs]
    bases = [f'{n}_BASE' for n in names]
    
    name_pad = max([len(n) for n in names])
    type_pad = max([len(t) for t in types])
    base_pad = max([len(b) for b in bases])
    
    for i, b in enumerate(bases):
        offset = (0x0000_4000 << strb_width)*i
        cw.put(f'#define {b:{base_pad}} (PERIPHS_BASE + {ahex(offset, dw)})')
    cw.skip()
    
    for n, t, b in zip(names, types, bases):
        cw.put(f'#define {n:{name_pad}} (*({t:{type_pad}} *) {b:{base_pad}})')
    cw.skip()

    cw.put(f'#endif')

    with open(args.output, 'w') as file:
        file.write(cw.content)