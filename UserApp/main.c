#include<stdio.h>
#include "FreeRTOS.h"

#include"bsplib.h"
unsigned int k=2;
unsigned char stack[0x100000];
char *p=0;
/*
unsigned int pxCurrentTCB;
unsigned int ulCriticalNesting;
*/

extern unsigned int _vector;
extern unsigned int _vectorend;

static void prvCheckTask2( void * pvParameters ){
	while(1){
		printf("prvCheckTask prvCheckTask2 \n");
		vTaskDelay(4);
	}
}
static void prvCheckTask3( void * pvParameters ){
	while(1){
		printf("prvCheckTask prvCheckTask3 \n");
		vTaskDelay(10);
	}
}

static void idle_task( void * pvParameters ){
	while(1){
	}
}

void test_my(){
	printf("test_my\n");
}

int board_init(void){
	//���¹����ж������?����Rtos��
	unsigned int vector=&_vector;
	unsigned int vectorend=&_vectorend;
	unsigned int count=vectorend-vector;
	memcpy((void *)0, (unsigned char *)&_vector, count);

}


int main(void){
	board_init();
	//__asm volatile ("SWI 0	\n\t");
	xTaskCreate( prvCheckTask2, "Check2", 0x1000, NULL, 2, NULL );
	
	xTaskCreate( prvCheckTask3, "Check3", 0x1000, NULL,3, NULL );

	xTaskCreate( idle_task, "idle_task", 0x1000, NULL, 1, NULL );
	
	
	
	/* Start the scheduler.  From this point on the execution will be under
	the control of the kernel. */
	vTaskStartScheduler();


    while(1);
    return 0;
}
