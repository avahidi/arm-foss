
#include <stdint.h>

#include "defs.h"
#include "arch.h"

#define STACK_SIZE  1024 * 8

extern uint32_t *__stack_start__, *__stack_end__;

extern void cpu_init_pass_1();
extern void soc_init_pass_1();
extern void cpu_init_pass_2();
extern void soc_init_pass_2();
extern void main();


static void reset_handler()
{
    /* initialize */
    cpu_init_pass_1();
    soc_init_pass_1();

    cpu_init_pass_2();
    soc_init_pass_2();

    /* main */
    main();

    /* done */
    for(;;) {
        soc_ctrl_die();
    }
}


uint32_t vectors[32] __attribute__((section(".vectors"))) =
{
    STACK_SIZE + (uint32_t) & __stack_start__,
    (uint32_t) reset_handler,
    0,
    0,
    0,
    0,
    [EXP_SYSTICK] = (uint32_t) cpu_systick_handler
};
