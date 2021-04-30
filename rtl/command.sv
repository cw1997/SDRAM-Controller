// FileName: command.sv
// Description: SDRAM Controller Command, reference memory chip datasheet
// Repo: https://github.com/cw1997/SDRAM-Controller
// Author: cw1997 [changwei1006@gmail.com] & [https://changwei.me]
// Datetime: 2021-04-30 15:06:54

// No operation (NOP)
task NOP;
begin
    DRAM_CS_N  = 0;
    DRAM_RAS_N = 1;
    DRAM_CAS_N = 1;
    DRAM_WE_N  = 1;
end
endtask

// Precharge all banks (PALL)
task PALL;
begin
    DRAM_CS_N  = 0;
    DRAM_RAS_N = 0;
    DRAM_CAS_N = 1;
    DRAM_WE_N  = 0;
    // DRAM_ADDR  = 13'b0 | (1 << 10);
    DRAM_ADDR[10] = 1;
end
endtask

// Precharge select bank (PRE)
task PRE;
begin
    DRAM_CS_N  = 0;
    DRAM_RAS_N = 0;
    DRAM_CAS_N = 1;
    DRAM_WE_N  = 0;
    DRAM_BA = 2'b11;
    DRAM_ADDR[10] = 0; 
end
endtask

// CBR Auto-Refresh (REF)
task REF;
begin
    DRAM_CS_N  = 0;
    DRAM_RAS_N = 0;
    DRAM_CAS_N = 0;
    DRAM_WE_N  = 1; 
end
endtask


function [2:0] decode_burst_length(logic [7:0] burst_length);
begin
    unique case (burst_length)
        1: decode_burst_length = 3'b000;
        2: decode_burst_length = 3'b001;
        4: decode_burst_length = 3'b010;
        8: decode_burst_length = 3'b011;
        0: decode_burst_length = 3'b111;
        default: begin
            decode_burst_length = 3'b100;
        end
    endcase
end
endfunction

// Mode register set (MRS)
task MRS(
    logic write_burst_mode, // 0: Programmed Burst Length, 1: Single Location Access
    logic [1:0] operating_mode, // All Other States Reserved
    logic [2:0] latency_mode,
    logic burst_type, // 0: Sequential, 1: Interleaved
    logic [7:0] burst_length
);
begin
    DRAM_CS_N  = 0;
    DRAM_RAS_N = 0;
    DRAM_CAS_N = 0;
    DRAM_WE_N  = 0;
    DRAM_BA    = 2'b00;
    DRAM_ADDR  = {3'b000, write_burst_mode, operating_mode, latency_mode, burst_type, decode_burst_length(burst_length)};
end
endtask