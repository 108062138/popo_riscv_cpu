import os
import shutil
from riscv_assembler.convert import AssemblyConverter
# asm_file = './asms/inst.asm'
# asm_file = './asms/test_CAL_R.asm'
# asm_file = './asms/test_CAL_I.asm'
# asm_file = './asms/test_LOAD.asm'
# asm_file = './asms/test_STORE.asm'
# asm_file = './asms/test_forward_normal.asm'
# asm_file = './asms/test_forward_malicious.asm'
# asm_file = './asms/test_alu.asm'
# asm_file = './asms/test_load_then_use.asm'
# asm_file = './asms/test_jal_and_jalr.asm'
# asm_file = './asms/find_max_in_array.asm'
# asm_file = './asms/test_normal_for_loop.asm'
# asm_file = './asms/test_nested_for_loop.asm'
# asm_file = './asms/justify_load_store.asm'
# asm_file = './asms/test_div_mod.asm'
# asm_file = './asms/factorial.asm'

def convert_bin_to_hex(line):
    hex_values = ''
    for i in range(0, len(line), 4):
        byte = line[i:i + 4]
        hex_value = hex(int(byte, 2))[2:].zfill(2)
        hex_values += hex_value[1]
    return hex_values
def convert_file(binary, hexa_file):
    hexas = []
    for content in binary:
        hexa = convert_bin_to_hex(content)
        print(content, '<=>', hexa)
        hexas.append(hexa)
    # dump hexas into test.asm
    with open(hexa_file, 'w') as f:
        f.write('\n'.join(hexas))
        f.flush()
    print("finish writing~~~", hexa_file)
def clean_folder(hexas_path:str):
    os.makedirs(hexas_path, exist_ok=True)

    for hexa_file in os.listdir(hexas_path):
        full_hexa_path = os.path.join(hexas_path, hexa_file)
        if os.path.isfile(full_hexa_path) or os.path.islink(full_hexa_path):
            os.remove(full_hexa_path)
        elif os.path.isdir(full_hexa_path):
            shutil.rmtree(full_hexa_path)
def compile_all_tb():
    current_directory = os.getcwd()
    asms_path = os.path.join(current_directory, 'tb/asms')
    hexas_path = os.path.join(current_directory, 'tb/hexas')
    if not os.path.exists(asms_path):
        print(f"The folder '{asms_path}' was not found.")
    clean_folder(hexas_path)
    for asm_file in os.listdir(asms_path):
        if asm_file.endswith(".asm"):
            asm_file_path = os.path.join(asms_path, asm_file)
            hexa_file_path = os.path.join(hexas_path, os.path.splitext(asm_file)[0] + ".mem")

            print(f"🔄 asm file: {asm_file_path}, hexa file: {hexa_file_path}")

            converter = AssemblyConverter()
            binary = converter.convert(asm_file_path)
            convert_file(binary, hexa_file_path)

if __name__=="__main__":
    compile_all_tb()