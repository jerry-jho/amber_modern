ARMGCC_PREFIX=arm-none-eabi-
SDK_ROOT=$(A25_ROOT)/sw


GCC=$(ARMGCC_PREFIX)gcc
LINK=$(ARMGCC_PREFIX)link
OBJDUMP=$(ARMGCC_PREFIX)objdump
OBJCOPY=$(ARMGCC_PREFIX)objcopy

FCOLOR=-fdiagnostics-color=always

INCLUDES=-I. -I$(SDK_ROOT)/include

CFLAGS= -O2 -march=armv2a -mno-thumb-interwork -ffreestanding \
        -g \
        -Wextra -Wall \
        -Wno-unused-parameter \
        -Wno-unused-variable \
        -Wno-unused-function \
        $(FCOLOR) $(DEFINES)
        
LDFLAGS = -Bstatic -Map app.map --strip-debug --fix-v4bx

        
APP=app.c
STARTUP=$(SDK_ROOT)/src/start.S -nostdlib -nostartfiles
LD_SCRIPT=$(SDK_ROOT)/etc/link.ld
MAINSRC=$(SDK_ROOT)/src/sw.c


MEM64=python3 $(SDK_ROOT)/bin/process_mem.py
OUT=app.m64
TEMPMEM=app.mem
BASE=0x0
firmware:
	$(GCC) $(INCLUDES) $(CFLAGS) $(ARCH_IMC) $(APP) $(STARTUP) $(MAINSRC) -T$(LD_SCRIPT) -o app.elf
	$(OBJDUMP) -dx --source app.elf > app.lst
	$(OBJCOPY) -O verilog app.elf app.mem
	$(MEM64) app.mem 128 $(BASE) mem > app.m64
    
elf2m64:
	$(OBJCOPY) -O verilog $(ELF) $(TEMPMEM)
	$(MEM64) $(TEMPMEM) 128 $(BASE) > $(OUT)	
	

