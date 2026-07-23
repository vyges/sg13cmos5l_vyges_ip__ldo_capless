<img src="vyges-logo.svg" alt="Vyges" class="logo" height="40">

# Chipalooza Challenge #2 (IHP SG13CMOS5L) — Proposal: Low-Dropout Regulator (LDO)

> **Proposal submission — Chipalooza Challenge #2 (IHP SG13CMOS5L), 2026-07-22.**
> Block type: **voltage regulator / power management** (analog). Licence:
> **Apache-2.0**. Public repository: `github.com/vyges/vyges-capless-ldo`.
> Submitted alongside a ring-oscillator PLL from the same designer — deliberately
> a **different block type**, so the two do not compete for the same slot. Per the
> rules, this document is written to become part of the IP block's repository
> documentation, so personal and institutional details, designer CVs, and the
> test-equipment list are **omitted here and sent separately**.

## 1. Summary

We propose an **all-CMOS, capacitor-less (capless), digitally-trimmable low-dropout
regulator (LDO)** for the IHP **SG13CMOS5L** process: **3.3 V in → programmable
~1.0–1.8 V out** (default 1.2 V), moderate load, internally compensated so it needs
**no external / large on-chip capacitor** — a deliberate fit for the no-MiM, 5-metal,
small-slot process. It regulates a clean local supply for sensitive analog/mixed-signal
blocks, taking its reference from the harness bandgap.

## 2. Why this block

- **Always in demand.** LDOs were among the most-requested blocks at Chipalooza #1
  (multiple LDO/ADC variants explicitly wanted); a clean, reusable LDO is a core SoC
  primitive every mixed-signal system needs.
- **Pulled by a real integration need, not a demo.** A trimmable local regulator
  for sensitive analog/mixed-signal islands is a recurring dependency in the
  designer's own SoC work — the same need that makes this a broadly reusable
  primitive makes it worth carrying to silicon and maintaining as catalog-grade
  IP. The block has an owner with a stake in its correctness past tapeout, not a
  one-off author.
- **Right-sized for SG13CMOS5L.** All-CMOS (PMOS pass device + error amp), **no MiM
  cap** (compensation is MOM/poly or internal), fits the **~520 × 250 µm** slot.
  Capless is the correct topology when a large stabilizing cap can't fit.
- **Digital-friendly** (a challenge requirement): enable/power-gate, **register-set
  output trim**, and a power-good status flag over the harness control bus.
- **Programmable output:** register trim makes one block serve many
  rails — broadly reusable across slot projects.

## 3. Architecture

A **capless LDO**: PMOS pass transistor, single/two-stage error amplifier with
internal (Miller / ahuja) compensation, resistive/register-trimmed feedback, and a
thin digital wrapper for enable / trim / power-good.

```
VIN (3.3 V) ──►[ PMOS pass ]──┬──► VOUT (1.0–1.8 V, trimmed)
                     ▲         │
   vref ──►[ error amp ]◄──[ feedback + trim ]
                     ▲
   [ enable, trim[..], power_good ] ◄── harness control bus
```

**SG13CMOS5L process notes that shape the design:**

- **Capless / internal compensation** — no MiM cap and a small slot preclude a large
  output cap; stability comes from internal pole-splitting compensation and a
  fast error amp. This is the central design challenge (load-transient vs stability).
- **PMOS pass device** in `sg13_hv` (3.3 V) for low dropout; error amp `sg13_hv`.
- **5-level metal** — pass-device layout + current routing planned within 5 metals.

## 4. I/O and test ports

| Signal | Dir | Domain | Pad allocation | Purpose |
|---|---|---|---|---|
| `vin` | in | supply (3.3 V) | harness | LDO input (harness 3.3 V) |
| `vout_force` | out | analog | **dedicated** | regulated output — carries the full load current |
| `vout_sense` | out | analog | **muxable** | Kelvin sense of `vout` — high-impedance, no load current |
| `enable` | in | control bus | shared | enable / power-gate |
| `trim[k-1:0]` | in | control bus | shared | output-voltage trim select |
| `power_good` | out | status bus | shared | regulation-OK flag |
| `ibias`/`vref` | in | analog (bias) | shared (harness refs) | bias current + bandgap reference |
| `VDD33`/`VSS` | — | supply | harness | 3.3 V / ground |

