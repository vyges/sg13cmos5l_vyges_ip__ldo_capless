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

⚠️ WHAT THIS IS NOT. It is a placement, not a routed floorplan. Each region's inset leaves
room for its guard ring (PACK "rings", 2026-10-26), but no routing channels are reserved and
each block is a rectangle. The utilisation number it prints is therefore a floor: a real placement will
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


RES_END_W = 1.40     # a w = 1 um rhigh segment WITH its end contacts, as the PyCell draws it


def snake(length_um, height_um, pitch=RES_PITCH):
    """(w, h) of a folded resistor of the given drawn length.

    ⛔ (cols - 1) pitches plus one contacted segment, not cols x pitch: the PDK's own rhigh
    serpentine (b bends) draws its segments at 1.18 um pitch with 1.40 um contacted ends.
    cols x pitch under-reserved XRnx by 0.08 um, found when chipalooza's tools/slot_gds.py
    placed the real PyCell (2026-10-04)."""
    cols = int(length_um / height_um) + 1
    return (cols - 1) * pitch + RES_END_W, height_um


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
    # Each MOM cap region is 1 um wider and taller than the cap: the routable terminals are
    # Metal4 stubs reaching 1 um out of its left and top edges (the PDK pins are 0.2 um).
    # 72.5, not 67 (2026-10-26): up against the top edge, to open the band beneath it for the
    # digital row; the slot's top less EDGE is exactly 267.
    ("Cm  193x193.5",     6,   72.5, 194,   194.5, "amp"),
    # The DIGITAL ROW (layout review item 5 and 11, 2026-10-22; the SAR ADC and Ridha pattern):
    # every standard cell of the block -- the en and ilim_en input inverters and the pgood and oc
    # output drivers -- in ONE ringed row beside the left-edge digital pins (y 72-88) and the
    # vdd_1v2 pin (y 2-57). Before, they sat in three places 200-330 um from those pins, so the
    # outputs were small gates driving long wires over the resistor snakes, and vdd_1v2 crossed
    # the slot at minimum width (">100 ohm", Tim). Now the pin-side wires are a few um long; the
    # long runs are the static analog-side controls, which no pad loads.
    ("digital row",       10,  62.5, 24,    8.2,   "dig"),     # cells 4.39 tall (bbox), + ring
    ("erramp devices",    6,   6,   95,    55,    "amp"),
    ("vref divider",      106, 6,   40,    55,    "ref"),

    # --- C2 x 205..360: feedback ladder, boost, status blocks.
    # 70 tall, not 192 (2026-10-26): its devices use 61 um; the rest was empty
    ("fbtrim ladder",     205, 6,   60,    70,    "fb"),
    ("Rb snake",          272, 6,   RB_W,  RB_H,  "boost"),
    ("Rnx snake",         300, 6,   RNX_W, RNX_H, "boost"),
    ("Cb 28x28.5",        313, 6,   29,    29.5,  "boost"),
    ("boost devices",     313, 40,  40,    116,   "boost"),
    # 60 um tall, not 42: each holds a single-finger wide device standing on end -- ilim's
    # Mref (w 50 um) is 51.0 um tall and pgood's Mt (w 40 um) 40.4. The region was sized by
    # area and never by its tallest device; the placed GDS is what caught it.
    ("ilim",              205, 200, 45,    67,    "stat"),     # +5 for its ring (2026-10-26)
    # pgood sits directly ABOVE the fbtrim ladder, not up beside ilim (2026-10-26): its comparator
    # takes vfb, the loop's high-impedance node, and the branch up to y 205 was ~230 of vfb's
    # ~490 um. vfb's C to vss follows its length (~0.04 fF/um on any of Metal1-3: holding it off
    # Metal1 moved nothing), and each fF costs ~0.065 deg at the worst corner.
    ("pgood",             205, 82,  45,    60,    "stat"),
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
    # 101.3, not 101.2: the device is 101.24 um tall; 101.2 was a rounding.
    # 157.5 x 101.5: 64 abutted fingers plus ONE shared well tap at the left end, and each
    # finger's gate contact on top (the PyCell has none).
    ("pass array 64x",    370, 6,   157.5, 101.5, "pass"),
    # Cc and Cout keep 1 um between Cc's plates and Cout's left terminal stub.
    # 2026-10-19: Cc 2.06 -> 3.56 pF for the post-layout phase-margin retune (w 69.15 x l 40;
    # the PyCell draws w along y, so it grows up this column, which is empty above it).
    ("Cc 40x69.65",       363, 115, 41,    70.65, "amp"),
    ("Cout 125x125.5",    405, 115, 126,   126.5, "out"),
]

