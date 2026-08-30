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
| `ldo_pass` | PMOS pass array, W = 100 µm × 64, L = 0.5 µm | [SVG](schematics/ldo_pass.svg) |
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
| 0 (preload only) | 106.9 dB | 0.87 MHz | 64.6° |
| 10 µA | 110.7 dB | 1.35 MHz | 60.1° |
| 30 µA | 113.7 dB | 1.94 MHz | 56.6° |
| 100 µA | 116.4 dB | 2.77 MHz | 57.3° |
| 300 µA | 117.7 dB | 3.33 MHz | 63.2° |
| 1 mA | 118.2 dB | 3.63 MHz | 69.3° |
| 10 mA | 117.6 dB | 3.79 MHz | 74.4° |
| 50 mA | 115.4 dB | 3.82 MHz | 75.5° |

**Worst case across load is 56.6°, at 30 µA** — not at either end of the range — against a
specification minimum of 45° and a typical target of 60°. ⚠️ Over corners **and load**
the worst case is 40.4°, which does not meet the minimum; see the PVT section below.

### A gate driver was tried and removed

The pass array is 6400 µm wide, so its gate is roughly 16 pF, and the second stage drives
it directly. A PMOS source follower between the two was built to present 1/gm at that node
instead of the stage's output resistance. **It was removed.** The record is kept because
the result is not obvious and the mistake it caused was worse than the design change.

It appeared to work: worst-case phase margin over the corner sweep went from 25.8° to
50.2°. That number was wrong — not mis-copied, but measured by a sweep that ran every
corner **at no load only**. Crossing load with corner (below) puts the same design at
**33.4°**, at ss/−40 °C/3.6 V with 100 µA drawn. Meanwhile dropout had gone from 149 mV to
573 mV, because a PMOS follower holds its output about a threshold *above* its input,
which sets a floor on how far the pass gate can be pulled down — and that floor is exactly
what dropout measures. Widening the follower's bias to compensate reached 64.5 µA
quiescent, over budget, with dropout *worse* and the load transient unmoved.

So the follower cost a specification and bought nothing. Removing it restores dropout to
149 mV and improves worst-case margin to 40.4°.

**The lesson is in the measurement, not the circuit:** a corner sweep at one load and a
load sweep at one corner do not bound a quantity that varies with both. `run_pvt.sh` now
crosses them.

### Stage-2 current — the same goal without the level shift

The follower's purpose was to lower the impedance at the pass gate. The second stage's own
bias current does that too, with no level shift, so dropout is untouched at every setting.
Scaling `M5` and `M6` together — `M6` sets the current, `M5`'s width keeps its gate-source
voltage where the operating point was:

| `M5`/`M6` | Load sweep, tt/27 | Corners at no load | Corners × load | Dropout | Iq |
| --- | --- | --- | --- | --- | --- |
| **10 µm / 2 µm** | **57.3°** | **40.4°** | **40.4°** | **149 mV** | **35.7 µA** |
| 15 µm / 3 µm | 53.9° | — | 34.5° | 149 mV | — |
| 20 µm / 4 µm | 51.0° | 43.8° | 22.8° | 149 mV | ~40 µA |
| 25 µm / 5 µm | 46.3° | 45.0° | 12.1° | 149 mV | ~43 µA |
| 30 µm / 6 µm | 41.9° | 46.3° | — | 149 mV | ~45 µA |
| 40 µm / 8 µm | 32.5° | 48.5° | — | 149 mV | 49.9 µA |

Read the last three columns together. Judged on corners at no load, more current looks
monotonically better and 25 µm/5 µm appears to *pass* at 45.0°. Judged on the crossed
sweep, the same setting is at 12.1° and more current is monotonically **worse**. The
no-load corner sweep does not merely understate the problem — it points the wrong way.

**The block ships at 10 µm/2 µm**, the best point under the sweep that bounds both.

### Minimum load

The regulation loop needs the pass device conducting: with no load at all its
transconductance goes to zero and the loop gain with it. The block therefore carries an
on-chip preload, `Mpre` — a 10 µA sink mirrored from the same `ibias` node as the
amplifier tail, so it tracks the harness bias rather than being a fixed resistor. A
resistive preload was rejected because its current falls with `vout`, which is the wrong
direction at the low-output trim codes where margin is thinnest.

