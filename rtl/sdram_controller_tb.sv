// FileName: sdram_controller_tb.sv
// Description: SDRAM Controller testbench
// Repo: https://github.com/cw1997/SDRAM-Controller
// Author: cw1997 [changwei1006@gmail.com] & [https://changwei.me]
// Datetime: 2021-04-30 23:17:50
`timescale 1ns/1ns

module sdram_controller_tb #(
    // parameters
) (
    // ports
);

localparam clock_frequency = 100_000_000;
localparam clock_period = 1_000_000_000 / clock_frequency;
logic clock = 0, reset = 1;

logic        request;
logic        response;
logic        write_enable;
logic [12:0] address;
logic [31:0] read_data, write_data;

always #(clock_period / 2) clock = ~clock;

sdram_controller sdram_controller_inst(
    .request ( request ),
    .response ( response ),
    .write_enable ( write_enable ),
    .address ( address ),
    .read_data ( read_data ),
    .write_data ( write_data ),
    
    .clock ( clock ),
    .reset ( reset )
);

initial begin
    #(clock_period)
    reset = 0;

    write_enable = 0;
    request = 0;
    address = 0;
    
    #(clock_period)

    #(300_000)
    $display("initiated");

    #(clock_period)
    $display("read start");

    request = 1;
    address = 1;
    write_data = 0;
    $monitor("read response: %b", response);
    $monitor("read_data: %b", read_data);
    #(clock_period)
    request = 0;
    
    #(clock_period * 50)

    request = 1;
    address = 1;
    write_enable = 1;
    write_data = 1;
    $monitor("response: %b", response);
    #(clock_period)
    request = 0;
    write_enable = 0;

    #(clock_period * 50)

    request = 1;
    address = 1;
    write_data = 0;
    $monitor("read response: %b", response);
    $monitor("read_data: %b", read_data);
    #(clock_period)
    request = 0;
    
    #(clock_period * 50)

    $stop();
end
    
endmodule