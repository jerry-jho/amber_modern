

module tb;
    
    reg sysclk = 1'b0;
    initial forever #41.66ns sysclk = ~sysclk; //12MHz
    
    reg rst = 1'b1;
    initial begin
        #112ns rst = 1'b0;
    end
    
 
    string fsdb_name = "top.fsdb";
    reg fsdb_en = 1'b0;
    
    initial begin
        $value$plusargs("FSDB_NAME=%s", fsdb_name);
        $value$plusargs("FSDB_EN=%d", fsdb_en);
        
        $display("===== SIM =====");
        if (fsdb_en) begin
        `ifdef _FSDB
            $fsdbDumpfile(fsdb_name);
            $fsdbDumpvars(0,tb);
		`endif
        end
        repeat(100000) @(posedge sysclk);
		$display("[ERROR] Simulation Timeout");
        $finish;
    end
    
    string im64_file;
    
    `ifndef NETLIST
    initial begin
        if ($value$plusargs("MEM_IN=%s", im64_file)) begin
            $display("[TB] Reading imem = %s",im64_file);
            dut.i_a25_top.u_rom.load_mem(im64_file);
        end        
    end
    `endif
    wire led0_r;
    wire tx_out;
    wire rx_in;
    wire tx1_out;
    wire rx1_in;
    
    
    cmod_a7_top dut (
        .sysclk(sysclk),
        .btn({1'b0,rst}),
        .led(),
        .led0_b(),
        .led0_g(),
        .led0_r(led0_r),
        .uart_rxd_out(tx_out),
        .uart_txd_in(rx_in),
        .pio28(1'b0),
        .pio27(tx1_out),
        .pio26(rx1_in)
    );
    
    wire rx_valid;
    wire [7:0] rx_data;
    
    uart_rx rx (
        .clk_i(sysclk),
        .rstn_i(~rst),
        .rx_i(tx_out),
        .cfg_div_i(16'd104), //115200@12M
        .cfg_en_i(1'b1),
        .cfg_parity_en_i(1'b0),
        .cfg_bits_i(2'b11),
        .busy_o(),
        .err_o(),
        .err_clr_i(1'b0),
        .rx_data_o(rx_data),
        .rx_valid_o(rx_valid),
        .rx_ready_i(1'b1)
    );
    
    always @(negedge sysclk) begin
        if (rx_valid) begin
            $display("[TX] %c (%02X)",rx_data,rx_data);
        end
    end    
    
    wire mtx1_busy;
    reg [7:0] mtx1_data = 'd0;
    reg       mtx1_valid = 'd0;
    
    uart_tx uart_tx1 (
        .clk_i(sysclk),
        .rstn_i(~rst),
        .tx_o(rx1_in),
        .busy_o(mtx1_busy),
        .cfg_div_i(16'd104), //115200@12M
        .cfg_en_i(1'b1),
        .cfg_parity_en_i(1'b0),
        .cfg_bits_i(2'b11),
        .cfg_stop_bits_i(1'b1),
        .tx_data_i(mtx1_data),
        .tx_valid_i(mtx1_valid),
        .tx_ready_o()
    );
    
    
    task mputchar1;
        input [7:0] d;
        begin
            while (mtx1_busy == 1'b1) begin
                @(posedge sysclk);
            end
            mtx1_data = d;
            mtx1_valid = 1'b0;
            @(negedge sysclk);
            mtx1_valid = 1'b1;
            @(negedge sysclk);
            mtx1_valid = 1'b0;
            @(negedge sysclk);
            @(posedge sysclk);    
        end
    endtask
    
    initial begin
        @(negedge rst);
        repeat(1500) @(posedge sysclk);
        
        mputchar1(8'h00);
        mputchar1(8'h00);
        mputchar1(8'hFF);
        mputchar1(8'h00);
        mputchar1(8'h00);
        mputchar1(8'h00);
        mputchar1(8'h00);
        mputchar1(8'h00);        
    end
    
    wire rx1_valid;
    wire [7:0] rx1_data;
    
    uart_rx rx1 (
        .clk_i(sysclk),
        .rstn_i(~rst),
        .rx_i(tx1_out),
        .cfg_div_i(16'd104), //115200@12M
        .cfg_en_i(1'b1),
        .cfg_parity_en_i(1'b0),
        .cfg_bits_i(2'b11),
        .busy_o(),
        .err_o(),
        .err_clr_i(1'b0),
        .rx_data_o(rx1_data),
        .rx_valid_o(rx1_valid),
        .rx_ready_i(1'b1)
    );
    
    always @(negedge sysclk) begin
        if (rx1_valid) begin
            $display("[TX1] %c (%02X)",rx1_data,rx1_data);
        end
    end 
    
    always @(posedge led0_r) begin
        repeat(100) @(posedge sysclk);
        $display("[INFO] Simulation Finishes");
        $finish;
    end

 
endmodule