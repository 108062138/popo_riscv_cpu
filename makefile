export CORE_ROOT=$(shell pwd)
# ==== Config ====
CHIP_TB_FILE   	  	:= tb/tb_chip.sv
AXI_TB_FILE    	  	:= tb/tb_axi.sv
CHIP_SRCS           := src/chip.v
AXI_SRCS  		  	:= $(wildcard src/axi/*.v)
L1_CACHE_SRCS  		:= $(wildcard src/L1_cache/*.v)
CPU_SRCS            := $(wildcard src/cpu/*.v src/cpu/IF/*.v src/cpu/PC/*.v src/cpu/ID/*.v src/cpu/EX/*.v src/cpu/MEM/*.v src/cpu/WB/*.v)
ASYNCFIFO_SRCS    	:= $(wildcard src/asyncfifo/*.v)
BUS_INTEGRATE_SRCS	:= $(wildcard src/bus_integrate/*.v)
MEMORY_SRCS			:= $(wildcard src/memory/*.v)
BUILD     		  	:= obj_dir
SIM_CHIP  		  	:= $(BUILD)/Vtb_chip
SIM_AXI           	:= $(BUILD)/Vtb_axi
SIM_ASYNCFIFO     	:= $(BUILD)/Vtb_asyncfifo

.PHONY: all run sim_chip clean sim_axi sim_asyncfifo

all: run

$(SIM_CHIP): tb/tb_chip.sv $(CHIP_SRCS) $(L1_CACHE_SRCS) $(CPU_SRCS) | $(BUILD)
	@echo "[VERILATOR] Compile -> $@"
	verilator --trace-vcd --binary -j 32 --top-module tb_chip -Isrc/cpu tb/tb_chip.sv $(CHIP_SRCS) $(L1_CACHE_SRCS) $(CPU_SRCS)

$(SIM_AXI): tb/tb_axi.sv $(AXI_SRCS) $(ASYNCFIFO_SRCS) $(BUS_INTEGRATE_SRCS) $(MEMORY_SRCS)| $(BUILD)
	@echo "[VERILATOR] Compile -> $@"
	verilator --trace-vcd --binary -j 32 -Wno-EOFNEWLINE -Wno-WIDTHEXPAND --top-module tb_axi tb/tb_axi.sv $(AXI_SRCS) $(ASYNCFIFO_SRCS) $(BUS_INTEGRATE_SRCS) $(MEMORY_SRCS)

$(SIM_ASYNCFIFO): tb/tb_asyncfifo.sv $(ASYNCFIFO_SRCS) | $(BUILD)
	@echo "[VERILATOR] Compile -> $@"
	verilator --trace-vcd --binary -j 32 -Wno-EOFNEWLINE -Wno-WIDTHEXPAND --top-module tb_asyncfifo tb/tb_asyncfifo.sv $(ASYNCFIFO_SRCS)

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
