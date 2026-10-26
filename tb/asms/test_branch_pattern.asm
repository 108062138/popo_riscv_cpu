# Three branches with different habits in one loop, for 32 iterations:
#   beq  even/odd check   -> alternates taken / not taken
#   blt  "i > n" guard    -> never taken, placed right after the beq
#   blt  loop branch      -> taken on every iteration but the last
# One counter shared by all branches gets pushed around by the mix;
# a per-branch table can learn each habit separately.
main:
    addi x1, x0, 0
    addi x2, x0, 32
    addi x3, x0, 0
loop:
    andi x5, x1, 1
    beq x5, x0, even
    blt x2, x1, fuck_up
    addi x3, x3, 1
even:
    addi x1, x1, 1
    blt x1, x2, loop
    # 16 odd numbers in 0..31
    addi x15, x0, 16
    bne x3, x15, fuck_up
    addi x31, x0, 666
    nop
    nop
    nop
    nop
    nop
fuck_up:
    addi x31, x0, 404
