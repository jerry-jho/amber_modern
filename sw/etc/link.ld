ENTRY(main)


SECTIONS {

    . = 0x0;
                        
	.text   : {  start*(.text); *(.text); }
        
	.data : { *(.data); }

	.rodata : { *(.rodata); }
        
 	.bss : { *(.bss); }

	.stack : { __stack = . ; }
    
    . = 0x7800;
    
    .xinit : { *(.xinit); }

}