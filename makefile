export CORE_ROOT=$(shell pwd)
# ==== Config ====
CHIP_TB_FILE   	:= tb/tb_chip.sv
AXI_TB_FILE    	:= tb/tb_axi.sv
SRCS      		:= $(wildcard src/*.v)
AXI_SRCS  		:= $(wildcard src/axi/*.v)
BUILD     		:= obj_dir
SIM_CHIP  		:= $(BUILD)/Vtb_chip
SIM_AXI         := $(BUILD)/Vtb_axi

.PHONY: all run sim_chip clean sim_axi

all: run

$(SIM_CHIP): $(CHIP_TB_FILE) $(SRCS) | $(BUILD)
	@echo "[VERILATOR] Compile -> $@"
	verilator --trace-vcd --binary -j 32 --top-module tb_chip $(CHIP_TB_FILE) $(SRCS)

$(SIM_AXI): $(AXI_TB_FILE) $(AXI_SRCS) | $(BUILD)
	@echo "[VERILATOR] Compile -> $@"
	verilator --trace-vcd --binary -j 32 -Wall --top-module tb_axi $(AXI_TB_FILE) $(AXI_SRCS)

$(BUILD):
	@mkdir -p $(BUILD)

sim_chip: $(SIM_CHIP)
	@echo "[VVP] Run -> ./$(SIM_CHIP)"
	./$(SIM_CHIP)

sim_axi: $(SIM_AXI)
	@echo "[VVP] Run -> ./$(SIM_AXI)"
	./$(SIM_AXI)

run: sim_chip

clean:
	@echo "[CLEAN]"
	@rm -rf $(BUILD) *.vcd *.fst *.lxt *.lxt2 *.vcd.gz
