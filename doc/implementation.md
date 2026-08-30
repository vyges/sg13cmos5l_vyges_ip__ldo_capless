# Implementation — capless LDO

What is actually built, what it measures, and what is deliberately not in this
revision. The design intent is in [`proposal.md`](proposal.md); this file records the
schematic that realises it.

## Assumptions

Everything below is an assumption the design rests on, with what it is based on. They are
stated here so a reviewer can check them against the harness rather than discover a
mismatch in the schematic. **Two are known to be unconfirmed and are marked.**

### Process

| | |
| --- | --- |
| PDK | IHP Open Source PDK, `ihp-sg13cmos5l` v0.2.0, commit `9f614c48` |
| Source | <https://github.com/IHP-GmbH/ihp-sg13cmos5l> |
| lv devices | maximum Vds **1.5 V** (`cornerMOSlv.lib`) |
| hv devices | maximum Vds **3.3 V** (`cornerMOShv.lib`) |
| Standard cells | characterised **1.08 – 1.65 V**. They are 1.2/1.5 V core cells and **cannot be operated from 3.3 V.** |
| Passives | `rhigh` 1360 Ω/sq, `rppd` 260, `rsil` 7; `cap_mfringe` at 0.67 + (mmax−mmin)×0.55 fF/µm², so 2.32 fF/µm² on an M1–M4 stack |
| No MiM capacitor | correct for this process — the CMOS5L overlay deliberately omits `capacitors_mod.lib` |

### Slot supply — the one to check first

> "Each pallet has an identical footprint. **It gets its 3.3V power supply from a pMOS power
> switch**, and is given pins to connect to the digital interface of the harness (control and
> status lines), regulated voltage bias signals, and regulated current bias signals."
>
> — `sg13cmos5l_ocd_openframe/README`, the openframe harness this block targets

So the slot has **one supply, 3.3 V**. ⚠️ **A 1.2 V rail is assumed available and this is
NOT confirmed.** The harness's own digital controller is built from 1.2 V standard cells, so
the rail exists on the die; whether it is distributed to the pallets is the open question.

### Harness resources assumed

| Resource | Assumed | Basis |
| --- | --- | --- |
| `vin` / slot supply | 3.3 V through an enable-gated pMOS switch | harness README |
| Bandgap reference | 1.2 V | harness bandgap, `bandgap*` nets |
| Bias current | see the block-specific note below | harness `ibias1_250n`, `ibias1u_*`, `ibias2_1u` nets — i.e. **250 nA and 1 µA sources** |
| Control / status | a register field on the harness SPI bus, at standard-cell logic levels | harness README |

### Simulation

| | |
| --- | --- |
| Corners | `cornerMOShv/lv.lib` (tt, ss, ff) with `cornerRES.lib` paired pessimistically (`res_typ`, `res_wcs`, `res_bcs`) |
| Temperature | −40, 27, 110 °C |
| Supply | 3.0, 3.3, 3.6 V |
| Tools | xschem 3.4.8RC, ngspice-46, in an IIC-OSIC-TOOLS-derived container |
| Not covered | Monte-Carlo mismatch, and post-layout parasitics — both after layout |

### Block-specific

✅ **`ibias` is 1 µA, matching the harness.** The harness bias nets are `ibias1_250n`,
`ibias1u_*` and `ibias2_1u`, so 1 µA is what a pallet can expect. The block was originally
drawn around 10 µA and has been re-ratioed: `Mn1` is 10× the reference device, so the
amplifier's internal operating current is unchanged, and the three NMOS mirrors that hang
off the reference — the preload, the power-good tail and the current-limit reference —
are 10× in width.

Regenerating a 10 µA reference node internally, so those three could keep their original
widths, was tried and **rejected on current**: that leg draws its 10 µA from `vin` and put
quiescent current up from 39 µA to 47 µA against a 30 µA typical. Width is nearly free in
this block; supply current is the scarce thing.

