library verilog;
use verilog.vl_types.all;
entity auto_refresh_counter is
    generic(
        clock_frequency_mhz: integer := 100;
        cycle_ns        : integer := 32000000
    );
    port(
        request         : out    vl_logic;
        response        : in     vl_logic;
        clock           : in     vl_logic;
        reset           : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of clock_frequency_mhz : constant is 1;
    attribute mti_svvh_generic_type of cycle_ns : constant is 1;
end auto_refresh_counter;
