
.text
.globl _start 
_start:
@使得CPU进入system 模式

	mrs	r0,cpsr
	bic	r0,r0,#0x1f
	orr	r0,r0,#0x11
	msr	cpsr,r0
	ldr sp,=0x33040000    @设置FIQ模式的栈

	mrs	r0,cpsr
	bic	r0,r0,#0x1f
	orr	r0,r0,#0x12
	msr	cpsr,r0
	ldr sp,=0x33080000    @设置irq模式的栈

	mrs	r0,cpsr
	bic	r0,r0,#0x1f
	orr	r0,r0,#0x13
	msr	cpsr,r0
	ldr sp,=0x330C0000    @设置管理模式的栈

	mrs	r0,cpsr
	bic	r0,r0,#0x1f
	orr	r0,r0,#0x17
	msr	cpsr,r0
	ldr sp,=0x33100000    @设置终止模式的栈


	mrs	r0,cpsr
	bic	r0,r0,#0x1f
	orr	r0,r0,#0x1B
	msr	cpsr,r0
	ldr sp,=0x33140000    @设置未定义模式的栈

	mrs	r0,cpsr
	bic	r0,r0,#0x1f
	orr	r0,r0,#0x1F
	msr	cpsr,r0
	ldr sp,=0x33180000    @设置系统模式的栈

	mrs	r0,cpsr
	bic	r0,r0,#0x1f
	orr	r0,r0,#0x13
	msr	cpsr,r0			 @开始必须工作再管理模式下面

@清除BSS段
	ldr	r0, _bss_start		/* find start of bss segment        */
	ldr	r1, _bss_end		/* stop here                        */
	mov 	r2, #0x00000000		/* clear                            */
clbss_l:
	str	r2, [r0]		/* clear loop...                    */
	add	r0, r0, #4
	cmp	r0, r1
	ble	clbss_l
	
    bl main


.globl _bss_start
_bss_start:
	.word __bss_start

.globl _bss_end
_bss_end:
	.word _end


.align  5
.globl _vector,_vectorend
_vector:	
	b       _start
	ldr	pc, _undefined_instruction
	ldr	pc, _software_interrupt
	ldr	pc, _prefetch_abort
	ldr	pc, _data_abort
	ldr	pc, _not_used
	ldr	pc, _irq
	ldr	pc, _fiq
_undefined_instruction:	.word undefined_instruction
_software_interrupt:	.word software_interrupt
_prefetch_abort:	    .word prefetch_abort
_data_abort:		    .word data_abort
_not_used:		        .word not_used
_irq:			        .word irq
_fiq:			        .word fiq
_vectorend:




.macro portSAVE_CONTEXT 

@ Push R0 as we are going to use the register. 					
STMDB	SP!, {R0}

@ Set R0 to point to the task stack pointer. 					
STMDB	SP, {SP}^
NOP
SUB		SP, SP, #4
LDMIA	SP!, {R0}

@ Push the return address onto the stack. 						
STMDB	R0!, {LR}

@ Now we have saved LR we can use it instead of R0. 				
MOV		LR, R0

@ Pop R0 so we can save it onto the system mode stack. 			
LDMIA	SP!, {R0}

@ Push all the system mode registers onto the task stack. 		
STMDB	LR, {R0-LR}^
NOP
SUB		LR, LR, #60

@ Push the SPSR onto the task stack. 							
MRS		R0, SPSR
STMDB	LR!, {R0}

LDR		R0, =ulCriticalNesting 
LDR		R0, [R0]
STMDB	LR!, {R0}

@ Store the new top of stack for the task. 						
LDR		R1, =pxCurrentTCB
LDR		R0, [R1]
STR		LR, [R0]

.endm


 .macro portRESTORE_CONTEXT

@ Set the LR to the task stack. 									
LDR		R1, =pxCurrentTCB
LDR		R0, [R1]
LDR		LR, [R0]

@ The critical nesting depth is the first item on the stack. 	
@ Load it into the ulCriticalNesting variable. 					
LDR		R0, =ulCriticalNesting
LDMFD	LR!, {R1}
STR		R1, [R0]

@ Get the SPSR from the stack. 									
LDMFD	LR!, {R0}
MSR		SPSR_cxsf, R0

@ Restore all system mode registers for the task. 				
LDMFD	LR, {R0-R14}^
NOP

@ Restore the return address. 									
LDR		LR, [LR, #+60]

@ And return - correcting the offset in the LR to obtain the 	
@ correct address. 												
SUBS	PC, LR, #4

.endm



.align  5
undefined_instruction:
	portSAVE_CONTEXT
	portRESTORE_CONTEXT

.align	5
software_interrupt:
	ADD LR,LR,#4   @后面portRESTORE_CONTEXT将LR-4给PC，而swi的LR本身就是实际的需要执行的地址
	portSAVE_CONTEXT
	BL test_my
	BL vTaskSwitchContext
	portRESTORE_CONTEXT
	
.align	5
prefetch_abort:
  b clbss_2

.align	5
data_abort:
	b clbss_2


.align	5
not_used:
	portSAVE_CONTEXT
	portRESTORE_CONTEXT

.align	5
irq:
	portSAVE_CONTEXT
	bl irq_int
	portRESTORE_CONTEXT

.align	5
fiq:
	portSAVE_CONTEXT
	portRESTORE_CONTEXT

.text
clbss_2:
	b clbss_2


