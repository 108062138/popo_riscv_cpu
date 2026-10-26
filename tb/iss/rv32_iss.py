#!/usr/bin/env python3
"""Reference RV32IM instruction-set simulator for the popo CPU testbench.

It runs a program the same way tb_chip does and writes two traces that
tb/tb_chip.sv also writes, so they can be diffed line by line:

  commit trace: one line per executed instruction, in program order
                "<pc> <inst> <rd> <value>"   ("-" "-" when no register is written)
  store trace:  one line per store, in program order
                "<byte addr> <data masked by strobe> <strobe>"

Machine model (matches the RTL, not a generic RISC-V platform):
  * Harvard: instruction memory and data memory are separate, both start at 0.
  * Data memory is byte addressed, little endian, NUM_WORDS 32-bit words,
    loaded from tb/word_data.mem. Missing words read as 0.
  * Register reset value: x[i] = 3*i (regfile INIT_STYLE=1), x0 = 0.
  * The run ends right after an instruction writes 666 (pass) or 404 (fail)
    into x31, like tb_chip's wait condition.
"""
import argparse
import sys

MASK = 0xFFFFFFFF


def sx(value, bits):
    """Sign-extend `value` from `bits` bits to a Python int."""
    value &= (1 << bits) - 1
    return value - (1 << bits) if value >> (bits - 1) else value


def s32(value):
    return sx(value, 32)


def tdiv(a, b):
    """Integer division rounding toward zero, like RISC-V div."""
    q = abs(a) // abs(b)
    return q if (a < 0) == (b < 0) else -q


def load_hex_words(path):
    words = []
    with open(path) as f:
        for line in f:
            line = line.split("//")[0].strip()
            if line:
                words.append(int(line, 16))
    return words


