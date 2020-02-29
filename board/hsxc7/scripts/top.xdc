## 50 MHz Clock Signal

create_clock -add -name sys_clk_pin -period 20 -waveform {0 10} [get_ports {clk50M}];

## Clocks

set_property -dict { PACKAGE_PIN D4   IOSTANDARD LVCMOS33 } [get_ports { clk50M }];

## LEDs
set_property -dict { PACKAGE_PIN K12   IOSTANDARD LVCMOS33 } [get_ports { led[0] }];
set_property -dict { PACKAGE_PIN L14   IOSTANDARD LVCMOS33 } [get_ports { led[1] }]; 
set_property -dict { PACKAGE_PIN L13   IOSTANDARD LVCMOS33 } [get_ports { led[2] }];
set_property -dict { PACKAGE_PIN M14   IOSTANDARD LVCMOS33 } [get_ports { led[3] }];


## Buttons
set_property -dict { PACKAGE_PIN D11   IOSTANDARD LVCMOS33 } [get_ports { btn0 }];

## UART

set_property -dict { PACKAGE_PIN C7   IOSTANDARD LVCMOS33 } [get_ports { uart_rx }];
set_property -dict { PACKAGE_PIN E6   IOSTANDARD LVCMOS33 } [get_ports { uart_tx }];

## PIO

set_property -dict { PACKAGE_PIN D5    IOSTANDARD LVCMOS33 } [get_ports { j7_32 }];

set_property -dict { PACKAGE_PIN D6    IOSTANDARD LVCMOS33 PULLDOWN TRUE } [get_ports { j7_34 }];

set_property -dict { PACKAGE_PIN A7    IOSTANDARD LVCMOS33 } [get_ports { j7_36 }];
set_property -dict { PACKAGE_PIN B7    IOSTANDARD LVCMOS33 } [get_ports { j7_38 }];


set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]