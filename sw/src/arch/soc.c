
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
    putchar_sim ? soc_ctrl_putchar(c) : soc_uart_write(c);
    return c;
}

/*****************************************
 * uart
 *****************************************/

__weak void soc_uart_handler()
{
    /* deault dummy handler: just disable uart interruts */
    soc_uart_irq_enable(0);
}

void soc_uart_write(int c)
{
    while(!(_uart->status & UART_TX_READY))
        /* wait for uart to accept data */;

    _uart->data = c;
}

bool soc_uart_read(int *c)
{
    if(_uart->status & UART_RX_READY) {
        *c = _uart->data;
        return true;
    }
    return false;
}

void soc_uart_irq_ack(int signals)
{
    if(signals & UART_ERROR_RX)
        _uart->status |= UART_ERROR_RX;
}

void soc_uart_irq_enable(int signals)
{
    uint32_t ctrl = _uart->ctrl;
    ctrl = (ctrl & ~7) | (signals & 7);
    _uart->ctrl = ctrl;

}

int soc_uart_irq_read()
{
    return 7 & _uart->status & _uart->ctrl;
}

static void soc_uart_init()
{
    /* (115200 × 16 × 2^12) ÷ 12000000 = 629.145599968 */
    _uart->clockdiv = 629;
    _uart->status = -1; /* clear all flags */
    _uart->ctrl = 0; /* no irq reasons */

    cpu_nvic_irq_priority(IRQ_UART, 0x80);
    cpu_nvic_irq_enable(IRQ_UART, true);
}

/*****************************************
 * GPIO
 *****************************************/

void soc_gpio_dir_set(uint32_t dir)
{
    _gpio->dir = dir;
}

void soc_gpio_data_set(uint32_t data)
{
    _gpio->data = data;
}

uint32_t soc_gpio_dir_get()
{
    return _gpio->dir;
}

uint32_t soc_gpio_data_get()
{
    return _gpio->data;
}

static void soc_gpio_init()
{
    soc_gpio_dir_set(0);
}

/*****************************************
 * SOC Ctrl
 *****************************************/

void soc_ctrl_die()
{
    _ctrl->die = 0xd1e00d1e;
}

void soc_ctrl_putchar(int c)
{
    _ctrl->putchar = c;
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
    }
}
