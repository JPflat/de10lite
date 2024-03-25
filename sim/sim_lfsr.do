transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work


project addfile ../../tb/tb_lfsr.sv

project addfile ../../rtl/lfsr/lfsr_top.sv
project addfile ../../rtl/lfsr/gen_lfsr.sv
project addfile ../../rtl/lfsr/shk_lfsr.sv

vlog -sv ../../rtl/lfsr/lfsr_top.sv
vlog -sv ../../rtl/lfsr/gen_lfsr.sv
vlog -sv ../../rtl/lfsr/shk_lfsr.sv

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L fiftyfivenm_ver -L rtl_work -L work -voptargs="+acc"  tb_lfsr

#add log {/tb_vga_ctrl/dut/syncgen/*}
#add wave {/tb_vga_ctrl/dut/vga_ctrl_inst/vram_ctrl_inst/*}
add wave {/tb_lfsr/dut/gen_lfsr_inst/*}

config wave -signalnamewidth 1

view structure
view signals
run 100 us
