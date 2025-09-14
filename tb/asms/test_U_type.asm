# somehow assembly2binary can't translate those lines
# x0 = 0 (hardwired, always 0)
# x1 = 0x20000000
# x2 = 0xF2BA000

lui   x1, 8192      # 0x200000B7
addi  x0, x0, 100   # 0x06400013
addi  x0, x0, 100   # 0x06400013
auipc x2, 62138     # 0xF2BA117