⚠️ **`vddd` (1.2 V) is required and unconfirmed**, per the slot-supply note above. The trim
switches do *not* need it — they are NMOS switches driven by the harness's control lines. The
enable inverter, the power-good comparator and the OC logic do.

## Cell hierarchy

| Cell | What it does | Schematic |
| --- | --- | --- |
| `ldo_vref` | Halves the 1.2 V harness bandgap to 0.6 V, RC-filtered | [SVG](schematics/ldo_vref.svg) |
| `ldo_erramp` | Two-stage error amplifier: PMOS input pair with NMOS mirror, then an NMOS common-source stage; Miller compensated with a nulling resistor | [SVG](schematics/ldo_erramp.svg) |
| `ldo_pass` | PMOS pass array, W = 100 µm × 20, L = 0.5 µm | [SVG](schematics/ldo_pass.svg) |
| `ldo_fbtrim` | Feedback divider with 5-bit binary-weighted output trim | [SVG](schematics/ldo_fbtrim.svg) |
| `ldo_enable` | Enable / power-gate, with a 1.2 V to 3.3 V level shift | [SVG](schematics/ldo_enable.svg) |
| `ldo_pgood` | Power-good comparator, lv domain, 1.2 V logic output | [SVG](schematics/ldo_pgood.svg) |
| `ldo_ilim` | Current limit: 1:1000 sense, throttle and OC flag | [SVG](schematics/ldo_ilim.svg) |
| `ldo_capless` | Top level, plus the Miller and output capacitors | [SVG](schematics/ldo_capless.svg) |

## Two decisions worth stating

**The 0.6 V internal reference is required, not a convenience.** A resistive-feedback
loop can only produce `Vout = Vref × (1 + R1/R2)`, which is never below `Vref`. Taking
the 1.2 V harness bandgap directly would put the bottom of the specified 1.0–1.8 V trim
window out of reach. `ldo_vref` divides it by two, and the trim range is then symmetric
about the 1.2 V default.

**Compensation capacitors are sized from the PDK model, not estimated.** The
`cap_mfringe` model gives `areacap = 0.67 + (mmax − mmin) × 0.55 fF/µm²`, so an M1–M4
stack is 2.32 fF/µm²:

| Capacitor | Value | Drawn size | Share of a 520 × 250 µm slot |
| --- | --- | --- | --- |
| `Cm` (amplifier compensation) | 48 pF | 144 × 144 µm | **16.0%** |
| `Cout` | 20 pF | 93 × 93 µm | 6.6% |
| `Cc` | 2 pF | 30 × 30 µm | 0.7% |

`Cm` sits inside `ldo_erramp` rather than at the top level, but it is the largest single
device in the block and dominates its area budget — see the PVT section for why it is
sized as it is.

This answers the "no MiM capacitor" area question directly. One caveat carried from the
model's own header: `cap_mfringe` is an empirical fit to extraction, not a foundry
compact model, and it degrades for small devices — re-extract after layout rather than
quoting these as silicon-grade.

## Measured, against the feasibility netlist

The schematic hierarchy is simulated with `sim/tb_ldo_dc.spice` and compared against the
flat feasibility netlist in `prototype/ldo/`, so a divergence shows up as a number rather
than as an opinion.

| Metric | Feasibility netlist | Schematic hierarchy | Specification |
| --- | --- | --- | --- |
| Output at mid trim code | 1.199 V | 1.2100 V | 1.0–1.8 V trimmed |
| Internal reference | — | 0.6000 V | — |
| Line regulation | ~0.04 mV/V | 0.38 mV/V | 5 mV/V max |
| Load regulation, 0→48 mA | ~15 mV | **0.38 mV** | 20 mV max |

The loop closes with `vfb` at 0.5997 V against `vref` at 0.6000 V.

## Loop stability — the primary risk, now measured

