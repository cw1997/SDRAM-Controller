library verilog;
use verilog.vl_types.all;
entity edge_detect is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        data_in         : in     vl_logic;
        pos_edge        : out    vl_logic;
        neg_edge        : out    vl_logic
    );
end edge_detect;
