The hardware
============

The SoC is basically a CPU connected to an AHB3-Lite bus connected
to a few peripherals (UART, GPIO, CTRL) and memories (ROM, RAM).


Some peripherals also have interrupt outputs which are connected
to CPU irq input:

* irq 0: uart interrupts
* irq 1-15: not used


The memory map
--------------

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
The part at 0xA000_xxxx however is defined by us.


How is the memory map enforced?
-------------------------------

For software, ROM and ROM placement is dictated by the the sw/src/memory.ld file.
All other regions are defined in sw/src/arch/hw_private.h.


In hardware, we decode the AHB address using this::

    // bus address encoder
    reg [2:0]   adrsel;
    always @(*) begin
      casex(cpu_adr_o[31:12])
        20'h0000X: adrsel <= 3'd1; // ROM
        20'h0001X: adrsel <= 3'd2; // RAM
        20'ha0000: adrsel <= 3'd3; // UART
        20'ha0001: adrsel <= 3'd4; // ctrl
        20'ha0002: adrsel <= 3'd5; // gpio
        20'ha0003: adrsel <= 3'd6; // ???
        20'ha0004: adrsel <= 3'd7; // ???
        default: adrsel <= 3'd0;
      endcase
    end


Note that the 0xE000_Exxx is not here since it is handled internally
inside the CPU.


The CTRL peripheral
-------------------

The CTRL is a dummy peripheral to simplify simulation.
It provides the following register:

* 0x0000: r/o, reads 1 if this is a simulation
* 0x0004: w/o, write to stdout
* 0x0008: w/o, write to kill simulation

Only the first one is available in real hardware.
