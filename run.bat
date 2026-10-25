del tb_output.vcd
del a.out

iverilog -g2012 -o a.out -s uart_tb -c logical/filelist -c sim/filelist
vvp a.out -fst
gtkwave a.out