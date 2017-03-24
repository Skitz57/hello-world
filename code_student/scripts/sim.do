set NumericStdNoWarnings 1

file delete -force "work"
file mkdir "work"

vlib work
vmap work work

cd ../tlmvm/comp
do ../scripts/compile.do
cd ../../sim

vmap tlmvm ../tlmvm/comp/tlmvm

vcom -2008 -explicit -novopt ../src_vhdl/fifo.vhd ../src_tb/random_pkg.vhd ../src_tb/fifo_tb.vhd

set fifosize 8
set datasize 8

if {$argc == 2} {
  set fifosize $1
  set datasize $2
}

vsim -GFIFOSIZE=$fifosize -GDATAWIDTH=$datasize fifo_tb

add wave -r *

run -all
