module a25_fpga_top (
    input  clk,
    input  rst_n,
    output [1:0] gpio_o,
    input  [1:0] gpio_i,
    output tx,
    input  rx
);

    localparam WB_AW = 32;
    localparam WB_DW = 128;
    localparam WB_SW = WB_DW >> 3;

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
    
    sram_sp_128x2048 u_room (
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
    
    wb_gpio_single  #(
        .MSK(24),
        .GW(2),
        .AW(WB_AW),
        .DW(WB_DW)
    ) u_gpio (
        .clk            ( clk         ),
        .rst_n          ( rst_n       ),
        .gpio_i         ( gpio_i       ),
        .gpio_o         ( gpio_o       ),        
        .i_wb_adr       ( sg_wb_adr    ),
        .i_wb_sel       ( sg_wb_sel    ),
        .i_wb_we        ( sg_wb_we     ),
        .o_wb_dat       ( sg_wb_dat_r  ),
        .i_wb_dat       ( sg_wb_dat_w  ),
        .i_wb_cyc       ( sg_wb_cyc    ),
        .i_wb_stb       ( sg_wb_stb    ),
        .o_wb_ack       ( sg_wb_ack    ),
        .o_wb_err       ( sg_wb_err    )
    );  

    wb_crossbar  #(
        .MSK(24),
        .NS(2),
        .AW(WB_AW),
        .DW(WB_DW)
    ) u_xbar (
        .m_wb_adr({sg_wb_adr,sr_wb_adr}),
        .m_wb_sel({sg_wb_sel,sr_wb_sel}),
        .m_wb_we({sg_wb_we,sr_wb_we}),
        .m_wb_dat_i({sg_wb_dat_r,sr_wb_dat_r}),
        .m_wb_dat_o({sg_wb_dat_w,sr_wb_dat_w}),
        .m_wb_cyc({sg_wb_cyc,sr_wb_cyc}),
        .m_wb_stb({sg_wb_stb,sr_wb_stb}),
        .m_wb_ack({sg_wb_ack,sr_wb_ack}),
        .m_wb_err({sg_wb_err,sr_wb_err}),
    
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
