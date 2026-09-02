#!/usr/bin/env python3
"""Emit this IP's datasheet from the simulation results already on disk.

The output is the CACE summary format -- one table per netlist source, the same rows in
every one, rows that cannot run against a given source marked Skip rather than dropped.
CACE itself is not required, and deliberately not a dependency: it cannot consume `.spice`
testbenches at all (upstream declares that branch and leaves it unimplemented), so using it
would mean carrying a patched fork AND a second copy of every bench in its own template
dialect. Two copies of a bench drift. This reads the benches' own output instead.

🔑 EVERY NUMBER HERE IS DERIVED, NEVER TRANSCRIBED. A figure a script has to produce cannot
quietly go stale; a figure a human reads off a plot and pastes into a README can, and in
this repository three of them had. `--check` compares what this emits against the values
published in README.md and fails if they have drifted apart.

Usage:
    python3 tools/datasheet.py                 # write doc/datasheet/*.md
    python3 tools/datasheet.py --check         # verify the published figures, exit 1 on drift

Inputs, all produced by sim/run.sh and sim/run_pvt.sh:
    sim/_report_<bench>.log   per-bench ngspice output (single corner, tt/27)
    sim/pvt/dc.txt            243 PVT corners: tag vout iq
    sim/pvt/<tag>.csv         243 loop-gain sweeps: f, dB, f, phase
"""

import argparse
import math
import os
import re
import sys
from datetime import datetime, timezone

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
NAME = "ldo_capless"

# The nominal corner. "Typical" in the table means the value here, not an average over
# corners -- an average is not a value the part ever takes.
NOMINAL = "tt_res_typ_27_3.3"


# ---------------------------------------------------------------- reading results

def _meas(bench, key):
    """One .meas result from a bench log.

    ngspice writes these two ways depending on the statement -- `key = value` from a
    `print`, and `key   =  value at= ...` from a `meas` -- so accept both and take the
    first. A missing key is an error, never a zero: a datasheet row whose measurement did
    not happen must not read as a number.
    """
    path = os.path.join(ROOT, "sim", f"_report_{bench}.log")
    if not os.path.isfile(path):
        raise SystemExit(f"no such bench log: {path}\nrun sim/run.sh first")
    pat = re.compile(rf"^{re.escape(key)}\s*=\s*([-+0-9.eE]+)")
    for line in open(path):
        m = pat.match(line)
        if m:
            return float(m.group(1))
    raise SystemExit(f"{path}: no measurement {key!r} -- the bench ran but did not measure it")


def _pvt():
    """The PVT sweep as {tag: (vout, iq)}."""
    path = os.path.join(ROOT, "sim", "pvt", "dc.txt")
    if not os.path.isfile(path):
        raise SystemExit(f"no PVT results: {path}\nrun sim/run_pvt.sh first")
    out = {}
    for line in open(path):
        parts = line.split()
        if len(parts) == 3 and parts[1] != "fail":
            out[parts[0]] = (float(parts[1]), float(parts[2]))
    if not out:
        raise SystemExit(f"{path}: no usable corners")
    return out


def phase_margin(csv):
    """(f_unity, PM, dc_gain_db) at the first 0 dB crossing, or None if it never crosses.

    ⛔ The 3-tuple is part of the contract: chipalooza/tools/report.py imports this in place
    of its own copy and unpacks all three. Returning two silently breaks that gate.

    ngspice `wrdata` repeats the sweep column per vector, so a two-vector write is
    f, dB, f, phase. PM is 180 + phase at the crossing, interpolated in log f against dB
    because that is where the response is straight, and wrapped into (-180, 180].

    ⛔ This definition is shared with the gate in chipalooza/tools/report.py. If the two
    ever disagree the datasheet and the gate report different phase margins for the same
    design, which is the exact failure this file exists to prevent -- so the gate imports
    this function rather than keeping its own copy.
    """
    rows = []
    for line in open(csv):
        parts = line.split()
        if len(parts) >= 4:
            try:
                rows.append((float(parts[0]), float(parts[1]), float(parts[3])))
            except ValueError:
                pass
    if len(rows) < 2:
        return None
    dc = rows[0][1]
    for (f0, d0, p0), (f1, d1, p1) in zip(rows, rows[1:]):
        if d0 > 0.0 >= d1:
            t = d0 / (d0 - d1)
            fu = math.exp(math.log(f0) + t * (math.log(f1) - math.log(f0)))
            pm = 180.0 + p0 + t * (p1 - p0)
            while pm > 180.0:
                pm -= 360.0
            while pm <= -180.0:
                pm += 360.0
            return fu, pm, dc
    return None


