#!/bin/sh
# Reproduce every simulated number in this repository from a clean clone.
#
# Netlists the xschem hierarchy and runs the testbenches. Requires an environment
# with xschem, ngspice and the ihp-sg13cmos5l PDK at /foss/pdks (any IIC-OSIC-TOOLS
# derived container provides this; we use ghcr.io/vyges-tools/vyges-iic-osic-tools).
set -e
cd "$(dirname "$0")/.."
mkdir -p sim/netlist
for cell in ldo_vref ldo_erramp ldo_pass ldo_fbtrim ldo_capless; do
  echo "netlist: $cell"
  (cd xschem && xschem --rcfile ./xschemrc -n -q -s "$cell.sch" >/dev/null 2>&1)
done
for tb in sim/tb_*.spice; do
  echo "=== $(basename "$tb") ==="
  (cd sim && ngspice -b "$(basename "$tb")")
done
