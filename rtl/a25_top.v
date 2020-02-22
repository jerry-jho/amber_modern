//A25 top with AXI-Lite Master

module a25_top #(
    parameter AXIL_AW = 32,
    parameter AXIL_DW = 128,
    parameter AXIL_SW = AXIL_DW >> 3
)(
    input                      clk,
    input                      rst_n,
    
    input                      irq,
    input                      firq,
    
    input                      system_rdy,

    output   [AXIL_AW-1:0]     m_axil_awaddr,
    output   [2:0]             m_axil_awprot,
    output                     m_axil_awvalid,
    input                      m_axil_awready,
    
    output   [AXIL_DW-1:0]     m_axil_wdata,
    output   [AXIL_SW-1:0]     m_axil_wstrb,
    output                     m_axil_wvalid,
    input                      m_axil_wready,
    
    input  [1:0]               m_axil_bresp,
    input                      m_axil_bvalid,
    output                     m_axil_bready,
    
    output   [AXIL_AW-1:0]     m_axil_araddr,
    output   [2:0]             m_axil_arprot,
    output                     m_axil_arvalid,
    input                      m_axil_arready,
    
    input  [AXIL_DW-1:0]       m_axil_rdata,
    input  [1:0]               m_axil_rresp,
    input                      m_axil_rvalid,
    output                     m_axil_rready
);

    localparam WB_DW  = AXIL_DW;
    localparam WB_SW  = AXIL_SW;
    localparam WB_AW  = AXIL_AW;


    // Wishbone Master Buses
    wire      [WB_AW-1:0]   m_wb_adr;
    wire      [WB_SW-1:0]   m_wb_sel;
    wire                    m_wb_we;
    wire      [WB_DW-1:0]   m_wb_dat_w;
    wire      [WB_DW-1:0]   m_wb_dat_r;
    wire                    m_wb_cyc;
    wire                    m_wb_stb;
    wire                    m_wb_ack;
    wire                    m_wb_err;
    
    a25_wbs2axilm #(
        .C_AXI_ADDR_WIDTH(AXIL_AW),
        .C_AXI_DATA_WIDTH(AXIL_DW)
	) wbs2axilm (
        .i_clk          (clk),
        .i_rst_n        (rst_n),
        
        .o_axi_awvalid  (m_axil_awvalid),
        .i_axi_awready  (m_axil_awready),
        .o_axi_awaddr   (m_axil_awaddr),
        .o_axi_awprot   (m_axil_awprot),

        .o_axi_wvalid   (m_axil_wvalid),
        .i_axi_wready   (m_axil_wready),
        .o_axi_wdata    (m_axil_wdata),
        .o_axi_wstrb    (m_axil_wstrb),

        .i_axi_bvalid   (m_axil_bvalid),
        .o_axi_bready   (m_axil_bready),
        .i_axi_bresp    (m_axil_bresp),

        .o_axi_arvalid  (m_axil_arvalid),
        .i_axi_arready  (m_axil_arready),
        .o_axi_araddr   (m_axil_araddr),
        .o_axi_arprot   (m_axil_arprot),
        
        .i_axi_rvalid   (m_axil_rvalid),
        .o_axi_rready   (m_axil_rready),
        .i_axi_rdata    (m_axil_rdata),
        .i_axi_rresp    (m_axil_rresp),
        
        .i_wb_cyc       (m_wb_cyc),
        .i_wb_stb       (m_wb_stb),
        .i_wb_we        (m_wb_we),
        .i_wb_addr      (m_wb_adr),
        .i_wb_data      (m_wb_dat_w),
        .i_wb_sel       (m_wb_sel),
        .o_wb_stall     (),
        .o_wb_ack       (m_wb_ack),
        .o_wb_data      (m_wb_dat_r),
        .o_wb_err       (m_wb_err)
	);    
    
    a25_core u_amber_wb (
        .i_clk          ( clk         ),
        .i_rst_n        ( rst_n       ),
        
        .i_irq          ( irq         ),
        .i_firq         ( firq        ),

        .i_system_rdy   ( system_rdy  ),

        .o_wb_adr       ( m_wb_adr   ),
        .o_wb_sel       ( m_wb_sel   ),
        .o_wb_we        ( m_wb_we    ),
        .i_wb_dat       ( m_wb_dat_r ),
        .o_wb_dat       ( m_wb_dat_w ),
        .o_wb_cyc       ( m_wb_cyc   ),
        .o_wb_stb       ( m_wb_stb   ),
        .i_wb_ack       ( m_wb_ack   ),
        .i_wb_err       ( m_wb_err   )
    );    

endmodule
