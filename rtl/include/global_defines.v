`ifndef _GLOBAL_DEFINES
`define _GLOBAL_DEFINES


`define U_AMBER                 tb.i_a25_top.u_amber_wb

`define U_FETCH                 `U_AMBER.u_fetch
`define U_MMU                   `U_FETCH.u_mmu
`define U_CACHE                 `U_FETCH.u_cache
`define U_COPRO15               `U_AMBER.u_coprocessor
`define U_EXECUTE               `U_AMBER.u_execute
`define U_WB                    `U_AMBER.u_write_back
`define U_REGISTER_BANK         `U_EXECUTE.u_register_bank
`define U_DECODE                `U_AMBER.u_decode
`define U_DECOMPILE             `U_DECODE.u_decompile
`define U_L2CACHE               `U_SYSTEM.u_l2cache
`define U_TEST_MODULE           `U_SYSTEM.u_test_module

`define TB_ERROR_MESSAGE        $display("\nFATAL ERROR in %m @%t",$realtime);
`define TB_DEBUG_MESSAGE        $display("\nDebug in %m @%t",$realtime);
`endif