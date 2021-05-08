onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /sdram_controller_tb/sdram_controller_inst/clock_frequency_mhz
add wave -noupdate /sdram_controller_tb/sdram_controller_inst/clock_stable_ns
add wave -noupdate /sdram_controller_tb/sdram_controller_inst/initiate_refresh_count
add wave -noupdate /sdram_controller_tb/sdram_controller_inst/bank_count
add wave -noupdate /sdram_controller_tb/sdram_controller_inst/row_count
add wave -noupdate /sdram_controller_tb/sdram_controller_inst/column_count
add wave -noupdate /sdram_controller_tb/sdram_controller_inst/write_burst_mode
add wave -noupdate /sdram_controller_tb/sdram_controller_inst/burst_type
add wave -noupdate /sdram_controller_tb/sdram_controller_inst/burst_length
add wave -noupdate /sdram_controller_tb/sdram_controller_inst/CAS_Latency
add wave -noupdate /sdram_controller_tb/sdram_controller_inst/address_width
add wave -noupdate /sdram_controller_tb/sdram_controller_inst/bit_width
add wave -noupdate /sdram_controller_tb/sdram_controller_inst/wait_clock_stable_cycle
add wave -noupdate /sdram_controller_tb/sdram_controller_inst/request
add wave -noupdate /sdram_controller_tb/sdram_controller_inst/response
add wave -noupdate /sdram_controller_tb/sdram_controller_inst/write_enable
add wave -noupdate /sdram_controller_tb/sdram_controller_inst/address
add wave -noupdate /sdram_controller_tb/sdram_controller_inst/read_data
add wave -noupdate /sdram_controller_tb/sdram_controller_inst/write_data
add wave -noupdate /sdram_controller_tb/sdram_controller_inst/initiated
add wave -noupdate /sdram_controller_tb/sdram_controller_inst/DRAM_ADDR
add wave -noupdate /sdram_controller_tb/sdram_controller_inst/DRAM_BA
add wave -noupdate /sdram_controller_tb/sdram_controller_inst/DRAM_CAS_N
add wave -noupdate /sdram_controller_tb/sdram_controller_inst/DRAM_CKE
add wave -noupdate /sdram_controller_tb/sdram_controller_inst/DRAM_CLK
add wave -noupdate /sdram_controller_tb/sdram_controller_inst/DRAM_CS_N
add wave -noupdate /sdram_controller_tb/sdram_controller_inst/DRAM_DQ
add wave -noupdate /sdram_controller_tb/sdram_controller_inst/DRAM_DQM
add wave -noupdate /sdram_controller_tb/sdram_controller_inst/DRAM_RAS_N
add wave -noupdate /sdram_controller_tb/sdram_controller_inst/DRAM_WE_N
add wave -noupdate /sdram_controller_tb/sdram_controller_inst/clock
add wave -noupdate /sdram_controller_tb/sdram_controller_inst/reset
add wave -noupdate /sdram_controller_tb/sdram_controller_inst/write_enable_latch
add wave -noupdate /sdram_controller_tb/sdram_controller_inst/DRAM_DQ_r
add wave -noupdate /sdram_controller_tb/sdram_controller_inst/state
add wave -noupdate /sdram_controller_tb/sdram_controller_inst/cycle_count
add wave -noupdate /sdram_controller_tb/sdram_controller_inst/bank
add wave -noupdate /sdram_controller_tb/sdram_controller_inst/row_address
add wave -noupdate /sdram_controller_tb/sdram_controller_inst/column_address
add wave -noupdate /sdram_controller_tb/sdram_controller_inst/request_posedge_edge
add wave -noupdate /sdram_controller_tb/sdram_controller_inst/write_enable_posedge_edge
add wave -noupdate /sdram_controller_tb/sdram_controller_inst/initiate_auto_refresh_count
add wave -noupdate /sdram_controller_tb/sdram_controller_inst/auto_refresh_request
add wave -noupdate /sdram_controller_tb/sdram_controller_inst/auto_refresh_response
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {23847 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 222
configure wave -valuecolwidth 158
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 1
configure wave -timelineunits ns
update
WaveRestoreZoom {24878 ns} {25327 ns}
