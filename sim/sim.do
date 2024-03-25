transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work


project addfile ../tb/tb_vga_ctrl.sv

project addfile ../rtl/top_de10lite.sv
project addfile ../rtl/vga_ctrl/vga_ctrl.sv
project addfile ../rtl/vga_ctrl/timgen.sv
project addfile ../rtl/vga_ctrl/divider.sv
project addfile ../rtl/vga_ctrl/syncgen.sv

#project addfile ../include/sync_params.h
#project addfile ../include/vga_conf.h

project addfile ../ip/pll/PLL.v
project addfile ../ip/vram/VRAM.v

vlog -sv ../tb/tb_vga_ctrl.sv

vlog -sv ../rtl/top_de10lite.sv
vlog -sv ../rtl/vga_ctrl/vga_ctrl.sv
vlog -sv ../rtl/vga_ctrl/timgen.sv
vlog -sv ../rtl/vga_ctrl/divider.sv
vlog -sv ../rtl/vga_ctrl/syncgen.sv
vlog -sv ../rtl/vga_ctrl/vram_ctrl.sv
vlog -sv ../rtl/vga_ctrl/timer.sv

vlog -sv ../rtl/lifegame/lfgm_top.sv
vlog -sv ../rtl/lifegame/lfgm_ctrl.sv
vlog -sv ../rtl/lifegame/lfgm_gen_ln.sv
vlog -sv ../rtl/lifegame/lfgm_jdg.sv
vlog -sv ../rtl/lifegame/vram_pts_inf.sv

vlog -sv ../rtl/misc/seg7_dcd.sv


#vlog -sv ../include/sync_params.h
#vlog -sv ../include/vga_conf.h

vlog -vlog01compat ../ip/pll/PLL.v
vlog -vlog01compat ../ip/vram_64bx1024w/vram_64bx1024w.v
vlog -vlog01compat ../ip/vram_64bx4096w/vram_64bx4096w.v
vlog -vlog01compat ../ip/vram_16bx1024w/vram_16bx1024w.v
vlog -vlog01compat ../ip/vram_16bx4096w/vram_16bx4096w.v
vlog -vlog01compat ../ip/dpram_108bx64w/dpram_108bx64w.v


#vlog -vlog01compat -work work +incdir+D:/work/FPGA/vga_ctrl/ip/pll {D:/work/FPGA/vga_ctrl/ip/pll/PLL.v}
#vlog -sv -work work +incdir+D:/work/FPGA/vga_ctrl/rtl {../rtl/vga_ctrl.sv}
#vlog -sv -work work +incdir+D:/work/FPGA/vga_ctrl/rtl {D:/work/FPGA/vga_ctrl/rtl/timgen.sv}
#vlog -sv -work work +incdir+D:/work/FPGA/vga_ctrl/rtl {D:/work/FPGA/vga_ctrl/rtl/divider.sv}
#vlog -sv -work work +incdir+D:/work/FPGA/vga_ctrl/rtl {D:/work/FPGA/vga_ctrl/rtl/syncgen.sv}
#vlog -sv -work work +incdir+D:/work/FPGA/vga_ctrl/tb {D:/work/FPGA/vga_ctrl/tb/tb_vga_ctrl.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L fiftyfivenm_ver -L rtl_work -L work -voptargs="+acc"  tb_vga_ctrl

#add log {/tb_vga_ctrl/dut/syncgen/*}
#add wave {/tb_vga_ctrl/dut/vga_ctrl_inst/vram_ctrl_inst/*}
add wave {/tb_vga_ctrl/dut/lfgm_top_inst/vram_pts_inf_inst/*}

config wave -signalnamewidth 1

view structure
view signals
run 100 us
