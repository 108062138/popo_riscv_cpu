addi x0, x0, 0
addi x0, x0, 0
addi x0, x0, 0
addi x1, x0, -88
addi x2, x0, -33
addi x3, x0, 6
sw x1, 1(x3) # mem[7] <= -88 with strob 1111
addi x2, x0, 24
addi x1, x0, -123
sh x1, 2(x2) # mem[26] <= 123 with strob 0011
addi x1, x0, 87
sb x1, 0(x2) # mem[24] <= 87 with strob 0001
addi x31, x0, 666