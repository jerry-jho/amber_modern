module a25_wbs2axilm #(
    parameter C_AXI_ADDR_WIDTH    =  28,// AXI Address width
    parameter C_AXI_DATA_WIDTH    =  32,// Width of the AXI R&W data
    localparam DW            =  C_AXI_DATA_WIDTH,// Wishbone data width
    localparam AW            =  C_AXI_ADDR_WIDTH// WB addr width (log wordsize)
) (
    input    i_clk,
    input    i_rst_n,
    //
    // AXI write address channel signals
    output                          o_axi_awvalid,
    input                           i_axi_awready,
    output [C_AXI_ADDR_WIDTH-1:0]   o_axi_awaddr,
    output [2:0]                    o_axi_awprot,
    //
    // AXI write data channel signals
    output                          o_axi_wvalid,
    input                           i_axi_wready,
    output [C_AXI_DATA_WIDTH-1:0]   o_axi_wdata,
    output [C_AXI_DATA_WIDTH/8-1:0] o_axi_wstrb,
    //
    // AXI write response channel signals
    input                           i_axi_bvalid,
    output                          o_axi_bready,
    input  [1:0]                    i_axi_bresp,
    //
    // AXI read address channel signals
    output                          o_axi_arvalid,
    input                           i_axi_arready,
    output [C_AXI_ADDR_WIDTH-1:0]   o_axi_araddr,
    output [2:0]                    o_axi_arprot,
    //
    // AXI read data channel signals   
    input                           i_axi_rvalid,
    output                          o_axi_rready,
    input  [C_AXI_DATA_WIDTH-1:0]   i_axi_rdata,
    input  [1:0]                    i_axi_rresp,
    //
    // We'll share the clock and the reset
    input   i_wb_cyc,
    input   i_wb_stb,
    input   i_wb_we,
    input   [(AW-1):0]    i_wb_addr,
    input   [(DW-1):0]    i_wb_data,
    input   [(DW/8-1):0]  i_wb_sel,
    output  o_wb_stall,
    output  o_wb_ack,
    output  [(DW-1):0]    o_wb_data,
    output  o_wb_err
    );

    assign o_axi_wdata = i_wb_data;
    assign o_axi_wstrb = i_wb_sel;

    assign o_wb_stall = 1'b0;

    assign o_axi_awaddr = i_wb_addr;
    assign o_axi_araddr = i_wb_addr;
    
    assign o_axi_awprot = 3'b010;
    assign o_axi_arprot = 3'b010;
    wire  write_transfer;
    wire  read_transfer;

    assign write_transfer = (i_wb_cyc & i_wb_stb) & i_wb_we;
    assign read_transfer  = (i_wb_cyc & i_wb_stb) & !i_wb_we;

    reg awdone, wdone, ardone;
    reg i_axi_bvalid_d;
    
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            awdone <= 0;
            wdone <= 0;
            ardone <= 0;
            i_axi_bvalid_d <= 0;
        end else begin
            i_axi_bvalid_d <= i_axi_bvalid;
            if (awdone & i_axi_bvalid || awdone & i_axi_bvalid_d)
                awdone <= 0;
            else if (write_transfer & i_axi_awready)
                awdone <= 1;

            if (wdone & i_axi_bvalid || wdone & i_axi_bvalid_d)
                wdone <= 0;
            else if (write_transfer & i_axi_wready)
                wdone <= 1;

            if (ardone & i_axi_rvalid)
                ardone <= 0;
            else if (read_transfer & i_axi_arready)
                ardone <= 1;
        end
    end

    assign o_axi_awvalid = write_transfer & !awdone;
    assign o_axi_wvalid = write_transfer & !wdone;
    assign o_axi_arvalid = read_transfer & !ardone;

    assign o_axi_bready = 1;
    assign o_axi_rready = 1;

    wire transfer_done, transfer_success;
    assign transfer_done = i_axi_bvalid | i_axi_rvalid;
    assign transfer_success = (i_axi_bvalid & !i_axi_bresp[1]) |
                             (i_axi_rvalid & !i_axi_rresp[1]);

    assign o_wb_ack = transfer_done & transfer_success;
    assign o_wb_err = transfer_done & !transfer_success;

    assign o_wb_data = i_axi_rdata;

endmodule
