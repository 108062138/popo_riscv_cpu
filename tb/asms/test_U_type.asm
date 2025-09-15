# somehow assembly2binary can't translate those lines
# x0 = 0 (hardwired, always 0)
# x1 = 0x20000000
# x2 = 0xF2BA000

lui   x1, 8192      # 0x200000B7
addi  x0, x0, 100   # 0x06400013
addi  x0, x0, 100   # 0x06400013
auipc x2, 62138     # 0xF2BA117

# fail to code gen by riscv_assembler
# x1 = -5
# x2 = 4
# x6 = 1
# x7 = 0
addi x1, x0, -5   → 0xFFB00093
addi x2, x0, 4    → 0x00400113
slt  x6, x1, x2   → 0x0020A333
sltu x7, x1, x2   → 0x0020B3B3