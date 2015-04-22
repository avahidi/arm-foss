
#include <stdint.h>

#include "defs.h"
#include "arch.h"




/*****************************************
 * SOC Ctrl
 *****************************************/

#define _ctrl ((volatile uint32_t *)SOC_CTRL_BASE)

void soc_ctrl_die()
{
    _ctrl[0] = 0xd1e00d1e;
}

static void soc_ctrl_init()
{

}



/*****************************************
 * uart
 *****************************************/

#define _uart ((volatile uint8_t *) SOC_UART_BASE)

int putchar(int c)
{
    _uart[0] = c;
    return c;
}

static void soc_uart_init()
{

}


/*****************************************
 * soc init
 *****************************************/

 void soc_init_pass_1()
 {
	 soc_ctrl_init();
	 soc_uart_init();
 }

 void soc_init_pass_2()
 {

	/* enable interrupts at this point */
	cpu_nvic_interrupt_enable(1);
 }
