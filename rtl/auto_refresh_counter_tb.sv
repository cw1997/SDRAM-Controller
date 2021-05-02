// FileName: auto_refresh_counter_tb.sv
// Description: SDRAM Controller testbench
// Repo: https://github.com/cw1997/SDRAM-Controller
// Author: cw1997 [changwei1006@gmail.com] & [https://changwei.me]
// Datetime: 2021-04-30 23:17:50
`timescale 1ns/1ns

module auto_refresh_counter_tb #(
    // parameters
) (
    // ports
);

localparam clock_frequency_hz = 100_000_000;
localparam clock_period_ns = 1_000_000_000 / clock_frequency_hz;
logic clock = 0, reset = 1;

logic request;
logic response;

always #(clock_period_ns / 2) clock = ~clock;

auto_refresh_counter auto_refresh_counter_inst(
    .request ( request ),
    .response ( response ),
    
    .clock ( clock ),
    .reset ( reset )
);

initial begin
    response = 0;
    #(clock_period_ns)
    reset = 0;
    
    #(clock_period_ns)

    #(65_000)
    response = 1;
    #(1_000)
    response = 0;

    #(65_000)
    response = 1;
    #(1_000)
    response = 0;

    $stop();
end
    
endmodule