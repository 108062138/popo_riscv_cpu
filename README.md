popo risc-v SoC 
===

## goal

![overall diagram](imgs/overall_arch.PNG)

I want to build a simplified risc-v SoC chip. It contains three module: five stage pipelined CPU, L1 cache, AXI4 bus. CPU interact with L1 cache to get the instruction and data. L1 cache stores data by SRAM and maintain SRAM's content with the help of DMA, which handles data transfer through AXI master. AXI bus connect AXI master to AXI slave through AXI interconect, where AXI slave maintains an DRAM.

The system should has two clk, one fast clk for CPU and L1 cache and the other slow clkk for AXI related component. CDC problems arises in-between DMA and AXI maste. I introduce afifo, double sync, ready valid to tackle CDC.

```
chip
├── cpu
│   ├── IF/ID/EX/MEM/WB/forward unit/hazard unit/...
│   ├── regfile
├── L1 cache
│   ├── fastest data mem
│   ├── fastest inst mem
│   ├── dma
│       ├── middle SRAM
├── AXI bus
│   ├── AXI master
│   ├── AXI interconnect
│   ├── AXI slave
│       ├──── slow DRAM
```
## progress

For now, these three module has not been connected yet. And they are not finished, independently.

- AXI bus: finish burst mode but interconnect module is not done yet. The currect setup is to 1-1 mapping, which is not realistic
- L1 cache: the memory calling DMA should be re-implemented. And the memory maintains should add TLB and so on
- five stage CPU: the CPU's branch is fixed, should use 4-state branch detection unit to replace it. the CPU's current jal, jalr is detected in EX stage, which always causes flush. I want it to move to ID stage, eliminating the need to flush ID/EX and add branch prediction module.

## how to run

step 0: clone main repo and enter the main working directory
    
    $ git clone https://github.com/108062138/popo_cpu.git
    
    $ cd popo_cpu

step 1: clone asm to hexa repo and make the python env aware of the python extension
    
    $ git clone https://https://github.com/108062138/riscv-assembler.git
    
    $ pip install -e ./riscv-assembler

step 2: change file path when possible in src/L1_cache/inst_mem accordingly

step 3: use makefile to run. for now, I provide two version of cpu to use: naive and opt, which can be specified by `CPU_VERSION`

    $ make sim_chip CPU_VERSION=basic

    $ make sim_chip CPU_VERSION=opt