
#include <stdint.h>

#include "defs.h"
#include "hw.h"
#include "hw_private.h"


/*****************************************
 * cpu Ctrl
 *****************************************/

uint32_t cpu_scb_cpuid()
{
    return _scb->cpuid;
}

void cpu_scb_init()
{
}

/*****************************************
 * cpu nvic
 *****************************************/
void cpu_nvic_irq_enable(int irq, bool enable)
{
    if(enable)
        _nvic->iser[0] = _BV(irq);
    else
        _nvic->icer[0] = _BV(irq);
}

void cpu_nvic_irq_priority(int irq, uint8_t prio)
{
    _nvic->ipr[irq] = prio;
}


void cpu_nvic_enable(bool enable)
{
    if(enable)
        __asm__ volatile("cpsie i");
    else
        __asm__ volatile("cpsid i");
}

void cpu_nvic_init()
{
    int i;

    cpu_nvic_enable(false);

    for(i = 0; i < 32; i++) {
        cpu_nvic_irq_enable(i, false);
        cpu_nvic_irq_priority(i, 0xF0);
    }
    cpu_nvic_enable(true);
}



/*****************************************
 * systick
 *****************************************/

void cpu_systick_start(bool start)
{
    if(start)
        _systick->ctrl |= 1;
    else
        _systick->ctrl &= ~1;
}

void cpu_systick_value(uint32_t val)
{
    _systick->reload = val - 12; /* 12 = interrupt latency */
    _systick->current = 0x0000;
}

void cpu_systick_ack()
{
    uint32_t tmp;

    /* remove and re-assert TICKINT */
    tmp = _systick->ctrl;
    _systick->ctrl = tmp & ~_BV(1);
    _systick->ctrl = tmp;

    /* systick interrupt is cleared from SCB, not systick or NVIC */
    _scb->icsr |= _BV(25);
}

/* default systick handler, can be overridden */
__weak void cpu_systick_handler()
{
    cpu_systick_ack();
    printf("tick!\n");
}

void cpu_systick_init()
{
    _systick->ctrl = 6;
}


/*****************************************
 * cpu init
 *****************************************/

 void cpu_init(int pass)
 {
     switch(pass) {
     case 0:
         cpu_scb_init();
         cpu_nvic_init();
         break;
     case 1:
         cpu_systick_init();
         break;
     case 2:
         /* enable interrupts at this point */
         cpu_nvic_enable(true);
         break;
     }
}
