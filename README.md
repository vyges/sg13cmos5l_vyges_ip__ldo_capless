# sg13cmos5l_vyges_ip__ldo_capless

Capacitor-less (**capless**) low-dropout regulator (**LDO**) for the IHP
**SG13CMOS5L** process — **3.3 V in → digitally-trimmable ~1.0–1.8 V out** (default
1.2 V), internally compensated so it needs **no external or large on-chip
capacitor**. **All-CMOS** (PMOS pass device + error amp; no MiM cap — compensation
is MOM/poly), sized to a single openframe analog-slot footprint. Built for the
**Chipalooza Challenge #2 (IHP SG13CMOS5L)**.

## Current status

**Phase: schematic complete, physical design started.**

- ✅ **The design is captured and reproducible.** Nine cells generated from a single source,
  netlisted, and simulated from a clean clone by `sim/run.sh`.
- ✅ **Every published specification is met except one** — the load-release overshoot. It no
  longer reaches the supply rail at any corner, which was the reliability concern, but it
  still exceeds its excursion target.
- ✅ **Two specifications were restated to the quantity the physics governs**, and both then
  passed: droop as a load **slew rate** rather than a step size, and supply rejection as a
  **mask over frequency** rather than a single point. Each limit is the worst of 243 corners,
  not a typical value.
- ✅ **Verified across corners, not at one operating point** — 243 PVT corners for phase
  margin and for supply rejection, 81 for the transient response.
- ⚠️ **Physical design is early.** The floorplan is held as checked data rather than a
  drawing, and the first device array is generated and DRC-clean against the PDK deck. Full
  layout, routing, LVS and sign-off have not started.
- ⛔ **Known limits to read before integrating**: the supply-rejection mask **stops** — above
  roughly 50 kHz at the worst corner this block does not reject supply ripple and near 2 MHz
  it amplifies it, so it should not be fed directly from a switching regulator; and the
  control logic runs from the 1.2 V rail, so the block cannot bring itself up in a system
  where it is the source of that rail.

Detail: [`doc/implementation.md`](doc/implementation.md) for what is built and measured,
[`doc/datasheet/`](doc/datasheet/) for the generated datasheet and figures, and
[`doc/proposal.md`](doc/proposal.md) for the original design intent.

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
| Output, trimmed | 0.9997 – 1.7974 V, 32 monotonic codes | 1.0 – 1.8 V | ✅ |
| Load | 0 – 50 mA | up to 50 mA | ✅ |
| Line regulation | 0.38 mV/V | 5 mV/V max | ✅ |
| Load regulation, 0→48 mA | 0.27 mV | 20 mV max | ✅ |
| Dropout at 50 mA | 149.7 mV | 250 mV max | ✅ |
| Quiescent current, enabled | 41.5 µA | 60 µA max | ✅ |
| Standby current, disabled | 3.19 µA | — | |
| Current limit trip | 58.5 mA | 60 mA | ✅ |
| Phase margin, worst over load | 58.2° (at 10 µA) | 45° min | ✅ |
| Phase margin, worst over PVT | 45.1° (ff / worst-case sheet / −40 °C / 3.6 V / no load), 0 of 243 corners below | 45° min | ✅ |
| PSRR at 100 Hz | 54.9 dB | 50 dB min | ✅ |
| **PSRR at 1 kHz** | **35.1 dB** | 30 dB min | ✅ |
| PSRR at 10 kHz | 15.1 dB | 10 dB min | ✅ |
| Supply rejection holds below | **71.4 kHz** (49.5 kHz worst corner) | — | |
| Load slew rate for ≤120 mV droop | **2.65 mA/µs** | 1 mA/µs min | ✅ |
| **Load-step droop at 19 mA/µs** | **338.2 mV** | beyond the specified rate | |
| **Load-release overshoot, 20 → 1 mA** | **235.6 mV** | 120 mV max | ❌ |
| Load step meeting ±120 mV | **2 mA** (droop 55.0 mV, overshoot 65.0 mV) | — | |
| Output capacitor | **capless** — on-chip compensation only | no external cap | ✅ |

⚠️ **One specification is still missed, and two have been restated as the things they
actually depend on.** The release overshoot is bounded at every corner now rather than
reaching the supply rail, but still exceeds 120 mV. **The droop is now specified as a load
SLEW RATE rather than a step size**, and **PSRR as a mask over frequency rather than one
number at 1 kHz** — in both cases because that is what the quantity is a function of.

🔑 **Why the PSRR specification changed shape.** Rejection here is a slope, not a point. The
open-loop supply coupling is a constant 47.4 dB — flat to 1.5 dB from 10 Hz to 10 kHz — and
the loop divides it down, so rejection falls 20 dB per decade. A flat 40 dB limit crosses
that slope once and describes neither side of the crossing. The mask is parallel to the
physics instead: **50 / 30 / 10 dB at 100 Hz / 1 kHz / 10 kHz**, each the worst of 243 PVT
corners rounded down to the next 10 dB, which leaves a uniform ~3.6 dB of margin. The corner
spread is unusually tight — 2.3 to 2.6 dB across process, resistor sheet, temperature, supply
and load.

