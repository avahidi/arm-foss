
The ARM FOSS experiment
========================


This is an experiment to see if we can design, test and deploy an ARM Cortex-M0 SoC 
on a FPGA development board using only open source software:

* Verilog simulation: iverilog, gtkwave
* Verilog lint: verilator
* FPGA synthesis: arachne-pnr, icestorm, yosys
* firmware development: GCC for ARM
* Ubuntu 16.04

Note however that within the SoC, the ARM core itself is not open source, and must be licensed from ARM.
Furthermore, we can currently only target the Lattice ICE40 hx8k.



.. image:: gtkwave0.png
    :align: center



Why?
----

The development tools are often a major obstacle to anyone wanting to learn FPGA and ASIC design.
Many are very very expansive and behind the reach of hobbyist
(and many companies for that matter). And while some companies provide free
or cheap tools for selected devices, those come often with a number of serious
issues (e.g. artificial limitations, huge installs, aggressive DRM, non-existing
support, very short licenses with no guarantees for future renewal and last but
not least: software quality is sometimes jaw-dropping low).


But what if you could replace all this with a few quality open source tools
and a few "make" commands?


Why not?
--------

These tools currently lack basic functions such as timing constraints.
If your projects need better control over the process you may need other tools.


In addition, only Lattice iCE40 is fully supported.


Who should use this?
--------------------

Students, teachers, people interested in open source and hardware design.

And if you want to learn by doing, here are a number of suitable tasks for improving this project:

hardware
~~~~~~~~

* change SoC flip-flops to use an asynchronous reset like the ARM cpu
* add a PLL to increase CPU frequency
* add an APB bus and move the slower peripherals to the bus to speed up the main AHB bus
* rewrite the ROM to accept code from the UART during start
* add interrupts to the GPIO port

software
~~~~~~~~

* rewrite the UART code to use a tx-buffer and interrupts to empty it

Usage
=====

1. Make sure you are using Ubuntu 16.04 or newer
2. copy the ARM IP to hw/src/cpu/  (available via the ARM University Program)
3. Then execute::

    make setup # download, build and install required tools

4. Run linter and perform post-synthesis simulation::
    
    make lint  # run verilator linter
    make sim0  # post-synthesis simulation
    make wave0 # see simulation result

5. Once you are happy with your design, you can perform the remaining steps::

    make synth # synthesis
    make sim1  # post-synthesis simulation
    make wave1 # see simulation result

6. Going from source code to bitstream and then programming the board involves these steps::

    make synth   # synthesis
    make par     # place and route
    make program # generate bitstream and flash the board

7. If you need to talk to the board UART::

    make console


Simulation notes
----------------

* Pre-synthesis simulation uses the fixture found in hw/src/sim0
* Post-synthesis simulation uses hw/build/m0.v (generated after synthesis) together with the fixture found in hw/src/sim1

Hardware
========

The SoC contains an AHB3-Lite bus connected to a Cortex-M0, a few peripherals (UART, GPIO, CTRL) and memories (ROM, RAM).
The memory map look like this::


    E000F000 +--------------+
             | CPU internal |
    E000E000 +--------------+
             |              |
    A0003000 +--------------+
             |    GPIO      |
    A0002000 +--------------+
             |    CTRL      |
    A0001000 +--------------+
             |    UART      |
    A0000000 +--------------+
             |              |
    00011000 +--------------+
             |    RAM       |
    00010000 +--------------+
             |              |
    00001000 +--------------+
             |    ROM       |
    00000000 +--------------+


The RAM, ROM and the 0xE000_Exxx regions are set by the ARM specification.
The part at 0xA000_xxxx however is defined by us. The implementation of all this can be found in:


* sw/src/arch/hw_private.h
* sw/src/memory.ld
* hw/src/top.v (the bus address encoder)


The interrupt map is as following:

* irq 0: uart interrupts
* irq 1-15: not used


Peripherals
-----------


CTRL
~~~~

The CTRL is a dummy peripheral to simplify simulation.
It provides the following register:

