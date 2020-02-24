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
    
    output                      done,
    
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

    localparam ADR_REG_GPIO       = 32'h0; //write: output gpio; read: input gpio;
    localparam ADR_REG_GPS        = 32'h4; //io direction
    localparam ADR_REG_CYCLE      = 32'h8; //cycle couter
    localparam ADR_REG_DONE       = {{(MSK-2){1'b1}},2'b0}; //simulation done 

    reg istat;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) istat <= 1'b1;
        else if (istat == 1'b1 && i_wb_cyc == 1'b1) istat <= 1'b0;
        else if (istat == 1'b0) istat <= 1'b1;
    end
    
    wire CE = i_wb_cyc & istat;
    assign o_wb_ack = ~istat;
    assign o_wb_err = 1'b0;
    
    wire [AW-1:0] addr = i_wb_adr & {MSK{1'b1}};
    
    //REG_RS_GPIO
    reg [GW-1:0] greg;
    wire en_REG_RS_GPIO = (addr == ADR_REG_GPIO);
    
    always @(posedge clk or negedge rst_n)
        if (!rst_n) greg <= 'b0;
        else        greg <= (i_wb_we & CE &en_REG_RS_GPIO) ? i_wb_dat[GW-1:0] : greg;
    
    assign gpio_o = greg;
    
    //REG_RW_GPS
    //TODO
    
    //REG_RO_CYCLE
    reg en_REG_CYCLE = addr == ADR_REG_CYCLE;
    reg [DW-1:0] cycle;
    always @(posedge clk or negedge rst_n)
        if (!rst_n) cycle <= 'b0;
        else        cycle <= cycle + 1;


    
    //REG_DONE
    wire en_REG_DONE = addr[MSK-1:0] == ADR_REG_DONE;
    reg reg_done;
    always @(posedge clk or negedge rst_n)
        if (!rst_n) reg_done <= 'b0;
        else        reg_done <= (i_wb_we & CE & en_REG_DONE);
    
    assign done = reg_done;    
    
    
    assign o_wb_dat = i_wb_cyc ? en_REG_RS_GPIO ? {{(DW-GW){1'b0}},gpio_i} : 
                                 en_REG_CYCLE   ? cycle : 'd0
                               : 'd0;
    
    
    
endmodule
    
    
    