Capless stability is the design's stated primary risk, and it is the one specification
that cannot be measured on silicon at all: there is no accessible loop-break pin. It is
established here instead. `sim/tb_ldo_ac.spice` breaks the loop at the feedback node with
a DC-0 / AC-1 source: a short at DC, so the operating point stays the real closed-loop
one, and a 1 V injection at AC.

| External load | DC loop gain | Crossover | Phase margin |
| --- | --- | --- | --- |
| 0 (preload only) | 104.4 dB | 1.03 MHz | 66.5° |
| 10 µA | 108.1 dB | 1.47 MHz | 64.3° |
| 100 µA | 114.1 dB | 2.59 MHz | 65.5° |
| 1 mA | 116.5 dB | 3.20 MHz | 72.1° |
| 10 mA | 116.0 dB | 3.33 MHz | 74.9° |
| 50 mA | 110.3 dB | 3.31 MHz | 76.1° |

**Worst case across load is 64.3°, at 10 µA** — not at either end of the range — against a
specification minimum of 45° and a typical target of 60°. Over PVT the worst case is
50.1°; see the PVT section below.

### Minimum load

The regulation loop needs the pass device conducting: with no load at all its
transconductance goes to zero and the loop gain with it. The block therefore carries an
on-chip preload, `Mpre` — a 10 µA sink mirrored from the same `ibias` node as the
amplifier tail, so it tracks the harness bias rather than being a fixed resistor. A
resistive preload was rejected because its current falls with `vout`, which is the wrong
direction at the low-output trim codes where margin is thinnest.

It costs 10 µA of the 30 µA typical Iq budget, bringing the total to about 24 µA: 10 µA
amplifier tail, 10 µA preload, and roughly 2 µA each in the reference and feedback
dividers. With it the block is stable and in regulation with **no external load at all**,
at 104.4 dB of loop gain and 66.5° of phase margin, and load regulation is 0.38 mV over
0–48 mA.

## Trim curve — measured across all 32 codes

`sim/tb_ldo_trim.spice` walks every code at 1 mA and records the output.

| | measured | specification |
| --- | --- | --- |
| Range | 1.0007 V (code 0) – 1.7992 V (code 31) | 1.0 – 1.8 V |
| Default, code 16 | 1.2100 V | 1.2 V nominal |
| Monotonicity | monotonic across all 32 codes | required |
| Step size | 8.8 mV at the bottom, 73.0 mV at the top | — |
| Worst-case quantisation | ±2.12 % | ±3 % max |

The range lands on specification almost exactly and the curve is monotonic everywhere.

**The step size grows by 8.3× across the range, and that is structural rather than a
sizing error.** Guaranteeing monotonicity from a binary code forces the lower leg to be
binary-weighted, which makes R2 *linear* in code; but `vout = Vref × (1 + Rtop/R2)` is
nonlinear in R2, so equal R2 steps must produce growing voltage steps. No choice of
segment lengths avoids it while keeping the code monotonic.

The consequence for accuracy, stated plainly: **±1 % quantisation holds up to code 19
(1.276 V); above that only the ±3 % maximum applies**, with the worst case ±2.12 % at the
top of the range. The specification is met across the whole range; the ±1 % *typical*
figure is met over the lower two-thirds of it.

Two ways out, if uniform steps are later wanted, neither free:

- **Trim `Rtop` instead of `R2`.** `vout` is linear in `Rtop`, so equal steps give equal
  voltage steps. But the switches then sit at `vout`, up to 1.8 V, and a 1.2 V control bus
  cannot turn on an NMOS whose source is above its gate — it needs level-shifted drive or
  PMOS switches with a high-side driver.
- **A 32-tap ladder with a 5-to-32 decoder.** Uniform by construction, at the cost of 32
  resistors and 32 switches instead of 5 and 5, plus the decode logic.

Low-side binary trim is the right choice against a 1.2 V control bus, and the
non-uniform step is what it costs.

