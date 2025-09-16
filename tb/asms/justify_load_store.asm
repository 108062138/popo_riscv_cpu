init:
    addi s0, x0, 12 # s0 is the base array address
    addi s1, x0, 0 # s1 is i
    addi s2, x0, 16 # at most write 4 content
for_loop:
    beq s2, s1, done
    add s3, s1, s0
    sw s1, 1(s3)
    addi s1, s1, 4 # i++
    j for_loop
done:
    addi x31, x0, 666 # my customized terminate condition