* 0x000: r/o, reads 1 if this is a simulation
* 0x004: w/o, (simulation only) write to stdout
* 0x008: w/o, (simulation only) write to kill simulation


UART
~~~~

UART is a minimal serial interface with interrupt capabilities.
It provides the following register:

* 0x000: r/w, DATA register

  * read [7:0] to get received data. Read removes RX interrupt
  * write [7:0] to send data (STATUS[2] must be 0))
* 0x004: r/w, CONTROL register

  * [0] r/w, interrupt on RX error
  * [1] r/w, interrupt on RX ready
  * [2] r/w, interrupt on TX ready
* 0x008: r/w, STATUS register

  * [0] r/w, RX error (write 1 to clear)
  * [1] r/o, RX is ready (data received)
  * [2] r/o, TX is ready (can send)
* 0x00c: r/w, CLOCK

  * [11:0] r/w, set to baud rate * 16 * 2^12 / AHB clock (12 MHz)

GPIO
~~~~

GPIO allows the CPU access to the 8 pins connected to Leds D2-D9.
It provides the following register:

* 0x000: r/w: DATA register. bits [7:0] are data bits
* 0x004: r/w: DIR register. bits [7:0] are port direction (1 means output)


Software
========

The software for the ARM core is found in the sw folder. 
In its current form all this code does is to toggle the LEDs at a speed you set from the console (press 0 to 9).

This is used to demonstrate number of things:

* bare metal development using GCC
* Cortex-M initialization without using any standard libraries or assembler
* use of printf() from *bmlib*, connected to the USB-UART
* Use of NVIC for interrupt management

  * use of SysTick to generate periodic interrupts
  * use of UART interrupts to read user input


The code uses a number of GGC-specific tricks to make things simpler.
For example, the exception vector can be written in C instead of assembler thanks to GCC extensions::

    uint32_t vectors[32] __attribute__((section(".vectors"))) =
    {
        [0 ... 31] = (uint32_t) dummy_handler,
        [0] = (uint32_t ) & __initial_msp,
        [1] = (uint32_t) reset_handler,
        [EXP_SYSTICK] = (uint32_t) cpu_systick_handler,
        [EXP_IRQ0 + IRQ_UART] = (uint32_t) soc_uart_handler
    };


Building
--------

To build the software, run::

    make -C sw

This will generate a number of files in sw/build :

* sw.elf - the generated ELF file
* sw.bin - the raw binary of sw.elf
* sw.dis - the disassembled version of sw.elf
* sw.hex - the hex version of sw.bin
* sw0.bin - zero-padded version of sw.bin


The top level make file will copy .bin and .hex files to build/ and renamed to rom.bin (and so on).
These files will be used to populate the SoC ROM during simulation and synthesis.

To browse the generated code, run::

   make -C sw show

Performance
===========

In hardware design performance generally means three things:

* Size (area in ASIC, device usage in FPGA)
* Frequency
* Power usage

The current tools shows you approximate design size and frequency::

    make synth
    ...
    === top_syn ===

     Number of wires:               6015
     Number of wire bits:           8204
     Number of public wires:        1993
     Number of public wire bits:    3761
     Number of memories:               0
     Number of memory bits:            0
     Number of processes:              0
     Number of cells:               5468
       SB_CARRY                      171
       SB_DFF                        147
       SB_DFFE                        35
       SB_DFFER                       67
       SB_DFFES                      549
       SB_DFFR                        56
       SB_DFFS                       155
       SB_LUT4                      4272
       SB_RAM40_4K                    16
    ...
    make time
    ...
    Total number of logic levels: 49
    Total path delay: 48.87 ns (20.46 MHz)


Hence we we are using about 70% of the cells and 50% of the memories and have a maximum frequency of about 20MHz. 
These are not particularly good numbers, mainly because the Cortex-M0 (unlike Cortex-M1) was not `designed for FPGA <http://dl.acm.org/citation.cfm?id=968291>`_.
Unfortunately, to best of my knowledge, we currently don't have the right tools to improve either of these. 


License
=======

This project is released under the GPL version 3, see the LICENSE file for details.



