#!/bin/sh
# m6ac.sh -- DIAGNOSTIC driver: phase margin against XM6 width, same substitution-and-check
# discipline as m6sweep.sh. w=2u is the shipping device, so its row is the control: if it
# does not reproduce the published 45.6 deg minimum, the extraction is wrong and no other
# row means anything.
set -e
cd "$(dirname "$0")"
[ -f ldo_cells.spice ] || { echo "FAILED: no ldo_cells.spice -- run sim/run.sh first" >&2; exit 2; }
BASE='XM6 eout pbias vin vin sg13_hv_pmos w=2u l=1u'
grep -q "^$BASE" ldo_cells.spice || { echo "FAILED: XM6 is not '$BASE' in ldo_cells.spice" >&2; exit 2; }
WIDTHS="$*"
[ -n "$WIDTHS" ] || WIDTHS="2 4 8"
for w in $WIDTHS; do
  sed "s|^$BASE|XM6 eout pbias vin vin sg13_hv_pmos w=${w}u l=1u|" ldo_cells.spice > ldo_cells_m6var.spice
  got=$(grep -m1 '^XM6 eout pbias' ldo_cells_m6var.spice | sed 's/.* w=\([^ ]*\) .*/\1/')
  [ "$got" = "${w}u" ] || { echo "FAILED: wanted w=${w}u, netlist says w=$got" >&2; exit 2; }
  echo "=============== XM6 w=${w}u ==============="
  ngspice -b tb_ldo_ac_m6.spice 2>&1 | tr '\r' '\n' | grep -iE '^(pm[0-9]+|fug[0-9]+) *=' || true
done
