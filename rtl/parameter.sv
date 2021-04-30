// FileName: parameter.sv
// Description: SDRAM Controller Parameter, reference memory chip datasheet
// Repo: https://github.com/cw1997/SDRAM-Controller
// Author: cw1997 [changwei1006@gmail.com] & [https://changwei.me]
// Datetime: 2021-04-30 15:00:09

localparam bit_width = 8;

// tCAC CAS_Latency
function [bit_width-1:0] tCAC(logic [bit_width-1:0] clock_frequency);
    case (clock_frequency)
        166    : tCAC <= 3;
        133    : tCAC <= 2;
        100    : tCAC <= 2;
        default: tCAC <= 2;
    endcase
endfunction

// tRCD Active Command To Read/Write Command Delay Time
function [bit_width-1:0] tRCD(logic [bit_width-1:0] CAS_Latency);
    case (CAS_Latency)
        3      : tRCD <= 3;
        2      : tRCD <= 2;
        default: tRCD <= 3;
    endcase
endfunction

// tRAC RAS Latency (trcd + tcac)
function [bit_width-1:0] tRAC(logic [bit_width-1:0] CAS_Latency);
    case (CAS_Latency)
        3      : tRAC <= 6;
        2      : tRAC <= 4;
        default: tRAC <= 6;
    endcase
endfunction

// tMRD Mode Register Set To Command Delay Time
function [bit_width-1:0] tMRD();
    tMRD <= 2;
endfunction

// tRC Command Period (REF to REF / ACT to ACT)
function [bit_width-1:0] tRC(logic [bit_width-1:0] CAS_Latency);
    case (CAS_Latency)
        3      : tRC <= 10;
        2      : tRC <= 7;
        default: tRC <= 10;
    endcase
endfunction

// tRP Command Period (PRE to ACT)
function [bit_width-1:0] tRP(logic [bit_width-1:0] CAS_Latency);
    case (CAS_Latency)
        3      : tRP <= 3;
        2      : tRP <= 2;
        default: tRP <= 3;
    endcase
endfunction
