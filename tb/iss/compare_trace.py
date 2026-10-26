#!/usr/bin/env python3
"""Compare the RTL traces from tb_chip.sv with the reference traces from rv32_iss.py.

Prints "TRACE MATCH" or "TRACE MISMATCH" plus the first differing line (with a
few lines of context), and exits 0 only on a match.
"""
import argparse
import sys


def read_lines(path):
    try:
        with open(path) as f:
            return [line.strip() for line in f if line.strip()]
    except FileNotFoundError:
        return None


def first_diff(expected, actual):
    for i, (e, a) in enumerate(zip(expected, actual)):
        if e != a:
            return i
    if len(expected) != len(actual):
        return min(len(expected), len(actual))
    return None


def report(kind, expected, actual, context=3):
    i = first_diff(expected, actual)
    if i is None:
        return True
    print(f"TRACE MISMATCH in {kind} trace at entry {i} "
          f"(reference has {len(expected)} entries, RTL has {len(actual)})")
    for j in range(max(0, i - context), i):
        print(f"    same      {expected[j]}")
    print(f"  > reference {expected[i] if i < len(expected) else '<end of trace>'}")
    print(f"  > rtl       {actual[i] if i < len(actual) else '<end of trace>'}")
    return False


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("iss_commit")
    p.add_argument("rtl_commit")
    p.add_argument("iss_stores")
    p.add_argument("rtl_stores")
    args = p.parse_args()

    traces = {name: read_lines(path) for name, path in vars(args).items()}
    missing = [name for name, lines in traces.items() if lines is None]
    if missing:
        print(f"TRACE MISMATCH: missing trace file(s): {', '.join(missing)}")
        return 1

    ok = report("commit", traces["iss_commit"], traces["rtl_commit"])
    ok = report("store", traces["iss_stores"], traces["rtl_stores"]) and ok
    if ok:
        print(f"TRACE MATCH ({len(traces['iss_commit'])} instructions, {len(traces['iss_stores'])} stores)")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
