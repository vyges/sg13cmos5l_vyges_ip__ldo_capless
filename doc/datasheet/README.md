# Datasheet

`ldo_capless_schematic.md` is generated. Do not edit it.

```bash
sh sim/run.sh && sh sim/run_pvt.sh     # produce the results
python3 tools/datasheet.py             # emit the table
python3 tools/datasheet.py --check     # verify README.md against them; exit 1 on drift
```

## The format

One table per netlist source, the same rows in every one, rows that cannot run against a
given source marked **Skip** rather than dropped. Only `schematic` exists today: there is no
layout, so `layout`, `pex` and `rcx`, and with them every physical row (area, DRC, LVS,
antenna), have nothing to run against. They are still listed, because a row that is missing
reads as an oversight while a row marked Skip states that the check exists and says what it
will be judged against.

## Why this is not CACE

The format is CACE's and the credit is CACE's. The tool is not a dependency, for one
practical reason: **CACE cannot consume `.spice` testbenches** — upstream declares that
template branch and leaves its body as `err("TODO: Implement substitution for spice
templates!")`. Every bench here is `.spice`, so using CACE would mean carrying a patched fork
*and* a second copy of every bench in CACE's template dialect. Two copies of a bench drift,
which is the failure this whole exercise exists to prevent. `tools/datasheet.py` reads the
benches' own output instead, so there is exactly one copy of each.

What that gives up, honestly: CACE would orchestrate the physical checks and derive the
schematic/symbol SVGs. Neither pays off before there is a layout, and the physical rows will
come from the Loom engines when there is one — `vacuous` maps to Skip, a violation count to
the value.

## Plots

Three, each showing something the table cannot:

- **`ldo_capless_bode.svg`** — loop gain and phase at the load where the margin is
  thinnest, so the crossing the phase margin is measured at is visible rather than asserted.
- **`ldo_capless_pm_vs_load.svg`** — margin across the load range. ⛔ A no-load sweep does
  not bound this: the margin dips in the microamp decade and recovers at milliamps, so the
  worst case sits in the middle. That is why the corner sweep crosses load with process
  rather than stacking them.
- **`ldo_capless_pm_pvt.svg`** — all 243 corners as a distribution against the 45° line.
  The worst corner is the only number that matters, but a reader deciding whether to use
  the block wants to see how much of the population sits near the limit.

Hand-written SVG, not matplotlib: the block's tooling is stdlib-only, an SVG diffs and
reviews like the rest of the repository, and no plotting library's version can quietly
change what a published figure looks like.

- **`ldo_capless_load_step.svg`** — the step, which is where both failures actually live.
  Each is a shape the table cannot carry: *338 mV of droop* says nothing about how long the
  output is out of regulation, and *to the 3.3 V rail* says nothing about how sharp the
  release excursion is or that it is an over-voltage on thin-oxide devices.
- **`ldo_capless_psrr.svg`** — rejection against frequency, with the four specification
  points marked. Supply noise does not arrive at one frequency; the curve shows where
  rejection collapses.

⛔ The annotations on the step plot use **the bench's own measurement windows** (`FROM=20u
TO=30u` for droop, `40u`–`50u` for overshoot). A global extremum instead labelled the droop
1808 mV against a published 338 — a plot that disagrees with the table above it is worse
than no plot.

## The check is the point

🔑 **Every figure is derived, never transcribed.** `--check` parses the table in `README.md`
and compares each published figure against the simulation behind it, to half of the last
digit that figure is published to. It found four numbers that had stopped tracking their
simulations: load regulation (published as the line-regulation figure, one row up), the two
trim-range endpoints, and quiescent current. All corrected.

⛔ The tolerance is taken from the published literal, never a constant — `0.05` is half a
millivolt against a figure quoted in mV and fifty millivolts against one quoted in volts, so
a fixed value let the volt-scale rows pass a window they could not fall out of. A check that
cannot fail proves nothing.

## Schematics

`tools/sch2svg.py` renders `xschem/*.sch` to `doc/schematics/`, using the PDK's own symbol
artwork cached in `sym_art.json` beside it:

```bash
python3 tools/sch2svg.py xschem/*.sch --out doc/schematics
```

It moved here from private tooling on 2026-09-02 for the same reason the numbers did: a
published figure whose generator is private cannot be re-derived by the person reading it.

⚠️ **It caught stale figures the moment it arrived.** The schematics changed in the
`dev@ab1510c` re-pin on 2026-09-01 but the committed SVGs were last generated on 2026-08-29,
so the published drawings showed the pre-re-pin circuit. Regenerated.

ℹ️ **Not xschem's own SVG export.** That dumps the editor canvas — whatever zoom happened to
be set — and in headless mode here it renders a fragment: for a 69-instance schematic it
emitted 44 elements containing one instance, with `tkwait visibility .drw failed`. This
renderer reads the `.sch` directly, so the picture cannot drift from the netlisted circuit.
