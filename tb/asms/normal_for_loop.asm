#
    # C code:
    # int res, psum;
    # psum = 10;
    # for(int i=0; i<8; i=i+1){
    #     psum = psum + i;
    # }
    # res = psum;
    # res = res * 2
    
    # Register Mapping:
    # x2: i
    # x3: loop bound (8)
    # x1: psum
    # x4: res: 76
    
.text
.global main

main:
    addi x1, x0, 10       # 00a00393 addr 0 0
    addi x2, x0, 0        # 00000293 addr 1 4
    addi x3, x0, 8        # 00300313 addr 2 8
loop_condition:
    bge x2, x3, loop_end  # 0062d863 addr 3 12
    add x1, x1, x2        # 005383b3 addr 4 16
    addi x2, x2, 1        # 00128293 addr 5 20
    j loop_condition      # ff5ff06f addr 6 24
loop_end:
    addi x4, x1, 0        # 00038413 addr 7 28
    add x4, x4, x4        # 00840433 addr 8 32
    addi x31, x0, 666