⛔ **And the mask stops. Above about 50 kHz this block does not reject the supply at all**, and
near 2.2 MHz it *amplifies* it — 4.9 dB typical and 12.1 dB at the worst corner, so output
ripple can be four times the supply ripple that caused it. **Do not feed this block directly
from a switching regulator**: a converter's fundamental lands squarely in that band, and being
capless there is no output capacitor to cover it. Filter the input or accept the ripple. The
frequency where rejection runs out is a reported figure in the datasheet so the mask cannot be
read as extending past where it is true.

🔑 **Why the droop specification changed shape.** It is a ramp-tracking error: the loop
follows the load ramp to about three parts in ten thousand, and that residue is the droop.
Measured by watching the pass current rather than the gate that controls it — at the end of a
1 µs edge the pass device delivers 20.0063 mA against a 20.000 mA load. Two consequences an
integrator needs:

- **It scales with dI/dt, not with step size.** 338.2 mV at 19 mA/µs, 167.1 at 4.75, 99.4 at
  1.90, 64.8 at 0.95 — the same 1 → 20 mA step throughout, only the edge changing. So the
  block holds ±120 mV up to **2.65 mA/µs**, and that is the specification.
- **More output capacitance does not help.** Nearly tripling `Cout` moves the droop by
  0.3 mV, in the wrong direction. A tracking error is not an integration, so the output
  capacitor is not the lever, and 17 % of the slot does not have to be reserved for one.

🔑 **But the step size is ours to specify, so it is now specified.** The 120 mV target came
from this block's own proposal, not from a requirement. Sweeping step size says what the
block actually holds: **both excursions stay inside ±120 mV up to a 1 → 2 mA step**
(droop 55.0 mV, overshoot 65.0 mV). See `doc/datasheet/ldo_capless_step_profile.svg`.

⚠️ **That row was 3 mA before the slew boost landed, and it is honest to say the boost cost
it.** At a 3 mA release the overshoot is 119.7 mV without the boost and 120.4 mV with it —
the old number passed this self-set limit by 0.34 mV and the new one misses it by 0.44 mV.
The cause is structural rather than incidental: the boost only engages once the output is
about 100 mV high, so a step whose natural overshoot is ~120 mV is exactly where it turns on
marginally and helps least. Below that threshold it does nothing, which is the design intent;
far above it, it is the difference between 235 mV and the supply rail.

ℹ️ **The next two paragraphs diagnose the ORIGINAL defect and describe the block without the
boost.** They are kept because the mechanism is what made the fix possible and because an
integrator's load profile still interacts with it — but the figures in them are pre-boost.
The fix and what it achieves are below them.

⛔ **The release overshoot is a threshold in dI/dt, not in step size.** It was recorded as
a cliff somewhere between a 5 mA and a 7 mA release — it tracks the droop to 231 mV at
5 mA and reaches the rail at 7 mA. Sweeping the release EDGE as well as the step says it is
not a property of the step at all. The same 6 mA step runs to the rail released in 1 µs and
settles within 235 mV released in 2 µs; a 13 mA step, double the charge, rails at the same
rate. The threshold is a **release rate of 5.0–5.5 mA/µs**, set by the one device that
pulls the pass gate up — about 5 µA into roughly 50 pF of compensation capacitance plus
6400 µm of pass-device gate, measured as 0.10–0.13 V/µs against a gate sensitivity of
19.5 mV/mA.

🔑 **Which means the specification this block could hold was a RATE, and by that measure it
was better than one step size suggested even before the fix.** A 7 mA release costs 69 mV at 0.6 mA/µs and 141 mV at
1.5 mA/µs — the same release that reaches the rail at 6 mA/µs. Below roughly 5 mA/µs no
step size tested produces an over-voltage. An integrator whose load releases more slowly
than that is not exposed to this defect.

✅ **THE OVER-VOLTAGE IS FIXED. The output no longer reaches the rail at any corner.** The
release overshoot is **235.6 mV** at the typical corner and **573 mV at the worst of 81
transient corners**, against an unboosted design that reached the supply rail at **81 of
81**. What the reviewer asked to have fixed — an over-voltage on thin-oxide devices — is
gone. The 120 mV target is still missed, so the row stays ❌, but it is now an ordinary
excursion rather than a reliability hazard.

The block that does it is [`ldo_boost`](xschem/ldo_boost.sch), and its shape follows from
what the pull-up could not be. That device is also the second stage's load, so its current
sits in the loop gain: widening it clears the release and takes the 243-corner phase-margin
minimum from 45.6° to 38.5°, nine corners below specification. So the boost had to be large
during the event and absent from the small-signal loop. It is an over-voltage comparator
against a tap on the reference divider, vetoing a dv/dt path, with both output devices in
series — current reaches the pass gate only when the output is above its regulation point
**and** rising quickly. Neither conducts at the operating point.