**Series-resistance requirement (per the rules, noted so mux switches can be
sized).** This block is unusual among analog slot projects in that its output
**carries real current**, so pad-to-project resistance is not a second-order
concern: at 50 mA, a 1 Ω mux switch drops 50 mV — several times the entire
load-regulation specification, which would make the headline spec unmeasurable.

We therefore use a **4-wire (Kelvin) arrangement**, which we would encourage the
harness to support generally:

- **`vout_force` — one dedicated pad, low resistance.** Carries up to 50 mA. We
  request a dedicated pad; if it must be shared, the switch needs
  **R_on ≤ 0.2 Ω** and we would derate maximum load accordingly.
- **`vout_sense` — muxable, and mux resistance is irrelevant here.** It is sensed
  by a high-impedance meter, so no current flows and no IR drop develops. All
  precision DC measurements (line regulation, load regulation, dropout, trim
  accuracy) are taken on this pin.

This is one dedicated pad — within the ~2-dedicated-pin budget — and no sole-pin
analog access is requested. Load-transient measurement uses `vout_force` at the
board, where the step is large (~100 mV) relative to any switch drop.

## 5. Target specification

| Parameter | Min | Typ | Max | Absolute limit |
|---|---|---|---|---|
| Input voltage VIN | 3.0 V | 3.3 V | 3.6 V | 3.6 V (process limit) |
| Output voltage VOUT (trimmed) | 1.0 V | 1.2 V | 1.8 V | VIN − dropout |
| Output trim accuracy | −3 % | ±1 % | +3 % | — |
| Load current | 0 mA | 25 mA | 50 mA | 60 mA (current limit) |
| Dropout @ 50 mA | — | 150 mV | 250 mV | — |
| Quiescent current Iq | — | 30 µA | 60 µA | — |
| Line regulation † | — | 0.5 mV/V | 5 mV/V | — |
| Load regulation, 0→50 mA † | — | 12 mV | 20 mV | — |
| PSRR @ 1 kHz / 1 MHz | 40 dB / 20 dB | — | — | — |
| Load-transient droop (1→20 mA, 1 µs edge) † | — | 80 mV | 120 mV | — |
| Transient recovery (to ±1 %) † | — | 4 µs | 6 µs | — |
| Phase margin (all loads, PVT) | 45° | 60° | — | 30° (absolute) |
| Output capacitor | **capless** | — | on-chip only | no external cap required |
| Temperature (commercial) | −40 °C | 27 °C | 110 °C | 125 °C |

**† Already demonstrated at or better than target** in the §7 feasibility
simulation (tt, 27 °C): line regulation ≈ 0.04 mV/V, load regulation ≈ 6.6 mV over
1→20 mA (≈ 15 mV extrapolated across 0→48 mA), transient droop ≈ 100 mV recovering
in 3.85 µs, well damped. The specification above is deliberately set **looser than
the demonstrated typical** so that it survives PVT, layout parasitics and trim
spread rather than describing one nominal simulation.

The **transient droop is the design's crux** — the capless transient-versus-area
trade of §12 — and the 80 mV typical is an improvement target on the demonstrated
100 mV, reached via a larger on-chip MOM capacitor, a faster error amplifier, or
higher pass-device gm bias. PSRR and phase margin over PVT are characterized
during schematic design and verified in **post-layout PVT**.

## 6. Harness integration (openframe slot)

Authored as an `openframe_user_project`-style analog cell fitting a
**~520 × 250 µm** slot:

- **Power:** 3.3 V VIN from the slot's enable-gated pMOS power switch. Note this
  block's switch must be sized for the **full load current (up to 50 mA)** plus
  quiescent — larger than a typical signal-path slot. We will state the final
  figure at the schematic gate so the switch can be drawn accordingly.
- **Bias:** operating point set from the harness **bandgap (1.2 V)** and the
  **bandgap-referenced voltage/current references**; the 5-bit iDAC
  (50 nA–10.32 µA) sets error-amplifier tail current. **No on-slot bandgap
  needed** — the trim network divides down from the harness reference, so output
  accuracy inherits the harness bandgap's accuracy.
