# Area budget for the capless LDO, from GENERATED geometry rather than estimates.
#
# Every device in the netlist is instantiated with the PDK's own PyCell and its bounding box
# measured. That is the only way to answer "does it fit" without guessing at contact rows,
# enclosure and spacing -- the numbers that actually decide analog area.
#
#   KLAYOUT_PATH=<pdk>/libs.tech/klayout klayout -zz -r area_budget.py -rd net=<netlist>
#
# ⚠️ WHAT THIS IS NOT: a floorplan. It sums DEVICE bounding boxes. It does not include
# routing channels, guard rings, well taps, device-to-device spacing or the dead space a real
# placement leaves. Treat the total as a floor, not a prediction.
import re, os, sys

layout = pya.Layout()
layout.technology_name = "sg13cmos5l"
dbu = layout.dbu

NET = os.environ.get("NET", "/work/sim/netlist/ldo_capless.spice")

# netlist model name -> (pycell name, how its size params map)
MAP = {
    "sg13_hv_nmos": "nmosHV", "sg13_hv_pmos": "pmosHV",
    "sg13_lv_nmos": "nmos",   "sg13_lv_pmos": "pmos",
    "rhigh": "rhigh", "cap_cmomf": "cap_cmomf",
}

def um(v):
    """'100u' / '0.5u' / '193u' -> metres for the PyCell API."""
    v = v.strip()
    return float(v[:-1]) * 1e-6 if v.endswith("u") else float(v)

cache = {}
dims = {}
_dim = {}
def dev_area(model, p):
    """Bounding-box area in um^2 of one drawn device."""
    key = (model, tuple(sorted(p.items())))
    if key in cache:
        return cache[key]
    name = MAP[model]
    if model.startswith("sg13_"):
        par = {"w": um(p["w"]), "l": um(p["l"]), "ng": int(float(p.get("ng", 1)))}
    elif model == "rhigh":
        par = {"w": um(p["w"]), "l": um(p["l"])}
    else:  # cap_cmomf
        par = {"w": um(p["w"]), "l": um(p["l"]),
               "nx": 1, "ny": 1,
               "topmetal": int(float(p.get("mmax", 4))),
               "botmetal": int(float(p.get("mmin", 1)))}
    try:
        c = layout.create_cell(name, "SG13_dev", par)
        if c is None:
            cache[key] = None
            return None
        b = c.bbox()
        a = (b.width() * dbu) * (b.height() * dbu)
        dims[key] = (b.width() * dbu, b.height() * dbu)
    except Exception as e:
        print("  ! %s %s: %s" % (model, par, str(e)[:70]))
        cache[key] = None
        return None
    cache[key] = a
    return a

cell = "TOP"
rows = []
for line in open(NET):
    t = line.split()
    if line.startswith(".subckt"):
        cell = t[1]
    elif line.startswith("**.subckt"):
        cell = t[1]
    if not t or not t[0].startswith("X"):
        continue
    model = next((x for x in t if x in MAP), None)
    if not model:
        continue
    p = dict(kv.split("=", 1) for kv in t if "=" in kv)
    if "w" not in p or "l" not in p:
        continue
    m = int(float(p.get("m", 1)))
    a = dev_area(model, p)
    rows.append((cell, t[0], model, p.get("w"), p.get("l"), m, a))
    k = (model, tuple(sorted(p.items())))
    if k in dims:
        _dim[(cell, t[0])] = "%.1f x %.1f" % dims[k]

SLOT = 530.0 * 310.0
print("%-12s %-8s %-14s %8s %8s %4s %12s %16s" % ("cell", "inst", "model", "w", "l", "m", "area um2", "drawn WxH um"))
tot = 0.0
unknown = []
for cell, inst, model, w, l, m, a in sorted(rows, key=lambda r: -(r[6] or 0) * r[5]):
    if a is None:
        unknown.append((cell, inst, model))
        continue
    tot += a * m
    if a * m > 200:
        d = dims.get((model, tuple(sorted(dict(kv.split("=",1) for kv in [] ).items()))), None)
        print("%-12s %-8s %-14s %8s %8s %4d %12.1f %16s" % (cell, inst, model, w, l, m, a * m, _dim.get((cell,inst),"")))
print("-" * 74)
print("%d devices measured, %d could not be generated" % (len(rows) - len(unknown), len(unknown)))
for c, i, mo in unknown:
    print("   not generated: %s.%s (%s)" % (c, i, mo))
percell = {}
for cell, inst, model, w, l, m, a in rows:
    if a is not None:
        percell[cell] = percell.get(cell, 0.0) + a * m
print()
print("per cell:")
for c, a in sorted(percell.items(), key=lambda x: -x[1]):
    print("  %-14s %9.1f um2   %5.1f %% of slot" % (c, a, 100 * a / SLOT))
print()
print("device area total : %10.1f um2" % tot)
print("slot 530 x 310    : %10.1f um2" % SLOT)
print("devices occupy    : %9.1f %% of the slot (bounding boxes only, no routing)" % (100 * tot / SLOT))
