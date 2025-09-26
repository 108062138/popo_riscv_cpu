# ==== Config ====
CHIP_SRCS           := src/chip.v
AXI_SRCS  		  	:= $(wildcard src/axi/*.v)
L1_CACHE_SRCS  		:= $(wildcard src/L1_cache/*.v)
ASYNCFIFO_SRCS    	:= $(wildcard src/asyncfifo/*.v)
BUS_INTEGRATE_SRCS	:= $(wildcard src/bus_integrate/*.v)
MEMORY_SRCS			:= $(wildcard src/memory/*.v)
# three type of cpu is offered: bug naive five stage, naive five stage, opt five stage
CPU_VERSION         := basic
CPU_SRCS_OPT        := $(wildcard src/cpu/*.v \
                                  src/cpu/IF/*.v \
                                  src/cpu/PC/*.v \
                                  src/cpu/ID/*.v \
                                  src/cpu/EX/*.v \
                                  src/cpu/MEM/*.v \
                                  src/cpu/WB/*.v)
CPU_SRCS_BASIC      := $(wildcard src/basic_five_stage_cpu/*.v \
                                  src/basic_five_stage_cpu/IF/*.v \
                                  src/basic_five_stage_cpu/PC/*.v \
                                  src/basic_five_stage_cpu/ID/*.v \
                                  src/basic_five_stage_cpu/EX/*.v \
                                  src/basic_five_stage_cpu/MEM/*.v \
                                  src/basic_five_stage_cpu/WB/*.v)
CPU_SRCS_TRAIN_FIX_FORWARD_BUG  := $(wildcard src/train_fix_forward_bug_five_stage_cpu/*.v \
                                  			  src/train_fix_forward_bug_five_stage_cpu/IF/*.v \
                                  			  src/train_fix_forward_bug_five_stage_cpu/PC/*.v \
                                  			  src/train_fix_forward_bug_five_stage_cpu/ID/*.v \
                                  			  src/train_fix_forward_bug_five_stage_cpu/EX/*.v \
                                  			  src/train_fix_forward_bug_five_stage_cpu/MEM/*.v \
                                  			  src/train_fix_forward_bug_five_stage_cpu/WB/*.v)
CPU_SRCS_JAL_OPT    := $(wildcard src/jal_opt_five_stage_cpu/*.v \
                                  src/jal_opt_five_stage_cpu/IF/*.v \
                                  src/jal_opt_five_stage_cpu/PC/*.v \
                                  src/jal_opt_five_stage_cpu/ID/*.v \
                                  src/jal_opt_five_stage_cpu/EX/*.v \
                                  src/jal_opt_five_stage_cpu/MEM/*.v \
                                  src/jal_opt_five_stage_cpu/WB/*.v)

ifeq ($(CPU_VERSION), basic)
	CPU_SRCS := $(CPU_SRCS_BASIC)
else ifeq ($(CPU_VERSION), opt)
	CPU_SRCS := $(CPU_SRCS_OPT)
else ifeq ($(CPU_VERSION), train_fix_forward_bug)
	CPU_SRCS := $(CPU_SRCS_TRAIN_FIX_FORWARD_BUG)
else ifeq ($(CPU_VERSION), jal_opt)
	CPU_SRCS := $(CPU_SRCS_JAL_OPT)
else 
    $(error Unknown CPU_VERSION '$(CPU_VERSION)', must be 'basic' or 'opt' or 'train_fix_forward_bug')
endif
# ==== Build ====
BUILD     		  	:= obj_dir
SIM_CHIP  		  	:= $(BUILD)/Vtb_chip
SIM_AXI           	:= $(BUILD)/Vtb_axi
SIM_ASYNCFIFO     	:= $(BUILD)/Vtb_asyncfifo
SIM_ALU          	:= $(BUILD)/Vtb_alu

.PHONY: all run sim_chip clean sim_axi sim_asyncfifo sim_alu

all: run

$(SIM_CHIP): tb/tb_chip.sv $(CHIP_SRCS) $(L1_CACHE_SRCS) $(CPU_SRCS) | $(BUILD)
	@echo "[VERILATOR] Compile -> $@"
	verilator --trace-vcd --binary -j 32 --top-module tb_chip -Isrc/cpu tb/tb_chip.sv $(CHIP_SRCS) $(L1_CACHE_SRCS) $(CPU_SRCS)

$(SIM_ALU): src/cpu/EX/tb_alu.v src/cpu/EX/alu.v | $(BUILD)
	@echo "[VERILATOR] Compile -> $@"
	verilator --trace-vcd --binary -j 32 --top-module tb_alu -Isrc/cpu src/cpu/EX/tb_alu.v src/cpu/EX/alu.v

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

sim_alu: $(SIM_ALU)
	@echo "[VVP] Run -> ./$(SIM_ALU)"
	./$(SIM_ALU)

run: sim_chip

clean:
	@echo "[CLEAN]"
	@rm -rf $(BUILD) *.vcd *.fst *.lxt *.lxt2 *.vcd.gz
