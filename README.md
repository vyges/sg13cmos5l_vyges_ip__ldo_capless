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
5-bit output trim over the digital control-status bus. It asks for **one dedicated
low-resistance pad** for `vout` and no other sole-use analog access.

⚠️ The proposal also asked for a muxable Kelvin `vout_sense` pin, on which mux resistance
would not matter because a meter sinks no current. **That pin is not in this revision** —
the block brings out a single `vout`. Adding it is a wire, not a circuit, but it needs a
pad to be worth adding.

Measured on the schematic hierarchy, tt/27 °C unless noted:

| Parameter | Measured | Specification | |
| --- | --- | --- | --- |
| Input | 3.0 – 3.6 V | 3.3 V nominal | |
| Output, trimmed | 1.0000 – 1.7979 V, 32 monotonic codes | 1.0 – 1.8 V | ✅ |
| Load | 0 – 50 mA | up to 50 mA | ✅ |
| Line regulation | 0.38 mV/V | 5 mV/V max | ✅ |
| Load regulation, 0→48 mA | 0.26 mV | 20 mV max | ✅ |
| Dropout at 50 mA | 149.3 mV | 250 mV max | ✅ |
| Quiescent current, enabled | 35.8 µA | 60 µA max | ✅ |
| Standby current, disabled | 3.19 µA | — | |
| Current limit trip | 58.5 mA | 60 mA | ✅ |
| Phase margin, worst over load | 58.2° (at 10 µA) | 45° min | ✅ |
| Phase margin, worst over PVT | 45.6° (ff / worst-case sheet / −40 °C / 3.6 V / no load), 0 of 243 corners below | 45° min | ✅ |
| **PSRR at 1 kHz** | **35.1 dB** | 40 dB | ❌ |
| **Load-step droop, 1 → 20 mA** | **338.1 mV** | 120 mV max | ❌ |
| **Load-release overshoot, 20 → 1 mA** | **to the 3.3 V rail** | 120 mV max | ❌ |
| Load step meeting ±120 mV | **3 mA** (droop 90.2 mV, overshoot 119.7 mV) | — | |
| Output capacitor | **capless** — on-chip compensation only | no external cap | ✅ |

⚠️ **Three specifications are not met and are documented with numbers rather than
omitted.** Droop and PSRR are the limitation they look like: 20 pF of on-chip output
capacitance cannot hold a 19 mA step for the microsecond the loop needs. **The release
overshoot is not, and measuring it rather than assuming it changed what the fix has to
be.**

🔑 **But the step size is ours to specify, so it is now specified.** The 120 mV target came
from this block's own proposal, not from a requirement. Sweeping step size says what the
block actually holds: **both excursions stay inside ±120 mV up to a 1 → 3 mA step**
(droop 90.2 mV, overshoot 119.7 mV). See `doc/datasheet/ldo_capless_step_profile.svg`.

⛔ **The release overshoot is a threshold in dI/dt, not in step size.** It was recorded as
a cliff somewhere between a 5 mA and a 7 mA release — it tracks the droop to 231 mV at
5 mA and reaches the rail at 7 mA. Sweeping the release EDGE as well as the step says it is
not a property of the step at all. The same 6 mA step runs to the rail released in 1 µs and
settles within 235 mV released in 2 µs; a 13 mA step, double the charge, rails at the same
rate. The threshold is a **release rate of 5.0–5.5 mA/µs**, set by the one device that
pulls the pass gate up — about 5 µA into roughly 50 pF of compensation capacitance plus
6400 µm of pass-device gate, measured as 0.10–0.13 V/µs against a gate sensitivity of
19.5 mV/mA. It remains the block's primary open defect, and it is now bounded by a
mechanism rather than by two samples.

🔑 **Which means the specification this block can hold is a RATE, and by that measure it is
better than one step size suggests.** A 7 mA release costs 69 mV at 0.6 mA/µs and 141 mV at
1.5 mA/µs — the same release that reaches the rail at 6 mA/µs. Below roughly 5 mA/µs no
step size tested produces an over-voltage. An integrator whose load releases more slowly
than that is not exposed to this defect.

ℹ️ **What the fix cannot be, measured rather than argued.** The pull-up is also the second
stage's load device, so its current sits in the loop gain: widening it clears the
1 → 20 mA release and takes the 243-corner phase-margin minimum from 45.6° to 38.5°, with
nine corners below specification. A prototype transient boost that is off at the operating
point — contributing no gm to the loop — removes the over-voltage at **every one of 81
transient corners** for +0.2 µA of quiescent current, unchanged PSRR, unchanged startup and
a 243-corner phase-margin minimum of 46.0°. Five of those 81, all at 110 °C with the
lowest-sheet resistor corner, then show it firing on the output's own recovery from the
droop, because an edge detector cannot tell a release from a recovery. The benches and the
prototype are in `sim/`. **The direction that follows is to sense the regulation error
rather than the output slew, which cannot confuse the two; it is not in this revision.**

✅ **Phase margin over PVT now passes**, at 45.6° with no corner below specification. It was
40.2°. **No device changed value**: the block was re-pinned to IHP-Open-PDK
`dev@ab1510c`, which carries a `rhigh` corner re-alignment worth **+5.4°** at the binding
corner. The same re-pin renamed the MoM capacitor `cap_mfringe` → `cap_cmomf` and
recalibrated its density from 2.32 to **1.287 fF/µm²**, so the two compensation capacitors
were re-drawn ×1.80 in area to hold the same 48 pF and 20 pF they always specified — the
capacitance is identical, the silicon it takes is not. Both are worked through in
[`doc/implementation.md`](doc/implementation.md).

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
clone. It needs xschem, ngspice, and the IHP PDK — **one checkout now covers both halves**,
since upstream merged the `ihp-sg13cmos5l` overlay into IHP-Open-PDK:

```sh
git clone --branch dev --recurse-submodules https://github.com/IHP-GmbH/IHP-Open-PDK.git
git -C IHP-Open-PDK checkout ab1510cbdcbd61fe82e24ec28179c02ea7083299
PDK_ROOT=$PWD/IHP-Open-PDK python3 IHP-Open-PDK/ihp-sg13g2/libs.tech/ngspice/install.py
PDK_ROOT=$PWD/IHP-Open-PDK PDK=ihp-sg13cmos5l sh sim/run.sh
```

`--recurse-submodules` is not optional, and `install.py` compiles the Verilog-A models
(`psp103`, `psp103_nqs`, `r3_cmc`, `mosvar`) that ship as sources rather than binaries.

⚠️ **One upstream gap to work around.** Both `.spiceinit` files load all six OSDI models
from `$PDK_ROOT/$PDK/libs.tech/ngspice/osdi/`, but `install.py` writes its four only into
`ihp-sg13g2`, while `ihp-sg13cmos5l` ships only the other two (`cap_cmomf`, `cap_cmomi`)
prebuilt. Neither directory holds all six, so whichever `$PDK` you select the elaboration
fails on the missing pair. Symlink the two sets into each other after installing.

`$PDK_ROOT` defaults to `/foss/pdks` (what IIC-OSIC-TOOLS sets) and `$PDK` to
`ihp-sg13g2`, so the bundled PDK still works — but it is the *old* two-repository pin and
will not reproduce the numbers above.

Apache-2.0. See [`NOTICE`](NOTICE) for attribution.
