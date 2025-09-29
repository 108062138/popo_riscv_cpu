main: 
    addi a0, x0, 8 # 00: 00800513, a0 = arr[] 
    addi a1, x0, 10 # 04: 00500593, a1 = len(arr) 00500593 
    jal fill_data, x1 # 08: 048000ef, offset 72 
    jal bubble_sort, x1 # 12: 00c000ef, offset = 12 
    jal check, x1 # 16: 06c000ef, offset = 108 
bubble_sort: 
    addi t0, x0, 0 # 24:00000293, t0 denoted as finish_swap flag 
    addi t1, x0, 1 # 28:00100313, t1 denoted as i 
for_loop: 
    bge t1, a1, detect_bubble_sort_done # 32: 02b35463, offset = 40 
    add t3, t1, a0 # 36: 00a30e33, t3 = &a[i] 
    lb t4, 0(t3) # 40: 000e0e83, t4 = a[i] 
    lb t5, -1(t3) # 44: fffe0f03, t5 = a[i-1] 
    beq t5, t4, in_order
    blt t5, t4, in_order # 48: 01df4863, ofset = 16 
swap: 
    sb t5, 0(t3) # 52: 01ee0023 
    sb t4, -1(t3) # 56: ffde0fa3 
    addi t0, x0, 1 # 60: 00100293, set swap flag to be true 
in_order: 
    addi t1, t1, 1 # 64: 00130313 
    jal for_loop, x0 # 68: fddff0ef, offset = -36 
detect_bubble_sort_done: 
    bne t0, x0, bubble_sort # 72: fc0298e3, offset = -48 
    jalr x0, x1, 0 # 76: 00008067 
fill_data:
    addi t2, x0, 10 # 80: 00a00393 
    sb t2, 0(a0) # 84: 00750023 
    addi t2, x0, -1 # 88: ffb00393 
    sb t2, 1(a0) # 92: 007500a3 
    addi t2, x0, -2 # 96: 00400393 
    sb t2, 2(a0) #100: 00750123 
    addi t2, x0, 7 #104: 00700393 
    sb t2, 3(a0) #108: 007501a3 
    addi t2, x0, -1 #112: fff00393 
    sb t2, 4(a0) #116: 00750223 
    addi t2, x0, 8 #112: fff00393 
    sb t2, 5(a0) #116: 00750223 
    addi t2, x0, 8 #112: fff00393 
    sb t2, 6(a0) #116: 00750223 
    addi t2, x0, 15 #112: fff00393 
    sb t2, 7(a0) #116: 00750223 
    addi t2, x0, 127 #112: fff00393 
    sb t2, 8(a0) #116: 00750223 
    addi t2, x0, -128 #112: fff00393 
    sb t2, 9(a0) #116: 00750223 
    addi t2, x0, 4 #112: fff00393 
    sb t2, 10(a0) #116: 00750223 
    jalr x0, x1, 0 #120: 00008067 
check:
    addi t0, x0, 0
    addi a2, a1, -1
cmp:
    beq t0, a2, finish_sort
    add t1, t0, a0
    lb t2, 0(t1)
    lb t3, 1(t1)
    blt t3, t2, fuck_up
    addi t0, t0, 1
    jal cmp, x0
finish_sort:
    addi x31, x0, 666
    nop
    nop
    nop
    nop
    nop
fuck_up:
    addi x31, x0, 404
    nop
    nop
    nop
    nop
    nop