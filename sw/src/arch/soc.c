
#include <stdint.h>

#include "defs.h"
#include "hw.h"
#include "hw_private.h"


/* putchar() implementation for printf()
 * we can either use real uart or a simulated device
 */
static bool putchar_sim = true;

int putchar(int c)
{
    return putchar_sim ? soc_ctrl_putchar(c) : soc_uart_putchar(c);
}

/*****************************************
 * uart
 *****************************************/

void soc_uart_handler()
{
    /* for now, just disable the irq causes */
    uint32_t status = _uart->status;
    _uart->ctrl &= ~(UART_CTRL_IRQ_ERROR | UART_CTRL_IRQ_RX | UART_CTRL_IRQ_TX);
}

int soc_uart_putchar(int c)
{
    while(_uart->status & UART_STATUS_TX_BUSY)
        /* wait for uart to accept data */;

    _uart->data = c;
    return c;
}

static void soc_uart_init()
{
    /* (115200 × 16 × 2^12) ÷ 12000000 = 629.145599968 */
    _uart->clockdiv = 629;
    _uart->status = -1; /* clear all flags */
    _uart->ctrl = 0; /* no irq reasons */

    cpu_nvic_irq_priority(IRQ_UART, 0x80);
    cpu_nvic_irq_enable(IRQ_UART, false);
}

/*****************************************
 * GPIO
 *****************************************/

void gpio_dir_set(uint32_t dir)
{
    _gpio->dir = dir;
}

void gpio_data_set(uint32_t data)
{
    _gpio->data = data;
}

uint32_t gpio_dir_get()
{
    return _gpio->dir;
}

uint32_t gpio_data_get()
{
    return _gpio->data;
}

static void soc_gpio_init()
{
    gpio_dir_set(0);
}

/*****************************************
 * SOC Ctrl
 *****************************************/

void soc_ctrl_die()
{
    _ctrl->die = 0xd1e00d1e;
}

int soc_ctrl_putchar(int c)
{
    _ctrl->putchar = c;
    return c;
}

static void soc_ctrl_init()
{
    putchar_sim = _ctrl->issim;
}

/*****************************************
 * soc init
 *****************************************/

void soc_init(int pass)
{
    switch(pass) {
    case 0:
        soc_ctrl_init();
        soc_uart_init();
        soc_gpio_init();
        break;
    case 1:
        /* enable interrupts at this point */
        cpu_nvic_enable(true);
        break;
    }
}
