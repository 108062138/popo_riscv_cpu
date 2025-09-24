main:
    addi x4, x0, 20
    addi x3, x0, 10
    addi x3, x3, 1
    addi x3, x3, 1
    sw x3, 4(x4) # mem[16] <= 12
    # load then use
    lw x2, 4(x4) # x2 get 12
    add x2, x2, x3 # x2 = 24
    # load not use
    lw x3, 4(x4)
    add x2, x2, x2 # x2 = 48
    addi x3, x0, 48
    bne x3, x2, fuck_up
    addi x31, x0, 666 # 29a00f93
    nop
    nop
    nop
    nop
fuck_up:
    addi x31, x0, 404