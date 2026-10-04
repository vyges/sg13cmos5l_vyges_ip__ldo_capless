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

  1. Cm is 193.0 x 193.5 um and the slot is only 273 um tall -- 71 % of the height. Cout is
     125.0 x 125.5. They cannot stack: 193.5 + 125.5 = 319 > 273. They go side by side, and
     that alone fixes 318 um of the 537 um width. Below Cm there is room for exactly one
     55 um band, which is where the amplifier and the reference go.
  2. The pass device is 64 instances of 2.42 x 101.24 um. Laid side by side that is a
     154.9 x 101.2 um array -- a natural shape, and short enough to sit under something.
     ✅ ABUTMENT IS NOW DRC-VERIFIED, 2026-09-17, by tools/passdrc.sh. It was an assumption
     until then, and the pitch turns out to be a CLIFF rather than a spacing: gap 0 abuts
     cleanly because the nwells merge, any gap from 0.02 to 0.5 um reports NW.b (nwell min
     space 0.62 um), and 0.62 um is clean again. There is no legal pitch between touching
     and 0.62 um apart, so the array is either abutted or 0.62 um looser per device --
     40 um of extra width across 64 of them.
     ⚠️ ng=1 IS A LAYOUT CHOICE AND IT IS THE WORST ONE MEASURED. Folding the same
     100 um/0.5 um device into 16 fingers gives 15.62 x 7.49 um, and 64 of those abut into
     124.96 x 59.92 um -- also DRC clean, and 7488 um2 against 15544. See the note below.
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

# ⛔ THE REAL SLOT, read from the harness's own wrapper layout (magic/slot11_wrapper.mag,
# magscale 1 2, harness @ 1906830; chipalooza/tools/slot_fit.py re-derives it). This said
# 530 x 310 until 2026-10-04 -- a verbal figure that the drawn wrapper never had -- and three
# blocks sat above the real top edge while this script reported that everything fit.
SLOT_W, SLOT_H = 537.15, 273.0
# Wrapper pins occupy a 2 um strip on both vertical edges; 4 um more keeps device geometry
# off them. Applied on all four sides so a block cannot be placed flush against anything.
EDGE = 6.0
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Sum of every device's PyCell bounding box, from tools/area_budget.py. A percentage of it was
# hard-coded here once, and it went stale the moment the slot changed size.
DEVICE_AREA = 80085.0

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
RLS_W, RLS_H = snake(701.2, 90.0)      # ldo_enable XRls -- 90 tall, not 120: see C2 below

# name, x, y, w, h, group
#
# Three columns, ordered by the signal rather than by packing efficiency:
#   C1  x 6..199    the quiet end -- reference, error amplifier, and Cm above them
#   C2  x 205..360  the feedback ladder, the boost and the status blocks
#   C3  x 364..531  the output node: pass array, Cc and Cout
#
# ⛔ Cm is placed ABOVE the amplifier rather than beside it because it is 193.5 um tall and
# the slot is 273: there is no arrangement where Cm and Cout share a column. That single fact
# fixes the shape of everything else.
#
# 2026-10-04, refitted to the real 273 um height WITHOUT CHANGING A DEVICE. Every move is a
# region reshaped or a block relocated; no W, L, value or finger count differs, so no
# simulated number is touched. The three blocks that overran, and what was done:
#   Cm         top 305.5 -> 260.5  dropped to y 67; the band below it shrinks 100 -> 55 um
#   enable+Rls top 285.0 -> 260.0  XRls folded 90 um tall instead of 120 (8 columns, not 6)
#   Cc         top 290.5 -> 155.5  moved down beside the pass array -- see C3
BLOCKS = [
    # --- C1 x 6..199: reference and amplifier, at the CORE-facing edge.
    # The band under Cm is 55 um, not 100. Neither region was ever full: the error amp's
    # devices outside Cm measure 259 um2 (now in 5225), and the vref divider is four rhigh
    # totalling 424 um -- a 50 um tall fold is 11 um wide -- plus a 10 x 10 um Cf.
    # Both stay at the bottom, nearest the core-edge bias pins (vbias/ibias0 at y 94-99).
    ("Cm  193x193.5",     6,   67,  193,   193.5, "amp"),
    ("erramp devices",    6,   6,   95,    55,    "amp"),
    ("vref divider",      106, 6,   40,    55,    "ref"),

    # --- C2 x 205..360: feedback ladder, boost, status blocks.
    ("fbtrim ladder",     205, 6,   60,    192,   "fb"),
    ("Rb snake",          272, 6,   RB_W,  RB_H,  "boost"),
    ("Rnx snake",         300, 6,   RNX_W, RNX_H, "boost"),
    ("Cb 28x28.5",        313, 6,   28,    28.5,  "boost"),
    ("boost devices",     313, 40,  40,    116,   "boost"),
    ("ilim",              205, 205, 45,    42,    "stat"),
    ("pgood",             255, 205, 45,    42,    "stat"),
    # XRls is a level-shift resistor with no matching partner, so its fold height is free.
    ("enable + Rls",      305, 165, 40,    95,    "stat"),

    # --- C3 x 366..525: the output, hard against the PADFRAME-facing edge.
    # ⛔ Tim confirmed 2026-09-16 that every wrapper has padframe-facing pins on the RIGHT and
    # core-facing pins on the left. vout therefore exits right, and the pass array - 153.6 um
    # of device carrying up to 50 mA - is placed against that edge rather than in the middle.
    # On-slot metal resistance at 50 mA lands in the same budget as the 20 mV load-regulation
    # specification, so every micron of that path is spent, not free.
    # ⛔ Cc is the Miller capacitor from eout (the pass gate) to vout. It sat at y 250, 140 um
    # above the pass array it compensates, which lengthened both of its nets. It now sits
    # directly on top of the array, beside Cout: eout comes up from the gates beneath it and
    # vout is the node it shares with Cout. Cout moved 11 um right to make the column.
    ("pass array 64x",    370, 6,   154.9, 101.2, "pass"),
    ("Cc 40x40.5",        364, 115, 40,    40.5,  "amp"),
    ("Cout 125x125.5",    406, 115, 125,   125.5, "out"),
]

COLOUR = {"ref": "#8ecae6", "amp": "#219ebc", "pass": "#fb8500", "fb": "#ffb703",
          "out": "#2a9d8f", "stat": "#adb5bd", "boost": "#e76f51"}


def check():
    bad = []
    for n, x, y, w, h, _ in BLOCKS:
        if x < EDGE or y < EDGE or x + w > SLOT_W - EDGE or y + h > SLOT_H - EDGE:
            bad.append(f"{n!r} is outside the slot less its {EDGE:g} um edge: "
                       f"({x:.1f},{y:.1f}) {w:.1f}x{h:.1f}")
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
    # itself. tools/area_budget.py measures DEVICE_AREA of actual devices; the blocks above
    # reserve noticeably more. The difference is slack INSIDE the regions, and it is
    # not spread evenly: Cm, Cout and the pass array are the devices themselves and are at
    # 100 % density by construction, so every bit of that slack sits in the small cells, where
    # the local routing and the well taps actually go. The erramp's devices outside Cm measure
    # 259 um2 in a 9500 um2 region; the trim ladder is 836 um2 in 11520.
    dev = 100 * DEVICE_AREA / (SLOT_W * SLOT_H)
    print(f"  devices measured elsewhere: {DEVICE_AREA:.0f} um2 ({dev:.1f} %). The {100*used/(SLOT_W*SLOT_H)-dev:.1f} "
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
