module wb_gpio_single #( parameter
    MSK = 24, //use high 32-24 = 8 for address selection
    GW  = 2,
    AW  = 32,
    DW  = 32,
    SW  = DW >> 3
) (   
    input                       clk,
    input                       rst_n,
    
    input          [GW-1:0]     gpio_i,
    output         [GW-1:0]     gpio_o,
    
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

    reg istat;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) istat <= 1'b1;
        else if (istat == 1'b1 && i_wb_cyc == 1'b1) istat <= 1'b0;
        else if (istat == 1'b0) istat <= 1'b1;
    end
    
    wire CE = i_wb_cyc & istat;
    assign o_wb_ack = ~istat;
    assign o_wb_err = 1'b0;
    
    reg [GW-1:0] greg;
    
    always @(posedge clk or negedge rst_n)
        if (!rst_n) greg <= 'b0;
        else        greg <= (i_wb_we & CE) ? i_wb_dat[GW-1:0] : greg;
    
    assign gpio_o = greg;
    
    assign o_wb_dat = {{(DW-GW){1'b0}},gpio_i};
    
endmodule
    
    
    