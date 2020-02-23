module wb_down_bridge #( parameter
    AW  = 32,
    SDW  = 128,
    SSW  = SDW >> 3,
    MDW  = 32,
    MSW  = MDW >> 3,    
) (   
       
    input          [AW-1:0]      i_s_wb_adr,
    input          [SSW-1:0]     i_s_wb_sel,
    input                        i_s_wb_we,
    input          [SDW-1:0]     i_s_wb_dat,
    output         [SDW-1:0]     o_s_wb_dat,
    input                        i_s_wb_cyc,
    input                        i_s_wb_stb,
    output                       o_s_wb_ack,
    output                       o_s_wb_err,
    
    output         [AW-1:0]      o_m_wb_adr,
    output         [SSW-1:0]     o_m_wb_sel,
    output                       o_m_wb_we,
    output         [MDW-1:0]     o_m_wb_dat,
    input          [MDW-1:0]     i_m_wb_dat,
    output                       o_m_wb_cyc,
    output                       o_m_wb_stb,
    input                        i_m_wb_ack,
    input                        i_m_wb_err    
);

    localparam LSDW = $clog2(SDW) - 3;
    localparam LMDW = $clog2(MDW) - 3;
    localparam LSW  = LSDW-LMDW;
    
    wire [LSW-1:0] dsel = i_s_wb_adr [LSDW-1:LMDW];
    
    assign o_m_wb_adr = i_s_wb_adr;
    
    wire [MSW-1:0] sel_mux [0:(1<<LSW)-1];
    wire [MDW-1:0] dat_mux [0:(1<<LSW)-1];
    
    genvar gs;
    generate
        for (gs=0;gs<(1<<LSW);gs=gs+1) begin : bs
            assign sel_mux[gs] = i_s_wb_sel[(gs+1)*MSW:g*MSW];
            assign dat_mux[gs] = i_s_wb_dat[(gs+1)*MDW:g*MDW];
            assign o_s_wb_dat[(gs+1)*MDW:g*MDW] =  i_m_wb_dat;
        end
    endgenerate
    
    assign o_m_wb_sel = sel_mux[dsel];
    assign o_m_wb_dat = dat_mux[dsel];
    
    assign o_m_wb_we  = i_s_wb_we;
    assign o_m_wb_cyc = i_s_wb_cyc;
    assign o_m_wb_stb = i_s_wb_stb;
    
    assign o_s_wb_ack = i_m_wb_ack;
    assign o_s_wb_err = i_m_wb_err;
    
endmodule
    
    
    