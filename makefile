export CORE_ROOT=$(shell pwd)
# ==== Config ====
CHIP_TB_FILE   	  := tb/tb_chip.sv
AXI_TB_FILE    	  := tb/tb_axi.sv
ASYNCFIFO_TB_FILE := tb/tb_asyncfifo.sv
SRCS      		  := $(wildcard src/*.v)
AXI_SRCS  		  := $(wildcard src/axi/*.v)
ASYNCFIFO_SRCS    := $(wildcard src/asyncfifo/*.v)
BUILD     		  := obj_dir
SIM_CHIP  		  := $(BUILD)/Vtb_chip
SIM_AXI           := $(BUILD)/Vtb_axi
SIM_ASYNCFIFO     := $(BUILD)/Vtb_asyncfifo

.PHONY: all run sim_chip clean sim_axi sim_asyncfifo

all: run

$(SIM_CHIP): $(CHIP_TB_FILE) $(SRCS) | $(BUILD)
	@echo "[VERILATOR] Compile -> $@"
	verilator --trace-vcd --binary -j 32 --top-module tb_chip $(CHIP_TB_FILE) $(SRCS)

$(SIM_AXI): $(AXI_TB_FILE) $(AXI_SRCS) | $(BUILD)
	@echo "[VERILATOR] Compile -> $@"
	verilator --trace-vcd --binary -j 32 -Wno-EOFNEWLINE --top-module tb_axi $(AXI_TB_FILE) $(AXI_SRCS) $(ASYNCFIFO_SRCS)

$(SIM_ASYNCFIFO): tb/tb_asyncfifo.sv tb/fifo_if.sv $(ASYNCFIFO_SRCS) | $(BUILD)
	@echo "[VERILATOR] Compile -> $@"
	verilator --trace-vcd --binary -j 32 -Wno-EOFNEWLINE -Wno-WIDTHEXPAND --top-module tb_asyncfifo tb/tb_asyncfifo.sv tb/fifo_if.sv $(ASYNCFIFO_SRCS)

$(BUILD):
	@mkdir -p $(BUILD)

sim_chip: $(SIM_CHIP)
	@echo "[VVP] Run -> ./$(SIM_CHIP)"
	./$(SIM_CHIP)

sim_axi: $(SIM_AXI)
	@echo "[VVP] Run -> ./$(SIM_AXI)"
	./$(SIM_AXI)

sim_asyncfifo: $(SIM_ASYNCFIFO)
	@echo "[VVP] Run -> ./$(SIM_ASYNCFIFO)"
	./$(SIM_ASYNCFIFO)

run: sim_chip

clean:
	@echo "[CLEAN]"
	@rm -rf $(BUILD) *.vcd *.fst *.lxt *.lxt2 *.vcd.gz