**The preload also sets the second pole, and its size was measured rather than assumed.**
At no external load the output node sees only the preload and the feedback divider, so the
pole there is low — around 6 kHz with a 1 µA preload, close enough to crossover to cost
most of the margin. Sweeping it over all 27 corners:

| `Mpre` width | preload | worst-case PM, corners × load |
| --- | --- | --- |
| 2 µm | 1 µA | 25.8° |
| 8 µm | 4 µA | 32.2° |
| **20 µm** | **10 µA** | **40.4°** |
| 40 µm | 20 µA | 39.9° |

The relationship is not monotonic: too little preload leaves the output pole near
crossover, too much raises crossover into the *next* pole. 20 µm is the interior optimum,
worth 14.6° over the original 2 µm, and it is where the design sits. It costs 10 µA of a
35.7 µA total, against a 60 µA maximum.

Two other knobs were swept the same way and both moved the wrong direction, which is worth
recording so they are not retried: increasing the nulling resistor `Rz` (35.2 µm → 140 µm)
took the worst case from 36.2° to 1.7°, because a large series resistor stops the Miller
capacitor shunting at high frequency and the dominant pole disappears with it; and
reducing `Cm` (48 pF → 5.8 pF) took it from 36.2° to −1.3°, because crossover rises into
the pole the compensation exists to stay below.

With the preload the block is stable and in regulation with **no external load at all**,
at 106.9 dB of loop gain and 64.6° of phase margin.

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

`sim/run_pvt.sh` sweeps three process corners against three temperatures, three supplies
**and three load currents** — 81 combinations. Resistor corners are paired pessimistically
with the MOS corner.

The load axis was added after a design was accepted at 45.0° on a no-load-only sweep and
found to be at 12.1° once load and corner were crossed. Phase margin in an LDO moves with
load, because the pass device's transconductance does; a corner sweep at one load and a
load sweep at one corner do not bound it between them.

| | across all 27 corners | specification |
| --- | --- | --- |
| Output | 1.2094 – 1.2135 V | trimmed, ±3 % |
| **Worst phase margin** | **40.4° (ff/110 °C/3.0 V, no load)** | 45° min ❌ |

**The block regulates across the full commercial range**, −40 to 110 °C, 3.0 to 3.6 V,
tt/ss/ff. ⚠️ **It does not meet the 45° phase-margin minimum**: the worst case is 40.4°,
4.6° short, at ff/110 °C with no external load. Everything tried to close that gap is
recorded above and in the compensation section; see the open question at the end.

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
- **`Cm` = 48 pF is the knee.** Both larger `Rz` and smaller `Cm` were swept and both
  make it worse — see the preload section above.

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
current, and a **cascode** holds its drain at `vout` plus a threshold so its Vds tracks the
pass device's. That cascode is not a refinement — without it the sense error *grows* as the
supply falls, because the pass device enters triode while the sense device stays saturated.
It made the limiter fire before the pass device had run out, which showed up as a dropout
reading of 730 mV against the 460 mV the device actually achieves. A protection circuit that
fires early is not conservative; it truncates the specified operating range.

`sim/tb_ldo_ilim_lowvin.spice` is the regression test: at the rated 50 mA load, with the
supply swept 3.3 → 2.0 V, `OC` stays deasserted at every point and the output stays
regulated. `Msd` defines the sense node when the cascode runs out of headroom at low supply
— left floating between two off devices, the DC sweep would not converge at all.

Sizing — 2 µm against the array's 6400 µm, so 1:3200. **That ratio is set by the pass
array's width, so the two cannot be changed independently**: widening the array for dropout
moves the trip point, and `Mref` has to be rescaled with it. It was, when the array went
from 2000 µm to 6400 µm. `Mref` sinks a reference mirrored from the harness bias, which
makes `oc_n` the comparison itself: low below the limit, rising above it. No separate
comparator is needed.

**The limiter acts, it does not merely report.** A 3.3 V-domain inverter drives `Mlim`,
which pulls the pass gate toward `vin` when the limit trips, so over-current reduces the
drive rather than waiting for firmware to notice. A separate level-shift path reports `OC`
on the 1.2 V rail.

| load | `vout` | `OC` |
| --- | --- | --- |
| 10 mA | 1.2090 V | low |
| 50 mA (rated) | 1.2088 V | low |
| **59.5 mA** | — | **trips** |
| 100 mA, `ILIM_EN` = 0 | 1.2087 V | low — limiter disabled |