A second, smaller effect is folded into the same measurement: `rhigh` carries a fixed
contact term of roughly 160 Ω per device on top of its 1360 Ω/sq sheet, so the small
segments are proportionally more contact than the large ones. The layout pass should
rebuild the ladder from series/parallel *unit* resistors, so the weighting is set by count
rather than by drawn length.

## PVT

`sim/run_pvt.sh` sweeps three process corners against three temperatures and three
supplies — 27 combinations — measuring output accuracy and loop phase margin at no
external load. Resistor corners are paired pessimistically with the MOS corner.

| | across all 27 corners | specification |
| --- | --- | --- |
| Output | 1.2094 – 1.2135 V | trimmed, ±3 % |
| **Worst phase margin** | **50.1° (ss/−40 °C/3.6 V)** | 45° min |

**The block regulates and stays stable across the full commercial range**, −40 to 110 °C,
3.0 to 3.6 V, tt/ss/ff.

### Why the compensation is sized the way it is

Unity-gain crossover is gm₁/Cm, and gm₁ moves with process and temperature — at −40 °C the
loop gain rises and the crossover pushes out to where there is no phase left, while at
110 °C both fall. Controlling that spread is what sets the component values:

- **The input pair is deliberately narrow (5 µm).** The loop had roughly 60 dB more gain
  than the specification needs, so narrowing the pair trades surplus gain for crossover
  control. It is a stability parameter here, not just a gain one — and it *saves* area.
- **`Rz` is not tuned to a corner, and must not be.** Its optimum conflicts across PVT:
  50 kΩ is best at ss/−40 °C, 80 kΩ at ff/110 °C, and moving toward either wrecks the
  other. The resolution is to lower the crossover until that optimum stops being sharp,
  not to keep re-tuning it.
- **`Cm` = 48 pF is the knee.** It gives 50.1° worst-case; 96 pF buys only 0.7° more.

The capacitors are the block's area cost: `Cm` at 144 × 144 µm is about 16 % of a
520 × 250 µm slot, and `Cout` a further 6.6 %.

## Verification with Vyges Loom

