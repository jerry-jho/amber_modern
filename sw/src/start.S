	.section .text
	.globl	start 
_start:               
        /* Switch to User Mode */
        /* and unset interrupt mask bits */
        mov     r0, #0x00000000
        teqp    pc, r0 
 
        @ Enable the cache
        
        mov     r0,  #0xffffffff
        mcr	15, 0, r0, cr3, cr0, 0   @ cacheable area
        mov     r0,  #1
        mcr	15, 0, r0, cr2, cr0, 0   @ cache enable
        
        
        @ initialize the stack pointer
        ldr     sp, AdrStack

        @ jump to crtmain
        .extern crtmain
        bl      crtmain
                
        
        
/* stack at top of ddr3 memory space */
AdrStack:  .word  0x8000
