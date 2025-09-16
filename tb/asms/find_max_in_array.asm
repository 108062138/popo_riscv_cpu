.text
.global main
main:
    addi x1, x0, 0 # strlen location is at 0
    lh x2, 0(x1) # x2 stores strlen
    addi x1, x0, 2 # base address location is stored at at 2
    lh x8, 0(x1) # x8 stores the base arr[]
find_min:
    addi x3, x0, -10000000 # x3 is psum
    addi x4, x0, 0 # i = 0
iterate_loop:
    beq x4, x2, terminate # i<strlen
    add x6, x8, x4 # x6 <= base arr[] + i
    lb x7, 0(x6) # x7 <= mem[x6]
    blt x3, x7, update_psum # try to update psum. if x3<x7, then update. otherwise, keep looking
    addi x2, x2, 1
    j iterate_loop
update_psum:
    addi x3, x7, 0
    j iterate_loop
terminate:
    addi x31, x0, 666