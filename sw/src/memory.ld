__page_size__ = 4096;

MEMORY
{
    ROM  (rx) : ORIGIN = 0x00000000, LENGTH = 4K
    SRAM (rw) : ORIGIN = 0x00010000, LENGTH = 4k
}

ENTRY(_start)

SECTIONS
{
    /* ROM starts here */
    . = 0K;

    .text : {
        __code_start__ = .;
        *.o (.vectors)
        *.o (.text)
        . = ALIGN(8);
        __code_end__ = .;
    } > ROM


    .rodata : {
        __rodata_start__ = .;
        *.o (.rodata)
        *.o (.rodata.*)
        . = ALIGN(8);
        __rodata_end__ = .;
    } > ROM

    /* (initialization data goes in the empty space here) */


    /* RAM starts here */
    . = 0x00010000;

    /* DATA: this section is empty at boot and will be filled
     * with the initial values from ROM (see above)
     */
    .data ALIGN( __page_size__ ) : AT(__rodata_end__) SUBALIGN(4) {
        __data_start__ = .;
        *.o  (.data)
        . = ALIGN(8);
        __data_end__ = .;
    } > SRAM


    /* BSS */
    .bss ALIGN(8) : {
        __bss_start__ = .;
        * (.bss*)
        . = ALIGN(8);
        __bss_end__ = .;
    } > SRAM

    /* stack */
    . = ALIGN(8);
    . += 1024;
    __initial_msp = .;
    . += 1024;
    __initial_psp = .;


}
