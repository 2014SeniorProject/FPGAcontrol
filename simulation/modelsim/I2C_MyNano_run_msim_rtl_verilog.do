transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/altera/13.0sp1/I2C_MyAccel {C:/altera/13.0sp1/I2C_MyAccel/I2C_MyNano.v}

