

module tb;
    
    reg sysclk = 1'b0;
    initial forever #10ns sysclk = ~sysclk; //50MHz
    
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
            dut.i_fpga_core.u_rom.load_mem(im64_file);
        end        
    end
    `endif

    wire done;
    wire tx_out;
    wire rx_in;
    wire tx1_out;
    wire rx1_in;
    wire led0;
    wire led1;
    wire led2;
    wire led3;
    
    top dut (
        .clk50M(sysclk),
        .btn0(rst),
        .led({led3,led2,led1,led0}),

        .uart_tx(tx_out),
        .uart_rx(rx_in),
        .j7_32(done), //done
        .j7_34(1'b0), //rst1
        .j7_36(tx1_out), //tx1
        .j7_38(rx1_in)  //rx1
    );
    
    wire rx_valid;
    wire [7:0] rx_data;
    
    uart_rx rx (
        .clk_i(sysclk),
        .rstn_i(~rst),
        .rx_i(tx_out),
        .cfg_div_i(16'd434), //115200@50M
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
        .cfg_div_i(16'd434), //115200@50M
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
        .cfg_div_i(16'd434), //115200@50M
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
    
    always @(posedge done) begin
        repeat(100) @(posedge sysclk);
        $display("[INFO] Simulation Finishes");
        $finish;
    end
    
    always @(posedge led0) $display("[HW] LED0 - On");
    always @(negedge led0) $display("[HW] LED0 - Off");
    always @(posedge led1) $display("[HW] LED1 - On");
    always @(negedge led1) $display("[HW] LED1 - Off"); 
endmodule