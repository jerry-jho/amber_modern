

module tb;
    
    reg sysclk = 1'b0;
    initial forever #41.66ns sysclk = ~sysclk; //12MHz
    
    reg rst = 1'b1;
    initial begin
        #112ns rst = 1'b0;
    end
    
 
    string fsdb_name = "top.fsdb";
    
    initial begin
        $value$plusargs("FSDB_NAME=%s", fsdb_name);
                  
        $display("===== SIM =====");
        `ifdef _FSDB
            $fsdbDumpfile(fsdb_name);
            $fsdbDumpvars(0,tb);
		`endif
        
        repeat(10000) @(posedge sysclk);
		$finish;
    end
    cmod_a7_top cmod_a7_top (
        .sysclk(sysclk),
        .btn({1'b0,rst}),
        .led(),
        .led0_b(),
        .led0_g(),
        .led0_r(),
        .uart_rxd_out(),
        .uart_txd_in(1'b0)
    );

 
endmodule