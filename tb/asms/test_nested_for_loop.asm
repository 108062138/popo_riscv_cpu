# limit_i = 5
# limit_j = 4
# hold = 11
# i = 0
# while(i<limit_i):
#     j = 0
#     while(j<limit_j):
#         hold += (i*j)
#         j++
#     i++
# x3 = 72
.text
.global main
main:
    addi x1, x0, 5
    addi x2, x0, 4
    addi x3, x0, 12
    addi x4, x0, 0
outer_for_loop:
    beq x4, x1, done
    addi x5, x0, 0
inner_for_loop:
    beq x5, x2, increment_i
    mul x6, x4, x5
    add x3, x3, x6
increment_j:
    addi x5, x5, 1
    j inner_for_loop
increment_i:
    addi x4, x4, 1
    j outer_for_loop
done:
    addi x15, x0, 72
    bne x15, x3, fuck_up
    addi, x31, x0, 666
    nop
    nop
    nop
    nop
    nop
fuck_up:
    addi x31, x0, 404