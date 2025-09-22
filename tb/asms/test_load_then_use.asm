addi x4, x0, 20
addi x3, x0, 10
addi x3, x3, 1
addi x3, x3, 1
sw x3, 4(x4)
# load then use
lw x2, 4(x4)
add x2, x2, x3
# load not use
lw x3, 4(x4)
add x2, x2, x2
addi x31, x0, 666 # 29a00f93