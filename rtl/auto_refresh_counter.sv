module auto_refresh_counter #(
    clock_frequency_mhz = 100,
    cycle_ns = 32_000_000
    // cycle_ns = 64_000 // for simulation
) (
    output logic request,
    input  logic response,

    input  logic clock, reset
);

logic response_posedge_edge;
edge_detect edge_detect_response (
    .clk ( clock ),
    .rst_n ( ~reset ),
    .data_in ( response ),
    .pos_edge ( response_posedge_edge )
);

logic [31:0] count;
always_ff @( posedge clock or posedge reset ) begin : auto_refresh_counter_ff
    if (reset) begin
        count <= 0;
        request <= 0;
    end else if (response_posedge_edge) begin
        count <= 0;
        request <= 0;
    end else begin
        if (count == (cycle_ns / clock_frequency_mhz) - 1) begin
            count <= 0;
            request <= 1;
        end else begin
            count <= count + 1;
        end
    end
end

endmodule