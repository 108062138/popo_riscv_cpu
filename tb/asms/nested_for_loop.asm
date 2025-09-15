# limit_i = 5
# limit_j = 3
# hold = 11
# i = 0
# while(i<limit_i):
#     j = 0
#     while(j<limit_j):
#         hold += (i*j)
#         j++
#     i++
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
    addi x5, x5, 1
    j inner_for_loop
increment_i:
    addi x4, x4, 1
    j outer_for_loop
done:
    addi, x31, x0, 666