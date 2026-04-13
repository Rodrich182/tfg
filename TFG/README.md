# RV32I Processor TFG

Educational RV32I processor implemented in VHDL for a TFG project. The main
focus of the repository is the processor itself, its RTL organization, and its
simulation on Vivado/XSim. A small bare-metal software flow to generate Vivado
instruction ROM images is also included as an extra.

## Overview

This project contains:

- an educational RV32I processor split into control (`UC`) and datapath (`UPG`)
- a Harvard-style organization with separate instruction ROM and data memory
- a Vivado block-design based integration around the processor
- an FPGA-ready top level with a simple LED MMIO demonstration
- an optional `C/assembly -> ELF -> BIN -> COE` flow for ROM generation

Main entry points:

- [Vivado project](./TFG.xpr)
- [FPGA top level](./TFG.srcs/sources_1/new/Procesador_FPGA_Top.vhd)
- [RTL sources](./TFG.srcs/sources_1/new/)
- [Simulation sources](./TFG.srcs/sim_1/new/)

## Processor architecture

The processor is organized around two main blocks:

- `UC`: control unit, instruction decoding, immediate generation, branch/jump control, and PC enable logic
- `UPG`: datapath, register bank, ALU, memory access path, load extension logic, and writeback path

Relevant source files:

- [UC.vhd](./TFG.srcs/sources_1/new/UC.vhd)
- [UPG.vhd](./TFG.srcs/sources_1/new/UPG.vhd)
- [Main_Control.vhd](./TFG.srcs/sources_1/new/Main_Control.vhd)
- [ALU_Decoder.vhd](./TFG.srcs/sources_1/new/ALU_Decoder.vhd)
- [ALU.vhd](./TFG.srcs/sources_1/new/ALU.vhd)
- [Register_Bank.vhd](./TFG.srcs/sources_1/new/Register_Bank.vhd)
- [Data_Memory.vhd](./TFG.srcs/sources_1/new/Data_Memory.vhd)
- [PC.vhd](./TFG.srcs/sources_1/new/PC.vhd)
- [Sign_And_Order_Extend.vhd](./TFG.srcs/sources_1/new/Sign_And_Order_Extend.vhd)
- [ISA_CONSTANTS.vhd](./TFG.srcs/sources_1/new/ISA_CONSTANTS.vhd)
- [CONSTANTS.vhd](./TFG.srcs/sources_1/new/CONSTANTS.vhd)

## Implemented ISA

Implemented instructions:

- R-type: `add`, `sub`, `sll`, `slt`, `sltu`, `xor`, `srl`, `sra`, `or`, `and`
- I-type ALU: `addi`, `slti`, `sltiu`, `xori`, `ori`, `andi`, `slli`, `srli`, `srai`
- Loads: `lb`, `lh`, `lw`, `lbu`, `lhu`
- Stores: `sb`, `sh`, `sw`
- Branches: `beq`, `bne`, `blt`, `bge`, `bltu`, `bgeu`
- Upper/jump: `lui`, `auipc`, `jal`, `jalr`
- Misc/system: `fence`, `ecall`, `ebreak`

Current simplifications:

- `fence` is treated as a NOP
- `ecall` and `ebreak` halt the PC instead of raising a full architectural trap
- misaligned accesses and illegal instructions do not raise architectural exceptions

So the core is valid for the educational bare-metal flow used in this project,
but it is not a full privileged RISC-V implementation.

## FPGA top and MMIO demo

The FPGA-oriented top level is:

- [Procesador_FPGA_Top.vhd](./TFG.srcs/sources_1/new/Procesador_FPGA_Top.vhd)

It exposes a simple 4-bit LED MMIO register at:

- `0x00000100`

Any store to that address updates `led_o(3 downto 0)` with the low nibble of
the written value.

Example program:

- [led_binary_demo.c](./programs/led_binary_demo.c)
- [led_binary_demo.coe](./programs/led_binary_demo.coe)

Constraint template:

- [led_demo_template.xdc](./constraints/led_demo_template.xdc)

## Simulation

Useful testbenches:

- [tb_fibonacci_processor_rtl.vhd](./TFG.srcs/sim_1/new/tb_fibonacci_processor_rtl.vhd)
- [tb_fibonacci_procesador_wrapper.vhd](./TFG.srcs/sim_1/new/tb_fibonacci_procesador_wrapper.vhd)
- [tb_procesador_fpga_top_led.vhd](./TFG.srcs/sim_1/new/tb_procesador_fpga_top_led.vhd)
- [tb_rv32i_instruction_walk_wrapper.vhd](./TFG.srcs/sim_1/new/tb_rv32i_instruction_walk_wrapper.vhd)
- [tb_rv32i_alu_upper_wrapper.vhd](./TFG.srcs/sim_1/new/tb_rv32i_alu_upper_wrapper.vhd)
- [tb_rv32i_mem_wrapper.vhd](./TFG.srcs/sim_1/new/tb_rv32i_mem_wrapper.vhd)
- [tb_rv32i_ctrl_wrapper.vhd](./TFG.srcs/sim_1/new/tb_rv32i_ctrl_wrapper.vhd)
- [tb_rv32i_ebreak_wrapper.vhd](./TFG.srcs/sim_1/new/tb_rv32i_ebreak_wrapper.vhd)

