
#include <stdint.h>

#include "defs.h"
#include "arch.h"




/*****************************************
 * cpu Ctrl
 *****************************************/

struct cpu_scb_ctrl {
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

#define _scb ((volatile struct cpu_scb_ctrl *)CPU_SCB_BASE)

void cpu_scb_init()
{
    printf("CPUID %x\n", _scb->cpuid);
}

/*****************************************
 * cpu nvic
 *****************************************/
struct cpu_nvic_ctrl {
    uint32_t iser;
    uint32_t unused1[31];
    uint32_t icer;
    uint32_t unused2[31];
    uint32_t ispr;
    uint32_t unused3[31];
    uint32_t icpr;
    uint32_t unused4[95];
    uint8_t ipr[32];
};

#define _nvic ((volatile struct cpu_nvic_ctrl *)CPU_NVIC_BASE)

void cpu_nvic_enable(int n, int enable)
{
    if(enable)
        _nvic->iser |= 1UL << n;
    else
        _nvic->icer |= 1UL << n;
}

void cpu_nvic_priority(int n, int prio)
{
    _nvic->ipr[n] = prio;
}


void cpu_nvic_interrupt_enable(int enable)
{
    if(enable)
        __asm__ volatile("cpsie i");
    else
        __asm__ volatile("cpsid i");
}

void cpu_nvic_init()
{
    int i;

    cpu_nvic_interrupt_enable(0);

    for(i = 0; i < 32; i++) {
        cpu_nvic_enable(i, 0);
        cpu_nvic_priority(i, -1);
    }
}



/*****************************************
 * systick
 *****************************************/

struct cpu_systick_ctrl {
    uint32_t unused[4];
    uint32_t ctrl;
    uint32_t reload;
    uint32_t current;
};

#define _systick ((volatile struct cpu_systick_ctrl *)CPU_SYSTICK_BASE)

void cpu_systick_start(int start)
{
    if(start)
        _systick->ctrl |= 1;
    else
        _systick->ctrl &= ~1;
}

void cpu_systick_handler()
{
    printf("SYSTICK HANDLER!\n");
    for(;;);
}

void cpu_systick_init()
{
    cpu_nvic_enable(EXP_SYSTICK, 1);

    _systick->current = 0x1000;
    _systick->reload = 0x10000; /* XXX: compute reload value from core clock */
    _systick->ctrl = 6;
}



/*****************************************
 * memory init
 *****************************************/
extern uint32_t *__rodata_start__, *__rodata_end__, *__data_start__;
extern uint32_t *__bss_start__, *__bss_end__;

void cpu_init_memory()
{
    uint32_t *a, *b, *c;

    /* copy rodata */
    a = (uint32_t *) &__rodata_start__;
    b = (uint32_t *) &__rodata_end__;
    c = (uint32_t *) &__data_start__;
    while(a < b)
        *c++ = *a++;

    /* clear BSS */
    a = (uint32_t *) &__bss_start__;
    b = (uint32_t *) &__bss_end__;
    while(a < b)
        *a++ = 0;
}


/*****************************************
 * cpu init
 *****************************************/

 void cpu_init_pass_1()
 {
     cpu_init_memory();
     cpu_scb_init();
	 cpu_nvic_init();
 }

void cpu_init_pass_2()
{
	cpu_systick_init();
}
