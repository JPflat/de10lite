onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_lfsr/dut/gen_lfsr_inst/clk
add wave -noupdate /tb_lfsr/dut/gen_lfsr_inst/rst_n
add wave -noupdate /tb_lfsr/dut/gen_lfsr_inst/gen_en
add wave -noupdate -radix unsigned /tb_lfsr/dut/gen_lfsr_inst/rgen_lfsr
add wave -noupdate /tb_lfsr/dut/gen_lfsr_inst/rgen_en
add wave -noupdate -radix unsigned /tb_lfsr/dut/gen_lfsr_inst/lfsr
add wave -noupdate /tb_lfsr/dut/gen_lfsr_inst/c
add wave -noupdate -expand -group shk /tb_lfsr/dut/shk_lfsr_inst/clk
add wave -noupdate -expand -group shk /tb_lfsr/dut/shk_lfsr_inst/rst_n
add wave -noupdate -expand -group shk /tb_lfsr/dut/shk_lfsr_inst/s_shk
add wave -noupdate -expand -group shk -radix unsigned /tb_lfsr/dut/shk_lfsr_inst/curr_lfsr
add wave -noupdate -expand -group shk /tb_lfsr/dut/shk_lfsr_inst/shk_end
add wave -noupdate -expand -group shk -radix unsigned /tb_lfsr/dut/shk_lfsr_inst/shk_lfsr
add wave -noupdate -expand -group shk /tb_lfsr/dut/shk_lfsr_inst/lt_trg
add wave -noupdate -expand -group shk -radix unsigned /tb_lfsr/dut/shk_lfsr_inst/shk_timer
add wave -noupdate -expand -group shk /tb_lfsr/dut/shk_lfsr_inst/not_allzero
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {778110 ps} {1322656 ps}
