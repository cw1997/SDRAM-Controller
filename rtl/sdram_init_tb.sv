// FileName: sdram_controller_tb.sv
// Description: SDRAM Controller testbench
// Repo: https://github.com/cw1997/SDRAM-Controller
// Author: cw1997 [changwei1006@gmail.com] & [https://changwei.me]
// Datetime: 2021-04-30 23:17:50
`timescale 1ns/1ns

module sdram_init_tb #(
    // parameters
) (
    // ports
);

localparam clock_frequency = 100_000_000;
localparam clock_period = 1_000_000_000 / clock_frequency;
logic clock = 0, reset = 1;

always #(clock_period / 2) clock = ~clock;

logic initiated;    
sdram_init sdram_init_inst(
    .initiated ( initiated ),
    
    .clock ( clock ),
    .reset ( reset )
);

initial begin
    #(clock_period)
    reset = 0;

    $monitor("%m : at time %t initiated = %b", $time, initiated);

    #(26_000)


    #(clock_period * 50)

    $stop();
end
    
endmodule