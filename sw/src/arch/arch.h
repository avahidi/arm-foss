
#ifndef _ARCH_H_
#define _ARCH_H_

#include "defs.h"

#define SOC_UART_BASE 0x40000000
#define SOC_CTRL_BASE  0x40010000

#define CPU_NVIC_BASE 0xE000E100
#define CPU_SCB_BASE  0xE000ED00
#define CPU_SYSTICK_BASE 0xE000E000


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
	EXP_IRQ0
};

/* SYSTICK */
extern void cpu_systick_start(int start);
extern void cpu_systick_handler();

/* NVIC */
extern void cpu_nvic_interrupt_enable(int enable);

extern void cpu_nvic_enable(int n, int enable);
extern void cpu_nvic_priority(int n, int prio);

/* ctrl */
extern void soc_ctrl_die();


#endif /* !_ARCH_H_ */