# Which region each netlist instance is placed in, for chipalooza's placement-only slot GDS
# (tools/slot_gds.py there). Instance-path regex, first match wins; every device must match.
PLACE = [
    (r"/x_en/Xinv$",      "digital row"),
    (r"/x_pg/Xout$",      "digital row"),
    (r"/x_il/Xinv_(ie|oc)$", "digital row"),
    (r"/x_amp/XCm$",      "Cm  193x193.5"),
    (r"/x_amp/",          "erramp devices"),
    (r"/x_vref/",         "vref divider"),
    (r"/x_fb/",           "fbtrim ladder"),
    (r"/x_boost/XRb$",    "Rb snake"),
    (r"/x_boost/XRnx$",   "Rnx snake"),
    (r"/x_boost/XCb$",    "Cb 28x28.5"),
    (r"/x_boost/",        "boost devices"),
    (r"/XMpre$",          "boost devices"),   # the 10 uA vout preload sink, beside the output
    (r"/x_il/",           "ilim"),
    (r"/x_pg/",           "pgood"),
    (r"/x_en/",           "enable + Rls"),
    (r"/x_pass/",         "pass array 64x"),
    (r"/XCc$",            "Cc 40x69.65"),
    (r"/XCout$",          "Cout 125x125.5"),
]
# Per-region packing. Regions drawn to a device's exact size take no inset; the pass array
# abuts (gap 0 is DRC-verified, tools/passdrc.sh); folds are the snake heights used above.
PACK = {
    "Cm  193x193.5":   dict(inset=0, gap=0),
    "Cout 125x125.5":  dict(inset=0, gap=0),
    "Cc 40x69.65":      dict(inset=0, gap=0),
    "Cb 28x28.5":      dict(inset=0, gap=0),
    "pass array 64x":  dict(inset=0, gap=0, array=True),
    "Rb snake":        dict(inset=0, gap=0, fold=150.0),
    "Rnx snake":       dict(inset=0, gap=0, fold=120.0),
    "enable + Rls":    dict(fold=90.0),
    "vref divider":    dict(fold=50.0),
    "fbtrim ladder":   dict(fold=50.0),
    "ilim":            dict(fold=30.0),
    "erramp devices":  dict(fold=30.0),
    # standard cells abut; the p+ ring needs 0.7 um plus 1 um clear
    "digital row":     dict(inset=1.8, gap=0.0, rings=("p",)),
}
# A p+ guard ring around every region of small devices (chipalooza tools/slot_gds.py, Ridha's
# construction; layout review item 2): the reference, the amplifier, the ladder's switches, the
# boost and the three status blocks. Their inset grows 1.0 -> 2.0 um for it. The MOM caps, the
# snakes and the pass array (one shared well, abutted fingers, inset 0) are not ringed here.
for _r in ("erramp devices", "vref divider", "fbtrim ladder", "boost devices", "ilim", "pgood",
           "enable + Rls"):
    PACK.setdefault(_r, {}).update(inset=2.0, rings=("p",))

