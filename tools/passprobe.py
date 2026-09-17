# What does the pass device ACTUALLY measure, and how should 64 of them be arranged?
#
# ⛔ THE FLOORPLAN ASSUMES AN ANSWER IT NEVER CHECKED. tools/floorplan.py reserves
# 153.6 x 101.2 um for the pass array, from "64 instances of 2.4 x 101.2 um laid side by
# side" -- i.e. it assumes the devices ABUT at exactly their own bounding-box width. Device
# bounding boxes do not include the well and diffusion spacing a neighbour needs, so that
# assumption is optimistic until DRC says otherwise, and the pass array is 15544 um2 of a
# 164300 um2 slot.
#
# The netlist says m=64 of (w=100u, l=0.5u, ng=1). That is a LAYOUT choice, not an
# electrical one: m=64 x ng=1 and m=1 x ng=64 are the same device electrically and very
# different shapes on silicon. This measures the options rather than assuming one.
#
#   KLAYOUT_PATH=<pdk>/libs.tech/klayout klayout -zz -r tools/passprobe.py
import os

layout = pya.Layout()
layout.technology_name = "sg13cmos5l"
dbu = layout.dbu

def dev(name, par):
    try:
        c = layout.create_cell(name, "SG13_dev", par)
    except Exception as e:
        return None, str(e)[:60]
    if c is None:
        return None, "create_cell returned None"
    b = c.bbox()
    return (b.width() * dbu, b.height() * dbu), None

print("pass device = sg13_hv_pmos w=100u l=0.5u, m=64 in the netlist\n")
print("%-28s %10s %10s %12s  %s" % ("variant", "w um", "h um", "area um2", "note"))

# ⚠️ Is `w` the width PER FINGER or the TOTAL? Everything downstream depends on it, and it
# is the kind of thing that is obvious only after it has been wrong. If w is per finger,
# ng=2 at w=100u is the same height and twice the width, and TOTAL width doubles.
for ng in (1, 2, 4, 8, 16, 32, 64):
    d, err = dev("pmosHV", {"w": 100e-6, "l": 0.5e-6, "ng": ng})
    if err:
        print("%-28s %10s %10s %12s  %s" % ("w=100u ng=%d" % ng, "-", "-", "-", err))
        continue
    print("%-28s %10.3f %10.3f %12.1f  total W = %g um if w is per-finger"
          % ("w=100u ng=%d" % ng, d[0], d[1], d[0] * d[1], 100 * ng))

print()
# Fold the SAME total 6400 um of width different ways and compare the resulting array.
TOTAL_W = 6400e-6
for ng in (1, 2, 4, 8, 16):
    wf = TOTAL_W / 64 / ng          # per-finger width so that 64 instances x ng fingers = 6400 um
    d, err = dev("pmosHV", {"w": wf, "l": 0.5e-6, "ng": ng})
    if err:
        continue
    print("%-28s %10.3f %10.3f %12.1f  x64 abutted = %.1f x %.1f um"
          % ("64 inst, w=%.4gu ng=%d" % (wf * 1e6, ng), d[0], d[1], d[0] * d[1],
             d[0] * 64, d[1]))
