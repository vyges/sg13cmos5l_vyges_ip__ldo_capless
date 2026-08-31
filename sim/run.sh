#!/bin/sh
# Reproduce every simulated number in this repository from a clean clone.
#
# Netlists the xschem hierarchy and runs the testbenches. Requires an environment
# with xschem, ngspice and the ihp-sg13cmos5l PDK at /foss/pdks (any IIC-OSIC-TOOLS
# derived container provides this; we use ghcr.io/vyges-tools/vyges-iic-osic-tools).
#
#   sh sim/run.sh
#
# Exit status is the verdict: 0 every bench ran, non-zero one or more failed.
cd "$(dirname "$0")/.." || exit 2
mkdir -p sim/netlist

# ⚠️ No `set -e` around the netlist step: xschem returns non-zero on a perfectly clean
# netlist, so aborting on its status skips everything after it and the benches then read
# whatever was already on disk.
# ⛔ All EIGHT cells, not five. ldo_enable, ldo_pgood and ldo_ilim were missing here while
# the private runner netlisted them, so this script could not have produced the enable,
# power-good or current-limit numbers this repository publishes.
for cell in ldo_vref ldo_erramp ldo_pass ldo_fbtrim ldo_enable ldo_pgood ldo_ilim ldo_capless; do
  echo "netlist: $cell"
  (cd xschem && xschem --rcfile ./xschemrc -n -q -s "$cell.sch" >/dev/null 2>&1)
  if [ ! -s "sim/netlist/$cell.spice" ]; then
    echo "FAILED: xschem produced no netlist for $cell" >&2
    exit 2
  fi
done

# 🔑 The sub-cell .subckt definitions come from the TOP-LEVEL netlist, not from netlisting
# each cell on its own: xschem comments out a cell's own .subckt line when that cell is the
# top, so including one of those puts its devices at top scope instead of defining a
# subcircuit.
# ⛔ This step used to live only in a private runner, so `sim/run.sh` could not reproduce a
# single number from a clean clone -- it stopped at "Could not find include file
# ldo_cells.spice" on the FIRST bench, which under `set -e` also meant the other five were
# never run at all.
awk '/^\.subckt/{p=1} p' sim/netlist/ldo_capless.spice > sim/ldo_cells.spice
if ! grep -q '^\.subckt' sim/ldo_cells.spice; then
  echo "FAILED: no .subckt definitions extracted from sim/netlist/ldo_capless.spice" >&2
  exit 2
fi
echo "cells:   $(grep -c '^\.subckt' sim/ldo_cells.spice) subcircuits -> sim/ldo_cells.spice"

# Run every bench and report a verdict for each. ⚠️ Stopping at the first failure hides the
# state of all the others.
rc=0
for tb in sim/tb_*.spice; do
  echo "=== $(basename "$tb") ==="
  if (cd sim && ngspice -b "$(basename "$tb")"); then :; else
    echo "FAILED: $(basename "$tb")" >&2
    rc=1
  fi
done
exit $rc
