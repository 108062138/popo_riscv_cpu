main:
    # normal forward testing
    addi x1, x0, 5
    add x1, x1, x1 # x1 = 10
    addi x15, x0, 10
    bne x15, x1, fuck_up
    addi x2, x0, 7
    addi x0, x0, 10
    add x2, x2, x2 # x2 = 14
    addi x15, x0, 14
    bne x15, x2, fuck_up
    addi x3, x0, 11
    addi x0, x0, 10
    addi x0, x0, 10
    add x3, x3, x3 # x3 = 22
    addi x15, x0, 22
    bne x15, x3, fuck_up
    addi x4, x0, 13
    addi x0, x0, 10
    addi x0, x0, 10
    addi x0, x0, 10
    add x4, x4, x4 # x4 = 26
    addi x15, x0, 26
    bne  x15, x4, fuck_up
should_not_trigger:
    addi x29, x0, 123
    addi x31, x0, 666
fuck_up:
    addi x31, x0, 404