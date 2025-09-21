main:
    addi sp, x0, 120     # 07800113
    addi sp, sp, -4      # ffc10113
    sw x1, 0(sp)         # 00112023
    addi a0, x0, 4       # 00500513
    jal factorial, x1    # 014000ef, offset = 20
    lw x1, 0(sp)         # 00012083
    addi sp, sp, 4       # 00410113
    addi x31, x0, 666    # 29a00f93
    jalr x0, 0(x1)       # 00008067
factorial:
    addi sp, sp, -8      # ff810113
    sw x1, 0(sp)         # 00112023
    sw a0, 4(sp)         # 00a12423???
    addi t0, x0, 1       # 00100293
    beq a0, t0, case_one # 02550063, imm = = 32
normal_case:
    addi a0, a0, -1      # fff50513
    jal factorial, x1    # fe9ff0ef, offset = -24
    lw t0, 4(sp)         # 00412283
    mul a0, t0, a0       # 02a28533
    lw x1, 0(sp)         # 00012083
    addi sp, sp, 8       # 00810113
    jalr x0, 0(x1)       # 00008067
case_one:
    addi a0, x0, 1       # 00100513
    lw x1, 0(sp)         # 00012083
    addi sp, sp, 8       # 00810113
    jalr x0, 0(x1)       # 00008067