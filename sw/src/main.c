
#include "defs.h"
#include "hw.h"


/* this overrides the handler in arch/cpu */
void cpu_systick_handler()
{
    static uint8_t val = 0;

    gpio_data_set(val++);
    cpu_systick_ack();
}


int main()
{
    /* GPIO blinker */
    gpio_dir_set(0xFF);
    cpu_systick_start(true);
    cpu_systick_value(1UL << 20);

    /* out and wait fo interrupts */
    return 0;
}
