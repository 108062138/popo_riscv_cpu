# Oct 25 examination: performance bottlenecks

## Setup

- Simulator: Verilator 5.041
- Before running, the `$readmemh` paths in `src/L1_cache/inst_mem.v`, `src/L1_cache/data_mem.v`,
  `src/memory/memory_wrapper_single_port.v` and `src/memory/sram_wrapper_dual_port.v` were changed from absolute
  paths (`/home/popo/Desktop/popo_train_cpu/...`) to repo-relative `tb/...`. Otherwise `run_all_tb.sh`
  silently loads programs from another checkout. (Not committed yet.)

## Test results (cycles)

| Test | basic | train_fix_forward_bug | jal_opt | opt |
|---|---|---|---|---|
| bubble_sort | 1387 | 1387 | **1285** | 1339 |
| nested_for_loop | 199 | 199 | **174** | 178 |
| normal_for_loop | 61 | 61 | **53** | 55 |
| find_max_in_array | 164 | 164 | **151** | 155 |
| factorial / JAL_JALR | 152 | 152 | **144** | 146 |
| load_then_use | 17 | FAIL | 17 | 19 |
| other 10 tests | pass | pass | pass | pass |

- `train_fix_forward_bug` fails `load_then_use` as intended. The bug is in
  `src/train_fix_forward_bug_five_stage_cpu/EX/handle_rs2_for_alu.v:42`, which uses `if` instead of `else if`, so the
  WB forward overrides the MEM forward.
- `opt` (branch prediction) is slower than `jal_opt` on every loop-heavy test.
- `sim_asyncfifo` passes with no data mismatches. `sim_axi` runs to completion, but it doesn't check the data.

## Cycle breakdown: `opt` CPU, `test_bubble_sort`

1339 cycles for 890 retired instructions, so CPI is about 1.50.
Branches: 292 executed, 93 taken.

| Rank | Cause | Lost cycles | Share |
|---|---|---|---|
| 1 | Branch mispredict, resolved in EX (2 cycles each) | 116 × 2 ≈ 232 | ~17% |
| 2 | ID-stage redirect: `jal` (102) + predicted-taken (39), 1 cycle each | 141 | ~11% |
| 3 | Load-then-use stall (1 cycle each) | 99 | ~7% |
| 4 | `jalr` resolved in EX (2 cycles each) | 4 | <1% |

The categories overlap slightly, so the numbers are approximate. In `factorial` / `JAL_JALR`, `jalr` costs
9 × 2 = 18 cycles (~12%).

The breakdown was measured with a separate profiling testbench outside the repo. It counts, each cycle,
`fix_predict_EX` > `meet_jalr_EX` > `stall_PC_IF` > `flush_IF_ID`, which is the same priority as `hazard_detection`.

## Bottlenecks

### 1. Branch predictor (`src/cpu/branch_prediction.v`)

- There is one global 2-bit counter shared by every branch, with no per-PC table. In bubble sort, `bge`/`beq`/`blt`/`bne`
  keep pushing the shared counter in different directions.
- It is worse than static not-taken. Static not-taken would mispredict 93 times. The predictor mispredicts 116 times and
  also pays 39 cycles of ID redirect for predicted-taken branches. This is why `opt` is slower than `jal_opt`.
- ~~Suspected correctness issue~~ **Ruled out (checked later on Oct 25):** `fix_predict_EX` compares the branch result
  against the counter's *current* state, not the prediction made in ID. A monitor that recorded the real ID guess for
  every branch found 0 disagreements in all tests, including both historical bubble_sort versions (292 branches
  compared in bubble_sort). The counter only crosses the taken/not-taken boundary on a mispredict, and a mispredict
  always flushes the next branch out of ID, so a stale counter can never change a guess. The predictor is correct;
  it is just slow on these tests.
- New tests confirm this. On `test_loop_bottom` (do-while loops, mostly taken branches) `opt` takes 648 cycles vs
  731 for `jal_opt` (−11%). On `test_branch_pattern` (alternating + never-taken + loop branch in one loop) `opt` takes
  296 vs 264 (+12%), with 47 mispredicts out of 81 branches, because the branches fight over the shared counter.
