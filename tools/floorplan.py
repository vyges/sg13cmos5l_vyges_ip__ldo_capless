#!/usr/bin/env python3
"""Floorplan for the capless LDO slot -- placement as data, checked, then drawn.

    python3 tools/floorplan.py            # check and report
    python3 tools/floorplan.py --svg      # also write doc/datasheet/ldo_capless_floorplan.svg

⛔ WHY THIS IS DATA AND NOT A DRAWING. A floorplan sketched in a diagram tool is a picture of
an intention; nothing checks that the blocks fit, that they do not overlap, or that the
numbers in it are the ones the devices actually measure. Every footprint below comes from
tools/area_budget.py, which instantiates each device with the PDK's own PyCell and measures
its bounding box. The checks at the bottom fail the run if a block leaves the slot or lands
on another.

THE THREE CONSTRAINTS THAT DECIDE THIS FLOORPLAN, all from measured geometry:

  1. Cm is 193.0 x 193.5 um and the slot is only 310 um tall -- 62 % of the height. Cout is
     125.0 x 125.5. They cannot stack: 193.5 + 125.5 = 319 > 310. They go side by side, and
     that alone fixes 318 um of the 530 um width.
  2. The pass device is 64 instances of 2.4 x 101.2 um. Laid side by side that is a
     153.6 x 101.2 um array -- a natural shape, and short enough to sit under something.
  3. XRb is 1.4 x 2941 um. It cannot be placed, only snaked, and snaking is pitch-limited
     rather than area-limited: at a 2.5 um pitch a 150 um tall snake needs 20 columns and
     50 um of width, so its real footprint is about 7500 um2 against 4118 um2 of drawn
     resistor. ⚠️ Long resistors cost roughly DOUBLE their drawn area once folded, and that
     is true of XRnx and XRls too.

ELECTRICAL ORDERING, which is why the columns are in this order and not a tighter packing:

  vref/erramp (quiet, high impedance)  ->  pass array  ->  vout, Cout, feedback
  left                                                                     right

  The pass device sits between the amplifier that drives its gate and the output it feeds,
  so eout is short on one side and the 50 mA output is short on the other. The reference
  divider and the trim ladder are the two highest-impedance nets in the block and sit at the
  far left, away from the pass device's switching edge and from the 3.3 V input rail.

⚠️ WHAT THIS IS NOT. It is a first-cut placement, not a routed floorplan. It reserves no
channels, no guard rings, no well taps and no seal-ring keep-out, and it assumes each block
is a rectangle. The utilisation number it prints is therefore a floor: a real placement will
be looser. Treat a number near 100 % as failure, not as success.
"""
import os, sys

SLOT_W, SLOT_H = 530.0, 310.0
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Footprints. Measured ones come from tools/area_budget.py; snaked ones are computed below
# from the drawn length at a stated pitch, because a 2941 um resistor has no bounding box
# worth placing.
# ✅ CONFIRMED AGAINST THE DRC DECK, 2026-09-16. This was assumed at 2.5 um and it is 1.18.
# Four rhigh PyCells were placed side by side at descending pitches and the full FEOL deck run
# on each:
#
#   GatPoly gap   0.05   0.10   0.15   0.18   0.20   um
#   violations       6      6      6      0      0
#
# The threshold sits exactly on Gat_b = 0.18 um, the minimum GatPoly space, so the floor is
# 1.0 um of resistor body + 0.18 = 1.18 um. The test resistors carried their end contacts, so
# that is included. ⛔ The check was falsified before it was believed: three tighter pitches
# report six violations each, which is what makes the two zeros mean something.
#
# ⚠️ The pitch adopted here is 1.2 um, a hair above the floor and on grid. What is NOT
# verified is the metal strapping between folds: the DRC run above had BEOL rules disabled
# and the test layout has no straps. Straps land at ALTERNATING ends so adjacent ones are far
# apart, which is why this is a note rather than a risk -- but it is unverified.
RES_PITCH = 1.2


