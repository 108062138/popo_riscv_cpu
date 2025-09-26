#!/bin/bash
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'
# Check if an argument was provided
if [ -z "$1" ]; then
  echo "No CPU version provided. Using 'opt' as default. Currently support 'opt', 'basic', 'train_fix_forward_bug', 'jal_opt' for cpu"
  CPU_VERSION="opt"
else
  CPU_VERSION=$1
fi
make clean
cp $2 ./tb/word_inst.mem
make sim_chip CPU_VERSION=$CPU_VERSION