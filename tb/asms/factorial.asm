# // ==== main ====
# 07800113    // addi sp, x0, 120          ; opcode=0010011, imm=0x078, rd=x2 (sp), rs1=x0
# FFC10113    // addi sp, sp, -4          ; imm=0xFFC (-4), rd=sp, rs1=sp
# 00112023    // sw ra, 0(sp)             ; opcode=0100011, funct3=010, rs2=ra, rs1=sp, imm=0
# 00500513    // addi a0, x0, 5           ; rd=x10 (a0), imm=5
# 014000EF    // jal ra, factorial        ; PC-relative jump: offset=+20 (0x14)
# 00012083    // lw ra, 0(sp)             ; opcode=0000011, funct3=010, rd=ra, rs1=sp
# 00410113    // addi sp, sp, 4           ; imm=4, rd=sp, rs1=sp
# 29A00F93    // addi x31, x0, 666        ; imm=0x29A, rd=x31 (debug output)
# 00008067    // jalr x0, 0(ra)           ; return: opcode=1100111, rd=x0, rs1=ra, imm=0

# // ==== factorial ====
# FF810113    // addi sp, sp, -8          ; imm=0xFF8 (-8), adjust stack
# 00112023    // sw ra, 0(sp)             ; store return address
# 00A12223    // sw a0, 4(sp)             ; store argument (n)
# 00100293    // addi t0, x0, 1           ; t0 = 1 (base case constant)
# 02050463    // beq a0, t0, case_one     ; offset=+32 bytes → imm=16 → PC=0x34→0x54

# // ==== normal_case ====
# FFF50513    // addi a0, a0, -1          ; a0 = a0 - 1
# FE9FF0EF    // jal ra, factorial        ; offset = -24 → PC=0x3C → 0x24
# 00412283    // lw t0, 4(sp)             ; restore original n
# 02A28533    // mul a0, t0, a0           ; a0 = n * factorial(n-1)
# 00012083    // lw ra, 0(sp)             ; restore return address
# 00810113    // addi sp, sp, 8           ; deallocate stack
# 00008067    // jalr x0, 0(ra)           ; return

# // ==== case_one ====
# 00100513    // addi a0, x0, 1           ; return 1
# 00012083    // lw ra, 0(sp)             ; restore return address
# 00810113    // addi sp, sp, 8           ; deallocate stack
# 00008067    // jalr x0, 0(ra)           ; return

main:
    addi sp, x0, 120
    addi sp, sp, -4
    sw ra, 0(sp)
    addi a0, x0, 5
    jal ra, factorial     #(offset = 0x24 - 0x10 = +20)
    lw ra, 0(sp)
    addi sp, sp, 4
    addi x31, x0, 666
    jalr x0, 0(ra)
factorial:
    addi sp, sp, -8
    sw ra, 0(sp)
    sw a0, 4(sp)
    addi t0, x0, 1
    beq a0, t0, case_one #(imm = 16 → offset = 32 bytes)
normal_case:
    addi a0, a0, -1
    jal ra, factorial     #(offset = 0x24 - 0x3C = -24)
    lw t0, 4(sp)
    mul a0, t0, a0
    lw ra, 0(sp)
    addi sp, sp, 8
    jalr x0, 0(ra)
case_one:
    addi a0, x0, 1
    lw ra, 0(sp)
    addi sp, sp, 8
    jalr x0, 0(ra)