# ---- The 50 mA path: vin and vout straps, drawn by chipalooza tools/slot_gds.py (STRAPS).
# The router draws every net at minimum width. These are sized against the process spec's
# current limits (SG13CMOS5L Process Specification Rev 0.2 §3.5, 0.01 % failures in 11 years at
# 105 C) and its sheet resistances (§3, RSMET2-4 103, RSTM1 21 mOhm/sq max). strap_check()
# below recomputes every number quoted here.
#
#   vin   enters on the LEFT edge (vdd_3v3, TopMetal1, y 150-256) and the pass array is at the
#         far right. TopMetal1 runs along the top of the slot (y 242-270) and down at the right
#         (x 497-525) onto two vin bands over the array, each Metal3 + Metal4 + TopMetal1.
#         ⚠️ 28 um, not narrower: an 8 um run was 89 squares = 93 mV at 50 mA, which is most of
#         the 100 mV dropout margin (149.7 measured, 250 max). 28 um is the widest metal allowed
#         without slits (Slt.c, 30 um). ⚠️ The run crosses the top 19.5 um of Cm (eout/nzc):
#         about 46 fF from vin against Cm's 48 pF. Accepted for the IR drop, NOT simulated.
#   vout  leaves on the RIGHT edge (s11_an[0], Metal3, y 80.18-104.95), level with the array's
#         top. One Metal3 + Metal4 band at exactly the pin's height carries it right.
#   per finger: Metal2 over each source and drain strip, along its length, Via1 every 1 um.
#         The PyCell's own strips are Metal1 0.16 um wide; the spec's IMAXM1 is 0.36 mA for a
#         line that narrow, and a finger carries 50/64 = 0.78 mA.
STRAPS = dict(
    fingers=r"/x_pass/XMpass", terms={"S": "vin", "D": "vout"}, n_fingers=64, load_ma=50.0,
    m1_w=0.29,          # Via1 (0.19) + 0.05 each side; < 0.30, so M1 spacing stays 0.18
    m2_w=0.50,          # 1.0 mA at JMAXM2 2 mA/um; > 0.39, so M2 spacing 0.24 (S-D gap 0.38)
    m2_top=111.9,       # stop 0.92 um below the gate pads (finger top + 0.2), router access
    via_pitch=1.0, plate_pitch=2.0,
    bands=[
        ("vout", ("Metal3", "Metal4"),              370.0, 80.18, 527.5, 104.95),
        ("vin",  ("Metal3", "Metal4", "TopMetal1"), 370.0, 8.0,   527.5, 36.0),
        ("vin",  ("Metal3", "Metal4", "TopMetal1"), 370.0, 44.0,  527.5, 72.0),
    ],
    feed=[
        ("vout", "Metal3",    527.0, 80.18, 536.15, 104.95),   # band -> s11_an[0]
        ("vin",  "TopMetal1", 0.0,   242.0, 525.0,  270.0),    # vdd_3v3 -> along the top
        ("vin",  "TopMetal1", 497.0, 8.0,   525.0,  270.0),    # down onto the vin bands
    ],
)

# ---- vss / vin supply grid over the small cells (layout review 2026-10-22: the ground was "a
# single thin wire on a long, wandering path"; the PLL got the same grid on 2026-10-26).
#   vss  a 28 um TopMetal1 bar from the vss_3v3 pin (y 113.5-143.5) straight across Cm --
#        TopMetal1 only, as the vin run already crosses it -- to a vss spine at x 202-216, the
#        gap between Cm and the middle column.
#   vin  a spine at x 346-360 hanging from the vin run along the top (y 242-270).
#   fingers 4 um on a 6 um pitch, vss and vin alternating, Metal4 + TopMetal1, over the middle
#        column (x 202-360, y 8-240): vss from the left spine, vin from the right. The vss rows
#        below Cm also run LEFT along the bottom band (error amp, vref), x 8-202.
# ⛔ No Metal4 over a MOM capacitor (Cm, Cb, Cc, Cout fill Metal1-4) nor over the vref divider
#    (Cf is a MOM cap placed by the packer, and the divider is the highest-impedance network):
#    a row's TopMetal1 runs on over them, its Metal4 is split around them.
GRID_Y0, GRID_W, GRID_PITCH, GRID_N = 8.0, 4.0, 6.0, 39
# The Metal4 under each band is a 1.64 um finger on its centre line, not the band's full 4 um
# (2026-10-26): Metal4 here only lands the drops and the TopVia1 row (0.42 cut, 0.42 margin), and
# every block under the grid draws uA. At full width it covered 2/3 of the area over the analog
# routing, and the router takes Metal3 over the guard rings: the feedback node vfb (the divider's
# high-impedance tap) went 27 -> 64 fF, mostly to Metal4 overhead, which cost 3-5 deg of phase
# margin at the high-UGF corners (ff/res_wcs/-40 C, 48.4 -> 45.3 deg).
GRID_M4_W = 1.64
VSS_SPINE, VIN_SPINE = (202.0, 216.0), (346.0, 360.0)
VFB_CLEAR_Y = 25.0           # vss rows at or below this y stop at the spine (see GRID_BANDS)
M4_KEEPOUT = [b for b in BLOCKS if b[0].startswith(("Cm ", "Cb ", "Cc ", "Cout ", "vref divider"))]


def _m4_spans(x1, x2, y1, y2):
    """x1..x2 at rows y1..y2, less every Metal4 keep-out (1 um clear of each)"""
    cuts = sorted((b[1] - 1.0, b[1] + b[3] + 1.0) for b in M4_KEEPOUT
                  if b[2] - 1.0 < y2 and y1 < b[2] + b[4] + 1.0 and b[1] - 1.0 < x2 and x1 < b[1] + b[3] + 1.0)
    spans, x = [], x1
    for a, b in cuts:
        if a > x + 4.0:
            spans.append((x, min(a, x2)))
        x = max(x, b)
    if x2 > x + 4.0:
        spans.append((x, x2))
    return spans


