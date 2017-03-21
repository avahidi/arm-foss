Software
========

The ARM code is in the sw/ folder.

Compiler requirements
---------------------

The code uses a number of GGC specific tricks to make things cleaner.
The exception vector is a prime example of that::

    uint32_t vectors[32] __attribute__((section(".vectors"))) =
    {
        [0 ... 31] = (uint32_t) dummy_handler,
        [0] = (uint32_t ) & __initial_msp,
        [1] = (uint32_t) reset_handler,
        [EXP_SYSTICK] = (uint32_t) cpu_systick_handler,
        [EXP_IRQ0 + IRQ_UART] = (uint32_t) soc_uart_handler
    };

This way we can avoid using assembler in the boot code.


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


See the code
~~~~~~~~~~~~

To watch the generated code, run::

   make -C sw show
