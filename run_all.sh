make clean
make sim_chip CPU_VERSION=opt
mkdir -p sim_out
# iterate through the hexas folder and cp it to word_inst.mem one by one, then make run
for file in ./tb/hexas/*.mem; do
    cp $file ./tb/word_inst.mem

    echo "Running simulation with $file"
    ./obj_dir/Vtb_chip > "sim_out/$(basename "$file" .mem).log"
done