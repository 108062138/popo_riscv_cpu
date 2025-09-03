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
    # psum = 10
    addi t2, x0, 10
    
    # for(int i=0; i<3; i=i+1)
    # i=0
    addi t0, x0, 0
    # loop bound = 3
    addi t1, x0, 3

loop_condition:
    # if (i >= 3) break;
    bge t0, t1, loop_end

    # psum = psum + i;
    add t2, t2, t0

    # i = i + 1;
    addi t0, t0, 1

    # jump back to the condition check
    j loop_condition

loop_end:
    # res = psum;
    addi s0, t2, 0