#!/bin/bash
# Run every program in tb/hexas on one CPU version.
# A test passes only if the program reports success (x31 == 666) AND the RTL
# commit/store traces match the reference model (tb/iss/rv32_iss.py).
#
# usage: ./run_all_tb.sh [opt|basic|jal_opt|train_fix_forward_bug]
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

if [ -z "$1" ]; then
  echo "No CPU version provided. Using 'opt' as default. Currently support 'opt', 'basic', 'train_fix_forward_bug', 'jal_opt' for cpu"
  CPU_VERSION="opt"
else
  CPU_VERSION=$1
fi
OUT="sim_out_$CPU_VERSION${PRED:+_$PRED}${BTB:+_btb$BTB}"

make clean > /dev/null
rm -rf "$OUT"
mkdir -p "$OUT"
if ! make "obj_dir/Vtb_chip" CPU_VERSION="$CPU_VERSION" > "$OUT/compile.log" 2>&1; then
  echo -e "${RED}Compile failed${NC}, see $OUT/compile.log"
  exit 1
fi

# run_all_tb.sh overwrites tb/word_inst.mem for each test; put it back at the end.
cp tb/word_inst.mem "$OUT/word_inst.mem.orig"
trap 'cp "$OUT/word_inst.mem.orig" tb/word_inst.mem' EXIT

num_fail=0
for file in ./tb/hexas/*.mem; do
  name=$(basename "$file" .mem)
  cp "$file" ./tb/word_inst.mem

  ./obj_dir/Vtb_chip +commit="$OUT/$name.rtl_commit.log" +stores="$OUT/$name.rtl_store.log" > "$OUT/$name.log" 2>&1
  python3 tb/iss/rv32_iss.py "$file" --commit "$OUT/$name.iss_commit.log" --stores "$OUT/$name.iss_store.log" > /dev/null
  python3 tb/iss/compare_trace.py "$OUT/$name.iss_commit.log" "$OUT/$name.rtl_commit.log" \
                                  "$OUT/$name.iss_store.log" "$OUT/$name.rtl_store.log" > "$OUT/$name.trace_cmp.log"
  trace_ok=$?

  perf=$(grep -oP '^PERF cycles=\K[0-9]+' "$OUT/$name.log")
  cpi=$(grep -oP '^PERF .*cpi=\K[0-9.]+' "$OUT/$name.log")
  if grep -q "TEST PASS" "$OUT/$name.log" && [ $trace_ok -eq 0 ]; then
    printf "Test %-28s ${GREEN}PASS${NC}  cycles=%-5s cpi=%s\n" "$name" "$perf" "$cpi"
  else
    num_fail=$((num_fail + 1))
    if grep -q "TEST PASS" "$OUT/$name.log"; then
      reason="program passed but trace differs from reference"
    elif grep -q "TEST FAIL" "$OUT/$name.log"; then
      reason="program reported failure (x31 == 404)"
    else
      reason="timeout"
    fi
    printf "Test %-28s ${RED}FAIL${NC}  (%s)\n" "$name" "$reason"
    sed -n '1,6p' "$OUT/$name.trace_cmp.log" | sed 's/^/      /'
  fi
done

if [ $num_fail -eq 0 ]; then
  echo -e "${GREEN}All tests passed${NC} on $CPU_VERSION"
else
  echo -e "${RED}$num_fail test(s) failed${NC} on $CPU_VERSION"
fi
exit $num_fail
