OUTPUT_FORMAT("elf32-littlearm", "elf32-littlearm", "elf32-littlearm")
OUTPUT_ARCH(arm)
ENTRY(_start)
SECTIONS
{
	. = 0x30008000;     
	. = ALIGN(4);         
	.text :               
	{
        build/BspLib/start.o (.text)   
        *(.text)          
	}
	  . = ALIGN(4); 
      .rodata : { *(.rodata) } 
      . = ALIGN(4);
      .data : { *(.data) }    
	  . = ALIGN(4);
      __bss_start = . ;      
      .bss : { *(.bss) }  
      _end = . ;           
}