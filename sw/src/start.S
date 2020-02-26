	.section .text
	.globl	start 
_start:             
        /*bsl entry*/
        bl      _bsl_entry
        /*err entry*/
        bl      _err_entry
_entry:
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
_bsl_entry:
        .extern bslmain
        bl      bslmain 
_err_entry:
        .extern _exit
        bl      _exit                 
      
        
AdrStack:  .word  0x1000
