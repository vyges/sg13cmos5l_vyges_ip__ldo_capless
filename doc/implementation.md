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

| Load | DC loop gain | Crossover | Phase margin |
| --- | --- | --- | --- |
| 0 mA | −16.3 dB | none, \ | T\ | < 1 | not applicable |
| 1 mA | 85.4 dB | 553 kHz | 87.6° |
| 10 mA | 84.3 dB | 538 kHz | 88.2° |
| 25 mA | 82.2 dB | 526 kHz | 88.3° |
| 50 mA | 78.6 dB | 509 kHz | 88.4° |

**Across 1–50 mA the loop holds 87.6–88.4° of phase margin**, against a specification
minimum of 45° and a typical target of 60°. At tt/27 °C the capless topology is stable
with a wide margin.

**At true no load the loop gain falls below unity.** With nothing drawing current the pass
device is effectively off, DC loop gain collapses to −16 dB and there is no crossover at
all. This is not an oscillation risk — a loop with \|T\| < 1 everywhere cannot
oscillate — but it is not regulating either, and it is the explanation for the otherwise
odd load-regulation figure: 1.180 V at 0 mA against 1.2086 V at 1 mA. **The block needs a
defined minimum load.** The only preload today is the feedback and reference dividers, at
about 4 µA combined; a explicit preload is the conventional fix and is a schematic-stage
change, not a layout one.

Two caveats stated rather than left implicit. This is one corner (tt, 27 °C); the
specification requires the margin across PVT, which has not been run. And a phase margin
near 88° means the loop is heavily over-damped — consistent with the ~100 mV transient
droop the feasibility work recorded. There is room to trade some of that margin for a
faster transient, which is the improvement path the proposal already names.

## Known approximation in the trim ladder

`rhigh` carries a fixed contact term of roughly 160 Ω per device on top of its
1360 Ω/sq sheet, so binary-weighted *single* resistors are not exactly binary — the
small segments are proportionally more contact than the large ones. The trim curve is
therefore measured across codes rather than assumed. The layout pass should rebuild the
ladder from series/parallel unit resistors so the weighting is set by count.

## Not in this revision

Stated here rather than left to be discovered:

- **Enable / power-gate**, **power-good comparator** and **current limit**. These wrap
  the regulation loop and do not change it; the loop is what the schematic establishes.
- **PVT corner sweeps.** Only the typical corner has been run.
- **AC loop gain and phase margin.** Capless stability is the design's primary risk and
  the AC testbench is the next thing to build.
- **Trim curve across all 32 codes.**
