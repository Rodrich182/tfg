param(
    [Parameter(Mandatory = $true)]
    [string[]]$Sources,

    [string]$OutDir = "",
    [string]$BaseName = "firmware",
    [string]$ToolPrefix = "",
    [int]$RomWords = 256,
    [string]$LinkerScript = "",
    [string]$Crt0 = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $PSCommandPath
$projectRoot = Split-Path -Parent $scriptRoot

if ([string]::IsNullOrWhiteSpace($OutDir)) {
    $OutDir = Join-Path $projectRoot "build\\firmware"
}

if ([string]::IsNullOrWhiteSpace($LinkerScript)) {
    $LinkerScript = Join-Path $scriptRoot "riscv32i_harvard.ld"
}

if ([string]::IsNullOrWhiteSpace($Crt0)) {
    $Crt0 = Join-Path $scriptRoot "crt0.S"
}

function Resolve-Executable {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Candidates
    )

    foreach ($candidate in $Candidates) {
        $cmd = Get-Command $candidate -ErrorAction SilentlyContinue
        if ($null -ne $cmd) {
            return $cmd.Source
        }
    }

    throw "None of these executables were found: $($Candidates -join ', ')"
}

function Resolve-RiscvTools {
    param(
        [string]$RequestedPrefix
    )

    if ($RequestedPrefix) {
        return @{
            Gcc     = Resolve-Executable @("$RequestedPrefix-gcc")
            Objcopy = Resolve-Executable @("$RequestedPrefix-objcopy")
            Objdump = Resolve-Executable @("$RequestedPrefix-objdump")
            Prefix  = $RequestedPrefix
        }
    }

    $prefixes = @(
        "riscv32-unknown-elf",
        "riscv64-unknown-elf",
        "riscv-none-elf"
    )

    foreach ($prefix in $prefixes) {
        try {
            return @{
                Gcc     = Resolve-Executable @("$prefix-gcc")
                Objcopy = Resolve-Executable @("$prefix-objcopy")
                Objdump = Resolve-Executable @("$prefix-objdump")
                Prefix  = $prefix
            }
        } catch {
        }
    }

    throw "No RISC-V GCC toolchain was detected in PATH."
}

$python = Resolve-Executable @("python")
$tools = Resolve-RiscvTools -RequestedPrefix $ToolPrefix

$resolvedSources = @()
foreach ($source in $Sources) {
    $resolved = Resolve-Path $source -ErrorAction Stop
    $resolvedSources += $resolved.Path
}

$resolvedLinker = (Resolve-Path $LinkerScript -ErrorAction Stop).Path
$resolvedCrt0 = (Resolve-Path $Crt0 -ErrorAction Stop).Path

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$outDirResolved = (Resolve-Path $OutDir).Path

$elf = Join-Path $outDirResolved "$BaseName.elf"
$bin = Join-Path $outDirResolved "$BaseName.bin"
$map = Join-Path $outDirResolved "$BaseName.map"
$disasm = Join-Path $outDirResolved "$BaseName.disasm.txt"
$sections = Join-Path $outDirResolved "$BaseName.sections.txt"
$converter = Join-Path $PSScriptRoot "bin_to_coe.py"

$commonFlags = @(
    "-march=rv32i",
    "-mabi=ilp32",
    "-mcmodel=medlow",
    "-mstrict-align",
    "-msmall-data-limit=0",
    "-ffreestanding",
    "-fno-builtin",
    "-fno-pic",
    "-fno-pie",
    "-nostdlib",
    "-nostartfiles",
    "-O2",
    "-Wall",
    "-Wextra"
)

$linkFlags = @(
    "-T", $resolvedLinker,
    "-Wl,-Map,$map",
    "-Wl,--gc-sections",
    "-Wl,--build-id=none",
    "-Wl,--no-relax",
    "-no-pie"
)

Write-Host "Detected toolchain: $($tools.Prefix)"
Write-Host "Compiling and linking..."

& $tools.Gcc @commonFlags @linkFlags "-o" $elf $resolvedCrt0 @resolvedSources
if ($LASTEXITCODE -ne 0) {
    throw "Compilation/linking failed."
}

Write-Host "Generating flat binary..."
& $tools.Objcopy "-O" "binary" $elf $bin
if ($LASTEXITCODE -ne 0) {
    throw "objcopy failed."
}

Write-Host "Generating disassembly..."
& $tools.Objdump "-d" "-M" "no-aliases,numeric" $elf | Set-Content -Path $disasm -Encoding ascii
& $tools.Objdump "-h" $elf | Set-Content -Path $sections -Encoding ascii

Write-Host "Converting to ROM artifacts..."
& $python $converter "--bin" $bin "--out-dir" $outDirResolved "--base-name" $BaseName "--depth" $RomWords "--word-width" "32"
if ($LASTEXITCODE -ne 0) {
    throw "bin -> ROM conversion failed."
}

Write-Host ""
Write-Host "Artifacts generated in: $outDirResolved"
Write-Host "  ELF  : $elf"
Write-Host "  BIN  : $bin"
Write-Host "  MAP  : $map"
Write-Host "  DIS  : $disasm"
Write-Host "  MIF  : $(Join-Path $outDirResolved "$BaseName.mif")"
Write-Host "  COE  : $(Join-Path $outDirResolved "$BaseName.coe")"
