main:
    addi x1, x0, 100
    addi x2, x0, 21
    div x3, x1, x2
mod:
    mul x4, x3, x2
    sub x5, x1, x4
    addi x31, x0, 666