- **Digital control/status:** enable, output trim and power-good over the harness
  SPI bus, in a small per-project field (below).
- **Analog I/O:** `vout_force` on a dedicated pad, `vout_sense` on a muxable pad
  (§4).

### Proposed control/status field

| Field | Bits | Dir | Meaning |
|---|---|---|---|
| `EN` | 1 | ctrl | enable / power-up handshake |
| `VTRIM` | 5 | ctrl | output-voltage trim (1.0–1.8 V) |
| `IB_SEL` | 3 | ctrl | error-amp bias select (maps to the harness iDAC scales) |
| `ILIM_EN` | 1 | ctrl | current-limit / short-circuit protection enable |
| `PGOOD` | 1 | status | regulation-OK flag |
| `OC` | 1 | status | over-current / current-limit tripped |

We would advocate a tiny machine-readable `key: value` register description
shipped per project, so top-level integration and the test sequencer are
generated rather than hand-wired.

## 7. Feasibility — demonstrated on SG13CMOS5L (2026-07-17)

A first capless-LDO schematic (PMOS pass `sg13_hv`, 5T OTA, resistive feedback,
20 pF on-chip comp) was simulated in ngspice on SG13CMOS5L (same validated
container/flow as the PLL). Results (tt, 27 °C, VIN 3.3 V):

| Metric | Result | Note |
|---|---|---|
| Output regulation | **Vout = 1.199 V** | target 1.2 V — spot on |
| **Line regulation** | **~0.04 mV/V** | Vout Δ0.03 mV over VIN 2.9→3.58 V — excellent |
| **Load regulation** | **~6.6 mV** for a 1→20 mA step (~0.35 mV/mA) | ~15 mV over full 0→48 mA |
| **Load transient** | droop ~100 mV, **recovers in 3.85 µs, well-damped (no ringing)** | loop **stable**; droop is the tunable item |

**Read:** the topology **works and is stable** on this PDK — regulation and line reg
are excellent, the loop is well-damped. The **fast-step droop (~100 mV) is the honest
design target to improve** (bigger on-chip MOM cap / faster error amp / higher gm pass
bias) — exactly the capless transient-vs-area trade called out in §12. This de-risks
the block: the hard question (does a capless loop stay stable on SG13CMOS5L?) is
answered **yes**, with a clear tuning path for the transient spec. Netlist:
`prototype/ldo/ldo.spice`.

## 8. Staged milestones (aligned to the challenge review gates)

| Stage | Deliverable | Review gate |
|---|---|---|
| Proposal | this document + I/O + target spec + test plan + demonstrated feasibility | **wk of Jul 27** |
| Schematic | sized pass device + error amp, compensation for phase margin across load, trim network, current limit; PVT sweep of line/load/PSRR/transient | **wk of Aug 31** (schematic + pre-layout sim) |
| Layout | pass-device array + amp layout, MOM compensation cap, slot fit; RC extraction → re-simulate (capless stability is parasitic-sensitive) | **wk of Sept 28** (layout + post-layout sim) |
| Final | DRC / LVS / antenna / density, reproducible sign-off from a clean clone, documentation | **wk of Oct 19** (final review) |
| Tapeout | shuttle submission | IHP tapeout (fixed) |
| Post-Si | bench characterization per §9, measured results published in the repo | (post-shuttle) |

## 9. Test plan (validation by measurement)

**Sign-off basis.** Every specification is met and signed off in **post-layout
PVT simulation** with open-source tools — this is what the challenge review gates
score, and it is fully in-house. The table below also states, per measurement,
how it is validated on silicon given the equipment actually available in-house (an
open-source-EDA workstation, a Xilinx FPGA board, and a USB-to-SPI adapter — full
list sent separately). Anything needing an analog bench is established in
simulation and, on silicon, depends on organizer-coordinated or collaborator lab
equipment.

