# do-while loops: the loop branch sits at the bottom and is taken on every
# iteration except the last. This is the case where branch prediction helps.
main:
    # sum = 0 + 1 + ... + 39 = 780
    addi x1, x0, 0
    addi x2, x0, 40
    addi x3, x0, 0
sum_loop:
    add x3, x3, x1
    addi x1, x1, 1
    blt x1, x2, sum_loop
    addi x15, x0, 780
    bne x3, x15, fuck_up
    # nested: for i in 0..5, 7 times: count += i  -> 7 * 15 = 105
    addi x4, x0, 0
    addi x6, x0, 0
    addi x7, x0, 7
    addi x8, x0, 6
outer:
    addi x5, x0, 0
inner:
    add x6, x6, x4
    addi x5, x5, 1
    blt x5, x7, inner
    addi x4, x4, 1
    blt x4, x8, outer
    addi x15, x0, 105
    bne x6, x15, fuck_up
    # array: mem[64+i] = 3*i for i in 0..15, then sum it back -> 360
    addi x10, x0, 256
    addi x11, x0, 0
    addi x12, x0, 16
fill:
    slli x13, x11, 2
    add x14, x10, x13
    add x16, x11, x11
    add x16, x16, x11
    sw x16, 0(x14)
    addi x11, x11, 1
    blt x11, x12, fill
    addi x11, x0, 0
    addi x17, x0, 0
sum_array:
    slli x13, x11, 2
    add x14, x10, x13
    lw x18, 0(x14)
    add x17, x17, x18
    addi x11, x11, 1
    blt x11, x12, sum_array
    addi x15, x0, 360
    bne x17, x15, fuck_up
    addi x31, x0, 666
    nop
    nop
    nop
    nop
    nop
fuck_up:
    addi x31, x0, 404
