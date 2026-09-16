#!/bin/sh
# m6sweep.sh -- DIAGNOSTIC driver for tb_ldo_m6sweep.spice.
#
# Substitutes XM6's width into a copy of the netlist and runs the bench once per width,
# so each point is a genuinely different elaborated device. XM6 is the sole pull-up on
# eout and the current that sets how fast the pass device can be turned off.
#
# ⛔ The substitution is VERIFIED before each run. The previous attempt at this used
# ngspice's `alter`, which failed silently and reported the unmodified circuit as the
# modified one; a sed that matches nothing would do exactly the same. If the line does
# not come back with the width asked for, this exits non-zero and runs nothing.
#
#   cd sim && sh m6sweep.sh            # default widths
#   cd sim && sh m6sweep.sh 2 4 8      # or name them
set -e
cd "$(dirname "$0")"
SRC=netlist/ldo_capless.spice
VAR=netlist/ldo_capless_m6var.spice
[ -f "$SRC" ] || { echo "FAILED: no $SRC -- run sim/run.sh first to netlist the schematics" >&2; exit 2; }

# The line as the schematic emits it. Anchored on the instance name and the node list so a
# rename upstream breaks this loudly instead of quietly matching something else.
BASE='XM6 eout pbias vin vin sg13_hv_pmos w=2u l=1u'
grep -q "^$BASE" "$SRC" || {
  echo "FAILED: XM6 is not '$BASE' in $SRC -- the schematic changed, so this sweep is" >&2
  echo "        substituting into a netlist it no longer understands" >&2
  grep -n '^XM6' "$SRC" >&2
  exit 2
}

WIDTHS="$*"
[ -n "$WIDTHS" ] || WIDTHS="2 4 8 16"
for w in $WIDTHS; do
  sed "s|^$BASE|XM6 eout pbias vin vin sg13_hv_pmos w=${w}u l=1u|" "$SRC" > "$VAR"
  got=$(grep -m1 '^XM6 eout pbias' "$VAR" | sed 's/.* w=\([^ ]*\) .*/\1/')
  [ "$got" = "${w}u" ] || { echo "FAILED: wanted w=${w}u, netlist says w=$got" >&2; exit 2; }
  echo "=============== XM6 w=${w}u ==============="
  ngspice -b tb_ldo_m6sweep.spice 2>&1 | tr '\r' '\n' \
    | grep -iE '^(iq|ov[0-9]+|vd[0-9]+|vpre7|psrr_[0-9]+k) *=' || true
done
