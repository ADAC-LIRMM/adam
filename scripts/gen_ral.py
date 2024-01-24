#!/usr/bin/env python3
"""
gen_ral.py is a command-line tool that generates a C header file for
the Register Access Layer (RAL) based on a YAML configuration file generated
by adam.py. This is distinct from the adam.yml file.
"""

import argparse
import os
import subprocess
import sys
import yaml

from datetime import datetime

header_template = """
/*
 * ============================================================================
 * ADAM Register Access Layer (RAL)
 * ============================================================================
 *
 * This header was auto-generated using gen_ral.py.
 *
 * Date   : {date}
 * Target : {target}
 * Branch : {branch}
 * Commit : {commit}
 *
 * It is not recommended to modify this this file. 
 * ============================================================================
 */
"""

class Field:
    def __init__(self, name=None, size=1):
        self.name = name
        self.size = size

class Flag(Field):
    pass

class Group(Field):
    def __init__(self, name=None, size=None):
        super().__init__(name, size)
        self.items = []
    
    def add(self, item):
        self.items += [item]

class Register(Group):
    def __init__(self, name=None, size=None, read_only=False):
        super().__init__(name, size)
        self.read_only = read_only if name else True

class Struct(Group):
    pass

class CodeWritter:
    def __init__(self):
        self.content = ''
        self.indent = 0

    def put(self, line):
        self.content += 4*self.indent*' ' + line + '\n'

    def skip(self, num=1):
        self.content += num*'\n'


def build_syscfg_tgt(name, size=None, en_bar=0, en_ier=0):
    syscfg_tgt = Struct(name, size)

    sr = Register('SR', read_only=True)
    sr.add(Flag(f'P'))
    sr.add(Flag(f'S'))
    syscfg_tgt.add(sr)

    mr = Register('MR')
    mr.add(Flag(f'ACTION', 4))
    syscfg_tgt.add(mr)

    syscfg_tgt.add(Register('BAR' if en_bar else None))
    syscfg_tgt.add(Register('IER' if en_ier else None))

    return syscfg_tgt


def build_syscfg(cfg):
    syscfg = Struct('ral_syscfg_t')

    syscfg.add(build_syscfg_tgt('LSDOM'))
    syscfg.add(build_syscfg_tgt('HSDOM'))
    syscfg.add(build_syscfg_tgt('FAB_LSDOM'))
    syscfg.add(build_syscfg_tgt('FAB_HSDOM'))
    if cfg['en_lspa']:
        syscfg.add(build_syscfg_tgt('FAB_LSPA'))
    if cfg['en_lspb']:
        syscfg.add(build_syscfg_tgt('FAB_LSPB'))
    if cfg['en_lpcpu']:
        syscfg.add(build_syscfg_tgt('LPCPU', en_bar=1, en_ier=1))
    if cfg['en_lpmem']:
        syscfg.add(build_syscfg_tgt('LPMEM'))
    syscfg.add(build_syscfg_tgt('CPU', cfg['no_cpus'], en_bar=1, en_ier=1))
    syscfg.add(build_syscfg_tgt('DMA', cfg['no_dmas'], en_ier=1))
    syscfg.add(build_syscfg_tgt('MEM', cfg['no_mems']))
    
    for lspx in ['lspa', 'lspb']:
        LSPX = lspx.upper()
        s = Struct(LSPX)
        s.add(build_syscfg_tgt(f'GPIO', cfg[f'no_{lspx}_gpios']))
        s.add(build_syscfg_tgt(f'SPI', cfg[f'no_{lspx}_spis']))
        s.add(build_syscfg_tgt(f'TIMER', cfg[f'no_{lspx}_timers']))
        s.add(build_syscfg_tgt(f'UART', cfg[f'no_{lspx}_uarts']))
        syscfg.add(s)
    
    return syscfg


def build_gpio(cfg):
    gpio = Struct('ral_gpio_t')

    idr = Register('IDR')
    for x in range(cfg['gpio_width']):
        idr.add(Flag(f'ID{x}'))
    gpio.add(idr)

    odr = Register('ODR')
    for x in range(cfg['gpio_width']):
        odr.add(Flag(f'OD{x}'))
    gpio.add(odr)

    moder = Register('MODER')
    for x in range(cfg['gpio_width']):
        moder.add(Flag(f'MODE{x}'))
    gpio.add(moder)
    
    otyper = Register('OTYPER')
    for x in range(cfg['gpio_width']):
        otyper.add(Flag(f'OTYPE{x}'))
    gpio.add(otyper)

    fsr = Register('FSR', 2)
    for x in range(cfg['gpio_width']):
        fsr.add(Flag(f'FS{x}', 2))
    gpio.add(fsr)

    ier = Register('IER')
    for x in range(cfg['gpio_width']):
        ier.add(Flag(f'IE{x}'))
    gpio.add(ier)

    return gpio


def build_spi(cfg):
    spi = Struct('ral_spi_t')
    
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


def build_timer(cfg):
    timer = Struct('ral_timer_t')

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


def build_uart(cfg):
    uart = Struct('ral_uart_t')

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


def build_ral_t(cfg):
    ral = Struct('RAL')


def write_register(register, cw):
    rw_dtype = 'ral_data_t'
    ro_dtype = 'const ral_data_t'
    dtype = ro_dtype if register.read_only else rw_dtype

    if register.items:
        cw.put('union {')
        cw.indent += 1
        
        if register.size == None:
            cw.put(f'{dtype} {register.name};')
        else:
            cw.put(f'{dtype} {register.name}[{register.size}];')

        cw.put('struct {')
        cw.indent += 1

        for flag in register.items:
            if flag.name:
                cw.put(f'{dtype} {flag.name} : {flag.size};')
            else:
                cw.put(f'{dtype} : {flag.size};')

        cw.indent -= 1
        cw.put('};')

        cw.indent -= 1
        cw.put('};')
        
    else:
        if register.size == None:
            cw.put(f'{dtype} {register.name};')
        else:
            cw.put(f'{dtype} {register.name}[{register.size}];')