| Measurement | Method | Silicon measurement by |
|---|---|---|
| **Output accuracy & trim** | sweep `VTRIM` across all codes at 1 mA; record `vout_sense` | precision DMM (lab) |
| **Line regulation** | sweep VIN 3.0→3.6 V at fixed load; ΔVOUT/ΔVIN on the sense pin | precision DMM (lab) |
| **Load regulation** | step load 0→50 mA; Kelvin-sensed VOUT | DMM + electronic load (lab); FPGA generates the load step |
| **Dropout** | reduce VIN until VOUT falls 1 % below nominal, at 50 mA | DMM + load (lab) |
| **Quiescent current** | VIN supply current at no load, enable asserted | precision DMM (lab) |
| **PSRR** | inject a swept sine on VIN, measure VOUT ripple 100 Hz–10 MHz | network analyser (lab) |
| **Load transient** | pulsed load 1→20 mA and 1→50 mA, ~1 µs edge; observe `vout_force` | scope + load (lab); FPGA generates the step |
| **Stability margin** | transient ring-down shape vs load/trim as the indirect phase-margin check (no on-chip loop-break) | scope (lab); **primary check is post-layout simulation** |
| **Enable / start-up** | assert `EN`, capture VOUT rise and `PGOOD` timing | `PGOOD` timing over **SPI in-house**; VOUT rise shape needs a scope (lab) |
| **Current limit** | ramp load past 50 mA with `ILIM_EN` set; confirm `OC`, no latch-up | **`OC` flag over SPI in-house**; trip level needs a load (lab) |
| **Temperature** | repeat the DC set over temperature | temperature chamber (lab) |

**In-house today:** the FPGA + SPI path verifies the digital/functional behaviour
directly — enable and power-good timing, trim-code acceptance, and the
over-current flag — and generates load-step stimulus. The precision analog numbers
come from post-layout PVT simulation and are published in the repository; measured
silicon values are added if and when bench equipment is arranged.

**Note on stability measurement.** A capless LDO has no accessible loop-break pin,
so phase margin is not directly measurable on silicon at all — it is validated in
post-layout simulation (across load and PVT) and, given a scope, corroborated by
the transient ring-down (overshoot and settling shape as a damping proxy). Stated
explicitly rather than claiming a measurement that cannot be made.

## 10. Deliverables

Public repo: schematic, layout, GDS, netlists, spec, sign-off (DRC/LVS), reproducible
OSS-EDA verification scripts, documentation, and a measurement/characterization plan.

## 11. Approach / differentiator

- **Working flow, already validated.** The full open-source SG13CMOS5L chain
  (xschem / ngspice / magic / KLayout, in a pinned container) is stood up and has
  produced the §7 results — no toolchain risk remains to be discovered.
- **Independent sign-off.** A second, independent DRC / LVS / RC-extract check
  runs alongside magic/netgen/klayout, so sign-off is corroborated by two
  implementations rather than one.
- **Clone-and-verify.** The repository's sign-off scripts run from a clean clone
  and reproduce every published number. Completeness and reproducibility are the
  deliverable, not just a circuit that works on the author's machine.
- **Specification honesty.** Targets are set inside demonstrated behaviour and
  loosened for PVT (§5); measurements we cannot make on silicon are named as such
  (§9) rather than asserted.

Any AI used during design is **not required** for an end user to use, verify or
modify the block — sign-off is fully deterministic, per the challenge rules.

## 12. Honest risk assessment

- **Capless stability is the primary risk.** Internal compensation must hold phase
  margin across the full load range and PVT without a large output capacitor.
  Front-loaded into the schematic gate, and the §7 feasibility already shows a
  stable, well-damped loop at nominal — so the question is margin across corners,
  not whether the topology works.
- **Load-transient droop** with no output capacitor is bounded by error-amplifier
  speed and the on-chip MOM capacitor. Demonstrated at ~100 mV; the 80 mV target
  is an improvement goal, and the specification's 120 mV maximum is set so the
  block passes even if the improvement does not fully land.
- **Compensation capacitor density (no MiM, 4 thin metals).** The same constraint
  the process places on any analog slot project: compensation is MOM or poly, at
  limited density. Trades directly against droop, above.
- **Pass-device area at 50 mA.** The PMOS pass array is the dominant area
  consumer in a ~520 × 250 µm slot. If the area/dropout trade does not close, the
  honest response is to **derate maximum load** rather than miss the dropout
  specification — declared as a specification change for approval, per the rules.
- **Experience.** This is early analog depth for us. Mitigated by a demonstrated
  working topology on this exact PDK (§7), a validated toolchain, the staged
  review structure, and an independent-verification safety net.
