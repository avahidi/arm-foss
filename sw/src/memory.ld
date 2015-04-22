__page_size__ = 4096;

MEMORY
{
    FLASH (rx) : ORIGIN = 0x00000000, LENGTH = 8K
    SRAM  (rw) : ORIGIN = 0x00010000, LENGTH = 16k
}

ENTRY(_start)

SECTIONS
{
    . = 0K;
    .text : {
        __code_start__ = .;
        *.o (.vectors)
        *.o (.text)
        . = ALIGN(8);
        __code_end__ = .;
    } > FLASH

    .rodata : {
        __rodata_start__ = .;
        *.o (.rodata)
        *.o (.rodata.*)
        . = ALIGN(8);
        __rodata_end__ = .;
    } > FLASH

    /* (initialization data goes in the empty space here) */

    . = 0x00010000;

    /* DATA */
    .data ALIGN( __page_size__ ) : AT(__rodata_end__) SUBALIGN(4) {
        __data_start__ = .;
        *.o  (.data)
        . = ALIGN(8);
        __data_end__ = .;
    } > SRAM


    /* BSS */
    .bss : {
        __bss_start__ = .;
        * (.bss*)
        . = ALIGN(8);
        __bss_end__ = .;
    } > SRAM

    /* stack */
    . = ALIGN(__page_size__);
    __stack_start__ = .;

}
