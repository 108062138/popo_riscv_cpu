main:
    # normal forward testing
    addi x1, x0, 5
    add x1, x1, x1 # x1 = 10
    addi x2, x0, 7
    addi x0, x0, 10
    add x2, x2, x2 # x2 = 14
    addi x3, x0, 11
    addi x0, x0, 10
    addi x0, x0, 10
    add x3, x3, x3 # x3 = 22
    addi x4, x0, 13
    addi x0, x0, 10
    addi x0, x0, 10
    addi x0, x0, 10
    add x4, x4, x4 # x4 = 26
    addi x5, x0, 17
    addi x0, x0, 10
    addi x0, x0, 10
    addi x0, x0, 10
    add x5, x5, x5 # x5 = 34
    
    # malicious forward testing
    # case1: when rs2 doesn't used, rs2 don't involved in forward. x7 should be 40
    addi x7, x5, 6
    # case2: x0 should not involved in forward. x8 should be 40
    addi x0, x0, 5
    add x8, x0, x7
    # case3: x9 should be 200
    add x9, x7, x7
    add x9, x9, x7
    add x9, x9, x7
    add x9, x9, x7
    # case4: x12 should not get forwarded by beq and x12 should be 64
    addi x12, x0, 32
    addi x11, x0, 5
    bne x8, x7, should_not_trigger # imm == 12, which is used to induce rd=12 case
    add x12, x12, x12
    addi x31, x0, 666
should_not_trigger:
    addi x29, x0, 12345
    addi x31, x0, 666