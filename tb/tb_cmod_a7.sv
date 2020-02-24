

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
        repeat(10000) @(posedge sysclk);
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
    
    cmod_a7_top dut (
        .sysclk(sysclk),
        .btn({1'b0,rst}),
        .led(),
        .led0_b(),
        .led0_g(),
        .led0_r(led0_r),
        .uart_rxd_out(),
        .uart_txd_in(1'b0)
    );
    
    always @(posedge led0_r) begin
        repeat(100) @(posedge sysclk);
        $finish;
    end

 
endmodule