module a25_fpga_top #(
    parameter real CLK_FREQ = 12
) (
    input  clk,
    input  rst_n,
    output [1:0] gpio_o,
    input  [1:0] gpio_i,
    output tx,
    input  rx,
    output done
);

    localparam WB_AW = 32;
    localparam WB_DW = 128;
    localparam WB_SW = WB_DW >> 3;

    localparam WB_LDW = 32;
    localparam WB_LSW = WB_LDW >> 3;

    wire      [WB_AW-1:0]   m_wb_adr;
    wire      [WB_SW-1:0]   m_wb_sel;
    wire                    m_wb_we;
    wire      [WB_DW-1:0]   m_wb_dat_w;
    wire      [WB_DW-1:0]   m_wb_dat_r;
    wire                    m_wb_cyc;
    wire                    m_wb_stb;
    wire                    m_wb_ack;
    wire                    m_wb_err;
    
    a25_core u_amber_wb (
        .i_clk          ( clk         ),
        .i_rst_n        ( rst_n       ),
        
        .i_irq          ( 1'b0        ),
        .i_firq         ( 1'b0        ),

        .i_system_rdy   ( 1'b1        ),

        .o_wb_adr       ( m_wb_adr    ),
        .o_wb_sel       ( m_wb_sel    ),
        .o_wb_we        ( m_wb_we     ),
        .i_wb_dat       ( m_wb_dat_r  ),
        .o_wb_dat       ( m_wb_dat_w  ),
        .o_wb_cyc       ( m_wb_cyc    ),
        .o_wb_stb       ( m_wb_stb    ),
        .i_wb_ack       ( m_wb_ack    ),
        .i_wb_err       ( m_wb_err    )
    );
    
    wire      [WB_AW-1:0]   sr_wb_adr;
    wire      [WB_SW-1:0]   sr_wb_sel;
    wire                    sr_wb_we;
    wire      [WB_DW-1:0]   sr_wb_dat_w;
    wire      [WB_DW-1:0]   sr_wb_dat_r;
    wire                    sr_wb_cyc;
    wire                    sr_wb_stb;
    wire                    sr_wb_ack;
    wire                    sr_wb_err;
    
    sram_sp_128x2048 u_rom (
        .clk            ( clk         ),
        .rst_n          ( rst_n       ),

        .i_wb_adr       ( sr_wb_adr    ),
        .i_wb_sel       ( sr_wb_sel    ),
        .i_wb_we        ( sr_wb_we     ),
        .o_wb_dat       ( sr_wb_dat_r  ),
        .i_wb_dat       ( sr_wb_dat_w  ),
        .i_wb_cyc       ( sr_wb_cyc    ),
        .i_wb_stb       ( sr_wb_stb    ),
        .o_wb_ack       ( sr_wb_ack    ),
        .o_wb_err       ( sr_wb_err    )
    );
    
    wire      [WB_AW-1:0]   sg_wb_adr;
    wire      [WB_SW-1:0]   sg_wb_sel;
    wire                    sg_wb_we;
    wire      [WB_DW-1:0]   sg_wb_dat_w;
    wire      [WB_DW-1:0]   sg_wb_dat_r;
    wire                    sg_wb_cyc;
    wire                    sg_wb_stb;
    wire                    sg_wb_ack;
    wire                    sg_wb_err;
    
    wire      [WB_AW-1:0]   sgl_wb_adr;
    wire      [WB_LSW-1:0]  sgl_wb_sel;
    wire                    sgl_wb_we;
    wire      [WB_LDW-1:0]  sgl_wb_dat_w;
    wire      [WB_LDW-1:0]  sgl_wb_dat_r;
    wire                    sgl_wb_cyc;
    wire                    sgl_wb_stb;
    wire                    sgl_wb_ack;
    wire                    sgl_wb_err;    
    
    wb_down_bridge #(
        .AW(WB_AW),
        .SDW(WB_DW),
        .MDW(WB_LDW)    
    ) u_sg_bridge (   
        .i_s_wb_adr(sg_wb_adr),
        .i_s_wb_sel(sg_wb_sel),
        .i_s_wb_dat(sg_wb_dat_w),
        .i_s_wb_cyc(sg_wb_cyc),
        .i_s_wb_stb(sg_wb_stb),
        .i_s_wb_we(sg_wb_we),
        .o_s_wb_dat(sg_wb_dat_r),
        .o_s_wb_ack(sg_wb_ack),
        .o_s_wb_err(sg_wb_err),
        
        .o_m_wb_adr(sgl_wb_adr),
        .o_m_wb_sel(sgl_wb_sel),
        .o_m_wb_dat(sgl_wb_dat_w),
        .o_m_wb_cyc(sgl_wb_cyc),
        .o_m_wb_stb(sgl_wb_stb),
        .o_m_wb_we(sgl_wb_we),
        .i_m_wb_dat(sgl_wb_dat_r),
        .i_m_wb_ack(sgl_wb_ack),
        .i_m_wb_err(sgl_wb_err)
    );
    
    wb_gpio_single  #(
        .MSK(24),
        .GW(2),
        .AW(WB_AW),
        .DW(WB_LDW)
    ) u_gpio (
        .clk            ( clk         ),
        .rst_n          ( rst_n       ),
        .gpio_i         ( gpio_i       ),
        .gpio_o         ( gpio_o       ),        
        .i_wb_adr       ( sgl_wb_adr    ),
        .i_wb_sel       ( sgl_wb_sel    ),
        .i_wb_we        ( sgl_wb_we     ),
        .o_wb_dat       ( sgl_wb_dat_r  ),
        .i_wb_dat       ( sgl_wb_dat_w  ),
        .i_wb_cyc       ( sgl_wb_cyc    ),
        .i_wb_stb       ( sgl_wb_stb    ),
        .o_wb_ack       ( sgl_wb_ack    ),
        .o_wb_err       ( sgl_wb_err    ),
        .done           ( done          )
    );  
    
    wire      [WB_AW-1:0]   ss_wb_adr;
    wire      [WB_SW-1:0]   ss_wb_sel;
    wire                    ss_wb_we;
    wire      [WB_DW-1:0]   ss_wb_dat_w;
    wire      [WB_DW-1:0]   ss_wb_dat_r;
    wire                    ss_wb_cyc;
    wire                    ss_wb_stb;
    wire                    ss_wb_ack;
    wire                    ss_wb_err;    
    
    
    wb_uart  #(
        .CLK_FREQ(CLK_FREQ),
        .UART_BAUD(115200),
        .WB_DWIDTH(WB_DW)
    ) i_uart (
        .i_clk(clk),
        .i_rst_n(rst_n),
        .i_wb_adr(ss_wb_adr),
        .i_wb_sel(ss_wb_sel),
        .i_wb_we(ss_wb_we),
        .i_wb_dat(ss_wb_dat_w),
        .i_wb_cyc(ss_wb_cyc),
        .i_wb_stb(ss_wb_stb),
        .o_wb_dat(ss_wb_dat_r),
        .o_wb_ack(ss_wb_ack),
        .o_wb_err(ss_wb_err),
        
        .o_uart_int(),

        .i_uart_cts_n(1'b0),   // Clear To Send
        .o_uart_txd(tx),     // Transmit data
        .o_uart_rts_n(),   // Request to Send
        .i_uart_rxd(rx)      // Receive data
    );

    wb_crossbar  #(
        .MSK(24),
        .NS(3),
        .AW(WB_AW),
        .DW(WB_DW)
    ) u_xbar (
        .m_wb_adr({ss_wb_adr,sg_wb_adr,sr_wb_adr}),
        .m_wb_sel({ss_wb_sel,sg_wb_sel,sr_wb_sel}),
        .m_wb_we({ss_wb_we,sg_wb_we,sr_wb_we}),
        .m_wb_dat_i({ss_wb_dat_r,sg_wb_dat_r,sr_wb_dat_r}),
        .m_wb_dat_o({ss_wb_dat_w,sg_wb_dat_w,sr_wb_dat_w}),
        .m_wb_cyc({ss_wb_cyc,sg_wb_cyc,sr_wb_cyc}),
        .m_wb_stb({ss_wb_stb,sg_wb_stb,sr_wb_stb}),
        .m_wb_ack({ss_wb_ack,sg_wb_ack,sr_wb_ack}),
        .m_wb_err({ss_wb_err,sg_wb_err,sr_wb_err}),
    
        .s_wb_adr(m_wb_adr),
        .s_wb_sel(m_wb_sel),
        .s_wb_we(m_wb_we),
        .s_wb_dat_i(m_wb_dat_w),
        .s_wb_dat_o(m_wb_dat_r),
        .s_wb_cyc(m_wb_cyc),
        .s_wb_stb(m_wb_stb),
        .s_wb_ack(m_wb_ack),
        .s_wb_err(m_wb_err)                    
    );

endmodule