def write_struct(struct, cw, typedef=False):
    if struct.size == 0:
        return
    
    reserved = 0
    cw.put('typedef struct {' if typedef else 'struct {')
    cw.indent += 1

    for item in struct.items:
        if isinstance(item, Struct):
            write_struct(item, cw)

        elif isinstance(item, Register):
            # deep copy it?
            if not item.name:
                item.name = f'reserved{reserved}'
                reserved += 1

            write_register(item, cw)

        else:
            print(type(item))
            raise ValueError()
        
    cw.indent -= 1
    if struct.name:
        if struct.size == None:
            cw.put(f'{"}"} {struct.name};')
        else:
            cw.put(f'{"}"} {struct.name}[{struct.size}];')
            
    else:
        cw.put('};')


def get_git_info():
    cwd = os.path.dirname(os.path.abspath(__file__))
    
    # Get the current branch name
    branch = subprocess.check_output(['git', 'rev-parse', '--abbrev-ref',
        'HEAD'], cwd=cwd)
    branch = branch.decode('utf-8').strip()

    # Get the last commit hash
    commit = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=cwd)
    commit = commit.decode('utf-8').strip()

    # Check if the repository is in a dirty state, ignoring submodules
    if subprocess.check_output(['git', 'status', '--porcelain',
        '--ignore-submodules'], cwd=cwd):
        commit += " (dirty)"

    return branch, commit


def clog2(x):
    if x <= 0:
        raise ValueError("domain error")
    return (x-1).bit_length()

def ahex(x, w):
    return f'0x{x:0{(w+3)//4}X}'

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__.strip())
    parser.add_argument('input', type=str,
        help='Input YAML configuration file.')
    parser.add_argument('-o', '--output', type=str, required=True,
        help='Output C header file.')
    parser.add_argument('-t', '--target', type=str,
        help='The ADAM target.')  

    args = parser.parse_args()

    with open(args.input, 'r') as file:
        cfg = yaml.safe_load(file)

    for lspx in ['lspa', 'lspb']:
        cfg[f'no_{lspx}'] = cfg[f'no_{lspx}_gpios'] + cfg[f'no_{lspx}_spis'] + \
            cfg[f'no_{lspx}_timers'] + cfg[f'no_{lspx}_uarts']

        cfg[f'en_{lspx}'] = cfg[f'no_{lspx}'] > 0

    aw = cfg['addr_width']
    dw = cfg['data_width']

    cw = CodeWritter()

    syscfg = build_syscfg(cfg)
    gpio = build_gpio(cfg)
    spi = build_spi(cfg)
    timer = build_timer(cfg)
    uart = build_uart(cfg)

    strb_width = clog2(dw//8)
    date = datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S UTC')
    branch, commit = get_git_info()
    target = args.target

    cw.put(header_template.strip().format(
        date=date,
        branch=branch,
        commit=commit,
        target=target
    ))
    cw.skip()

    cw.put(f'#pragma once')
    cw.skip()

    cw.put(f'typedef volatile unsigned int ral_data_t;')
    cw.skip()

    for typedef in [syscfg, gpio, spi, timer, uart]:
        write_struct(typedef, cw, typedef=True)
        cw.skip(1)

    ptrs = []
    ptrs += [('ral_data_t', 'LPMEM',  None, cfg['mmap_lpmem'][0], 0)]
    ptrs += [('ral_syscfg_t', 'SYSCFG', None, cfg['mmap_syscfg'][0], 0)]

    for lspx in ['lspa', 'lspb']:
        addr, _, inc = cfg[f'mmap_{lspx}']
        
        LSPX = lspx.upper()

        length = cfg[f'no_{lspx}_gpios']
        ptrs += [('ral_gpio_t', f'{LSPX}_GPIO', length, addr, inc)]
        addr += inc*length

        length = cfg[f'no_{lspx}_spis']
        ptrs += [('ral_spi_t', f'{LSPX}_SPI', length, addr, inc)]
        addr += inc*length

        length = cfg[f'no_{lspx}_timers']
        ptrs += [('ral_timer_t', f'{LSPX}_TIMER', length, addr, inc)]
        addr += inc*length

        length = cfg[f'no_{lspx}_uarts']
        ptrs += [('ral_uart_t', f'{LSPX}_UART', length, addr, inc)]
        addr += inc*length

    addr, _, inc = cfg['mmap_mem']
    ptrs += [('ral_data_t', 'MEM', cfg[f'no_mems'], addr, inc)]
    
    cw.put('static struct {')
    cw.indent += 1
    
    for dtype, name, length, _, _ in ptrs:
        if length == None:
            cw.put(f'{dtype} * const {name};')

        elif length > 0:
            cw.put(f'{dtype} * const {name}[{length}];')

    cw.indent -= 1
    cw.put('} RAL = {')
    cw.indent += 1
    
    for dtype, name, length, addr, inc in ptrs:
        if length == None:
            cw.put(f'.{name} = ({dtype} *) {ahex(addr, aw)},')

        elif length > 0:
            cw.put(f'.{name}' + ' = {')
            cw.indent += 1

            for _ in range(length):
                cw.put(f'({dtype} *) {ahex(addr, aw)},')
                addr += inc

            cw.indent -= 1
            cw.put('},')
            
    cw.indent -= 1
    cw.put('};')

    with open(args.output, 'w') as file:
        file.write(cw.content)