GRID_BANDS = []
for _k in range(GRID_N):
    _y = GRID_Y0 + _k * GRID_PITCH
    _net = "vss" if _k % 2 == 0 else "vin"
    if _net == "vss":
        # into the bottom band too, where the row clears Cm (y 67) -- but not the two lowest rows
        # (y 8, y 20): the feedback node vfb leaves the amplifier along the bottom of the band on
        # Metal3 (y 12 and 19.6, x 71-213), and those rows doubled its capacitance to vss
        # (14.5 -> 30.9 fF). Deleting exactly that coupling in the extracted netlist is worth
        # 2.0 deg at the worst corner (ff/res_wcs/-40 C, 46.6 -> 48.6). Rows y 32-56 still ground
        # the band.
        _x1 = 8.0 if VFB_CLEAR_Y < _y and _y + GRID_W < 66.0 else VSS_SPINE[0]
        _x2 = VIN_SPINE[0] - 2.0
    else:
        _x1, _x2 = VSS_SPINE[1] + 2.0, VIN_SPINE[0]
    GRID_BANDS.append((_net, ("TopMetal1",), _x1, _y, _x2, _y + GRID_W))
    _m1, _m2 = _y + (GRID_W - GRID_M4_W) / 2, _y + (GRID_W + GRID_M4_W) / 2
    GRID_BANDS += [(_net, ("Metal4", "TopMetal1"), a, _m1, b, _m2)
                   for a, b in _m4_spans(_x1, _x2, _m1, _m2)]
STRAPS["bands"] += GRID_BANDS
STRAPS["feed"] += [
    ("vss", "TopMetal1", 0.0,           114.5, VSS_SPINE[1], 142.5),   # vss_3v3 pin -> spine
    ("vss", "TopMetal1", VSS_SPINE[0], GRID_Y0, VSS_SPINE[1], 240.0),
    ("vin", "TopMetal1", VIN_SPINE[0], GRID_Y0, VIN_SPINE[1], 244.0),  # from the top vin run
]
STRAPS["drops"] = dict(nets=("vss", "vin"), step=2.5, max_jog=8.0)
# vdd_1v2 has no room in the grid: it feeds the digital row by its pin and five devices in pgood
# and ilim, 200 um away. Routed 1 um wide (a non-default rule; Metal1-3) instead of 0.2: about
# 5x less resistance than the ">100 ohm" minimum-width path of the layout review.
WIDE_NETS = {"vddd": 1.0}
# vfb, the divider tap into the amplifier, is the loop's high-impedance node: deleting only its
# extracted C to vss is worth 2.0 deg at the worst corner (ff/res_wcs/-40 C, 46.6 -> 48.6), and
# that C doubled with the grid because the router ran vss wires beside it at 0.42-0.48 um (Metal2
# at x 212 and 119, Metal3 at y 19.6). A spacing rule keeps the router's neighbours away from it.
SPACED_NETS = {"vfb": 1.2}


def grid_check():
    """the vss/vin grid's geometry: TopMetal1 width, opposite-net spacing on each layer, and
    no Metal4 over a keep-out. Returns the failures."""
    bad = []
    shapes = [(n, "TopMetal1", f[2:]) for f in STRAPS["feed"] for n in (f[0],) if f[1] == "TopMetal1"]
    shapes += [(n, l, (x1, y1, x2, y2)) for n, ls, x1, y1, x2, y2 in STRAPS["bands"] for l in ls]
    for i, (na, la, a) in enumerate(shapes):
        for nb, lb, b in shapes[i + 1:]:
            if na == nb or la != lb:
                continue
            dx, dy = max(b[0] - a[2], a[0] - b[2], 0), max(b[1] - a[3], a[1] - b[3], 0)
            if max(dx, dy) < 1.64:
                bad.append(f"{na}/{nb} {la} {a} and {b}: {max(dx, dy):.2f} um apart")
    for n, ls, x1, y1, x2, y2 in GRID_BANDS:
        for b in M4_KEEPOUT:
            if "Metal4" in ls and x1 < b[1] + b[3] and b[1] < x2 and y1 < b[2] + b[4] and b[2] < y2:
                bad.append(f"{n} Metal4 at y {y1} over {b[0]!r}")
    return bad