def snake(length_um, height_um, pitch=RES_PITCH):
    """(w, h) of a folded resistor of the given drawn length."""
    cols = int(length_um / height_um) + 1
    return cols * pitch, height_um


RB_W, RB_H = snake(2941.2, 150.0)      # ldo_boost XRb
RNX_W, RNX_H = snake(736.2, 120.0)     # ldo_boost XRnx
RLS_W, RLS_H = snake(701.2, 120.0)     # ldo_enable XRls

# name, x, y, w, h, group
#
# Three columns, ordered by the signal rather than by packing efficiency:
#   C1  x 6..199    the quiet end -- reference, error amplifier, and Cm above them
#   C2  x 205..360  the pass device, the feedback ladder and the status blocks
#   C3  x 366..525  the output node, Cout, and the boost
#
# ⛔ Cm is placed ABOVE the amplifier rather than beside it because it is 193.5 um tall and
# the slot is 310: there is no arrangement where Cm and Cout share a column. That single fact
# fixes the shape of everything else.
BLOCKS = [
    # --- C1: reference and amplifier. Highest-impedance nets in the block, furthest from
    # the pass device's switching edge and from the 3.3 V input rail.
    ("Cm  193x193.5",     6,   112, 193,   193.5, "amp"),
    ("erramp devices",    6,   6,   95,    100,   "amp"),
    ("vref divider",      106, 6,   40,    100,   "ref"),

    # --- C2: the pass device sits between the gate that drives it and the output it feeds.
    ("pass array 64x",    205, 6,   153.6, 101.2, "pass"),
    ("fbtrim ladder",     205, 113, 60,    192,   "fb"),
    ("Cc 40x40.5",        270, 113, 40,    40.5,  "amp"),
    ("ilim",              270, 158, 45,    42,    "stat"),
    ("pgood",             270, 205, 45,    42,    "stat"),
    ("enable + Rls",      320, 113, 40,    RLS_H, "stat"),

    # --- C3: output node. Cout sits directly across from the pass array so the 50 mA path
    # is short and wide; the boost's long resistors fold into the space beneath it.
    ("Cout 125x125.5",    366, 178, 125,   125.5, "out"),
    ("Rb snake",          366, 6,   RB_W,  RB_H,  "boost"),
    ("Rnx snake",         396, 6,   RNX_W, RNX_H, "boost"),
    ("Cb 28x28.5",        412, 6,   28,    28.5,  "boost"),
    ("boost devices",     412, 40,  40,    116,   "boost"),
]

COLOUR = {"ref": "#8ecae6", "amp": "#219ebc", "pass": "#fb8500", "fb": "#ffb703",
          "out": "#2a9d8f", "stat": "#adb5bd", "boost": "#e76f51"}


def check():
    bad = []
    for n, x, y, w, h, _ in BLOCKS:
        if x < 0 or y < 0 or x + w > SLOT_W or y + h > SLOT_H:
            bad.append(f"{n!r} leaves the slot: ({x:.1f},{y:.1f}) {w:.1f}x{h:.1f}")
    for i, a in enumerate(BLOCKS):
        for b in BLOCKS[i + 1:]:
            if (a[1] < b[1] + b[3] and b[1] < a[1] + a[3] and
                    a[2] < b[2] + b[4] and b[2] < a[2] + a[4]):
                bad.append(f"{a[0]!r} overlaps {b[0]!r}")
    return bad


