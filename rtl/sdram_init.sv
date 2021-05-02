module sdram_init #(
    clock_frequency_mhz = 100,
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
    output logic        initiated,

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

`include "C:/my/GitHub/cw1997/SDRAM-Controller/rtl/parameter.sv"
`include "C:/my/GitHub/cw1997/SDRAM-Controller/rtl/command.sv"

localparam wait_clock_stable_cycle = clock_stable_ns / clock_frequency_mhz; // (clock_stable_ns * (1 / 1_000_000_000)) / (1 / clock_frequency_mhz);
logic [15:0] cycle_count;
logic [ 3:0] initiate_auto_refresh_count;

typedef enum logic [2:0] {
    state_wait_for_clock_stable,
    state_wait_for_tRP,
    state_do_initiate_auto_refresh,
    state_wait_for_initiate_tRC,
    state_do_set_mode_register,
    state_wait_for_tMRS,
    state_initiated
} state_t;

state_t state;

always_ff @( posedge clock or posedge reset ) begin :  init_state_machine
    if (reset) begin    
        DRAM_CKE <= 1;
        DRAM_CS_N <= 0;
        DRAM_ADDR <= 0;
        DRAM_BA <= 0;
        // DRAM_DQ_r <= {32{1'bz}};

        initiated <= 0;
        cycle_count <= 0;
        state <= state_wait_for_clock_stable;
    end else begin
        unique case (state)
            // wait {clock_stable_us} us
            state_wait_for_clock_stable : begin
                if (cycle_count == wait_clock_stable_cycle - 1) begin
                    // precharge all L-Bank
                    PALL();
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
                    state <= state_do_initiate_auto_refresh;
                end else begin
                    NOP();
                    cycle_count <= cycle_count + 1;
                end
            end
            state_do_initiate_auto_refresh : begin
                initiate_auto_refresh_count <= initiate_auto_refresh_count + 1;
                REF();
                state <= state_wait_for_initiate_tRC;
            end
            state_wait_for_initiate_tRC : begin
                if (cycle_count == tRC(CAS_Latency) - 1) begin
                    cycle_count <= 0;
                    // auto refresh {initiate_refresh_count} times
                    if (initiate_auto_refresh_count <= initiate_refresh_count - 1) begin
                        state <= state_do_initiate_auto_refresh;
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
                if (cycle_count == tMRD() - 1) begin
                    initiated <= 1;
                    cycle_count <= 0;
                    state <= state_initiated;
                end else begin
                    NOP();
                    cycle_count <= cycle_count + 1;
                end
            end
            state_initiated: begin
                state <= state;
            end
            default: begin
                state <= state_initiated;
            end
        endcase
    end
end

endmodule