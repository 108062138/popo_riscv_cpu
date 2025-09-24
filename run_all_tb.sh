#!/bin/bash
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'
# Check if an argument was provided
if [ -z "$1" ]; then
  echo "No CPU version provided. Using 'opt' as default. Currently support 'opt', 'basic', 'train_fix_forward_bug' for cpu"
  CPU_VERSION="opt"
else
  CPU_VERSION=$1
fi
make clean
make sim_chip CPU_VERSION=$CPU_VERSION > "sim_out_$CPU_VERSION/compile.log"
rm -r sim_out_$CPU_VERSION
mkdir -p sim_out_$CPU_VERSION
# iterate through the hexas folder and cp it to word_inst.mem one by one, then make run
for file in ./tb/hexas/*.mem; do
    cp $file ./tb/word_inst.mem

    # echo "Running simulation with $file"
    ./obj_dir/Vtb_chip > "sim_out_$CPU_VERSION/$(basename "$file" .mem).log"
    # grep log's comment for success or failure
    if grep -q "TEST PASS" "sim_out_$CPU_VERSION/$(basename "$file" .mem).log"; then
        cycle=$(grep -oP 'TEST PASS! Use cycle\s+\K[0-9]+' "sim_out_$CPU_VERSION/$(basename "$file" .mem).log")
        echo -e "Test with $file: ${GREEN}PASS${NC} (Cycles used: $cycle)"
    else
        echo -e "Test with $file: ${RED}FAIL${NC}"
    fi
done