module sram_sp_128x2048 (   
    input                       clk,
    input                       rst_n,
    
    input          [31:0]     i_wb_adr,
    input          [15:0]     i_wb_sel,
    input                     i_wb_we,
    input          [127:0]    i_wb_dat,
    output         [127:0]    o_wb_dat,
    input                     i_wb_cyc,
    input                     i_wb_stb,
    output                    o_wb_ack,
    output                    o_wb_err                  
);

    wb_sram #(.MW(11),.AW(32),.DW(128)) u_mem (
        .clk            ( clk         ),
        .rst_n          ( rst_n       ),

        .i_wb_adr       ( i_wb_adr    ),
        .i_wb_sel       ( i_wb_sel    ),
        .i_wb_we        ( i_wb_we     ),
        .o_wb_dat       ( o_wb_dat    ),
        .i_wb_dat       ( i_wb_dat    ),
        .i_wb_cyc       ( i_wb_cyc    ),
        .i_wb_stb       ( i_wb_stb    ),
        .o_wb_ack       ( o_wb_ack    ),
        .o_wb_err       ( o_wb_err    )
    );
    
//synopsys translate_off
    task load_mem;
        input string filename;
        begin
            $readmemh(filename,u_mem.mem);
        end
    endtask
//synopsys translate_on    
    
endmodule