⚠️ **What it cost, stated rather than buried.** Quiescent current 35.8 → **41.5 µA** against
a 60 µA budget. Phase margin over PVT 45.6° → **45.1°**, still with no corner below 45 but
with a tenth of a degree of slack where the block had six. The ±120 mV step row above, from
3 mA to 2 mA. Droop and PSRR are unchanged. Anything further added to that node should be
paid for out of the compensation rather than out of what is left.

✅ **Phase margin over PVT passes**, at 45.1° with no corner below specification. It was
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

## Physical design

⚠️ **There is no full layout yet, and `magic/` is empty.** What exists is a floorplan held as
checked data rather than a drawing, and the first device-level geometry generated and
DRC-verified against the IHP deck.

**The floorplan is data.** `tools/floorplan.py` places every block from footprints that
`tools/area_budget.py` measured by instantiating the PDK's own PyCells, and the run fails if
any block leaves the slot or lands on another — a diagram cannot do that. It reports 69.4 %
of a 530 × 310 µm slot occupied, which is a **floor**: it reserves no routing channels, guard
rings or well taps. `doc/datasheet/ldo_capless_floorplan.svg` is drawn from the same data.

Three measured constraints set the shape: `Cm` at 193 × 193.5 µm and `Cout` at 125 × 125.5
cannot stack (319 µm against a 310 µm slot), so they sit side by side and fix 318 µm of the
530 µm width; the pass array is short enough to sit under something; and long resistors cost
roughly **double** their drawn area once folded, so `XRb` at 1.4 × 2941 µm is pitch-limited
rather than area-limited.

**The pass array is generated and DRC-clean.** `tools/layout_pass.py` emits the 64-device
array as GDS from the `pmosHV` PyCell and `tools/passdrc.sh` runs the IHP deck over a pitch
sweep, which replaced an assumption with a measurement: the devices *do* abut legally, at
2.42 µm, so the array is 154.9 × 101.2 µm.

🔑 **The pitch is a cliff, not a spacing.** Abutted is clean because adjacent nwells merge;
any gap from 0.02 to 0.5 µm reports `NW.b` (nwell minimum space, 0.62 µm); 0.62 µm is clean
again. **There is no legal pitch between touching and 0.62 µm apart** — across 64 devices
that is 40 µm of width, so nudging one device to slip a strap through costs the whole array.

⛔ The sweep **exits non-zero if no row fails**. A pitch sweep in this project once returned
zero violations at every pitch because the deck arguments were guessed and it never read the
layout, and overlap turned out to be the wrong falsification: coincident geometry *merges*
into shapes that pass every width and spacing rule, so overlapping two transistors is an LVS
error rather than a DRC one. The falsifying case has to stay separate and too close.

```sh
sh tools/passdrc.sh 0.02 0.1 0.3 0.5 0.62 1.0 0     # inside the PDK container
```

⚠️ **A 52 % area saving on the pass array exists and is not taken.** `w` is the *total*
device width and `ng` folds it into fingers, so every `ng` is the same transistor — same W,
same L, same drive — in a different shape, and the drawn area is not flat across that
choice: 245.0, 169.1, 132.8, 117.9, **117.0**, 129.6, 162.0 µm² per device for `ng` 1 to 64.
The block is drawn at `ng=1`, the worst of them. At `ng=16` the 64 devices abut into
124.96 × 59.92 µm and pass DRC — 7488 µm² against 15544.

⛔ **It costs 0.33° of phase margin and the block has 0.097°.** Folding shares source/drain
diffusions, cutting drain capacitance and lifting the loop's unity-gain frequency from 1.231
to 1.246 MHz: 45.097° → 44.772° at the worst of 243 corners. Nearly all of it is the *first*
fold (`ng` 2 through 16 are flat within 0.03°), so there is no partial retreat. Buying the
margin back with `Cm` works electrically but breaks the floorplan and costs 1.3 dB of PSRR;
buying it with `Cout` helps the failing corner and simply moves the worst case elsewhere.
⟹ The saving is real, and available only if the 45° floor is revisited.

## Repository layout

| Dir | Contents |
| --- | --- |
| `xschem/` | schematics — nine cells, generated, `ldo_capless` on top |
| `doc/schematics/` | rendered SVGs of every cell, readable without opening xschem |
| `tools/` | floorplan, area budget, datasheet/drift gate, layout and DRC scripts |
| `sim/` | testbenches — six published, plus the diagnostics that found the mechanisms |
| `netlist/` | extracted / simulation netlists |
| `doc/` | design notes, characterization, datasheet |
| `prototype/ldo/` | feasibility netlist (`ldo.spice`) — stable capless loop demonstrated in-process |
| `magic/` | analog layout — **empty; not started** |
| `verilog/` | digital enable / trim / power-good wrapper (LibreLane) |
| `signoff/` | DRC / LVS / extract / STA reports — **empty until there is layout** |

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
