addi x0, x0, 0
addi x0, x0, 0
addi x0, x0, 0
addi x1, x0, 88
addi x2, x0, -33
addi x3, x0, 6
sw x1, 1(x3)
addi x2, x0, 24
addi x1, x0, 123
sh x1, 2(x2)
addi x1, x0, 87
sb x1, 0(x2)
addi x31, x0, 666

0009000a
00080001
0007000b
00060002
0005000c
00000003
0000000d
00000004
0000000e
00000005
deadbeef
00000006

0a
00
09
00
01
00
08
00