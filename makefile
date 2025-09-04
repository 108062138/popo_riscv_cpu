export CORE_ROOT=$(shell pwd)
# ==== Config ====
TB_FILE   := tb/tb.v
SRCS      := $(wildcard src/*.v)
AXI_SRCS  := $(wildcard src/axi/*.v)
BUILD     := obj_dir
SIM_OUT   := $(BUILD)/Vtb
VCD_FILE  := cpu_tb.vcd

.PHONY: all run sim clean

all: run

$(SIM_OUT): $(TB_FILE) $(SRCS) | $(BUILD)
	@echo "[VERILATOR] Compile -> $@"
	verilator --trace-vcd --binary -j 32 --top-module tb $(TB_FILE) $(SRCS)

$(BUILD):
	@mkdir -p $(BUILD)

sim: $(SIM_OUT)
	@echo "[VVP] Run -> $(SIM_OUT)"

run: sim

clean:
	@echo "[CLEAN]"
	@rm -rf $(BUILD) *.vcd *.fst *.lxt *.lxt2 *.vcd.gz
