#!/bin/bash

# Check if an argument was provided
if [ -z "$1" ]; then
  echo "No CPU version provided. Using 'opt' as default."
  CPU_VERSION="opt"
else
  CPU_VERSION=$1
fi
make clean
make sim_chip CPU_VERSION=$CPU_VERSION
mkdir -p sim_out_$CPU_VERSION
# iterate through the hexas folder and cp it to word_inst.mem one by one, then make run
for file in ./tb/hexas/*.mem; do
    cp $file ./tb/word_inst.mem

    # echo "Running simulation with $file"
    ./obj_dir/Vtb_chip > "sim_out_$CPU_VERSION/$(basename "$file" .mem).log"
    # grep log's comment for success or failure
    if grep -q "TEST PASS" "sim_out_$CPU_VERSION/$(basename "$file" .mem).log"; then
        echo "Test with $file: PASS"
    else
        echo "Test with $file: FAIL"
    fi
done