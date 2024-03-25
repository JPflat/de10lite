transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work


project addfile ../../rtl/i2c/i2c_m_if/i2c_ap_test.v
project addfile ../../rtl/i2c/i2c_m_if/i2c_ap.v
project addfile ../../rtl/i2c/i2c_m_if/i2c_kxp84_ctrl.v
project addfile ../../rtl/i2c/i2c_m_if/i2c_m_if.v
project addfile ../../rtl/i2c/i2c_m_if/fifo.v
project addfile ../../rtl/i2c/i2c_m_if/ram.v
project addfile ../../rtl/i2c/i2c_m_if/rs232c_tx_rx.v


vlog  ../../rtl/i2c/i2c_m_if/i2c_ap_test.v
vlog  ../../rtl/i2c/i2c_m_if/i2c_ap.v
vlog  ../../rtl/i2c/i2c_m_if/i2c_kxp84_ctrl.v
vlog  ../../rtl/i2c/i2c_m_if/i2c_m_if.v
vlog  ../../rtl/i2c/i2c_m_if/fifo.v
vlog  ../../rtl/i2c/i2c_m_if/ram.v
vlog  ../../rtl/i2c/i2c_m_if/rs232c_tx_rx.v

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L fiftyfivenm_ver -L rtl_work -L work -voptargs="+acc"  i2c_ap_test

add wave  -group drv {/i2c_ap_test/uut/i2c_dev_ctrl/*}
add wave  -group i2c {/i2c_ap_test/uut/i2c_m_if/*}

config wave -signalnamewidth 1

view structure
view signals
run 100 us
