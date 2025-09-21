# first store data at 12
addi sp, x0, 20
addi t0, x0, 10
sw t0, 0(sp)
add t0, t0, t0
sw t0, 4(sp)
# load then use
ld t1, 0(sp)
add t1, t1, t1
sw t1, 4(sp)
# load not use
ld t2, 4(t1)
nop
addi t2, t2, 5
addi x31, x0, 666