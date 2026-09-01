# sg13cmos5l_vyges_ip__ldo_capless

Capacitor-less (**capless**) low-dropout regulator (**LDO**) for the IHP
**SG13CMOS5L** process — **3.3 V in → digitally-trimmable ~1.0–1.8 V out** (default
1.2 V), internally compensated so it needs **no external or large on-chip
capacitor**. **All-CMOS** (PMOS pass device + error amp; no MiM cap — compensation
is MOM/poly), sized to a single openframe analog-slot footprint. Built for the
**Chipalooza Challenge #2 (IHP SG13CMOS5L)**.

> Status: **schematic**. The full cell hierarchy is captured in xschem, netlists, and
> simulates. See [`doc/implementation.md`](doc/implementation.md) for what is built and
> measured, and [`doc/proposal.md`](doc/proposal.md) for the original design intent.

![Block diagram](doc/schematics/ldo_capless_block.svg)

## What it is

A clean, reusable local-supply regulator for sensitive analog/mixed-signal
blocks. Designed to drop into one openframe pallet slot: 3.3 V VIN from
the slot power switch, reference/bias from the harness V/I references, and
5-bit output trim over the digital control-status bus. A **4-wire (Kelvin) output**
keeps precision DC measurable through the shared analog mux.

Measured on the schematic hierarchy, tt/27 °C unless noted:

| Parameter | Measured | Specification | |
| --- | --- | --- | --- |
| Input | 3.0 – 3.6 V | 3.3 V nominal | |
| Output, trimmed | 1.0007 – 1.7992 V, 32 monotonic codes | 1.0 – 1.8 V | ✅ |
| Load | 0 – 50 mA | up to 50 mA | ✅ |
| Line regulation | 0.38 mV/V | 5 mV/V max | ✅ |
| Load regulation, 0→48 mA | 0.38 mV | 20 mV max | ✅ |
| Dropout at 50 mA | 149.3 mV | 250 mV max | ✅ |
| Quiescent current, enabled | 35.7 µA | 60 µA max | ✅ |
| Standby current, disabled | 3.19 µA | — | |
| Current limit trip | 58.5 mA | 60 mA | ✅ |
| Phase margin, worst over load | 57.3° (at 10 µA) | 45° min | ✅ |
| **Phase margin, worst over PVT** | **40.2°** (ff / worst-case sheet / −40 °C / 3.6 V / no load) | 45° min | ❌ |
| **PSRR at 1 kHz** | **35.0 dB** | 40 dB | ❌ |
| **Load-step droop, 1 → 20 mA** | **325.8 mV** | 120 mV max | ❌ |
| **Load-release overshoot, 20 → 1 mA** | **to the 3.3 V rail** | 120 mV max | ❌ |
| Output capacitor | **capless** — on-chip compensation only | no external cap | ✅ |

⚠️ **Four specifications are not met and are documented with numbers rather than omitted.**
The three large-signal figures are all the same limitation — 20 pF of on-chip output
capacitance cannot hold a 19 mA step for the microsecond the loop needs, which is a charge
problem before it is a loop problem. The phase-margin gap is about 1° at one corner once a
PDK resistor-corner fix already on upstream `main` is accounted for. Both are worked
through in [`doc/implementation.md`](doc/implementation.md).

Enable, power-good and current limit are implemented and exercised; see
[`doc/implementation.md`](doc/implementation.md). The block needs a 1.2 V control-bus
supply (`vddd`) alongside the 3.3 V rail.

## For the integrator

[`doc/implementation.md`](doc/implementation.md) carries two sections written for scoping
this block into a slot:

- **Assumptions** — the process, slot supply and harness resources the design rests on, with two marked as unconfirmed: the 1.2 V control-bus rail, and the bias current value.
- **Slot requirements** — pads, harness resources, control/status bits, clocks and the
  current budget. One dedicated low-resistance pad for `vout`; no clocks; needs a 1.2 V
  digital rail alongside the 3.3 V supply.
- **Against the proposal** — every specification line with what the schematic measures,
  including the three that do not yet meet target.

## Layout

| Dir | Contents |
| --- | --- |
| `xschem/` | schematics — `ldo_vref`, `ldo_erramp`, `ldo_pass`, `ldo_fbtrim`, `ldo_capless` |
| `doc/schematics/` | rendered SVGs of every cell, readable without opening xschem |
| `magic/` | analog layout |
| `netlist/` | extracted / simulation netlists |
| `sim/` | testbenches |
| `verilog/` | digital enable / trim / power-good wrapper (LibreLane) |
| `signoff/` | DRC / LVS / extract / STA reports |
| `doc/` | design notes, characterization |
| `prototype/ldo/` | feasibility netlist (`ldo.spice`) — stable capless loop demonstrated in-process |

## Toolchain

IHP open flow: **xschem / ngspice / magic / netgen / klayout** + **LibreLane**
for the digital wrapper. ngspice must support **OSDI v0.4** (the IHP PSP103
models — SG13CMOS5L shares them with SG13G2) — use IIC-OSIC-TOOLS or
ngspice ≥ 43.

[**Vyges Loom**](https://vyges.com/products/loom) provides independent sign-off
alongside it — `vyges loom meas` measures the loop phase margin, `vyges loom lvs`
gates connectivity against a known-good netlist, and `vyges loom extract` supplies
parasitics once there is layout. Each exits non-zero on a violation, so they run as
build gates. Install: <https://docs.vyges.com/installation.html>. Commands and
results are in [`doc/implementation.md`](doc/implementation.md).

## Reproducing the results

`sim/run.sh` netlists the schematic hierarchy and runs every testbench from a clean
clone. It needs xschem, ngspice, and **both** IHP PDKs under one root: the
`ihp-sg13cmos5l` overlay for the models and stdcells, and the `ihp-sg13g2` base for the
compiled OSDI models. That root is `$PDK_ROOT`, which defaults to `/foss/pdks` (what
IIC-OSIC-TOOLS sets), so pass `PDK_ROOT=/your/pdks` to run against a checkout anywhere
else; `$PDK` names the base directory and defaults to `ihp-sg13g2`.

Apache-2.0. See [`NOTICE`](NOTICE) for attribution.
