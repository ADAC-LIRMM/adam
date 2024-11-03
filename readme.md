when using the HS2, if u get 
Info : auto-selecting first available session transport "jtag". To override use 'transport select <transport>'.
Info : clock speed 1000 kHz
Info : JTAG tap: riscv.cpu tap/device found: 0x249511c3 (mfg: 0x0e1 (Wintec Industries), part: 0x4951, ver: 0x2)
Info : [riscv.cpu] Retry examination.
Info : [riscv.cpu] Examination started.
Info : [riscv.cpu] datacount=2 progbufsize=8
Error: [riscv.cpu] Unable to halt. dmcontrol=0x80010001, dmstatus=0x00000c82
Error: [riscv.cpu] Fatal: Hart 1 failed to halt during examine
Error: [riscv.cpu] Examination failed. examine() -> -4
Info : starting gdb server for riscv.cpu on 3333
Info : Listening on port 3333 for gdb connections
Error: Target not examined yet

then reset ADAM by pressing the reset button, then try again
------------------
For bug reports, read
        http://openocd.org/doc/doxygen/bugs.html
Info : auto-selecting first available session transport "jtag". To override use 'transport select <transport>'.
Error: libusb_claim_interface() failed with LIBUSB_ERROR_BUSY
Error: unable to open ftdi device with description 'Digilent USB Device', serial '*' at bus location '*'
=> Close Vivado hardware manager and make sure no vivado process is running in the background