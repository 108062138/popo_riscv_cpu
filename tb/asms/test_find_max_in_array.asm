.text
.global main
main:
set_up_datas:
    addi x1, x0, 9
    sh x1, 0(x0) # we set strlen to be 9
    addi x1, x0, 13
    sh x1, 2(x0) # store data at address 13
    addi x2, x0, 5
    sb x2, 0(x1)
    addi x2, x0, -2
    sb x2, 1(x1)
    addi x2, x0, 10
    sb x2, 2(x1)
    addi x2, x0, 37
    sb x2, 3(x1)
    addi x2, x0, -128
    sb x2, 4(x1)
    addi x2, x0, 11
    sb x2, 5(x1)
    addi x2, x0, 40
    sb x2, 6(x1)
    addi x2, x0, -100
    sb x2, 7(x1)
    addi x2, x0, -111
    sb x2, 8(x1)
using:
    addi x1, x0, 0 # strlen location is at 0
    lh x2, 0(x1) # x2 stores strlen
    addi x1, x0, 2 # base address location is stored at at 2
    lh x8, 0(x1) # x8 stores the base arr[]
find_min:
    addi x3, x0, -2048 # x3 is psum
    slli x3, x3, 3
    addi x4, x0, 0 # i = 0
iterate_loop:
    beq x4, x2, terminate # i<strlen
    add x6, x8, x4 # x6 <= base arr[] + i
    lb x7, 0(x6) # x7 <= mem[x6]
    blt x3, x7, update_psum # try to update psum. if x3<x7, then update. otherwise, keep looking
    addi x4, x4, 1
    j iterate_loop
update_psum:
    addi x3, x7, 0
    j iterate_loop
terminate:
    addi x15, x0, 40
    bne x15, x3, fuck_up
    addi x31, x0, 666
    nop
    nop
    nop
    nop
    nop
fuck_up:
    addi x31, x0, 404