Suggested uses:

- `tb_fibonacci_processor_rtl`: core-level RTL behavior
- `tb_fibonacci_procesador_wrapper`: complete wrapper execution
- `tb_procesador_fpga_top_led`: FPGA MMIO LED behavior
- `tb_rv32i_instruction_walk_wrapper`: passive waveform exploration of supported instructions

## Optional software flow: C to COE

The repository also includes a small software flow to generate instruction ROM
images for Vivado.

Core files:

- [build_riscv_program.ps1](./scripts/build_riscv_program.ps1)
- [bin_to_coe.py](./scripts/bin_to_coe.py)
- [crt0.S](./scripts/crt0.S)
- [riscv32i_harvard.ld](./scripts/riscv32i_harvard.ld)

Flow:

1. Compile and link bare-metal RISC-V code into an ELF executable.
2. Convert the ELF executable into a flat binary image.
3. Convert the binary image into a Vivado `.coe` file.

### Requirements

- Windows PowerShell
- Python
- RISC-V GCC toolchain in `PATH`
- Vivado project available locally

The flow has been exercised with the `riscv-none-elf` toolchain prefix.

### Example command

From the repository root, this command builds the LED MMIO demo:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\build_riscv_program.ps1 `
  -Sources .\programs\led_binary_demo.c `
  -BaseName led_binary_demo `
  -RomWords 64 `
  -ToolPrefix riscv-none-elf
```

Default output directory:

- [build/firmware](./build/firmware)

Typical generated files:

- `led_binary_demo.elf`
- `led_binary_demo.bin`
- `led_binary_demo.map`
- `led_binary_demo.disasm.txt`
- `led_binary_demo.mif`
- `led_binary_demo.coe`

## Example programs

- [fibonacci_rv32i.S](./programs/fibonacci_rv32i.S)
- [fibonacci.coe](./programs/fibonacci.coe)
- [led_binary_demo.c](./programs/led_binary_demo.c)
- [led_binary_demo.coe](./programs/led_binary_demo.coe)
- [rv32i_instruction_walk.S](./programs/rv32i_instruction_walk.S)
- [rv32i_instruction_walk.coe](./programs/rv32i_instruction_walk.coe)
- [rv32i_instruction_walk_notes.txt](./programs/rv32i_instruction_walk_notes.txt)

`rv32i_instruction_walk` is intended for waveform-level exploration. It
executes many supported instructions in sequence so the internal behavior of
the core can be observed directly in simulation.

## Repository layout

- [TFG.srcs/sources_1/new](./TFG.srcs/sources_1/new/): handwritten RTL
- [TFG.srcs/sources_1/bd](./TFG.srcs/sources_1/bd/): Vivado block designs
- [TFG.srcs/sim_1/new](./TFG.srcs/sim_1/new/): testbenches
- [programs](./programs/): source examples and prebuilt ROM images
- [scripts](./scripts/): essential build scripts
- [constraints](./constraints/): FPGA constraints templates
- [docs](./docs/): optional notes

## Notes

- The current instruction ROM uses 64 words, so test programs must fit that limit unless the ROM IP is resized.
- The software flow is an extra helper around the main processor project.
- Vivado-generated folders such as `TFG.gen`, `TFG.sim`, `TFG.cache`, `TFG.runs`, `xsim.dir`, and `.Xil` are tool artifacts rather than conceptual parts of the processor design.



PS C:\Users\rodrich\Documents\AA uni\reps\tfg> powershell -ExecutionPolicy Bypass -File .\TFG\scripts\build_riscv_program.ps1 -Sources .\TFG\programs\led_binary_demo.c -BaseName led_binary_demo -RomWords 64 -ToolPrefix riscv-none-elf

powershell -ExecutionPolicy Bypass -File .\TFG\scripts\build_riscv_program.ps1 -Sources .\TFG\programs\startup_harvard_demo.c -BaseName startup_harvard_demo -RomWords 64 -ToolPrefix riscv-none-elf

powershell -ExecutionPolicy Bypass -File .\TFG\scripts\build_riscv_program.ps1 -Sources .\TFG\programs\startup_harvard_loop_demo.c -BaseName startup_harvard_loop_demo -RomWords 64 -ToolPrefix riscv-none-elf


[Environment]::SetEnvironmentVariable(
  "Path",
  [Environment]::GetEnvironmentVariable("Path", "User") + ";" + (Get-Location).Path,
  "User"
)
