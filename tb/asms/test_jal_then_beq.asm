# used to test jal then bx1nch
main:
    addi x4, x0, 9           # 00: 00900213
    addi x3, x0, 2           # 04: 00200193
    jal incr_3, x1           # 08: 01c000ef, offset is 28
    beq x3, x4, should_enter # 12: 02408063, offset is 32
    addi x15, x0, 36         # 16: 02400793
    bne x3, x15, fuck_up     # 20: 02f19263, offset is 36
    jal incr_3, x1           # 24: 00c000ef, offset is 12
    bne x0, x0, fuck_up      # 28: 00001e63, offset is 28
    addi x31, x0, 666        # 32: 29a00f93
incr_3:
    addi x3, x3, 7           # 36: 00718193
    jalr x0, 0(x1)           # 40: 00008067
should_enter:
    add x3, x3, x3           # 44: 003181b3
    add x3, x3, x3           # 48: 003181b3
    jalr x0, 0(x1)           # 52: 00008067
fuck_up:
    addi x31, x0, 404        # 56: 19400f93