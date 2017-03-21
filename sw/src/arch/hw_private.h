#ifndef _HW_PRIVATE_H_
#define _HW_PRIVATE_H_

#include "defs.h"

/* defined by ARM */
#define CPU_NVIC_BASE 0xE000E100
#define CPU_SCB_BASE  0xE000ED00
#define CPU_SYSTICK_BASE 0xE000E000

/* defined by our SoC */
#define SOC_UART_BASE 0xA0000000
#define SOC_CTRL_BASE 0xA0001000
#define SOC_GPIO_BASE 0xA0002000


/* from linker script */
extern uint32_t *__initial_msp, *__initial_psp;
extern uint32_t *__rodata_end__, *__data_start__, *__data_end__;
extern uint32_t *__bss_start__, *__bss_end__;

/* SCB */
struct cpu_scb {
    uint32_t cpuid;
    uint32_t icsr;
    uint32_t unused1;
    uint32_t aipcr;
    uint32_t scr;
    uint32_t ccr;
    uint32_t unused2;
    uint32_t shpr2;
    uint32_t shpr3;
};

#define _scb ((volatile struct cpu_scb *)CPU_SCB_BASE)

/* NVIC */
struct cpu_nvic {
    uint32_t iser[32];
    uint32_t icer[32];
    uint32_t ispr[32];
    uint32_t icpr[32];
    uint32_t unused[64];
    uint8_t ipr[32];
};

#define _nvic ((volatile struct cpu_nvic *)CPU_NVIC_BASE)

/* SysTick */

struct cpu_systick {
    uint32_t unused[4];
    uint32_t ctrl;
    uint32_t reload;
    uint32_t current;
};

#define _systick ((volatile struct cpu_systick *)CPU_SYSTICK_BASE)

extern void cpu_systick_handler();

/* UART */
#define UART_CTRL_IRQ_ERROR _BV(0)
#define UART_CTRL_IRQ_RX _BV(1)
#define UART_CTRL_IRQ_TX _BV(2)

#define UART_STATUS_RX_ERROR _BV(0)
#define UART_STATUS_RX_READY _BV(1)
#define UART_STATUS_TX_BUSY  _BV(2)

struct soc_uart {
    uint32_t data;
    uint32_t ctrl;
    uint32_t status; /* write 1 to clear */
    uint32_t clockdiv;
};

#define _uart ((volatile struct soc_uart *) SOC_UART_BASE)

extern int soc_uart_putchar(int c);
extern void soc_uart_handler();

/* GPIO */

struct gpio {
    uint32_t data;
    uint32_t dir;
};

#define _gpio ((volatile struct gpio *) SOC_GPIO_BASE)


/* CTRL */
struct soc_ctrl {
    uint32_t issim;
    uint32_t putchar;
    uint32_t die;
};

#define _ctrl ((volatile struct soc_ctrl *)SOC_CTRL_BASE)

extern int soc_ctrl_putchar(int c);


/* init */
extern void cpu_init(int pass);
extern void soc_init(int pass);
#endif