def report():
    used = sum(w * h for _, _, _, w, h, _ in BLOCKS)
    print(f"slot {SLOT_W:.0f} x {SLOT_H:.0f} um = {SLOT_W*SLOT_H:.0f} um2")
    print(f"{'block':<22} {'x':>7} {'y':>7} {'w':>8} {'h':>8} {'area':>10}")
    for n, x, y, w, h, _ in sorted(BLOCKS, key=lambda b: -b[3] * b[4]):
        print(f"{n:<22} {x:>7.1f} {y:>7.1f} {w:>8.1f} {h:>8.1f} {w*h:>10.1f}")
    print("-" * 66)
    print(f"placed area {used:.0f} um2 = {100*used/(SLOT_W*SLOT_H):.1f} % of the slot")
    print(f"free        {SLOT_W*SLOT_H-used:.0f} um2 = "
          f"{100*(1-used/(SLOT_W*SLOT_H)):.1f} % for routing, guard rings, taps and spacing")
    print(f"  (long resistors folded at a {RES_PITCH} um pitch: "
          f"Rb {RB_W:.0f}x{RB_H:.0f}, Rnx {RNX_W:.0f}x{RNX_H:.0f}, Rls {RLS_W:.0f}x{RLS_H:.0f})")
    # ⛔ RESERVED AREA IS NOT DEVICE AREA, and conflating them is how a floorplan flatters
    # itself. tools/area_budget.py measures 80085 um2 of actual devices -- 48.7 % of the slot.
    # The blocks above reserve 72.3 %. The difference is slack INSIDE the regions, and it is
    # not spread evenly: Cm, Cout and the pass array are the devices themselves and are at
    # 100 % density by construction, so every bit of that slack sits in the small cells, where
    # the local routing and the well taps actually go. The erramp's devices outside Cm measure
    # 259 um2 in a 9500 um2 region; the trim ladder is 836 um2 in 11520.
    print(f"  devices measured elsewhere: 80085 um2 (48.7 %). The {100*used/(SLOT_W*SLOT_H)-48.7:.1f} "
          f"point difference is in-region slack for local routing and taps, concentrated in the "
          f"small cells -- Cm, Cout and the pass array have none by construction.")
    bad = check()
    if bad:
        print(f"\n{len(bad)} placement problem(s):")
        for b in bad:
            print(f"  {b}")
        return 1
    print("\nevery block is inside the slot and none overlap")
    return 0


def svg():
    S = 1.6
    out = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{SLOT_W*S+80:.0f}" '
           f'height="{SLOT_H*S+90:.0f}">',
           '<rect width="100%" height="100%" fill="#ffffff"/>',
           f'<text x="40" y="26" font-family="sans-serif" font-size="15" font-weight="bold">'
           f'ldo_capless floorplan -- {SLOT_W:.0f} x {SLOT_H:.0f} um slot</text>',
           f'<rect x="40" y="40" width="{SLOT_W*S:.0f}" height="{SLOT_H*S:.0f}" '
           f'fill="#f8f9fa" stroke="#212529" stroke-width="2"/>']
    for n, x, y, w, h, g in BLOCKS:
        px, py = 40 + x * S, 40 + (SLOT_H - y - h) * S
        out.append(f'<rect x="{px:.1f}" y="{py:.1f}" width="{w*S:.1f}" height="{h*S:.1f}" '
                   f'fill="{COLOUR[g]}" fill-opacity="0.75" stroke="#212529" stroke-width="1"/>')
        if w * S > 46 and h * S > 16:
            out.append(f'<text x="{px+3:.1f}" y="{py+13:.1f}" font-family="sans-serif" '
                       f'font-size="10">{n}</text>')
    out.append(f'<text x="40" y="{SLOT_H*S+62:.0f}" font-family="sans-serif" font-size="11">'
               f'first-cut placement from measured device geometry -- no routing channels, '
               f'guard rings or taps reserved</text>')
    out.append("</svg>\n")
    p = os.path.join(ROOT, "doc", "datasheet", "ldo_capless_floorplan.svg")
    open(p, "w").write("\n".join(out))
    print(f"wrote {os.path.relpath(p, ROOT)}")


if __name__ == "__main__":
    rc = report()
    if "--svg" in sys.argv and rc == 0:
        svg()
    sys.exit(rc)
