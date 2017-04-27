
The M0 experiment
=================

This is an experiment to see if we can design, test and deploy an
ARM Cortex-M0 SoC on a Lattice ICE40 hx8k FPGA development board
using only open source software:

* Verilog simulation: iverilog, gtkwave
* Verilog lint: verilator
* FPGA synthesis: arachne-pnr, icestorm, yosys
* firmware development: GCC for ARM

Note however that within the SoC, the ARM core itself is not open source, and must be licensed from ARM.

Why?
----

The development tools are often a major obstacle to anyone wanting to learn FPGA or ASIC.
Many are very very expansive and behind the reach of hobbyist
(and many companies for that matter). And while some companies provide free
or cheap tools for selected devices, those come often with a number of serious
issues (e.g. artificial limitations, huge installs, aggressive DRM, non-existing
support, very short licenses with no guarantees for future renewal and last but
not least: software quality is sometimes jaw-dropping low).


But what if you could replace all this with a few quality open source tools
and a few "make" commands?


Who should use this?
--------------------

Students, teachers, people interested in open source and hardware design.

See docs/ for more information.

License
-------

GPL version 3, see the LICENSE file for details.