The measurements above are produced with [Vyges Loom](https://vyges.com/products/loom), a
suite of open-source silicon sign-off engines. Each is a deterministic command that exits
non-zero on a violation, so it works as a build gate rather than as something a human has
to read. Install: <https://docs.vyges.com/installation.html>.

| Engine | Why we run it | Stage |
| --- | --- | --- |
| `vyges loom meas` | Extracts a scalar from a simulated sweep — here the phase margin of the regulation loop, which can never be measured on silicon because a capless LDO has no loop-break pin. | now |
| `vyges loom lvs` | Compares two netlists by graph isomorphism, independent of net names, **and compares device sizing** — so an edit that changes connectivity *or* re-sizes a component fails instead of surviving to silicon. | now, and again against layout at sign-off |
| `vyges loom extract` | Parasitics from layout (DEF/GDS → SPEF) to re-simulate against. Capless stability is parasitic-sensitive, so this is what confirms the margin survives. | after layout |

### Loop phase margin — `vyges loom meas`

**Why:** turns an AC sweep into the number the specification is written against, by a
stated method rather than an eyeballed plot.

```sh
ngspice -b sim/tb_ldo_ac.spice                        # writes loop_<load>.csv
awk '{print $1, $2, $4}' loop_001m.csv > loop.sweep   # hz gain_db phase_deg
vyges loom meas transfer loop.sweep --metric phase-margin
```

Cross-checked once against an independent interpolation of the unity-gain crossing, which
agreed to six figures — worth doing for any measurement a specification depends on.

### Connectivity and sizing gate — `vyges loom lvs`

**Why:** the schematics are generated, so an edit can change the circuit without changing
anything visible in the drawing. This compares the current netlist against a known-good one
and fails if it is no longer the same circuit.

⚠️ xschem comments out the *top* `.subckt` line, so the netlist needs unwrapping first or
the tool reports the top cell as missing:

```sh
sed 's/^\*\*\.subckt/.subckt/; s/^\*\*\.ends/.ends/' \
    sim/netlist/ldo_capless.spice > sim/lvs/current.spice
vyges loom lvs run sim/lvs/check.lvs --fail-on-mismatch
```

Against an unchanged netlist it reports the two netlists structurally equivalent and exits

0. Shorting one capacitor's plates together gives `LVS MISMATCH` and exit 3, and so does

re-sizing a device while leaving the topology untouched — verified both ways, because a
gate that cannot fail is not a gate.

ℹ️ Device-sizing comparison needs a build newer than v0.1.33; that release compares
topology only.

## Enable

`EN` arrives from the harness control bus at 1.2 V logic while the amplifier and pass
device sit on the 3.3 V rail, so **the engineering content here is a domain crossing, not
a switch**: a 1.2 V signal cannot turn off a PMOS whose source is at 3.3 V — it would sit
at Vsg = 2.1 V, permanently on. `ldo_enable` level-shifts the high side.

Disabling does two things, and doing only the first is a trap:

1. **Kill the bias**, so the mirrors stop drawing current.
2. **Force `eout` to the rail**, so the pass device is definitely off. With every mirror
   off, nothing drives `eout` — and a floating gate on the pass device can drift low and
   turn it *on*.

The same argument applies one level deeper, and it cost real current before it was
handled: the amplifier's stage-1 output is a deliberately high-impedance node, so with the
bias off it floats too, and a floating gate on the second stage can sit above threshold.
That opened a path from `vin` through the disable PMOS to ground. A pull-down on that node
defines it.

| | enabled | disabled |
| --- | --- | --- |
| `vout` | 1.2100 V | 0.27 mV |
| `eout` (pass gate) | 2.594 V | 3.300 V — full rail |
| Supply current | 1.04 mA at 1 mA load | **3.19 µA** |

Standby current is the level-shifter's pull-up leg and essentially nothing else — the leg
only conducts while disabled. A smaller resistor would switch harder and cost more standby
current; this is that trade.

The block recovers to regulation on re-enable with no latched state, and the loop's phase
margin is unchanged by the wrapper.

⚠️ **`vddd` is a new port.** The 1.2 V control-bus supply is now explicit. The block always
depended on it — the trim switches rely on a 1.2 V gate drive — so this makes an existing
assumption visible rather than adding a requirement.

## Power-good and current limit

### Power-good

**The domain is forced, and it is the opposite of the error amplifier's.** Both comparator
inputs sit near 0.6 V, which is below the hv threshold — the constraint that forced the
amplifier onto a PMOS pair — but comfortably above the lv one. So this comparator is lv,
runs from the 1.2 V control-bus rail, and its output is already a logic level with no
shift. Same constraint, opposite answer.

The trip threshold is 90 % of `vref`, taken as a **tap off the reference chain itself**.
Generating it locally was tried and rejected: a second divider hung on `vref` loads it, and
that measurably shifted the regulated output from 1.21 V to 0.998 V. Splitting the
reference's lower leg 1 : 0.1 : 0.9 gives both taps from the same 2 µA, with the ratio set
by resistor matching rather than by an added load.

| | `vout` | `PGOOD` |
| --- | --- | --- |
| In regulation | 1.2091 V | **1.20 V (asserted)** |
| Disabled | 0.27 mV | **0.06 µV (deasserted)** |

Hysteresis is **not** included. A comparator without it will chatter while the output sits
near the trip point; adding it is a feedback device from the output stage back to the
threshold node, deliberately left until the trip level is fixed.

### Current limit

`Msense` shares the pass device's gate and source, so it carries a scaled copy of the pass
current — 2 µm against the array's 2000 µm, so 1:1000. `Mref` sinks a reference mirrored
from the harness bias, which makes `oc_n` the comparison itself: low below the limit,
rising above it. No separate comparator is needed.

**The limiter acts, it does not merely report.** A 3.3 V-domain inverter drives `Mlim`,
which pulls the pass gate toward `vin` when the limit trips, so over-current reduces the
drive rather than waiting for firmware to notice. A separate level-shift path reports `OC`
on the 1.2 V rail.

| load | `vout` | `OC` |
| --- | --- | --- |
| 10 mA | 1.2090 V | low |
| 50 mA (rated) | 1.2088 V | low |
| **62.5 mA** | — | **trips** |
| 100 mA, `ILIM_EN` = 0 | 1.2087 V | low — limiter disabled |

**The trip point is sized by measurement, not by the width ratio.** At the drawn 1:1000 the
limit came out at 39 mA, well below the 50 mA rated load, because `Msense` sees a larger
Vds than the pass device and channel-length modulation makes it carry more than its share.
Scaling the reference moved the trip to 62.5 mA — above the rated load, at the stated 60 mA
absolute limit. This is why the ratio is characterised rather than calculated.

`ILIM_EN` gates both behaviours with a single device: forcing `oc_n` low disables the trip,
which disables the throttle **and** the flag together. Gating them separately would allow a
state where the limiter acts but does not report, which is the worst of both.

Neither block disturbs the regulator: the loop's phase margins are unchanged to six figures.

## Slot requirements — pins, power and clocks

For scoping pin allocation. This is the **implemented** port list, not the proposal's.

```text
.subckt ldo_capless  vref_bg ibias en ilim_en vtrim0..4 vout pgood oc vin vddd vss
```

### Pads required

| Signal | Kind | Requirement |
| --- | --- | --- |
| `vout` | analog out | **1 dedicated pad, low resistance.** Carries the full load, up to 50 mA. At 50 mA a 1 Ω mux switch drops 50 mV, which is more than the entire load-regulation specification — so a shared mux path makes the headline number unmeasurable. If it must be shared, R_on ≤ 0.2 Ω, and we would derate the maximum load accordingly. |

**One dedicated pad, and no other sole-use analog access is requested.**

⚠️ The proposal also asked for a **muxable `vout_sense`** Kelvin pin, on which mux
resistance is irrelevant because it is sensed by a high-impedance meter. **That pin is not
in this revision** — the block currently brings out a single `vout`. Adding it is a wire,
not a circuit, but it needs a pad slot to be worth adding.

### Harness resources (shared, no pads)

| Signal | From the harness |
| --- | --- |
| `vin` | 3.3 V slot supply, through the enable-gated pMOS switch. **Size that switch for 50 mA plus quiescent** — larger than a signal-path slot needs. |
| `vddd` | **1.2 V digital supply.** Required, not optional: the trim switches and the control-side logic run from it. |
| `vref_bg` | 1.2 V harness bandgap. Drawn current ~2 µA. |
| `ibias` | **1 µA**, as the harness provides. Multiplied 10× on-slot. |
| `vss` | Ground. |

### Control and status bits (register field, no pads)

| Bits | Direction | |
| --- | --- | --- |
| 7 | control | `EN` (1), `ILIM_EN` (1), `VTRIM[4:0]` (5) |
| 2 | status | `PGOOD` (1), `OC` (1) |

`IB_SEL` from the proposal's field is **not implemented**, so the control side is 7 bits
rather than 10.

### Clocks

**None.** The block needs no clock of any kind.

### Current budget

| | |
| --- | --- |
| Load | up to 50 mA through the slot switch |
| Quiescent, enabled | 35.7 µA |
| Quiescent, disabled | 3.19 µA |

## Not in this revision

Stated here rather than left to be discovered:

- **Hysteresis on the power-good comparator.** See above.
- **Trim ladder as unit resistors.** The binary weighting is currently set by drawn
  length, which carries `rhigh`'s fixed contact term into the small segments. The layout
  pass should rebuild it from series/parallel unit resistors so the weighting is set by
  count.
