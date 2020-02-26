module wb_sram #( parameter
    MW  = 10,
    AW  = 32,
    DW  = 32,
    SW  = DW >> 3
) (   
    input                       clk,
    input                       rst_n,
    
    input          [AW-1:0]     i_wb_adr,
    input          [SW-1:0]     i_wb_sel,
    input                       i_wb_we,
    input          [DW-1:0]     i_wb_dat,
    output         [DW-1:0]     o_wb_dat,
    input                       i_wb_cyc,
    input                       i_wb_stb,
    output                      o_wb_ack,
    output                      o_wb_err                  
);

    localparam MSIZE = 1<<MW;
    reg [DW-1:0] mem [0:MSIZE-1];
    
    localparam WW = $clog2(DW) - 3;
    wire [MW-1:0] mem_addr = i_wb_adr[MW+WW-1:WW];
    
    reg istat;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) istat <= 1'b1;
        else if (istat == 1'b1 && i_wb_cyc == 1'b1) istat <= 1'b0;
        else if (istat == 1'b0) istat <= 1'b1;
    end
    
    wire CE = i_wb_cyc & istat;
    assign o_wb_ack = ~istat;
    assign o_wb_err = 1'b0;
    
    wire [DW-1:0] msk;
    genvar g;
    generate
        for (g=0;g<SW;g=g+1) begin
            assign msk[(g+1)*8-1:g*8] = {8{i_wb_sel[g]}};
        end
    endgenerate

    reg [DW-1:0] tmp;

    always @(posedge clk) begin
        if (CE & i_wb_we) begin
            tmp = mem[mem_addr];
            tmp = tmp & ~msk;
            tmp = tmp | (i_wb_dat & msk);
            mem[mem_addr] <= tmp;
        end
    end
    
    assign o_wb_dat = i_wb_cyc ? mem[mem_addr] : 'd0;

endmodule