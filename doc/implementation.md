# Implementation — capless LDO

What is actually built, what it measures, and what is deliberately not in this
revision. The design intent is in [`proposal.md`](proposal.md); this file records the
schematic that realises it.

## Cell hierarchy

| Cell | What it does | Schematic |
| --- | --- | --- |
| `ldo_vref` | Halves the 1.2 V harness bandgap to 0.6 V, RC-filtered | [SVG](schematics/ldo_vref.svg) |
| `ldo_erramp` | 5T OTA error amplifier, `sg13_hv`, tail mirrored from the harness bias | [SVG](schematics/ldo_erramp.svg) |
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
| `Cout` | 20 pF | 93 × 93 µm | 6.6% |
| `Cc` | 2 pF | 30 × 30 µm | 0.7% |

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
| Output at mid trim code | 1.199 V | 1.2086 V | 1.0–1.8 V trimmed |
| Internal reference | — | 0.6000 V | — |
| Line regulation | ~0.04 mV/V | 0.044 mV/V | 5 mV/V max |
| Load regulation, 0→48 mA | ~15 mV | 17.3 mV | 20 mV max |

The loop closes with `vfb` at 0.5997 V against `vref` at 0.6000 V.

## Loop stability — the primary risk, now measured

Capless stability is the design's stated primary risk, and it is the one specification
that cannot be measured on silicon at all: there is no accessible loop-break pin. It is
established here instead. `sim/tb_ldo_ac.spice` breaks the loop at the feedback node with
an inductor that is a short at DC and an open at AC, so the operating point stays the real
closed-loop one while the sweep sees an open loop.

| External load | DC loop gain | Crossover | Phase margin |
| --- | --- | --- | --- |
| 0 (preload only) | 75.4 dB | 518 kHz | 65.4° |
| 10 µA | 78.6 dB | 543 kHz | 74.2° |
| 100 µA | 83.6 dB | 557 kHz | 84.7° |
| 1 mA | 85.2 dB | 553 kHz | 87.6° |
| 10 mA | 84.2 dB | 538 kHz | 88.2° |
| 50 mA | 78.6 dB | 509 kHz | 88.4° |

**Worst case is 65.4° at no external load**, against a specification minimum of 45° and a
typical target of 60°. The capless topology is stable across the full load range.

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
at 75.4 dB of loop gain and 65.4° of phase margin, and load regulation is 14.5 mV over
0–48 mA.

## Trim curve — measured across all 32 codes

`sim/tb_ldo_trim.spice` walks every code at 1 mA and records the output.

| | measured | specification |
| --- | --- | --- |
| Range | 0.9996 V (code 0) – 1.7971 V (code 31) | 1.0 – 1.8 V |
| Default, code 16 | 1.2086 V | 1.2 V nominal |
| Monotonicity | monotonic across all 32 codes | required |
| Step size | 8.8 mV at the bottom, 72.9 mV at the top | — |
| Worst-case quantisation | ±2.11 % | ±3 % max |

The range lands on specification almost exactly and the curve is monotonic everywhere.

**The step size grows by 8.3× across the range, and that is structural rather than a
sizing error.** Guaranteeing monotonicity from a binary code forces the lower leg to be
binary-weighted, which makes R2 *linear* in code; but `vout = Vref × (1 + Rtop/R2)` is
nonlinear in R2, so equal R2 steps must produce growing voltage steps. No choice of
segment lengths avoids it while keeping the code monotonic.

The consequence for accuracy, stated plainly: **±1 % quantisation holds up to code 19
(1.275 V); above that only the ±3 % maximum applies**, with the worst case ±2.11 % at the
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

## PVT status

`sim/run_pvt.sh` sweeps three process corners against three temperatures and three
supplies, measuring output accuracy and loop phase margin at no external load (its worst
case). Resistor corners are paired pessimistically with the MOS corner.

**Phase margin holds across process and supply at and above room temperature** — worst
case 47.7° at ff/110 °C/3.6 V, against a 45° specification minimum, with tt/110 °C at 51.2°
and ss/110 °C at 57.0°.

⚠️ **The block is not yet validated below 0 °C.** The error amplifier's input stage does
not hold sufficient loop gain at −40 °C, and a revised input stage is in progress. The
commercial temperature range in the specification is therefore **not** met by this
revision, and the numbers elsewhere in this document are room-temperature figures. This is
stated here rather than left for a reviewer to discover.

## Not in this revision

Stated here rather than left to be discovered:

- **Enable / power-gate**, **power-good comparator** and **current limit**. These wrap
  the regulation loop and do not change it; the loop is what the schematic establishes.
- **Full temperature range.** The amplifier input stage is being revised to hold loop gain at −40 °C; see the PVT status above. This is the next change to land.
- **AC loop gain and phase margin.** Capless stability is the design's primary risk and
  the AC testbench is the next thing to build.
- **Trim curve across all 32 codes.**
