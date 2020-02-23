

module tb;
    
    reg clk = 1'b0;
    initial forever #5ns clk = ~clk; //100MHz
    
    reg rst_n = 1'b0;
    initial begin
        #112ns rst_n = 1'b1;
    end
    
    reg system_rdy = 1'b0;
    initial begin
        #200ns system_rdy = 1'b1;
    end    
  
    string fsdb_name = "top.fsdb";
    
    initial begin
        $value$plusargs("FSDB_NAME=%s", fsdb_name);
                  
        $display("===== SIM =====");
        `ifdef _FSDB
            $fsdbDumpfile(fsdb_name);
            $fsdbDumpvars(0,tb);
		`endif
        
        repeat(10000) @(posedge clk);
		$finish;
    end
    string im64_file;

    
    logic [63:0] BOOT_ADDR = 'h1000;
    
    logic check_a0 = 0;
    logic [63:0] expect_a0_data;
    logic [63:0] fetch_a0_data;
    `ifndef FPGA
    initial begin
        if ($value$plusargs("MEM_IN=%s", im64_file)) begin
            $display("-- Reading imem = %s",im64_file);
            $readmemh(im64_file,imem.mem);
        end   
        if ($value$plusargs("BOOT_ADDR=%x", BOOT_ADDR)) begin
            
        end
        $display("-- BOOT_ADDR = %016X",BOOT_ADDR);
        if ($value$plusargs("CHECK_A0=%x", expect_a0_data)) begin
            check_a0 = 1'b1;
        end        
    end
    `endif



    `ifndef NETLIST
    /*
    always @(posedge i_ariane_single_core.i_ariane.id_stage_i.decoder_i.ecall) begin
        fetch_a0_data = i_ariane_single_core.i_ariane.instr_tracer_i.gp_reg_file[10];
        $display("-- Exit code %016X",fetch_a0_data);
        if (check_a0) begin
            $display("--------------------------------------");
            if (expect_a0_data === fetch_a0_data)
            $display("                 PASS");    
            else
            $display("        FAIL: Expect: %016X, Get: %016X",expect_a0_data,fetch_a0_data); 
            $display("--------------------------------------");
        end
        repeat(20) @(posedge clk);
        $finish;
    end*/
    `endif
    `ifndef FPGA
    localparam AXI_DATA_WIDTH = 128;
    localparam AXI_ADDR_WIDTH = 32;
    localparam AXI_STRB_WIDTH = (AXI_DATA_WIDTH/8);

    

    wire   [AXI_ADDR_WIDTH-1:0] i_axi_awaddr;
    wire   [2:0]                i_axi_awprot;
    wire                        i_axi_awvalid;
    wire                        i_axi_awready;
    
    wire   [AXI_DATA_WIDTH-1:0] i_axi_wdata;
    wire   [AXI_STRB_WIDTH-1:0] i_axi_wstrb;
    wire                        i_axi_wvalid;
    wire                        i_axi_wready;

    wire   [1:0]                i_axi_bresp;
    wire                        i_axi_bvalid;
    wire                        i_axi_bready;
    
    wire   [AXI_ADDR_WIDTH-1:0] i_axi_araddr;
    wire   [2:0]                i_axi_arprot;
    wire                        i_axi_arvalid;
    wire                        i_axi_arready;
    

    wire   [AXI_DATA_WIDTH-1:0] i_axi_rdata;
    wire   [1:0]                i_axi_rresp;
    wire                        i_axi_rvalid;
    wire                        i_axi_rready;

    
    a25_top i_a25_top (
        .clk(clk),
        .rst_n(rst_n),

        .irq(1'b0),
        .firq(1'b0),
    
        .system_rdy(system_rdy),
    
        .m_axil_awaddr(i_axi_awaddr),
        .m_axil_awprot(i_axi_awprot),
        .m_axil_awvalid(i_axi_awvalid),
        .m_axil_awready(i_axi_awready),
        
        .m_axil_wdata(i_axi_wdata),
        .m_axil_wstrb(i_axi_wstrb),
        .m_axil_wvalid(i_axi_wvalid),
        .m_axil_wready(i_axi_wready),
        
        .m_axil_bresp(i_axi_bresp),
        .m_axil_bvalid(i_axi_bvalid),
        .m_axil_bready(i_axi_bready),
        
        .m_axil_araddr(i_axi_araddr),
        .m_axil_arprot(i_axi_arprot),
        .m_axil_arvalid(i_axi_arvalid),
        .m_axil_arready(i_axi_arready),
        
        .m_axil_rdata(i_axi_rdata),
        .m_axil_rresp(i_axi_rresp),
        .m_axil_rvalid(i_axi_rvalid),
        .m_axil_rready(i_axi_rready)       
    );    
    
    axil_ram #(
        .DATA_WIDTH(AXI_DATA_WIDTH),
        .ADDR_WIDTH(AXI_ADDR_WIDTH),
        .MEM_ADDR_WIDTH(18), //128KB,
        .PIPELINE_OUTPUT(1)
    ) imem (
        .clk(clk),
        .rst_n(rst_n),

        .s_axil_awaddr(i_axi_awaddr),
        .s_axil_awprot(i_axi_awprot),
        .s_axil_awvalid(i_axi_awvalid),
        .s_axil_awready(i_axi_awready),
        
        .s_axil_wdata(i_axi_wdata),
        .s_axil_wstrb(i_axi_wstrb),
        .s_axil_wvalid(i_axi_wvalid),
        .s_axil_wready(i_axi_wready),
        
        .s_axil_bresp(i_axi_bresp),
        .s_axil_bvalid(i_axi_bvalid),
        .s_axil_bready(i_axi_bready),
        
        .s_axil_araddr(i_axi_araddr),
        .s_axil_arprot(i_axi_arprot),
        .s_axil_arvalid(i_axi_arvalid),
        .s_axil_arready(i_axi_arready),
        
        .s_axil_rdata(i_axi_rdata),
        .s_axil_rresp(i_axi_rresp),
        .s_axil_rvalid(i_axi_rvalid),
        .s_axil_rready(i_axi_rready)
    );        
    `endif
    
    `ifdef FPGA
    a25_fpga_top i_a25_top (
        .clk(clk),
        .rst_n(rst_n),
        .gpio_o(),
        .gpio_i(2'b0),
        .tx(),
        .rx()
    );    
    `endif
 
endmodule