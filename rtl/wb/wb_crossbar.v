module wb_crossbar #( parameter
    MSK = 24, //use high 32-24 = 8 for address selection
    NS  = 2,
    AW  = 32,
    DW  = 32,
    SW  = DW >> 3
) (
    output      [AW*NS-1:0]     m_wb_adr,
    output      [SW*NS-1:0]     m_wb_sel,
    output         [NS-1:0]     m_wb_we,
    input       [DW*NS-1:0]     m_wb_dat_i,
    output      [DW*NS-1:0]     m_wb_dat_o,
    output         [NS-1:0]     m_wb_cyc,
    output         [NS-1:0]     m_wb_stb,
    input          [NS-1:0]     m_wb_ack,
    input          [NS-1:0]     m_wb_err,
    
    input          [AW-1:0]     s_wb_adr,
    input          [SW-1:0]     s_wb_sel,
    input                       s_wb_we,
    input          [DW-1:0]     s_wb_dat_i,
    output         [DW-1:0]     s_wb_dat_o,
    input                       s_wb_cyc,
    input                       s_wb_stb,
    output                      s_wb_ack,
    output                      s_wb_err                  
);

    localparam SEW = AW - MSK;
    wire [SEW-1:0] addr_select = s_wb_adr[AW-1:MSK];
    
    genvar g;
    generate
        for (g=0;g<NS;g=g+1) begin : g_NS
            wire en = addr_select == g;
            assign m_wb_adr[AW*(g+1)-1:AW*g] = s_wb_adr;
            assign m_wb_sel[SW*(g+1)-1:SW*g] = s_wb_sel;
            assign m_wb_we[g] = en & s_wb_we;
            assign m_wb_dat_o[DW*(g+1)-1:DW*g] = s_wb_dat_i;
            assign m_wb_cyc[g] = en & s_wb_cyc;
            assign m_wb_stb[g] = en & s_wb_stb;
        end
    endgenerate
    
    assign s_wb_err = |m_wb_err;
    assign s_wb_ack = m_wb_ack[addr_select];
    
    wire [NS-1:0] data_rot [DW-1:0];
    
    genvar x,y;
    generate
        for (x=0;x<DW;x=x+1) begin : x_DW   
            for (y=0;y<NS;y=y+1) begin : y_NS
                assign data_rot[x][y] = m_wb_dat_i[y*DW+x];
            end
            assign s_wb_dat_o[x] = |data_rot[x];
        end
    endgenerate
    
endmodule

    
    
    
    
    