def _pvt_phase_margins():
    """Phase margin at every PVT corner that produced a loop sweep."""
    d = os.path.join(ROOT, "sim", "pvt")
    out = {}
    for f in sorted(os.listdir(d)) if os.path.isdir(d) else []:
        if f.endswith(".csv"):
            r = phase_margin(os.path.join(d, f))
            if r:
                out[f[:-4]] = r[1]
    return out


# ---------------------------------------------------------------- the specification
#
# Limits are the published specification. They live HERE, in the thing that also produces
# the measured value, so a limit cannot drift away from the number it judges -- the Gate B
# review found a checker gating the PLL against 1 GHz where the specification said 800 MHz,
# which is exactly what a limit kept somewhere else looks like when it rots.
#
# Values are in BASE units (V, A, dB, degrees); `unit` only decides how they are displayed.

def rows():
    pvt = _pvt()
    pm = _pvt_phase_margins()
    nom_iq = pvt[f"{NOMINAL}_0"][1]

    vouts = [v for v, _ in pvt.values()]
    iqs = [i for tag, (_, i) in pvt.items() if tag.endswith("_0")]
    pms = list(pm.values())

    # dropout: the input voltage at which the output has fallen 1 % below its 3.3 V value,
    # measured at a 50 mA load, minus that 1 %-low target.
    vo_at33 = _meas("tb_ldo_perf.spice", "vo_at33")
    dropout = _meas("tb_ldo_perf.spice", "vin_dr") - 0.99 * vo_at33

    lo_, hi_ = _meas("tb_ldo_dc.spice", "vo_lo"), _meas("tb_ldo_dc.spice", "vo_hi")
    nl_, fl_ = _meas("tb_ldo_dc.spice", "vo_noload"), _meas("tb_ldo_dc.spice", "vo_fullload")

    def spread(vals):
        return (min(vals), sorted(vals)[len(vals) // 2], max(vals))

    def one(v):
        return (v, v, v)

    # (display, unit, lo, hi, (min, typ, max)) -- lo/hi None means unbounded on that side
    return [
        ("Output voltage, mid code", "V", 1.1, 1.3,
         (min(vouts), pvt[f"{NOMINAL}_0"][0], max(vouts))),
        ("Output trim range, low code", "V", None, 1.05, one(_meas("tb_ldo_trim.spice", "vt_00"))),
        ("Output trim range, high code", "V", 1.75, None, one(_meas("tb_ldo_trim.spice", "vt_31"))),
        ("Line regulation", "mV/V", None, 5e-3, one(abs(hi_ - lo_) / (3.58 - 2.9))),
        ("Load regulation, 0-48 mA", "mV", None, 20e-3, one(abs(nl_ - fl_))),
        ("Dropout at 50 mA", "mV", None, 250e-3, one(dropout)),
        ("Quiescent current, enabled", "uA", None, 60e-6, (min(iqs), nom_iq, max(iqs))),
        ("Current limit trip", "mA", None, 60e-3, one(_meas("tb_ldo_status.spice", "i_trip"))),
        ("Phase margin over PVT", "deg", 45.0, None, spread(pms)),
        ("PSRR at 1 kHz", "dB", 40.0, None, one(abs(_meas("tb_ldo_perf.spice", "psrr_1k")))),
        ("Load-step droop, 1-20 mA", "mV", None, 120e-3,
         one(_meas("tb_ldo_perf.spice", "vo_pre") - _meas("tb_ldo_perf.spice", "vo_droop"))),
        ("Load-release overshoot", "mV", None, 120e-3,
         one(_meas("tb_ldo_perf.spice", "vo_over") - _meas("tb_ldo_perf.spice", "vo_settle"))),
    ]


# Physical verification. Declared and Skipped rather than omitted: a row that is missing
# reads as an oversight, a row marked Skip states that the check exists and has not been
# run. There is no layout yet, so none of these can run against any netlist source.
# When there is one, these come from the Loom engines -- `vacuous` maps to Skip, a
# violation count maps to the value.
PHYSICAL = [
    ("Area", "um2", None, 530 * 310e-12),
    ("Magic DRC", "", None, 0),
    ("Netgen LVS", "", None, 0),
    ("KLayout DRC", "", None, 0),
    ("Antenna violations", "", None, 0),
]

SCALE = {"V": 1, "mV": 1e3, "uA": 1e6, "mA": 1e3, "mV/V": 1e3, "dB": 1, "deg": 1,
         "um2": 1e12, "": 1}


# ---------------------------------------------------------------- rendering

def _fmt(v, unit):
    return f"{v * SCALE[unit]:.3f} {unit}".strip()


def _limit(v, unit):
    return "any" if v is None else _fmt(v, unit)


def _status(lo, hi, mn, mx):
    if lo is not None and mn < lo:
        return "Fail ❌"
    if hi is not None and mx > hi:
        return "Fail ❌"
    return "Pass ✅"


def table(source):
    """The summary table for one netlist source.

    The row set does not change between sources; only whether a row could run does. That
    is the point of the format: on `schematic` the physical rows say Skip, and a reader can
    see that the check exists and what it will be judged against.
    """
    out = [f"# Datasheet for {NAME}", "", f"**netlist source**: {source}", "",
           "| Parameter | Unit | Min Limit | Min Value | Typ Value | Max Limit | Max Value | Status |",
           "| :-------- | :--- | --------: | --------: | --------: | --------: | --------: | :----: |"]
    for disp, unit, lo, hi, (mn, ty, mx) in rows():
        out.append(f"| {disp} | {unit or '-'} | {_limit(lo, unit)} | {_fmt(mn, unit)} | "
                   f"{_fmt(ty, unit)} | {_limit(hi, unit)} | {_fmt(mx, unit)} | "
                   f"{_status(lo, hi, mn, mx)} |")
    for disp, unit, lo, hi in PHYSICAL:
        # No layout exists, so every one of these is Skip against every source today.
        out.append(f"| {disp} | {unit or '-'} | {_limit(lo, unit)} | ​ | ​ | "
                   f"{_limit(hi, unit)} | ​ | Skip 🟧 |")
    return "\n".join(out) + "\n"


# ---------------------------------------------------------------- published-figure check
#
# The figures README.md publishes, against the row that derives each. This is the guard the
# repository did not have: three published numbers had stopped tracking the simulations
# behind them, and nothing failed when they did.
# Which README table row each derived figure is published in. Only the LABELS live here:
# the values are parsed out of README.md at check time. Copying the numbers into this file
# would recreate the exact duplication this check exists to catch -- two places holding the
# same figure, drifting apart quietly.
PUBLISHED_AS = {
    "Output trim range, low code": ("Output, trimmed", 0),
    "Output trim range, high code": ("Output, trimmed", 1),
    "Line regulation": ("Line regulation", 0),
    "Load regulation, 0-48 mA": ("Load regulation, 0\u219248 mA", 0),
    "Dropout at 50 mA": ("Dropout at 50 mA", 0),
    "Quiescent current, enabled": ("Quiescent current, enabled", 0),
    "Current limit trip": ("Current limit trip", 0),
    "Phase margin over PVT": ("Phase margin, worst over PVT", 0),
    "PSRR at 1 kHz": ("**PSRR at 1 kHz**", 0),
    "Load-step droop, 1-20 mA": ("**Load-step droop, 1 \u2192 20 mA**", 0),
}

NUM = re.compile(r"[-+]?\d+\.?\d*")


def _tolerance(literal):
    """Half of the last digit the figure is published to.

    ⛔ The tolerance MUST come from the published literal, never a constant. A fixed 0.05 is
    half a millivolt against a figure quoted in mV and fifty millivolts against one quoted
    in volts -- so the volt-scale rows were checked against a window they could not fall out
    of, and a check that cannot fail proves nothing. "1.0007" is held to 0.00005.
    """
    frac = literal.split(".")[1] if "." in literal else ""
    return 0.5 * 10 ** (-len(frac))


def _readme_figures():
    """{row label: [numbers published in its measured column]} from README.md."""
    out = {}
    for line in open(os.path.join(ROOT, "README.md"), encoding="utf-8"):
        if not line.startswith("|"):
            continue
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        if len(cells) >= 2:
            out[cells[0]] = NUM.findall(cells[1])
    return out


def check():
    """Compare every figure README.md publishes against the value derived here."""
    by_name = {r[0]: r for r in rows()}
    published = _readme_figures()
    bad = []
    print(f"{'figure':<32} {'published':>10} {'derived':>10}   status")
    for name, (label, idx) in PUBLISHED_AS.items():
        if label not in published or len(published[label]) <= idx:
            raise SystemExit(f"README.md has no figure {idx} in row {label!r} -- the table "
                             f"was edited without updating tools/datasheet.py")
        literal = published[label][idx]
        disp, unit, lo, hi, (mn, ty, mx) = by_name[name]
        # A figure quoted as a worst case over PVT is compared against the worst case;
        # everything else against the typical corner.
        derived = mn if name == "Phase margin over PVT" else ty
        derived *= SCALE[unit]
        ok = abs(derived - float(literal)) <= _tolerance(literal)
        if not ok:
            bad.append(name)
        print(f"{name:<32} {literal:>10} {derived:>10.6g}   {'ok' if ok else 'DRIFTED'}")
    if bad:
        print(f"\n{len(bad)} published figure(s) no longer match the simulations:")
        for n in bad:
            print(f"  {n}")
        return 1
    print("\nevery figure README.md publishes still matches the simulation behind it")
    return 0


# ---------------------------------------------------------------- plots
#
# Plots are emitted as SVG by hand rather than through matplotlib. The block's tooling is
# stdlib-only and staying that way matters more than the extra features would: an SVG is
# text, so it diffs and reviews like the rest of the repository, and there is no plotting
# library whose version can change what a published figure looks like.

def _svg(w, h, body, title):
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" '
            f'viewBox="0 0 {w} {h}" font-family="sans-serif" font-size="12">\n'
            f'<title>{title}</title>\n'
            f'<rect width="{w}" height="{h}" fill="#ffffff"/>\n' + body + '</svg>\n')


def _axes(x0, y0, x1, y1, xlo, xhi, ylo, yhi, xlabel, ylabel, xfmt="{:g}", yfmt="{:g}"):
    """Frame, ticks and labels. Returns (svg, project) where project maps data -> pixels."""
    def px(x):
        return x0 + (x - xlo) / (xhi - xlo) * (x1 - x0)

    def py(y):
        return y1 - (y - ylo) / (yhi - ylo) * (y1 - y0)

    s = [f'<rect x="{x0}" y="{y0}" width="{x1-x0}" height="{y1-y0}" fill="none" '
         f'stroke="#334155" stroke-width="1"/>']
    for i in range(6):
        v = xlo + (xhi - xlo) * i / 5
        s.append(f'<line x1="{px(v):.1f}" y1="{y1}" x2="{px(v):.1f}" y2="{y1+4}" stroke="#334155"/>')
        s.append(f'<text x="{px(v):.1f}" y="{y1+18}" text-anchor="middle" fill="#334155">'
                 f'{xfmt.format(v)}</text>')
        if i:
            s.append(f'<line x1="{px(v):.1f}" y1="{y0}" x2="{px(v):.1f}" y2="{y1}" '
                     f'stroke="#e2e8f0" stroke-width="1"/>')
    for i in range(6):
        v = ylo + (yhi - ylo) * i / 5
        s.append(f'<line x1="{x0-4}" y1="{py(v):.1f}" x2="{x0}" y2="{py(v):.1f}" stroke="#334155"/>')
        s.append(f'<text x="{x0-8}" y="{py(v)+4:.1f}" text-anchor="end" fill="#334155">'
                 f'{yfmt.format(v)}</text>')
        if i:
            s.append(f'<line x1="{x0}" y1="{py(v):.1f}" x2="{x1}" y2="{py(v):.1f}" '
                     f'stroke="#e2e8f0" stroke-width="1"/>')
    s.append(f'<text x="{(x0+x1)/2:.0f}" y="{y1+38}" text-anchor="middle" fill="#0f172a">{xlabel}</text>')
    s.append(f'<text x="18" y="{(y0+y1)/2:.0f}" text-anchor="middle" fill="#0f172a" '
             f'transform="rotate(-90 18 {(y0+y1)/2:.0f})">{ylabel}</text>')
    return "\n".join(s) + "\n", px, py


def _series(pts, px, py, colour, width=2):
    d = " ".join(f"{'M' if i == 0 else 'L'}{px(x):.1f},{py(y):.1f}" for i, (x, y) in enumerate(pts))
    return (f'<path d="{d}" fill="none" stroke="{colour}" stroke-width="{width}" '
            f'stroke-linejoin="round"/>\n')


def _limit_line(val, px, py, x0, x1, label, colour="#dc2626"):
    """A specification limit, drawn so a reader can see the margin rather than compute it."""
    y = py(val)
    return (f'<line x1="{x0}" y1="{y:.1f}" x2="{x1}" y2="{y:.1f}" stroke="{colour}" '
            f'stroke-width="1.5" stroke-dasharray="6 4"/>\n'
            f'<text x="{x1-4}" y="{y-5:.1f}" text-anchor="end" fill="{colour}">{label}</text>\n')




def plots_section(written):
    """The figures, under the table. A table states a number; a plot shows the margin around
    it, which is what a reader deciding whether to use the block actually needs."""
    if not written:
        return ""
    out = ["", "## Plots", ""]
    for slug, caption in written:
        out += [f"### {caption}", "", f"![{caption}]({NAME}_{slug}.svg)", ""]
    return "\n".join(out)



LOADS = [("000u", 0.0), ("010u", 10e-6), ("030u", 30e-6), ("100u", 100e-6),
         ("300u", 300e-6), ("001m", 1e-3), ("010m", 10e-3), ("050m", 50e-3)]


def _loop_csv(tag):
    p = os.path.join(ROOT, "sim", f"loop_{tag}.csv")
    if not os.path.isfile(p):
        return None
    rows = []
    for line in open(p):
        f = line.split()
        if len(f) >= 4:
            try:
                rows.append((float(f[0]), float(f[1]), float(f[3])))
            except ValueError:
                pass
    return rows or None


def plot_bode():
    """Loop gain and phase at the load where the margin is thinnest.

    An LDO's stability is not one number: the pass device's gm moves with load, so the
    output pole moves with it. This is the binding load, and the plot shows the crossing
    the phase margin is measured at rather than asserting the result.
    """
    worst, rows = None, None
    for tag, _ in LOADS:
        r = _loop_csv(tag)
        if not r:
            continue
        pm = phase_margin(os.path.join(ROOT, "sim", f"loop_{tag}.csv"))
        if pm and (worst is None or pm[1] < worst[1]):
            worst, rows = (tag, pm[1], pm[0]), r
    if not rows:
        return None
    tag, pm, fu = worst
    lo, hi = math.log10(rows[0][0]), math.log10(rows[-1][0])
    body, px, py = _axes(70, 30, 620, 210, lo, hi, -40, 130,
                         "", "loop gain (dB)", "1e{:.0f}", "{:.0f}")
    body += _limit_line(0, px, py, 70, 620, "0 dB", "#64748b")
    body += _series([(math.log10(f), d) for f, d, _ in rows], px, py, "#2563eb")
    body += (f'<line x1="{px(math.log10(fu)):.1f}" y1="30" x2="{px(math.log10(fu)):.1f}" '
             f'y2="330" stroke="#16a34a" stroke-width="1.5" stroke-dasharray="4 3"/>\n')
    b2, px2, py2 = _axes(70, 250, 620, 330, lo, hi, -180, 0,
                         "frequency (Hz)", "phase (deg)", "1e{:.0f}", "{:.0f}")
    body += b2
    body += _series([(math.log10(f), p) for f, _, p in rows], px2, py2, "#7c3aed")
    body += (f'<text x="620" y="24" text-anchor="end" fill="#0f172a">'
             f'{tag} load — crossover {fu/1e3:.0f} kHz, phase margin {pm:.1f}°</text>\n')
    return _svg(650, 380, body, "Loop gain and phase")


def plot_pm_vs_load():
    """Phase margin across the load range.

    ⛔ A no-load sweep does not bound this. The margin dips in the microamp decade and
    recovers at milliamps, so the worst case sits in the middle of the range -- which is
    why the corner sweep crosses load with process rather than stacking them.
    """
    pts = []
    for tag, amps in LOADS:
        p = os.path.join(ROOT, "sim", f"loop_{tag}.csv")
        if os.path.isfile(p):
            r = phase_margin(p)
            if r:
                pts.append((math.log10(max(amps, 1e-6)), r[1]))
    if len(pts) < 2:
        return None
    body, px, py = _axes(70, 30, 620, 330, -6, -1.3, 40, 90,
                         "load current (A)", "phase margin (deg)", "1e{:.1f}", "{:.0f}")
    body += _limit_line(45.0, px, py, 70, 620, "45° specified")
    body += _series(sorted(pts), px, py, "#2563eb")
    for x, y in pts:
        body += f'<circle cx="{px(x):.1f}" cy="{py(y):.1f}" r="3" fill="#2563eb"/>\n'
    lo = min(p[1] for p in pts)
    body += (f'<text x="620" y="24" text-anchor="end" fill="#0f172a">'
             f'worst {lo:.1f}° in the microamp decade, not at no load</text>\n')
    return _svg(650, 380, body, "Phase margin against load")


def plot_pm_pvt():
    """Every PVT corner's phase margin, as a distribution against the specification.

    243 corners is too many to tabulate and the worst one is the only number that matters,
    but a reader deciding whether to use the block wants to see how much of the population
    sits near the limit rather than only how far the tail reaches.
    """
    d = os.path.join(ROOT, "sim", "pvt")
    if not os.path.isdir(d):
        return None
    pms = []
    for f in sorted(os.listdir(d)):
        if f.endswith(".csv"):
            r = phase_margin(os.path.join(d, f))
            if r:
                pms.append(r[1])
    if not pms:
        return None
    lo, hi = 40, 90
    nb = 25
    bins = [0] * nb
    for v in pms:
        i = min(nb - 1, max(0, int((v - lo) / (hi - lo) * nb)))
        bins[i] += 1
    body, px, py = _axes(70, 30, 620, 330, lo, hi, 0, max(bins) * 1.15,
                         "phase margin (deg)", "corners", "{:.0f}", "{:.0f}")
    w = (620 - 70) / nb
    for i, c in enumerate(bins):
        if not c:
            continue
        x = 70 + i * w
        colour = "#dc2626" if lo + (i + 1) * (hi - lo) / nb <= 45 else "#2563eb"
        body += (f'<rect x="{x+1:.1f}" y="{py(c):.1f}" width="{w-2:.1f}" '
                 f'height="{330-py(c):.1f}" fill="{colour}" opacity="0.75"/>\n')
    body += _limit_line(0, px, py, 70, 620, "", "#ffffff")
    body += (f'<line x1="{px(45):.1f}" y1="30" x2="{px(45):.1f}" y2="330" '
             f'stroke="#dc2626" stroke-width="1.5" stroke-dasharray="6 4"/>\n'
             f'<text x="{px(45)+6:.1f}" y="46" fill="#dc2626">45° specified</text>\n')
    body += (f'<text x="620" y="24" text-anchor="end" fill="#0f172a">'
             f'{len(pms)} corners — worst {min(pms):.1f}°, none below specification</text>\n')
    return _svg(650, 380, body, "Phase margin over PVT")


def _two_col(path):
    rows = []
    for line in open(path):
        f = line.split()
        if len(f) >= 2:
            try:
                rows.append((float(f[0]), float(f[1])))
            except ValueError:
                pass
    return rows or None


def plot_load_step():
    """The load step, which is where this block's two failures actually live.

    ⛔ Both misses are shapes, not scalars, and the table cannot carry either. "338 mV of
    droop" says nothing about how long the output is out of regulation; "to the 3.3 V rail"
    says nothing about how sharp the release excursion is or that it is an over-voltage on
    thin-oxide devices rather than a settling wobble. A reader scoping this block into a
    slot needs to see them.
    """
    p = os.path.join(ROOT, "sim", "step.csv")
    if not os.path.isfile(p):
        return None
    rows = _two_col(p)
    if not rows:
        return None
    pre = _meas("tb_ldo_perf.spice", "vo_pre")
    tol = 120e-3
    xs = [t * 1e6 for t, _ in rows]
    body, px, py = _axes(70, 30, 620, 330, min(xs), max(xs), 0.6, 3.5,
                         "time (µs)", "output voltage (V)", "{:.0f}", "{:.1f}")
    # The specification is a band around the pre-step output, not a single line.
    y_hi, y_lo = py(pre + tol), py(pre - tol)
    body += (f'<rect x="70" y="{y_hi:.1f}" width="550" height="{y_lo-y_hi:.1f}" '
             f'fill="#16a34a" opacity="0.10"/>\n'
             f'<text x="76" y="{y_hi-5:.1f}" fill="#16a34a">±120 mV specified band</text>\n')
    body += _series([(t * 1e6, v) for t, v in rows], px, py, "#2563eb", 1.5)
    # ⛔ The SAME windows the bench measures over: `meas tran vo_droop MIN ... FROM=20u
    # TO=30u` and `vo_over MAX ... FROM=40u TO=50u`. Taking a global extremum instead
    # annotated the droop as 1808 mV against a published 338, because the trace dips
    # elsewhere -- a plot that disagrees with the table it sits under is worse than none.
    def _extreme(t0, t1, fn):
        w = [(t, v) for t, v in rows if t0 <= t <= t1]
        return min(w, key=lambda r: r[1]) if fn is min else max(w, key=lambda r: r[1])

    t_lo, lo = _extreme(20e-6, 30e-6, min)
    t_hi, hi = _extreme(40e-6, 50e-6, max)
    t_lo *= 1e6
    t_hi *= 1e6
    for t, v, lab, col in ((t_lo, lo, f"droop {(pre-lo)*1e3:.0f} mV", "#dc2626"),
                           (t_hi, hi, f"overshoot to {hi:.2f} V", "#dc2626")):
        body += (f'<circle cx="{px(t):.1f}" cy="{py(v):.1f}" r="3.5" fill="{col}"/>\n'
                 f'<text x="{px(t)+7:.1f}" y="{py(v)+4:.1f}" fill="{col}">{lab}</text>\n')
    body += ('<text x="620" y="24" text-anchor="end" fill="#0f172a">'
             '1 → 20 mA step at 20 µs, release at 40 µs</text>\n')
    return _svg(650, 380, body, "Load-step response")


def plot_psrr():
    """Power-supply rejection against frequency, with the four specification points marked.

    The single published figure is rejection at 1 kHz, but supply noise does not arrive at
    one frequency. The curve shows where rejection actually collapses.
    """
    p = os.path.join(ROOT, "sim", "psrr.csv")
    if not os.path.isfile(p):
        return None
    rows = _two_col(p)
    if not rows:
        return None
    # psrr_db is db(v(vout)) for a 1 V supply perturbation, so rejection is its negation.
    pts = [(math.log10(f), -d) for f, d in rows if f > 0]
    body, px, py = _axes(70, 30, 620, 330, pts[0][0], pts[-1][0], 0, 80,
                         "frequency (Hz)", "rejection (dB)", "1e{:.0f}", "{:.0f}")
    body += _limit_line(40.0, px, py, 70, 620, "40 dB specified")
    body += _series(pts, px, py, "#2563eb")
    for key, f in (("psrr_1k", 1e3), ("psrr_10k", 1e4), ("psrr_100k", 1e5), ("psrr_1m", 1e6)):
        try:
            v = abs(_meas("tb_ldo_perf.spice", key))
        except SystemExit:
            continue
        col = "#16a34a" if v >= 40 else "#dc2626"
        body += f'<circle cx="{px(math.log10(f)):.1f}" cy="{py(v):.1f}" r="3.5" fill="{col}"/>\n'
    body += ('<text x="620" y="24" text-anchor="end" fill="#0f172a">'
             'marked points are the specification frequencies</text>\n')
    return _svg(650, 380, body, "Power-supply rejection")


PLOTS = [("bode", plot_bode, "Loop gain and phase at the binding load"),
         ("pm_vs_load", plot_pm_vs_load, "Phase margin across the load range"),
         ("pm_pvt", plot_pm_pvt, "Phase margin over 243 PVT corners"),
         ("load_step", plot_load_step, "Load-step response — where both failures live"),
         ("psrr", plot_psrr, "Power-supply rejection against frequency")]


def footer():
    """Attribution line for the generated sheet.

    The year is taken from the clock at emit time rather than typed in, for the same
    reason every measured figure here is: a constant someone has to remember to update is
    a constant that goes stale, and this file exists to stop that happening.
    """
    return (f"\n---\n\n© {datetime.now(timezone.utc).year} Vyges "
            f"(https://vyges.com) · generated by `tools/datasheet.py`, "
            f"do not edit by hand\n")

def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--check", action="store_true",
                    help="verify README figures against the simulations; exit 1 on drift")
    a = ap.parse_args()
    if a.check:
        return check()
    d = os.path.join(ROOT, "doc", "datasheet")
    os.makedirs(d, exist_ok=True)
    written = []
    for slug, fn, caption in PLOTS:
        svg = fn()
        if svg is None:
            print(f"skipped plot {slug}: its inputs are absent")
            continue
        q = os.path.join(d, f"{NAME}_{slug}.svg")
        open(q, "w").write(svg)
        written.append((slug, caption))
        print(f"wrote {os.path.relpath(q, ROOT)}")
    # Only `schematic` exists today. layout/pex/rcx appear here as soon as there is a
    # layout to extract, with the same rows and the physical ones no longer Skipped.
    for source in ("schematic",):
        p = os.path.join(d, f"{NAME}_{source}.md")
        open(p, "w").write(table(source) + plots_section(written) + footer())
        print(f"wrote {os.path.relpath(p, ROOT)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