def strap_check():
    """Current and IR drop of every strap segment at STRAPS["load_ma"]. Returns the failures."""
    I, n = STRAPS["load_ma"], STRAPS["n_fingers"]
    J = {"Metal2": 2.0, "Metal3": 2.0, "Metal4": 2.0, "TopMetal1": 15.0}   # mA/um, w > 0.3
    RS = {"Metal3": 0.103, "Metal4": 0.103, "TopMetal1": 0.021}           # ohm/sq, max
    rows, bad = [], []
    def seg(name, i, cap, harness=False):
        # harness=True: the limit is the harness wrapper's metal, not ours; reported apart, so
        # it is neither hidden by a pass nor counted as a failure of these straps
        rows.append((name, i, cap, harness))
        if i > cap + 1e-9 and not harness:
            bad.append(f"{name}: {i:.2f} mA over its {cap:.2f} mA limit")
    seg("Metal2 strip per finger (0.50 um)", I / n, J["Metal2"] * STRAPS["m2_w"])
    seg("Via1 per strip (1 um pitch, >= 90 cuts)", I / n, 90 * 0.4)
    vb = STRAPS["bands"][0]
    h = vb[5] - vb[3]
    seg(f"vout band Metal3 + Metal4 ({h:.2f} um)", I, 2 * J["Metal3"] * h)
    fo = STRAPS["feed"][0]
    # ⚠️ The wrapper's own metal at s11_an[0] is Metal3 only, 24.77 um tall (magic/
    # slot11_wrapper.mag @ c32fabe): 49.5 mA at JMAXM3, 1 % under the 50 mA load. Raised with
    # the harness owner; nothing on our side of the outline can widen it.
    seg(f"vout through the harness pin, Metal3 ({fo[5] - fo[3]:.2f} um)", I, J["Metal3"] * (fo[5] - fo[3]), True)
    for f in STRAPS["feed"][1:3]:                      # the 50 mA vin run; the grid feeds are not on it
        w = min(f[4] - f[2], f[5] - f[3])
        seg(f"vin feed TopMetal1 ({w:.0f} um)", I, J["TopMetal1"] * w)
    # IR drop, vin: the run's length in squares plus the leg down to the first band's top
    run, leg = STRAPS["feed"][1], STRAPS["feed"][2]
    sq = (run[4] - run[2]) / (run[5] - run[3]) + (run[3] - STRAPS["bands"][2][5]) / (leg[4] - leg[2])
    v_in = I * sq * RS["TopMetal1"]
    # vout: current injected evenly along the band and collected at its right end: I*R/2
    v_out = I * ((vb[4] - vb[2]) / h) * RS["Metal3"] / 2 / 2      # two layers in parallel
    for name, i, cap, harness in rows:
        flag = ("  ⚠️ HARNESS LIMIT, over" if i > cap else "  (harness)") if harness else ""
        print(f"  {name:<48} {i:6.2f} mA of {cap:7.2f}{flag}")
    print(f"  IR drop at {I:g} mA, max sheet R: vin feed {sq:.1f} sq = {v_in:.1f} mV; "
          f"vout band to pin {v_out:.1f} mV (average over the fingers)")
    return bad


COLOUR = {"ref": "#8ecae6", "amp": "#219ebc", "pass": "#fb8500", "fb": "#ffb703",
          "out": "#2a9d8f", "stat": "#adb5bd", "boost": "#e76f51", "dig": "#6c757d"}


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
    sb = strap_check() + grid_check()
    for b in sb:
        print("  FAIL " + b)
    if sb:
        return 1
    print("\nevery block is inside the slot and none overlap; every strap is within its current limit")
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
        elif w * S > 30 and h * S > 10:             # the digital row: small, but worth naming
            out.append(f'<text x="{px+2:.1f}" y="{py+9:.1f}" font-family="sans-serif" '
                       f'font-size="6.5">{n}</text>')
    out.append(f'<text x="40" y="{SLOT_H*S+62:.0f}" font-family="sans-serif" font-size="11">'
               f'regions as placed, each sized for its devices and its guard ring; '
               f'the supply grid and the routing are not drawn</text>')
    out.append("</svg>\n")
    p = os.path.join(ROOT, "doc", "datasheet", "ldo_capless_floorplan.svg")
    open(p, "w").write("\n".join(out))
    print(f"wrote {os.path.relpath(p, ROOT)}")


if __name__ == "__main__":
    rc = report()
    if "--svg" in sys.argv and rc == 0:
        svg()
    sys.exit(rc)
