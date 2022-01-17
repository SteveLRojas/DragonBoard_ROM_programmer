transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+E:/riptide_rom_programmer {E:/riptide_rom_programmer/toplevel.v}
vlog -vlog01compat -work work +incdir+E:/riptide_rom_programmer/CPU {E:/riptide_rom_programmer/CPU/shift_merge.v}
vlog -vlog01compat -work work +incdir+E:/riptide_rom_programmer/CPU {E:/riptide_rom_programmer/CPU/RIPTIDE-III.v}
vlog -vlog01compat -work work +incdir+E:/riptide_rom_programmer/CPU {E:/riptide_rom_programmer/CPU/right_rotate.v}
vlog -vlog01compat -work work +incdir+E:/riptide_rom_programmer/CPU {E:/riptide_rom_programmer/CPU/PC.v}
vlog -vlog01compat -work work +incdir+E:/riptide_rom_programmer/CPU {E:/riptide_rom_programmer/CPU/mask_unit.v}
vlog -vlog01compat -work work +incdir+E:/riptide_rom_programmer/CPU {E:/riptide_rom_programmer/CPU/internal_mem.v}
vlog -vlog01compat -work work +incdir+E:/riptide_rom_programmer/CPU {E:/riptide_rom_programmer/CPU/hazard_unit.v}
vlog -vlog01compat -work work +incdir+E:/riptide_rom_programmer/CPU {E:/riptide_rom_programmer/CPU/decode_unit.v}
vlog -vlog01compat -work work +incdir+E:/riptide_rom_programmer/CPU {E:/riptide_rom_programmer/CPU/ALU.v}
vlog -vlog01compat -work work +incdir+E:/riptide_rom_programmer {E:/riptide_rom_programmer/data_ram.v}
vlog -vlog01compat -work work +incdir+E:/riptide_rom_programmer {E:/riptide_rom_programmer/program_rom.v}
vlog -vlog01compat -work work +incdir+E:/riptide_rom_programmer {E:/riptide_rom_programmer/PLL0.v}
vlog -vlog01compat -work work +incdir+E:/riptide_rom_programmer/db {E:/riptide_rom_programmer/db/pll0_altpll.v}
vlog -sv -work work +incdir+E:/riptide_rom_programmer {E:/riptide_rom_programmer/UART.sv}
vlog -sv -work work +incdir+E:/riptide_rom_programmer {E:/riptide_rom_programmer/timer.sv}
vlog -sv -work work +incdir+E:/riptide_rom_programmer {E:/riptide_rom_programmer/serial.sv}
vlog -sv -work work +incdir+E:/riptide_rom_programmer {E:/riptide_rom_programmer/interrupt_controller.sv}
vlog -sv -work work +incdir+E:/riptide_rom_programmer {E:/riptide_rom_programmer/I2C_phy.sv}
vlog -sv -work work +incdir+E:/riptide_rom_programmer {E:/riptide_rom_programmer/I2C_ri.sv}

vlog -vlog01compat -work work +incdir+E:/riptide_rom_programmer {E:/riptide_rom_programmer/data_ram.v}
vlog -sv -work work +incdir+E:/riptide_rom_programmer {E:/riptide_rom_programmer/I2C_phy.sv}
vlog -sv -work work +incdir+E:/riptide_rom_programmer {E:/riptide_rom_programmer/I2C_ri.sv}
vlog -sv -work work +incdir+E:/riptide_rom_programmer {E:/riptide_rom_programmer/interrupt_controller.sv}
vlog -vlog01compat -work work +incdir+E:/riptide_rom_programmer {E:/riptide_rom_programmer/PLL0.v}
vlog -vlog01compat -work work +incdir+E:/riptide_rom_programmer {E:/riptide_rom_programmer/program_rom.v}
vlog -sv -work work +incdir+E:/riptide_rom_programmer {E:/riptide_rom_programmer/serial.sv}
vlog -sv -work work +incdir+E:/riptide_rom_programmer {E:/riptide_rom_programmer/testbench.sv}
vlog -sv -work work +incdir+E:/riptide_rom_programmer {E:/riptide_rom_programmer/timer.sv}
vlog -vlog01compat -work work +incdir+E:/riptide_rom_programmer {E:/riptide_rom_programmer/toplevel.v}
vlog -sv -work work +incdir+E:/riptide_rom_programmer {E:/riptide_rom_programmer/UART.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  Testbench

add wave *
view structure
view signals
run 1 us