class Machine:
    def __init__(self, inst_words, data_words, num_words, reg_init):
        self.imem = inst_words
        self.dmem = bytearray(num_words * 4)
        for i, w in enumerate(data_words[:num_words]):
            self.dmem[4 * i:4 * i + 4] = w.to_bytes(4, "little")
        self.x = [(3 * i) & MASK if reg_init == 1 else (i if reg_init == 0 else 0) for i in range(32)]
        self.x[0] = 0
        self.pc = 0

    def load(self, addr, size, signed):
        value = int.from_bytes(self.dmem[addr:addr + size], "little")
        return sx(value, size * 8) & MASK if signed else value

    def store(self, addr, size, value):
        self.dmem[addr:addr + size] = (value & ((1 << (size * 8)) - 1)).to_bytes(size, "little")

    def step(self):
        """Execute one instruction. Returns (commit_line, store_line_or_None)."""
        pc = self.pc
        idx = pc >> 2
        if idx >= len(self.imem):
            raise RuntimeError(f"PC 0x{pc:08x} runs past the end of instruction memory")
        inst = self.imem[idx]
        op = inst & 0x7F
        rd = (inst >> 7) & 0x1F
        f3 = (inst >> 12) & 0x7
        rs1 = (inst >> 15) & 0x1F
        rs2 = (inst >> 20) & 0x1F
        f7 = inst >> 25
        a, b = self.x[rs1], self.x[rs2]
        imm_i = sx(inst >> 20, 12)
        imm_s = sx(((inst >> 25) << 5) | ((inst >> 7) & 0x1F), 12)
        imm_b = sx((((inst >> 31) & 1) << 12) | (((inst >> 7) & 1) << 11)
                   | (((inst >> 25) & 0x3F) << 5) | (((inst >> 8) & 0xF) << 1), 13)
        imm_u = inst & 0xFFFFF000
        imm_j = sx((((inst >> 31) & 1) << 20) | (((inst >> 12) & 0xFF) << 12)
                   | (((inst >> 20) & 1) << 11) | (((inst >> 21) & 0x3FF) << 1), 21)

        next_pc = (pc + 4) & MASK
        wb = None          # value written to rd, or None
        store_line = None

        if op == 0x37:                      # LUI
            wb = imm_u
        elif op == 0x17:                    # AUIPC
            wb = (pc + imm_u) & MASK
        elif op == 0x6F:                    # JAL
            wb = (pc + 4) & MASK
            next_pc = (pc + imm_j) & MASK
        elif op == 0x67:                    # JALR
            wb = (pc + 4) & MASK
            next_pc = (a + imm_i) & MASK & ~1
        elif op == 0x63:                    # BRANCH
            taken = {
                0: a == b, 1: a != b,
                4: s32(a) < s32(b), 5: s32(a) >= s32(b),
                6: a < b, 7: a >= b,
            }.get(f3)
            if taken is None:
                raise RuntimeError(f"bad branch funct3 at 0x{pc:08x}: {inst:08x}")
            if taken:
                next_pc = (pc + imm_b) & MASK
        elif op == 0x03:                    # LOAD
            addr = (a + imm_i) & MASK
            size, signed = {0: (1, True), 1: (2, True), 2: (4, False), 4: (1, False), 5: (2, False)}[f3]
            wb = self.load(addr, size, signed)
        elif op == 0x23:                    # STORE
            addr = (a + imm_s) & MASK
            size = {0: 1, 1: 2, 2: 4}[f3]
            self.store(addr, size, b)
            strobe = (1 << size) - 1
            store_line = f"{addr:08x} {b & ((1 << (size * 8)) - 1):08x} {strobe:x}"
        elif op == 0x13:                    # OP-IMM
            shamt = (inst >> 20) & 0x1F
            wb = {
                0: (a + imm_i),
                1: (a << shamt),
                2: int(s32(a) < imm_i),
                3: int(a < (imm_i & MASK)),
                4: (a ^ imm_i),
                5: (s32(a) >> shamt) if f7 & 0x20 else (a >> shamt),
                6: (a | imm_i),
                7: (a & imm_i),
            }[f3] & MASK
        elif op == 0x33:                    # OP / M extension
            if f7 == 0x01:
                sa, sb = s32(a), s32(b)
                if f3 == 0:
                    wb = sa * sb
                elif f3 == 1:
                    wb = (sa * sb) >> 32
                elif f3 == 2:
                    wb = (sa * b) >> 32
                elif f3 == 3:
                    wb = (a * b) >> 32
                elif f3 == 4:   # div: round toward zero
                    wb = -1 if sb == 0 else (-2**31 if (sa == -2**31 and sb == -1) else tdiv(sa, sb))
                elif f3 == 5:
                    wb = MASK if b == 0 else a // b
                elif f3 == 6:
                    wb = sa if sb == 0 else (0 if (sa == -2**31 and sb == -1) else sa - sb * tdiv(sa, sb))
                else:
                    wb = a if b == 0 else a % b
                wb &= MASK
            else:
                sub_or_sra = f7 & 0x20
                wb = {
                    0: (a - b) if sub_or_sra else (a + b),
                    1: (a << (b & 0x1F)),
                    2: int(s32(a) < s32(b)),
                    3: int(a < b),
                    4: (a ^ b),
                    5: (s32(a) >> (b & 0x1F)) if sub_or_sra else (a >> (b & 0x1F)),
                    6: (a | b),
                    7: (a & b),
                }[f3] & MASK
        else:
            raise RuntimeError(f"unknown opcode 0x{op:02x} at 0x{pc:08x}: {inst:08x}")

        if wb is not None and rd != 0:
            self.x[rd] = wb & MASK
            commit = f"{pc:08x} {inst:08x} {rd:02d} {self.x[rd]:08x}"
        else:
            commit = f"{pc:08x} {inst:08x} - -"
        self.pc = next_pc
        return commit, store_line, rd if (wb is not None and rd != 0) else None


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("inst", help="instruction memory hex file (e.g. tb/hexas/test_LOAD.mem)")
    p.add_argument("--data", default="tb/word_data.mem", help="data memory hex file")
    p.add_argument("--num-words", type=int, default=128, help="data memory size in words")
    p.add_argument("--reg-init", type=int, default=1, help="regfile INIT_STYLE (0: i, 1: 3*i, 2: 0)")
    p.add_argument("--max-steps", type=int, default=100000)
    p.add_argument("--commit", default="iss_commit.log", help="commit trace output")
    p.add_argument("--stores", default="iss_store.log", help="store trace output")
    args = p.parse_args()

    m = Machine(load_hex_words(args.inst), load_hex_words(args.data), args.num_words, args.reg_init)
    commits, stores = [], []
    result = "TIMEOUT"
    for _ in range(args.max_steps):
        commit, store, rd = m.step()
        commits.append(commit)
        if store:
            stores.append(store)
        if rd == 31 and m.x[31] in (666, 404):
            result = "PASS" if m.x[31] == 666 else "FAIL"
            break

    with open(args.commit, "w") as f:
        f.write("\n".join(commits) + "\n")
    with open(args.stores, "w") as f:
        f.write("\n".join(stores) + ("\n" if stores else ""))
    print(f"ISS {result} instructions={len(commits)} stores={len(stores)}")
    return 0 if result == "PASS" else 1


if __name__ == "__main__":
    sys.exit(main())
