main:
    addi sp, x0, 120     # 00: 0x07800113
    addi sp, sp, -4      # 04: 0xffc10113
    sw x1, 0(sp)         # 08: 0x00112023
    addi a0, x0, 8       # 12: 0x00500513
    jal factorial, x1    # 16: 0x014000ef, offset = 20
    lw x1, 0(sp)         # 20: 0x00012083
    addi sp, sp, 4       # 24: 0x00410113
    addi a1, x0, 1024
    addi a2, x0, 40
    mul a1, a1, a2
    addi a2, x0, 640
    sub a1, a1, a2
    bne a1, a0, fuck_up
    addi x31, x0, 666    # 28: 0x29a00f93
    jalr x0, 0(x1)       # 32: 0x00008067
factorial:
    addi sp, sp, -8      # 36: 0xff810113
    sw x1, 0(sp)         # 40: 0x00112023
    sw a0, 4(sp)         # 44: 0x00a12223
    addi t0, x0, 1       # 48: 0x00100293
    beq a0, t0, case_one # 52: 0x02550063, imm = = 32
normal_case:
    addi a0, a0, -1      # 56: 0xfff50513
    jal factorial, x1    # 60: 0xfe9ff0ef, offset = -24
    lw t0, 4(sp)         # 64: 0x00412283
    mul a0, t0, a0       # 68: 0x02a28533
    lw x1, 0(sp)         # 72: 0x00012083
    addi sp, sp, 8       # 76: 0x00810113
    jalr x0, 0(x1)       # 80: 0x00008067
case_one:
    addi a0, x0, 1       # 84: 0x00100513
    lw x1, 0(sp)         # 88: 0x00012083
    addi sp, sp, 8       # 92: 0x00810113
    jalr x0, 0(x1)       # 96: 0x00008067
fuck_up:
    addi x31, x0, 404