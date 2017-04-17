Performance
===========

Software
--------

Software performance is fine, nothing to see here :)


Hardware
--------

In hardware design performance generally means three things:

* Size (area in ASIC, device usage in FPGA)
* Frequency
* Power usage


Design size
~~~~~~~~~~~

Yosys resource utilization report looks like this::

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

Hence we are using 5468 of the available 7680 cells in our Hx8K FPGA. We are also using 16 of the 32 available memory blocks.
These numbers don't seem to improve during place-and-route.


Compare this to the `NIOS-II <https://en.wikipedia.org/wiki/Nios_II>`_ CPU by Altera (now Intel) which IIRC is 2-3 times smaller and 200-500% faster.
One reason for this may be that the Cortex M0 was designed for ASIC and not FPGA
(I believe ARM does have another CPU optimized for FPGA usage but I have not been able to get my hands on that one yet).


If you are interested about the subject, Altera has a `great paper <http://dl.acm.org/citation.cfm?id=968291>`_ about CPU design for FPGAs.
In particular, the chapter about ALU optimization is a must-read for anyone working
with digital design.


Max frequency
~~~~~~~~~~~~~

You can use the tools to calculate a max frequency estimate::

    make time
    ...
    Total number of logic levels: 49
    Total path delay: 48.87 ns (20.46 MHz)

Hence we can run the system at a frequency around 18-20 MHZ, which is pretty low.
The tool also shows us that this is dictated by the CPU.

Unfortunately we currently don't have the proper tools to improve this.

Power usage
~~~~~~~~~~~

This is an advanced topic and we don't have the right tools to cover it anyway :(
