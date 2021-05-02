// FileName: sdram_controller.sv
// Description: SDRAM Controller
// Repo: https://github.com/cw1997/SDRAM-Controller
// Author: cw1997 [changwei1006@gmail.com] & [https://changwei.me]
// Datetime: 2021-04-30 23:09:24

module sdram_controller #(
    clock_frequency = 100_000_000, // unit: Hz
    clock_stable_ns = 250_000, // Power-up: VCC and CLK stable T=200us Min
    initiate_refresh_count = 8,

    bank_count = 2,
    row_count = 13,
    column_count = 10,

    // Mode Register Set
    write_burst_mode = 0,
    burst_type = 1,
    burst_length = 4,
    CAS_Latency = 3
) (
    // bus
    input  logic        request,
    output logic        response,
    input  logic        write_enable,
    input  logic [24:0] address,
    output logic [31:0] read_data,
    input  logic [31:0] write_data,

    // DRAM 
    output logic [12:0] DRAM_ADDR,
    output logic [ 1:0] DRAM_BA,
    output logic        DRAM_CAS_N,
    output logic        DRAM_CKE,
    output logic        DRAM_CLK,
    output logic        DRAM_CS_N,
    inout  logic [31:0] DRAM_DQ,
    output logic [ 3:0] DRAM_DQM,
    output logic        DRAM_RAS_N,
    output logic        DRAM_WE_N,

    input  logic        clock, reset
);

reg [31:0] DRAM_DQ_r;
assign DRAM_DQ = DRAM_DQ_r;

localparam address_width = bank_count + row_count + column_count;

`include "C:/my/GitHub/cw1997/SDRAM-Controller/rtl/parameter.sv"
`include "C:/my/GitHub/cw1997/SDRAM-Controller/rtl/command.sv"

assign DRAM_CLK = clock;
// `define CAS_Latency tCAC(clock_frequency / 1_000_000);

// initiate

typedef enum logic [7:0] {
    state_wait_for_clock_stable,
    state_wait_for_tRP,
    state_do_auto_fresh,
    state_wait_for_tRC,
    state_do_set_mode_register,
    state_wait_for_tMRS,
    state_wait_for_tRCD,
    state_wait_for_tCAC,
    state_wait_for_tDPL,
    state_idle
} state_t;

state_t state;

localparam wait_clock_stable_cycle = clock_stable_ns / (1_000_000_000 / clock_frequency); // (clock_stable_ns * (1 / 1_000_000_000)) / (1 / clock_frequency);
logic [15:0] cycle_count;
logic [ 3:0] initiate_auto_refresh_count;
logic        initiated;

wire  [ 1:0] bank           = address[24:23];
wire  [12:0] row_address    = address[22:10];
wire  [ 9:0] column_address = address[ 9: 0];

logic request_posedge_edge;
edge_detect edge_detect_request (
    .clk ( clock ),
    .rst_n ( ~reset ),
    .data_in ( request ),
    .pos_edge ( request_posedge_edge )
);

logic write_enable_posedge_edge;
edge_detect edge_detect_write_enable (
    .clk ( clock ),
    .rst_n ( ~reset ),
    .data_in ( write_enable ),
    .pos_edge ( write_enable_posedge_edge )
);

logic write_enable_latch;
always_ff @( posedge clock or posedge reset ) begin : latch_write_enable
    if (reset) begin
        write_enable_latch <= 0;
    end else begin
        if (request_posedge_edge) begin
            write_enable_latch <= write_enable_posedge_edge;
        end else begin
            write_enable_latch <= write_enable_latch;
        end
    end
end

always_ff @( posedge clock or posedge reset ) begin : controller_state_machine
    if (reset) begin    
        DRAM_CKE <= 1;
        DRAM_CS_N <= 0;
        DRAM_ADDR <= 0;
        DRAM_BA <= 0;

        initiated <= 0;
        cycle_count <= 0;
        state <= state_wait_for_clock_stable;
    end else begin
        if (!initiated) begin
            case (state)
                // wait {clock_stable_us} us
                state_wait_for_clock_stable : begin
                    if (cycle_count == wait_clock_stable_cycle - 1) begin
                        // precharge all L-Bank
                        PALL();
                        initiate_auto_refresh_count <= 0;
                        cycle_count <= 0;
                        state <= state_wait_for_tRP;
                    end else begin
                        cycle_count <= cycle_count + 1;
                    end
                end
                state_wait_for_tRP : begin
                    if (cycle_count == tRP(CAS_Latency) - 1) begin
                        initiate_auto_refresh_count <= 0;
                        cycle_count <= 0;
                        state <= state_do_auto_fresh;
                    end else begin
                        NOP();
                        cycle_count <= cycle_count + 1;
                    end
                end
                state_do_auto_fresh : begin
                    initiate_auto_refresh_count <= initiate_auto_refresh_count + 1;
                    REF();
                    state <= state_wait_for_tRC;
                end
                state_wait_for_tRC : begin
                    if (cycle_count == tRC(CAS_Latency) - 1) begin
                        cycle_count <= 0;
                        // auto refresh {initiate_refresh_count} times
                        if (initiate_auto_refresh_count <= initiate_refresh_count - 1) begin
                            state <= state_do_auto_fresh;
                        end else begin
                            state <= state_do_set_mode_register;
                        end
                    end else begin
                        NOP();
                        cycle_count <= cycle_count + 1;
                    end
                end
                state_do_set_mode_register : begin
                    MRS(write_burst_mode, 2'b0, CAS_Latency, burst_type, burst_length);
                    state <= state_wait_for_tMRS;
                end
                // wait tMRS cycles and the mode register setup successful
                state_wait_for_tMRS : begin
                    if (cycle_count == tMRD()) begin
                        initiated <= 1;
                        cycle_count <= 0;
                        state <= state_idle;
                    end else begin
                        NOP();
                        cycle_count <= cycle_count + 1;
                    end
                end
                default: begin
                    state <= state_wait_for_clock_stable;
                end
            endcase
        end else begin
            if (request_posedge_edge) begin
                ACT(bank, row_address);
                cycle_count <= 0;
                state <= state_wait_for_tRCD;
            end else begin
                case (state)
                    state_wait_for_tRCD : begin
                        if (cycle_count == tRCD(CAS_Latency) - 1) begin
                            cycle_count <= 0;
                            if (write_enable_latch) begin
                                WRITE(bank, column_address, 1);
                                DRAM_DQ_r <= write_data;
                                state <= state_wait_for_tDPL;
                            end else begin
                                READ(bank, column_address, 1);
                                DRAM_DQ_r <= {32{1'bz}};
                                state <= state_wait_for_tCAC;
                            end
                        end else begin
                            NOP();
                            cycle_count <= cycle_count + 1;
                        end
                    end
                    // read latency
                    state_wait_for_tCAC : begin
                        if (cycle_count == tCAC(clock_frequency / 1_000_000) - 1) begin
                            cycle_count <= 0;
                            response <= 1;
                            read_data <= DRAM_DQ;
                            state <= state_idle;
                        end else begin
                            NOP();
                            cycle_count <= cycle_count + 1;
                        end
                    end
                    // write latency
                    state_wait_for_tDPL : begin
                        if (cycle_count == tCAC(clock_frequency / 1_000_000) - 1) begin
                            cycle_count <= 0;
                            response <= 1;
                            state <= state_idle;
                        end else begin
                            NOP();
                            cycle_count <= cycle_count + 1;
                        end
                    end
                    state_idle : begin
                        response <= 0;
                        cycle_count <= 0;
                    end
                    default: state <= state_idle;
                endcase
            end
        end
        
    end
end

endmodule