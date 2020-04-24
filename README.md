Amber-Modern
============

An ARM processor forked from amber a25 project. https://github.com/Disasm/amber-arm

Quick Start
===========

Hardware
--------

1. A Cmod-A7 FPGA module from Digilent : https://reference.digilentinc.com/reference/programmable-logic/cmod-a7/start

Software
--------

1. MSYS2, Windows 10 WSL or Ubuntu Linux or CentOS Linux, root access for serial port.
2. Vivado WebPACK (cost free from xilinx) (Digilent driver included)
3. Any serial port debug tool, like putty
4. ARM none-eabi compilers, either install from arm.com or like 'apt-get install gcc-arm-none-eabi'. Add the executables into PATH.

Run the demo!
-------------

1. Open Xilinx Hardware Manager and find the Cmod-A7 FPGA
2. Open a serial terminal (putty or minicom) and find the second serial port of Cmod-A7, set the baudrate of 115200.
3. Program cmod_a7.bit (unzipped from board/ca7/release/cmod_a7.zip)
4. You may see Leds blink in turn and serial port prints hello messages. The source code is in /tests/blink_print/app.c

Build and Program applications using UART0
==========================================

Hardware
--------

All hardware from 'Quick Start'

Software
--------

All software from 'Quick Start', and 

1. Python3 with pyserial installed (pip3 install pyserial)

Run the demo!
-------------

1. Open Xilinx Hardware Manager and find the Cmod-A7 FPGA.
2. Close all serial port debuggers to release the serial port, we'll use it later.
3. Program cmod_a7_bls_uart0.bit (unzipped from board/ca7/release/cmod_a7_bls_uart0.zip).
4. Edit the `setenv.csh` or  `setenv.bash`  to setup the directory, and `source` it.
5. To build a test, run `cd simdir && make sw APP=blink`. Here blink is the application name stored in tests/blink.
6. Program the CPU via serial port, run `python3 sw/bin/proj.py -p <serial_port> -f tests/blink/app.mem`. Press the reset button (the one next to the PMod slot) when required, and the programmer will flush the code into instruction memory.
7. Run the application by `python3 sw/bin/proj.py -p <serial_port> -e run`, you will see the leds and the coler leds blink in turn.

Build and Program applications using UART1
==========================================

We know the programmer requires UART0 which is not good for application that also uses UART0.
Therefore we have an alternative method for programming applications.

Hardware
--------

All hardware from 'Quick Start', and

1. A USB-Serial converter, or RS232-TTL converter. A converter with RTS pin is recommended.

Software
--------

All software from 'Quick Start'

Run the demo!
-------------

1. Power off the FPGA before operation. Plug the tx of your serial converter to Cmod-A7 Pin26 (Which is the rx of the chip), rx to Pin27, cts to Pin28 if you have one. Also GND to Pin24.
2. Plug the converter onto your computer, notice its serial number.
1. Open Xilinx Hardware Manager and find the Cmod-A7 FPGA.
2. Serial port debuggers does not have to be closed, especially when your application uses it.
3. Program cmod_a7_bls_uart1.bit (unzipped from board/ca7/release/cmod_a7_bls_uart1.zip).
4. Edit the `setenv.csh` or  `setenv.bash`  to setup the directory, and `source` it
5. To build a test, run `cd simdir && make sw APP=blink`. Here blink is the application name stored in tests/blink.
6. Program the CPU via serial port, run `python3 sw/bin/proj.py -p <converter_serial_port> -f tests/blink/app.mem`. If your serial converter has a cts pin connected, the programming will automatically start. Otherwise, press the reset button (the one next to the PMod slot) when required, and the programmer will flush the code into instruction memory.
7. Run the application by `python3 sw/bin/proj.py -p <converter_serial_port> -e run`, you will see the leds and the coler leds blink in turn. Also you may try the uart_led tests to control the leds by serial port.

What if I have another FPGA?
============================

If you have FPGAs of Xilinx 7-series, make sure you have the followings on your platform:

1. A 12MHz clock (usually from USB-serial chips), or you have the idea on how to generate a 12MHz clock (see `/board/ca7/rtl/top.v` for MMC)
2. Enough GPIO pins for serial, push buttons and leds.

Then create a new board entry in /board. You may copy the original /board/ca7 as start point.

Then modify the followings:

1. `/board/<your_board>/rtl/top.xdc` to re-config the IO bindings.
2. `/board/<your_board>/scripts/platform.tcl` to re-set your FPGA part.

Also you may edit `/board/<your_board>/rtl/top.v` to get your own top, and also `/board/<your_board>/tb/tb.sv` to setup your own testbench.

Then run vivado with:

1. Edit the `setenv.csh` or  `setenv.bash`  to setup the directory, and `source` it.
2. Set A25_BOARD to your board name (the same name in /board directory)
3. Source the vivado settings csh/sh.
4. Run `cd simdir && make vivado APP=blink_print OPTS=-D_NO_BLS_` to generate a cmod_a7.bit similiar in 'Quick Start'.
5. Run `cd simdir && make vivado APP=blink_print OPTS=-D_BLS_UART0_` to generate a cmod_a7_bls_uart0.bit alike.
6. Run `cd simdir && make vivado APP=blink_print` to generate a cmod_a7_bls_uart1.bit alike. You need an extra usb-serial converter.
7. The bit file is in simdir/work_xilinx7_<your_board>/a25.bit, program the bit file using Vivado Hardware Manager and the run demos. 

See A25_BOARD = hsxc7 for board https://item.taobao.com/item.htm?spm=a230r.1.14.4.76c36abazr01v0&id=598068789139&ns=1&abbucket=17#detail














