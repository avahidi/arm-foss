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


Peripherals
-----------


CTRL
~~~~

The CTRL is a dummy peripheral to simplify simulation.
It provides the following register:

* 0x000: r/o, reads 1 if this is a simulation
* 0x004: w/o, (simulation only) write to stdout
* 0x008: w/o, (simulation only) write to kill simulation

Only the first one is available in real hardware.

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
