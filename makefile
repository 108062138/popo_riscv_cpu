export CORE_ROOT=$(shell pwd)
# ==== Config ====
TB_FILE   := tb/tb.v
SRCS      := $(wildcard src/*.v)
BUILD     := build
SIM_OUT   := $(BUILD)/sim.out
VCD_FILE  := $(BUILD)/cpu_tb.vcd     # 請與 testbench 內 $dumpfile("cput_tb.vcd") 一致
IVFLAGS   := -Wall -g2012 # 若只用 Verilog-2005 可移除 -g2012

.PHONY: all run sim wave clean

all: run

# 編譯：先 TB，再所有 src/*.v
$(SIM_OUT): $(TB_FILE) $(SRCS) | $(BUILD)
	@echo "[IVL] Compile -> $@"
	iverilog $(IVFLAGS) -o $@ $(TB_FILE) $(SRCS)

$(BUILD):
	@mkdir -p $(BUILD)

# 執行模擬
sim: $(SIM_OUT)
	@echo "[VVP] Run -> $(SIM_OUT)"
	vvp $(SIM_OUT)

# 一鍵：編譯 + 模擬
run: sim

# 開波形（需 TB 內有 $dumpfile/$dumpvars）
wave:
	@if [ -f "$(VCD_FILE)" ]; then \
		echo "[GTKWave] Open $(VCD_FILE)"; \
		gtkwave "$(VCD_FILE)"; \
	else \
		echo "[WARN] 找不到 $(VCD_FILE)，先 `make run` 產生波形吧！"; \
	fi

clean:
	@echo "[CLEAN]"
	@rm -rf $(BUILD) *.vcd *.fst *.lxt *.lxt2 *.vcd.gz
