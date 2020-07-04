#include"s3c24x0.h"
#include"s3c2440.h"
#include"bsplib.h"

void enable_interrupts (void)
{
	unsigned long temp;
	__asm__ __volatile__(
#ifdef CONFIG_GTA02_REVISION
			     "mov %0, #0x30000000\n"
			     "mcr p15, 0, %0, c13, c0\n"
#endif
			     "mrs %0, cpsr\n"
			     "bic %0, %0, #0x80\n"
			     "msr cpsr_c, %0\n"
			     : "=r" (temp)
			     :
			     : "memory");
}

int disable_interrupts (void)
{
	unsigned long old,temp;
	__asm__ __volatile__("mrs %0, cpsr\n"
			     "orr %1, %0, #0xc0\n"
			     "msr cpsr_c, %1\n"
#ifdef CONFIG_GTA02_REVISION
			     "mov %1, #0\n"
			     "mcr p15, 0, %1, c13, c0\n"
#endif
			     : "=r" (old), "=r" (temp)
			     :
			     : "memory");
	return (old & 0x80) == 0;
}

void (*interrupt_handle[32])(void)={0};
void request_irq(int irq,void (*pt_fun)(void)){
	S3C24X0_INTERRUPT *interrupt= S3C24X0_GetBase_INTERRUPT();
	if(irq<32){
		
		interrupt_handle[irq]=pt_fun;
		interrupt->INTMSK &= ~(1<<irq);//使能定时器中断
	}
	else
		printf("err irq request\n");
}


void init_interrupt(){
		S3C24X0_INTERRUPT *interrupt= S3C24X0_GetBase_INTERRUPT();
		interrupt->SRCPND = 0xffffffff;//清除中断
		interrupt->INTPND = 0xffffffff;//清除中断
		enable_interrupts();
}


void timer_handle(void){
	printf("timer has a interrupt\n");
}

void timer_init(){
	
	S3C24X0_TIMERS *timer= S3C24X0_GetBase_TIMERS();
	S3C24X0_INTERRUPT *interrupt= S3C24X0_GetBase_INTERRUPT();
	timer->TCFG0 &= ~(0xff);
	timer->TCFG0 |=99;
	
	timer->TCFG1 &=~(0xf);
	timer->TCFG1|=0x02;

	timer->ch[0].TCNTB=62500;
	timer->TCON|=(1<<1);
	timer->TCON=0x09;


	printf(" timer  interrupt init ok\n");
}


void software_int(void){
	printf("software_int\n");
	vTaskSwitchContext();
}

void irq_int(void){
	S3C24X0_INTERRUPT *interrupt= S3C24X0_GetBase_INTERRUPT();
	unsigned char pt=interrupt->INTOFFSET;
	//printf ("interrupt request %x mask(%x)\n",interrupt->INTOFFSET,interrupt->INTMSK);
  	if(interrupt_handle[pt]!=NULL){
		interrupt_handle[pt]();
	}
	interrupt->SRCPND |= (1<<pt);//清除定时器中断
	interrupt->INTPND |= (1<<pt);//清除定时器中断
	printf("irq handle done\n");
}


