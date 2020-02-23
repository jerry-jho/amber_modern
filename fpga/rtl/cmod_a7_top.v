module cmod_a7_top (
    input sysclk,
    input [1:0] btn,
    output [1:0] led,
    output led0_b,
    output led0_g,
    output led0_r,
    output uart_rxd_out,
    input  uart_txd_in 
);

    wire clk;
    
    BUFG BUFG_inst (
      .O(clk), // 1-bit output: Clock output
      .I(sysclk)  // 1-bit input: Clock input
    );
    
    wire rst_n = ~btn[0];
    
    a25_fpga_top i_a25_top (
        .clk(clk),
        .rst_n(rst_n),
        .gpio_o(led),
        .gpio_i({btn[1],btn[1]}),
        .tx(uart_rxd_out),
        .rx(uart_txd_in)
    );     
    
    assign {led0_b,led0_g,led0_r} = 3'b111;
    
endmodule