- Possible fix: a PC-indexed table of 2-bit counters (BHT), with the ID prediction carried down the pipeline to EX.

### 2. ID-stage redirect for `jal` and predicted-taken branches

- The target is only known in ID, so the instruction fetched after it is always flushed, costing 1 cycle.
- Bubble sort loops end with `jal for_loop`, so this costs 102 cycles.
- Possible fix: a BTB checked in IF. In software, rotate the loops so the branch is at the bottom, which removes the `jal`.

### 3. Load-then-use stall

- `lb t5, -1(t3)` followed right away by `beq t5, t4, ...` costs 1 cycle per iteration.
- This is inherent to a 5-stage pipeline. Reordering the instructions in the assembly hides most of it.

### 4. Branch / `jalr` resolution in EX

- A mispredict or `jalr` flushes IF/ID and ID/EX, costing 2 cycles.
- Moving the compare and the jalr target into ID would cut this to 1 cycle. The cost is forwarding into ID and a longer
  path through that stage.

### 5. Not visible yet: memory

- `inst_mem` and `data_mem` respond combinationally and `inst_mem_hazard` / `data_mem_hazard` are always 0.
- Once L1 misses go through DMA → AXI on the slow `sys_clk`, memory latency will probably outweigh all of the above.

## Other issues noticed

- The README refers to `run_all.sh` and `tb/hexa/`. The real names are `run_all_tb.sh` and `tb/hexas/`.
- The `make sim_alu` target points to `src/cpu/EX/tb_alu.v`, which doesn't exist.

## Progress after Oct 25 work (Phase 1 + 2 of the plan)

### Testbench now checks every instruction

- `tb/iss/rv32_iss.py`: reference RV32IM model of this machine (Harvard memories, regs reset to `3*i`).
- `tb/tb_chip.sv` writes a commit trace (`pc inst rd value` per instruction reaching WB) and a store trace.
  `tb/iss/compare_trace.py` diffs them against the reference and prints the first mismatch.
- `run_all_tb.sh` passes a test only if `x31 == 666` **and** both traces match, and it prints cycles and CPI.
- This already catches a case the old check missed: on `train_fix_forward_bug`, `test_LOAD` reached 666, but a load
  returns a stale value (`deadb6f0` instead of `deadbeef`).
- New tests: `test_loop_bottom` (do-while loops, taken-heavy) and `test_branch_pattern` (alternating + never-taken +
  loop branch in one loop).

### Branch predictor rebuilt (`src/cpu/branch_prediction.v`)

- `make sim_chip CPU_VERSION=opt PRED=static|global|bht BTB=0|1` (default `bht`, `BTB=1`).
- BHT: 16 two-bit counters indexed by `PC[5:2]`, starting at weakly not-taken.
- BTB: 16 entries, looked up in IF with full-PC tags and filled in ID. A hit on a `jal` or on a taken-predicted
  branch fetches the target next cycle, so the 1-cycle ID redirect goes away.
- Each branch's guess travels IF → ID → EX, and EX compares the outcome with that guess.

Total cycles over all 18 tests, all trace-checked (`imgs/perf_predictor_configs.png`):

| Config | Total cycles | vs jal_opt |
|---|---|---|
| basic | 3309 | +5% |
| jal_opt (no prediction) | 3143 | — |
| old opt (one shared counter) | 3169 | +1% |
| BHT, no BTB | 3026 | −4% |
| BTB only (static not-taken) | 2993 | −5% |
| global counter + BTB | 2858 | −9% |
| **BHT + BTB (new default)** | **2682** | **−15%** |

Lessons:
- Neither the BHT nor the BTB helps much alone. The BTB removes the `jal` cost, and the BHT then makes taken guesses
  free instead of costing 1 cycle.
- Counters starting at weakly-taken cost a 2-cycle mispredict the first time each branch runs (bad for code that
  runs once). Starting at weakly-not-taken fixes that.
- A 2-bit counter can't learn an alternating T/NT branch: starting from a weak state it flips between the two weak
  states and is wrong every time. That would need a history-based predictor (e.g. gshare).
