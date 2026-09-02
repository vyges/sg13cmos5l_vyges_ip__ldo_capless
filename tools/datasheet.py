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


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--check", action="store_true",
                    help="verify README figures against the simulations; exit 1 on drift")
    a = ap.parse_args()
    if a.check:
        return check()
    d = os.path.join(ROOT, "doc", "datasheet")
    os.makedirs(d, exist_ok=True)
    # Only `schematic` exists today. layout/pex/rcx appear here as soon as there is a
    # layout to extract, with the same rows and the physical ones no longer Skipped.
    for source in ("schematic",):
        p = os.path.join(d, f"{NAME}_{source}.md")
        open(p, "w").write(table(source))
        print(f"wrote {os.path.relpath(p, ROOT)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
