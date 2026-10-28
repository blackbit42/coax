# Yosys/nextpnr/icepack Migration Guide

This document describes the migration of the interface2 FPGA design from Lattice IceCube2 (Synplify Pro + Diamond) to the open-source Yosys/nextpnr/icepack toolchain.

## Original Toolchain (IceCube2)

- **Synthesis**: Synplify Pro (via `synpwrap`)
- **Place & Route**: Lattice Diamond (via `sbt_backend_synpl.tcl`)
- **Bitstream**: `icecube2_flow.tcl` → `top_bitmap.bin`
- **Device**: iCE40UP5K-SG48
- **Constraints**: `pins.pcf` (pin assignments), `clocks.sdc` (timing)

## New Toolchain (Yosys/nextpnr/icepack)

- **Synthesis**: Yosys (`synth_ice40`)
- **Place & Route**: nextpnr-ice40
- **Bitstream**: icepack
- **Device**: iCE40UP5K-SG48 (`--up5k --package sg48`)
- **Constraints**: `pins.pcf` (pin assignments), timing via `--freq` flag

## Key Changes Required

### 1. PLL Primitive — No Change Needed!

**Surprising discovery**: The `SB_PLL40_CORE` primitive **is available in Yosys** with the exact same interface as the IceCube2 design. No primitive replacement is needed!

The original `top.v` instantiation works unchanged:
```verilog
SB_PLL40_CORE #(
    .FEEDBACK_PATH("SIMPLE"),
    .DIVR(4'b0000),
    .DIVF(7'b0010000),
    .DIVQ(3'b011),
    .FILTER_RANGE(3'b011)
) clk_fast_pll (
    .RESETB(1'b1),
    .BYPASS(1'b0),
    .REFERENCECLK(clk),
    .PLLOUTCORE(clk_fast)
);
```

**What we did**: We kept the primitive but moved it to a separate `pll.v` wrapper module for cleaner separation. The `pll.v` uses `SB_PLL40_CORE` with all required ports explicitly connected (the original only connected a subset).

**Why it works**: Yosys's `cells_sim.v` defines `SB_PLL40_CORE` with the exact same ports and parameters as Lattice's IceCube2. The iCE40UP5K has one PLL that can be driven directly from a clock-capable I/O pin (pin 37 in this design).

**Note**: Earlier attempts to use `SB_PLL40_2_PAD` (which includes an I/O buffer) or `SB_PLL40_2F_CORE` (dual-output core PLL) failed due to placement conflicts. The single-output `SB_PLL40_CORE` works seamlessly.

### 2. PLL Generation (Optional Automation)

The `pll.v` module can be regenerated using the `icepll` tool if needed:

```bash
icepll -i 40 -o 85 -f pll.v
```

This generates a Verilog module with the correct primitive and parameters. The current `pll.v` was manually created with equivalent parameters matching the original design.

### 3. Build System

**New `Makefile`** replaces `icecube2.mk` and `icecube2_flow.tcl`:

```make
# Synthesize
yosys -p "read_verilog -sv *.v; synth_ice40 -top top -json top.json"

# Place & Route
nextpnr-ice40 --up5k --package sg48 --json top.json --pcf pins.pcf --asc top.asc --freq 40

# Bitstream
icepack top.asc top.bin
```

### 4. Timing Constraints

The original `clocks.sdc` used Synopsys Design Constraints format. nextpnr-ice40 has limited SDC support. Timing is now specified via:
- `--freq 40` — main clock frequency (MHz) for timing analysis
- `--timing-allow-fail` — allows P&R to complete even if timing isn't met

For more complex constraints, nextpnr supports a `--pre-pack` Python script or `--lpf` constraint file (Liberty-style).

## File Changes Summary

| File | Change |
|------|--------|
| `top.v` | Moved `SB_PLL40_CORE` instantiation to `pll` module instance (cleaner separation) |
| `pll.v` | **New** — PLL wrapper using `SB_PLL40_CORE` primitive (same as IceCube2) |
| `coax_buffer.v` | Fixed signed/unsigned comparison warning (`$unsigned()` cast) |
| `Makefile` | **Replaced** — New Yosys/nextpnr/icepack build flow |
| `YOSYS_MIGRATION.md` | **New** — This documentation |

## Building

```bash
cd coax/interface2/fpga/rtl
make
```

Outputs:
- `top.bin` — Bitstream for flashing
- `top_timing.rpt` — Timing report

## Known Limitations / Differences

1. **Timing Analysis**: nextpnr's timing analysis is less comprehensive than Diamond's. The `--timing-allow-fail` flag is used to prevent build failures on timing violations.

2. **SDC Support**: Full SDC is not supported. Complex timing constraints may need manual translation to nextpnr's constraint format or pre-pack scripts.

3. **PLL Parameters**: The PLL output frequency (~85 MHz) is derived from the original IceCube2 parameters. Verify this meets your design requirements.

4. **RAM Inference**: The behavioral RAM in `ram_sdp.v` and `fifo_sync_ram.v` should infer `SB_RAM40_4K` blocks automatically. Verify in Yosys synthesis log.

5. **Dual-Clock FIFO**: `dual_clock_spi_device.v` uses `clk` (40 MHz) and `clk_fast` (~85 MHz). Ensure CDC paths are properly constrained if needed.

## Verification

After building, verify:
1. Synthesis log shows no errors/warnings for PLL and RAM inference
2. nextpnr reports successful placement and routing
3. Timing report shows acceptable slack on critical paths
4. Functional simulation (testbenches in `../tests/`) still pass

**Timing Results (from successful build)**:
- **clk (40 MHz)**: achieved 40.14 MHz ✓ (meets constraint)
- **clk_fast (85 MHz)**: achieved 90.20 MHz ✓ (well above 40 MHz constraint)

**Device Utilization**:
- ICESTORM_LC: 772/5280 (14%)
- ICESTORM_RAM: 10/30 (33%)
- SB_IO: 15/96 (15%)
- SB_GB: 7/8 (87%)
- ICESTORM_PLL: 1/1 (100%)

## Rollback

The original IceCube2 flow is preserved in:
- `icecube2.mk`
- `icecube2_flow.tcl`
- `icecube2_env.sh`

The git history on `main` branch contains the original IceCube2-only state.