CC =/work/opt/arm-linux-gcc-4.4.3/bin/arm-linux-gcc
OBJCOPY =/work/opt/arm-linux-gcc-4.4.3/bin/arm-linux-objcopy
LD =/work/opt/arm-linux-gcc-4.4.3/bin/arm-linux-ld
OBJDUMP =/work/opt/arm-linux-gcc-4.4.3/bin/arm-linux-objdump

LIB_PATH +=/work/opt/arm-linux-gcc-4.4.3/lib/gcc/arm-none-linux-gnueabi/4.4.3

INCLDUE_DIR += -I. -I./BspLib/include -I./OS/include -I./UserApp/include \
			/work/opt/arm-linux-gcc-4.4.3/arm-none-linux-gnueabi/sys-root/usr/include

CFLAGS=$(INCLDUE_DIR) -g  -fno-builtin    \
        -msoft-float -O1

LDFLAGS =  -T rt_os.lds -L  $(LIB_PATH) -lgcc -static

BSP_DIR = BspLib
OS_DIR = OS
USER_DIR = UserApp

SRC	= \
$(BSP_DIR)/start.s \
$(BSP_DIR)/serial.c \
$(BSP_DIR)/string.c \
$(BSP_DIR)/vsprintf.c \
$(BSP_DIR)/ctype.c \
$(BSP_DIR)/interrupt.c \
$(USER_DIR)/main.c \
$(OS_DIR)/heap_1.c \
$(OS_DIR)/tasks.c \
$(OS_DIR)/list.c \
$(OS_DIR)/port.c \
$(OS_DIR)/portISR.c \

# Define all object files.

OBJ = $(SRC:%.c=build/%.o)
OBJS = $(OBJ:%.s=build/%.o)


build/app.bin: setenv   build/app.elf 
	$(OBJCOPY) -O binary build/app.elf  $@ 
	$(OBJDUMP)  -d build/app.elf  > build/app.dis

build/app.elf :  $(OBJS)
	$(LD)  $(OBJS) $(LDFLAGS) -o $@ 

build/%.o : %.s 
	$(CC) $(CFLAGS) -c $< -o $@ 

build/%.o : %.c  
	$(CC)  $(CFLAGS) -c $< -o $@ 


setenv:
	echo "set current enviroment"
	mkdir -p build
	mkdir -p build/BspLib
	mkdir -p build/OS
	mkdir -p build/OS/common
	mkdir -p build/UserApp

clean:
	rm -fr build/*




	