**The trip point is sized by measurement, not by the width ratio.** At the drawn 1:1000 the
limit came out at 39 mA, well below the 50 mA rated load, because `Msense` sees a larger
Vds than the pass device and channel-length modulation makes it carry more than its share.
With the cascode the trip sits at 59.5 mA — above the rated load and at the stated 60 mA
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

Quiescent current is **above the proposal's 30 µA typical** and comfortably inside its
60 µA maximum. The excess is the 10 µA preload, which the corner sweep showed to be the
interior optimum for phase margin — see the minimum-load section. There is roughly 24 µA
of headroom against the maximum, which is what any remaining stability work has to spend.

## Large-signal response — three specifications not met

Phase margin is a small-signal number and it does not see any of this. All three figures
below come from `sim/tb_ldo_perf.spice` and are checked by the reporting script on every
run, so they cannot quietly drop out of the record.

| | measured | specification |
| --- | --- | --- |
| Dropout at 50 mA | 573 mV | 250 mV max |
| Load-step droop, 1 → 20 mA, 1 µs edge | 324 mV | 120 mV max |
| Load-release overshoot, 20 → 1 mA | **to the 3.3 V input rail** | 120 mV max |

### Droop and overshoot are set by `Cout`, not by the loop

A 19 mA step sustained for the microsecond the loop needs to respond moves 19 nC of
charge. Across 20 pF of output capacitance that is three orders of magnitude more than the
120 mV the specification allows — the output reaches the rail on release and 324 mV below
nominal on application, and no amount of loop gain changes it. Holding 120 mV requires the
loop to respond within

    t = Cout x dV / dI = 20 pF x 120 mV / 19 mA = 126 ns

which is a large-signal slew requirement on the pass gate, not a bandwidth one: turning
16 pF of gate through half a volt in 126 ns needs about 63 µA of drive, against a
quiescent budget of 60 µA for the whole block.

**This was measured against the design as it stood before the gate driver, to be sure of
the attribution:** droop 325 mV and overshoot to the rail, i.e. unchanged. The gate driver
neither caused nor fixed either one. `Cout` is the variable.

### Dropout regressed when the gate driver landed

| | without the driver | with it | specification |
| --- | --- | --- | --- |
| Worst phase margin, corners × load | **40.4°** | 33.4° | 45° min |
| Dropout at 50 mA | **149 mV** | 573 mV | 250 mV max |
| Load-step droop | 325 mV | 324 mV | 120 mV max |
| Load-release overshoot | rail | rail | 120 mV max |
| Quiescent current | **35.7 µA** | 45.6 µA | 60 µA max |

Measured on the same crossed sweep for both, which is the comparison that matters: the
driver is worse on every line. It was removed.

The mechanism is the follower's level shift, and it is the same property that makes the
follower work at all. A PMOS follower holds its output roughly a threshold *above* its
input, which is what lets the pass gate rise far enough to turn the device off. The same
shift sets a *floor* on how far the gate can be pulled down — about 1.1 V — and that floor
caps the pass device's gate-source drive, which is exactly what dropout measures.

Widening `Msrc` to drive the follower harder was tried and rejected: at 12 µm the
quiescent current goes to 64.5 µA, over budget, dropout gets *worse* at 644 mV, and the
overshoot does not move at all.

**So the block currently trades a passing dropout specification for a passing stability
one, and cannot have both in this topology.** The proposal names capless stability as the
primary risk and states that the honest response to an area-or-dropout squeeze is to
derate maximum load as a declared specification change. That is why the gate driver is
kept in this revision — but it is a review decision, not a settled one, and the numbers
for both choices are above.

## Not in this revision

Stated here rather than left to be discovered:

- **Hysteresis on the power-good comparator.** See above.
- **Trim ladder as unit resistors.** The binary weighting is currently set by drawn
  length, which carries `rhigh`'s fixed contact term into the small segments. The layout
  pass should rebuild it from series/parallel unit resistors so the weighting is set by
  count.
- **`IB_SEL` bias selection.** Specified, not implemented. The block takes the 1 µA
  harness bias unconditionally.
- **PSRR is short of specification**: 35 dB at 1 kHz against 40 dB, and it crosses zero
  above roughly 50 kHz — +1.2 dB at 100 kHz and +3.8 dB at 1 MHz, i.e. supply ripple is
  *amplified* there rather than rejected. The high-frequency figure is the same `Cout`
  limitation as the load transient.

