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

### The minimum-load problem, and the preload that answers it

That table is the *fixed* behaviour. Before the preload was added the loop collapsed at
no load: with nothing drawing current the pass device is effectively off, its gm goes with
it, and DC loop gain fell to **−16.3 dB** with no crossover at all. Not an oscillation
risk — a loop below unity everywhere cannot oscillate — but not a regulator either. It
showed up in the DC sweep as 1.180 V at 0 mA against 1.2086 V at 1 mA, a *rising* load
regulation, which is the wrong sign for an LDO and was the clue worth chasing.

Sweeping upward located the edge: the loop is already healthy at about 10 µA (77 dB,
65°), so the block needs a defined minimum load rather than a redesign. `Mpre` supplies
it — a 10 µA sink mirrored from the same `ibias` node as the amplifier tail, so it tracks
the harness bias instead of being a fixed resistor. A resistive preload was rejected
because its current falls with `vout`, which is the wrong direction at exactly the
low-output trim codes where margin is thinnest.

It costs 10 µA of the 30 µA typical Iq budget, bringing the total to about 24 µA: 10 µA
amplifier tail, 10 µA preload, and roughly 2 µA each in the reference and feedback
dividers.

What it bought, measured:

| | before preload | after |
| --- | --- | --- |
| DC loop gain at no load | −16.3 dB | 75.4 dB |
| Phase margin at no load | none (\ | T\ | < 1) | 65.4° |
| Output at no load | 1.180 V | 1.2120 V |
| Load regulation, 0→48 mA | +17.3 mV (rising) | **14.5 mV** (falling, correct sign) |

One caveat stated rather than left implicit. This is one corner (tt, 27 °C); the
specification requires the margin across PVT, which has not been run. A phase margin
near 88° at mid load means the loop is heavily over-damped — consistent with the ~100 mV transient
droop the feasibility work recorded. There is room to trade some of that margin for a
faster transient, which is the improvement path the proposal already names.

## Verification with Vyges Loom

The measurements above are produced with [Vyges Loom](https://vyges.com/products/loom), a
suite of open-source silicon sign-off engines. Each is a deterministic command that exits
non-zero on a violation, so it works as a build gate rather than as something a human has
to read and interpret. Install instructions: <https://docs.vyges.com/installation.html>.

The point of running these at the *schematic* stage, before any layout exists, is that
both faults they catch here are cheap to fix now and expensive later.

| Engine | Why we run it | Stage |
| --- | --- | --- |
| `vyges loom meas` | Extracts a scalar from a simulated sweep — here the phase margin of the regulation loop, which is the one specification that can never be measured on silicon because a capless LDO has no loop-break pin. | now |
| `vyges loom lvs` | Compares two netlists by graph isomorphism, independent of net names — so a schematic edit that silently changes connectivity fails instead of being discovered in simulation. | now, and again against layout at sign-off |
| `vyges loom extract` | Parasitics from layout (DEF/GDS → SPEF) to re-simulate against. Capless stability is parasitic-sensitive, so this is what confirms the margin below survives. | after layout |

### Loop phase margin — `vyges loom meas`

**Why:** turns an AC sweep into the number the specification is written against, with a
stated method rather than an eyeballed plot.

```sh
ngspice -b sim/tb_ldo_ac.spice                 # writes loop_<load>.csv
awk '{print $1, $2, $4}' loop_001m.csv > loop.sweep   # hz gain_db phase_deg
vyges loom meas transfer loop.sweep --metric phase-margin
```

```text
vyges-meas — phase-margin = 87.580541 deg
  sweep     361 point(s)
  peak gain 85.3617 dB at 1.000000 Hz
```

Results across load are tabulated above. The figure was cross-checked against an
independent interpolation of the unity-gain crossing and agrees to six figures — worth
doing once for any measurement a specification depends on.

### Connectivity gate — `vyges loom lvs`

**Why:** the schematics are generated, so a routing change can alter connectivity without
changing anything visible. This compares the current netlist against a known-good one and
fails if the circuit is no longer the same circuit.

⚠️ xschem comments out the *top* `.subckt` line, so the netlist needs unwrapping first or
the tool reports the top cell as missing:

```sh
sed 's/^\*\*\.subckt/.subckt/; s/^\*\*\.ends/.ends/' \
    sim/netlist/ldo_capless.spice > sim/lvs/current.spice
cat > sim/lvs/check.lvs <<EOF
layout: sim/lvs/current.spice
schematic: sim/lvs/golden.spice
top: ldo_capless
EOF
vyges loom lvs run sim/lvs/check.lvs --fail-on-mismatch
```

Against an unchanged netlist:

```text
  nets      A 22  B 22
  refine    4 iteration(s)
  the two netlists are structurally equivalent (verified by explicit isomorphism).
```

Exit status 0. Shorting one capacitor's plates together and re-running gives
`LVS MISMATCH` and exit status 3 — verified, because a gate that cannot fail is not a
gate.

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

## Not in this revision

Stated here rather than left to be discovered:

- **Enable / power-gate**, **power-good comparator** and **current limit**. These wrap
  the regulation loop and do not change it; the loop is what the schematic establishes.
- **PVT corner sweeps.** Only the typical corner has been run.
- **AC loop gain and phase margin.** Capless stability is the design's primary risk and
  the AC testbench is the next thing to build.
- **Trim curve across all 32 codes.**
