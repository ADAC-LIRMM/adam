#!/bin/bash

PROGRAM=$1

# -m0x01000000:0x01000000,0x03000000:0x01000000 \

echo "Starting Spike..."
spike --rbb-port=9824 --isa=rv32imfc_zicsr --halted \
    "$PROGRAM" \
    < /dev/null > spike.log 2>&1 &
SPIKE_PID=$!

sleep 1

echo "Starting OpenOCD..."
openocd \
    -c "adapter driver remote_bitbang" \
    -c "remote_bitbang host localhost" \
    -c "remote_bitbang port 9824" \
    -c "set _CHIPNAME riscv" \
    -c "jtag newtap \$_CHIPNAME cpu -irlen 5 -expected-id 0xdeadbeef" \
    -c "set _TARGETNAME \$_CHIPNAME.cpu" \
    -c "target create \$_TARGETNAME riscv -chain-position \$_TARGETNAME" \
    -c "gdb_report_data_abort enable" \
    -c "init" \
    -c "halt" \
    < /dev/null > openocd.log 2>&1 &
OPENOCD_PID=$!

cleanup() {
    echo "Cleaning up..."
    if ps -p $OPENOCD_PID > /dev/null; then
        kill $OPENOCD_PID
        wait $OPENOCD_PID 2>/dev/null
    fi
    if ps -p $SPIKE_PID > /dev/null; then
        kill $SPIKE_PID
        wait $SPIKE_PID 2>/dev/null
    fi
    exit
}

trap cleanup SIGINT SIGTERM EXIT

sleep 1

echo "Starting GDB..."
riscv32-unknown-elf-gdb "$PROGRAM" -ex "target remote localhost:3333"
