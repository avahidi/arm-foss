
#ifndef _ARCH_H_
#define _ARCH_H_

#include "defs.h"


#define MRS(reg)\
	({ uint32_t x; __asm__ volatile ("mrs %0, " reg : "=r"(x)); x; })

#define MSR(reg, val) \
	do {  __asm__ volatile ("msr " reg ", %0" :: "r"(val)); } while(0)

enum exception_numbers {
	EXP_THREAD = 0,
	EXP_NMI = 2,
	EXM_HARD,
	EXP_SVC = 11,
	EXP_PENDSV = 14,
	EXP_SYSTICK,
	EXP_IRQ0 = 16
};

enum irq_numbers {
    IRQ_UART = 0
};

/* SCB */
extern uint32_t cpu_scb_cpuid();

/* SYSTICK */
extern void cpu_systick_start(bool start);
extern void cpu_systick_value(uint32_t val);
extern void cpu_systick_ack();
extern void cpu_systick_handler();

/* NVIC */
extern void cpu_nvic_enable(bool enable);

extern void cpu_nvic_irq_enable(int irq, bool enable);
extern void cpu_nvic_irq_priority(int irq, uint8_t prio);

/* ctrl */
extern void soc_ctrl_die();

/* UART */
enum  {
    UART_ERROR_RX = 1,
    UART_RX_READY = 2,
    UART_TX_READY = 4
};
extern void soc_uart_irq_ack(int signals);
extern void soc_uart_irq_enable(int signals);
extern int soc_uart_irq_read();
extern void soc_uart_write(int c);
extern bool soc_uart_read(int *c);
extern void soc_uart_handler();

/* gpio */
extern void gpio_dir_set(uint32_t dir);
extern void gpio_data_set(uint32_t data);

extern uint32_t gpio_dir_get();
extern uint32_t gpio_data_get();


#endif /* !_ARCH_H_ */
