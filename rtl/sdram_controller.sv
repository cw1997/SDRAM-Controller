// FileName: sdram_controller.sv
// Description: SDRAM Controller
// Repo: https://github.com/cw1997/SDRAM-Controller
// Author: cw1997 [changwei1006@gmail.com] & [https://changwei.me]
// Datetime: 2021-04-30 23:09:24

module sdram_controller #(
    clock_frequency = 100_000_000, // unit: Hz
    clock_stable_ns = 250_000, // Power-up: VCC and CLK stable T=200us Min
    initiate_refresh_count = 8,

    // Mode Register Set
    write_burst_mode = 1,
    burst_type = 1,
    burst_length = 4,
    CAS_Latency = 3
) (

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
    state_idle
} state_t;

state_t state;

localparam wait_clock_stable_cycle = clock_stable_ns / (1_000_000_000 / clock_frequency); // (clock_stable_ns * (1 / 1_000_000_000)) / (1 / clock_frequency);
logic [31:0] cycle_count;
logic [ 3:0] initiate_auto_refresh_count;
logic        initiated;

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
                // 等待 {clock_stable_us} us 后 时钟稳定 
                state_wait_for_clock_stable : begin
                    if (cycle_count == wait_clock_stable_cycle - 1) begin
                        // 对所有 L-Bank 预充电
                        PALL();
                        initiate_auto_refresh_count <= 0;
                        cycle_count <= 0;
                        state <= state_wait_for_tRP;
                    end else begin
                        cycle_count <= cycle_count + 1;
                    end
                end
                // 等待 tRP 后 全部 bank 预充电完成
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
                        // 执行 {initiate_refresh_count} 次自动刷新
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
                // 设置 MRS 模式寄存器
                state_do_set_mode_register : begin
                    // set MRS
                    MRS(write_burst_mode, 2'b0, CAS_Latency, burst_type, burst_length);
                    state <= state_wait_for_tMRS;
                end
                // 等待 tMRS 后 模式寄存器设置成功
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
            // 空闲状态，等待控制指令
            state_state_idle : begin
                // pass
            end
        end
        
    end
end

endmodule