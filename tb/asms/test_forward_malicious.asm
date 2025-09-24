main:
    # malicious forward testing
    addi x5, x0, 17
    addi x0, x0, 10
    addi x0, x0, 10
    addi x0, x0, 10
    add x5, x5, x5 # x5 = 34
    # case1: when rs2 doesn't used, rs2 don't involved in forward. x7 should be 40
    addi x7, x5, 6
    addi x15, x0, 40
    bne x15, x7, fuck_up
    # case2: x0 should not involved in forward. x8 should be 40
    addi x0, x0, 5
    add x8, x0, x7
    addi x15, x0, 40
    bne x15, x8, fuck_up
    # case3: x9 should be 200
    add x9, x7, x7
    add x9, x9, x7
    add x9, x9, x7
    add x9, x9, x7
    addi x15, x0, 200
    bne x15, x9, fuck_up
    # case4: x12 should not get forwarded by beq and x12 should be 64
    addi x12, x0, 32
    addi x11, x0, 5
    bne x8, x7, should_not_trigger # imm == 12, which is used to induce rd=12 case
    add x12, x12, x12
    addi x31, x0, 666
should_not_trigger:
    addi x29, x0, 123
    nop
    nop
    nop
    addi x31, x0, 404
fuck_up:
    addi x31, x0, 404