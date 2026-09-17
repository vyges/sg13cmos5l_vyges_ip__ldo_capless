# Generate the pass-device array as real GDS, so DRC can answer what the floorplan assumed.
#
# ⛔ THE ASSUMPTION UNDER TEST. tools/floorplan.py reserves 153.6 x 101.2 um for the pass
# array, derived from "64 instances of 2.4 x 101.2 um laid side by side". Side by side means
# abutting at the device bounding box, and a device bounding box does not include the nwell
# and diffusion spacing a NEIGHBOUR requires. If abutment is illegal the array is wider than
# the floorplan reserves, and the pass array is the block that has to sit hard against the
# right edge where vout leaves the slot -- so its width is not a detail.
#
#   klayout -zz -r tools/layout_pass.py -rd ng=1 -rd cols=64 -rd rows=1 -rd gap=0 -rd out=x.gds
#
# gap is the EDGE-TO-EDGE spacing added to the device bounding box, in um. gap=0 is pure
# abutment, which is what the floorplan assumes. ⚠️ A NEGATIVE gap deliberately overlaps the
# devices and must produce violations: that is how this proves the DRC deck is actually
# running, and it is not optional. A check that cannot fail proves nothing, and this project
# has already had a DRC sweep return 0 violations at every pitch because the deck was never
# reading the layout.
import os

def arg(name, default):
    v = globals().get(name, os.environ.get(name.upper()))
    return default if v is None else type(default)(v)

NG   = arg("ng", 1)
COLS = arg("cols", 64)
ROWS = arg("rows", 1)
GAP  = arg("gap", 0.0)
OUT  = str(globals().get("out", "/work/layout/pass_array.gds"))

layout = pya.Layout()
layout.technology_name = "sg13cmos5l"
dbu = layout.dbu

dev = layout.create_cell("pmosHV", "SG13_dev", {"w": 100e-6, "l": 0.5e-6, "ng": NG})
if dev is None:
    raise RuntimeError("pmosHV PyCell returned None")
b = dev.bbox()
dw, dh = b.width() * dbu, b.height() * dbu

top = layout.create_cell("pass_array")
px = dw + GAP
py = dh + GAP
n = 0
for r in range(ROWS):
    for c in range(COLS):
        # ⚠️ Shift by -bbox origin so the placement pitch is measured between BOUNDING BOXES,
        # not between cell origins, which the PyCell does not guarantee sit at the corner.
        t = pya.Trans(pya.Vector(round((c * px) / dbu) - b.left,
                                 round((r * py) / dbu) - b.bottom))
        top.insert(pya.CellInstArray(dev.cell_index(), t))
        n += 1

tb = top.bbox()
print("device   ng=%d  %.3f x %.3f um" % (NG, dw, dh))
print("array    %d x %d = %d instances, gap %.3f um" % (COLS, ROWS, n, GAP))
print("bbox     %.3f x %.3f um = %.1f um2" % (tb.width() * dbu, tb.height() * dbu,
                                              (tb.width() * dbu) * (tb.height() * dbu)))
print("total W  %g um of pass device" % (100.0 * n))
layout.write(OUT)
print("wrote    %s" % OUT)
