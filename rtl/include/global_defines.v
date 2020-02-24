`ifndef _GLOBAL_DEFINES
`define _GLOBAL_DEFINES

`define U_WB                     u_write_back
`define U_EXECUTE                u_execute
`define U_REGISTER_BANK         `U_EXECUTE.u_register_bank

`define TB_ERROR_MESSAGE        $display("\nFATAL ERROR in %m @%t",$realtime);
`define TB_DEBUG_MESSAGE        $display("\nDebug in %m @%t",$realtime);
//`define AMBER_UART_DEBUG

`endif