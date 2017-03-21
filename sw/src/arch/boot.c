
#include <stdint.h>

#include "defs.h"

#include "hw.h"
#include "hw_private.h"

extern void main();

static void reset_handler()
{
    int i;
    uint32_t *a, *b, *c;

    /* set PSP (MSP is already set) */
    MSR("PSP", &__initial_psp);

    /* initialize memory */

    /* copy rodata */
    a = (uint32_t *) &__data_start__;
    b = (uint32_t *) &__data_end__;
    c = (uint32_t *) &__rodata_end__;
    while(a < b)
        *a++ = *c++;

    /* clear BSS */
    a = (uint32_t *) &__bss_start__;
    b = (uint32_t *) &__bss_end__;
    while(a < b)
        *a++ = 0;


    /* multi-pass cpu and soc initialization */
    for(i = 0; i < 5; i++) {
        cpu_init(i);
        soc_init(i);
    }


    /* main */
    main();

    /* done */
    soc_ctrl_die();

    for(;;)
        __asm__ volatile("wfi");
}

static void dummy_handler()
{
    for(;;)
        ;
}

/* The exception vector at 0x0000_0000 also contains reset
 * address and initial MSP.
 * Thanks to GCC magic we can define this in a simple way.
 */
uint32_t vectors[32] __attribute__((section(".vectors"))) =
{
    [0 ... 31] = (uint32_t) dummy_handler,
    [0] = (uint32_t ) & __initial_msp,
    [1] = (uint32_t) reset_handler,
    [EXP_SYSTICK] = (uint32_t) cpu_systick_handler,
    [EXP_IRQ0 + IRQ_UART] = (uint32_t) soc_uart_handler
};
