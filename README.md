# vyges-capless-ldo

Capacitor-less (**capless**) low-dropout regulator (**LDO**) for the IHP
**SG13CMOS5L** process — **3.3 V in → digitally-trimmable ~1.0–1.8 V out** (default
1.2 V), internally compensated so it needs **no external or large on-chip
capacitor**. **All-CMOS** (PMOS pass device + error amp; no MiM cap — compensation
is MOM/poly), sized to a single openframe analog-slot footprint. Built for the
**Chipalooza Challenge #2 (IHP SG13CMOS5L)**.

> Status: **proposal / feasibility** stage. See [`doc/proposal.md`](doc/proposal.md).

## What it is

A clean, reusable local-supply regulator for sensitive analog/mixed-signal
blocks — one of the most-requested primitives from the original Efabless
Chipalooza list. Designed to drop into one openframe pallet slot: 3.3 V VIN from
the slot power switch, reference/bias from the harness V/I references, and
`enable` / output-trim / `power_good` over the digital control-status bus. A
**4-wire (Kelvin) output** keeps precision DC measurable through the shared analog
mux.

| Parameter | Preliminary target |
|---|---|
| Input | 3.3 V |
| Output (trimmed) | ~1.0–1.8 V (default 1.2 V) |
| Load | up to ~50 mA |
| Output cap | **capless** (on-chip compensation only) |

## Layout

| Dir | Contents |
|---|---|
| `xschem/` | schematics (pass device, error amp, compensation, trim, top) |
| `magic/` | analog layout |
| `netlist/` | extracted / simulation netlists |
| `sim/` | testbenches |
| `verilog/` | digital enable / trim / power-good wrapper (LibreLane) |
| `signoff/` | DRC / LVS / extract / STA reports |
| `doc/` | design notes, characterization |
| `prototype/ldo/` | feasibility netlist (`ldo.spice`) — stable capless loop demonstrated in-process |

## Toolchain

IHP open flow: **xschem / ngspice / magic / netgen / klayout** + **LibreLane**
for the digital wrapper, with **Vyges Loom** (`vyges-drc` / `-lvs` / `-extract` /
`-sta-si`) as independent sign-off. ngspice must support **OSDI v0.4** (the IHP
PSP103 models — SG13CMOS5L shares them with SG13G2) — use IIC-OSIC-TOOLS or
ngspice ≥ 43.

Apache-2.0.
