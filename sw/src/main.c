
#include "defs.h"
#include "hw.h"

static uint32_t gpio_add = 1;
static uint32_t gpio_val = 0;

/* these two handlers overrides default handlers in arch */
void cpu_systick_handler()
{
    gpio_val += gpio_add;
    soc_gpio_data_set(gpio_val >> 8);
    cpu_systick_ack();
}

void soc_uart_handler()
{
    int signals, c;

    signals = soc_uart_irq_read();

    /* RX error */
    if(signals & UART_ERROR_RX) {
        soc_uart_irq_ack(true);
    }

    /* RX ready */
    if((signals & UART_RX_READY) && soc_uart_read(&c)) {
        if(c >= '0' && c <= '9')
            gpio_add = c - '0';
    }

    /* TX ready */
    if(signals & UART_TX_READY) {
        /* TODO */
    }
}


int main()
{
    /* uart RX intterrupts */
    soc_uart_irq_enable(UART_RX_READY);

    /* GPIO blinker */
    soc_gpio_dir_set(0xFF);
    cpu_systick_start(true);
    cpu_systick_value(1UL << 16);

    /* print some debug information */
    printf("CPUID %x\n", cpu_scb_cpuid());

    /* out and wait fo interrupts */
    return 0;
}
