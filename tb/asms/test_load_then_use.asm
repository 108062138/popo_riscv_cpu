addi x1, x0, 32
addi x3, x0, 5
lw x2, 0(x1)
add x2, x2, x3 # load then use, an nop is inserted
lw x4, 0(x1)
add x2, x2, x3 # load not use
addi x31, x0, 666