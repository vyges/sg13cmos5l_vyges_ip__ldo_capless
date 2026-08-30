# Implementation — capless LDO

What is actually built, what it measures, and what is deliberately not in this
revision. The design intent is in [`proposal.md`](proposal.md); this file records the
schematic that realises it.

## Cell hierarchy

| Cell | What it does | Schematic |
| --- | --- | --- |
| `ldo_vref` | Halves the 1.2 V harness bandgap to 0.6 V, RC-filtered | [SVG](schematics/ldo_vref.svg) |
| `ldo_erramp` | Two-stage error amplifier: PMOS input pair with NMOS mirror, then an NMOS common-source stage; Miller compensated with a nulling resistor | [SVG](schematics/ldo_erramp.svg) |
| `ldo_pass` | PMOS pass array, W = 100 µm × 20, L = 0.5 µm | [SVG](schematics/ldo_pass.svg) |
| `ldo_fbtrim` | Feedback divider with 5-bit binary-weighted output trim | [SVG](schematics/ldo_fbtrim.svg) |
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

## Not in this revision

Stated here rather than left to be discovered:

- **Enable / power-gate**, **power-good comparator** and **current limit**. These wrap
  the regulation loop and do not change it; the loop is what the schematic establishes.
- **Full temperature range.** The amplifier input stage is being revised to hold loop gain at −40 °C; see the PVT status above. This is the next change to land.
- **AC loop gain and phase margin.** Capless stability is the design's primary risk and
  the AC testbench is the next thing to build.
- **Trim curve across all 32 codes.**
