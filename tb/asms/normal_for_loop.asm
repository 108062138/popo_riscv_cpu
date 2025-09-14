#
    # C code:
    # int res, psum;
    # psum = 10;
    # for(int i=0; i<3; i=i+1){
    #     psum = psum + i;
    # }
    # res = psum;
    #
    
    # Register Mapping:
    # t0: i
    # t1: loop bound (3)
    # t2: psum
    # s0: res
    
.text
.global main

main:
    addi t2, x0, 10       # 00a00393 addr 0 0
    addi t0, x0, 0        # 00000293 addr 1 4
    addi t1, x0, 3        # 00300313 addr 2 8
loop_condition:
    bge t0, t1, loop_end  # 0062d863 addr 3 12
    add t2, t2, t0        # 005383b3 addr 4 16
    addi t0, t0, 1        # 00128293 addr 5 20
    j loop_condition      # ff5ff06f addr 6 24
loop_end:
    addi s0, t2, 0        # 00038413 addr 7 28
    add s0, s0, s0        # 00840433 addr 8 32