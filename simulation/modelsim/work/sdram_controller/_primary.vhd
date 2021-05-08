library verilog;
use verilog.vl_types.all;
entity sdram_controller is
    generic(
        clock_frequency_mhz: integer := 100;
        clock_stable_ns : integer := 250000;
        initiate_refresh_count: integer := 8;
        bank_count      : integer := 2;
        row_count       : integer := 13;
        column_count    : integer := 10;
        write_burst_mode: integer := 1;
        burst_type      : integer := 1;
        burst_length    : integer := 1;
        CAS_Latency     : vl_notype
    );
    port(
        request         : in     vl_logic;
        response        : out    vl_logic;
        write_enable    : in     vl_logic;
        address         : in     vl_logic_vector(24 downto 0);
        read_data       : out    vl_logic_vector(31 downto 0);
        write_data      : in     vl_logic_vector(31 downto 0);
        initiated       : out    vl_logic;
        DRAM_ADDR       : out    vl_logic_vector(12 downto 0);
        DRAM_BA         : out    vl_logic_vector(1 downto 0);
        DRAM_CAS_N      : out    vl_logic;
        DRAM_CKE        : out    vl_logic;
        DRAM_CLK        : out    vl_logic;
        DRAM_CS_N       : out    vl_logic;
        DRAM_DQ         : inout  vl_logic_vector(31 downto 0);
        DRAM_DQM        : out    vl_logic_vector(3 downto 0);
        DRAM_RAS_N      : out    vl_logic;
        DRAM_WE_N       : out    vl_logic;
        clock           : in     vl_logic;
        reset           : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of clock_frequency_mhz : constant is 1;
    attribute mti_svvh_generic_type of clock_stable_ns : constant is 1;
    attribute mti_svvh_generic_type of initiate_refresh_count : constant is 1;
    attribute mti_svvh_generic_type of bank_count : constant is 1;
    attribute mti_svvh_generic_type of row_count : constant is 1;
    attribute mti_svvh_generic_type of column_count : constant is 1;
    attribute mti_svvh_generic_type of write_burst_mode : constant is 1;
    attribute mti_svvh_generic_type of burst_type : constant is 1;
    attribute mti_svvh_generic_type of burst_length : constant is 1;
    attribute mti_svvh_generic_type of CAS_Latency : constant is 3;
end sdram_controller;