## Work remaining, in the order it should be done

1. **Close the last 4.6° of phase margin** — see the open question below. Dropout,
   quiescent current and output accuracy all pass; this is the only remaining
   small-signal gap and everything cheap has been tried.
2. **Size `Cout` against the load-step specification rather than against area.** 20 pF was
   chosen as 6.6 % of the slot. The transient specification implies far more, and a
   capless LDO with a 1 µs, 19 mA step is a charge problem before it is a loop problem.
   This needs a number from the review: what step must actually be survived, and at what
   output droop.
3. **Re-run PVT once 1 and 2 are settled** — both change the operating point, and the
   corner sweep is the only thing that has caught a regression here so far.
4. **Monte-Carlo the trim divider and the reference**, which no run has covered yet.
5. Then the deferred items above: power-good hysteresis, unit-resistor trim ladder,
   `IB_SEL`.

## Open question — the last 4.6° of phase margin

**Posted for anyone who wants to chip in.** The block is 40.4° against a 45° minimum, at
ff/110 °C with no external load. Everything else passes.

**What it is:** capless LDO on IHP SG13G2, 3.3 V in, 1.0–1.8 V trimmed out (1.2 V
nominal), 50 mA. Two-stage Miller-compensated amplifier, PMOS input pair (5 µm), PMOS pass
array 6400 µm / 0.5 µm. `Cm` 48 pF MOM with a 50 kΩ `rhigh` nulling resistor, `Cc` 2 pF
across the pass device, `Cout` 20 pF on chip, 10 µA preload. Quiescent 35.7 µA of a 60 µA
budget, so there is current to spend. Dropout 149 mV against 250 max.

**What has been swept, and which way it moved** — all measured over 81 corner × load
combinations, worst case quoted:

| Change | Result |
| --- | --- |
| Preload 1 → 10 µA | 25.8° → **40.4°**, an interior optimum; 20 µA gives 39.9° |
| Nulling `Rz` 50 kΩ → 140 kΩ | 40.4° → 9.8°, then −15.2° |
| `Cm` 48 pF → 5.8 pF | worse at every step |
| `Cc` 2 pF → 23 pF | 40.4° → 18.5° (but load-release overshoot improves 3×) |
| Input pair 5 µm → 1 µm | 40.4° → 34.2° |
| Stage-2 current 5 → 25 µA | no-load corners improve, corner × load gets **worse** |
| PMOS source-follower gate driver | 33.4°, and dropout 149 → 573 mV. Removed |

**The questions:**

1. **Is there a compensation topology for this case that has not been tried?** The
   binding corner is fast silicon, hot, no load — where the loop is slowest and the
   phase dip sits nearest crossover.
2. **Is 45° the right target for a capless LDO with only 20 pF of on-chip output
   capacitance**, or is the honest answer that `Cout` has to be much larger and the
   stability question changes shape once it is? The load-step numbers point the same way.
3. **Anything IHP-specific?** Is there a known characteristic of the SG13G2 thick-oxide
   devices at the ff corner and 110 °C — output resistance, or `rhigh`'s temperature and
   sheet corner pairing — that makes this combination unusually hard, or that means our
   corner pairing (ff with best-case sheet) is more pessimistic than the PDK intends?

Everything above is reproducible from this repository: `sim/run_pvt.sh` for the corner ×
load sweep, `sim/tb_ldo_ac.spice` for the loop-gain measurement.

## Questions that need answers before layout

These block work rather than merely informing it.

1. **Is a 1.2 V rail distributed to the pallets, or is 3.3 V the only supply?** The
   enable inverter, the power-good comparator and the OC reporting path all run from
   `vddd` at 1.2 V. If the slot supplies only 3.3 V, those three need rebuilding in
   thick-oxide devices, and the block has to generate its own low rail. Everything else
   in the block is already 3.3 V-native. This is the single largest unknown.
2. **What load step must the block survive, and at what droop?** See item 2 above. The
   answer sets `Cout`, which is the block's second-largest area consumer.
3. **What bias currents does a pallet actually receive?** The design assumes a 1 µA
   source and multiplies it by ten internally. The harness names `ibias1_250n`,
   `ibias1u_*` and `ibias2_1u` suggest 250 nA and 1 µA are both available; confirmation
   would let the internal multiplication be dropped.
4. **Is derating maximum load acceptable** if the dropout trade in item 1 goes that way,
   and to what current?
