Things to do
============

Here is a list of things you may do if you want to improve this project


Software
--------

* rewrite the UART code to use a tx-buffer and interrupts to empty it


Hardware
--------

* change SoC flip-flops to use an asynchronous reset like the ARM cpu
* add a PLL to make the CPU run faster
* add an APB bus and move the slower peripherals to the bus to speed up the main AHB bus
* rewrite the ROM to accept code from the UART during start
* add interrupts to the GPIO port
