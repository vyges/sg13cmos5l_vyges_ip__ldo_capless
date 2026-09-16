#!/bin/sh
# boost_pvt.sh -- the 1 -> 20 mA load release across process, resistor, temperature and
# supply, for whatever sizing currently sits in ldo_boost.spice.
#
# Reports the WORST overshoot, not the typical one. The pass/fail question is binary and it
# is not "is the overshoot small": it is whether any corner still runs to the rail, because
# that is the over-voltage the design review asked to have fixed.
#
#   cd sim && sh boost_pvt.sh          # needs ldo_boost.spice, written by boost.sh
set -e
cd "$(dirname "$0")"
PDK_ROOT="${PDK_ROOT:-/foss/pdks}"; PDK="${PDK:-ihp-sg13g2}"; export PDK_ROOT PDK
M="$PDK_ROOT/ihp-sg13cmos5l/libs.tech/ngspice/models"
[ -f ldo_boost.spice ] || { echo "FAILED: no ldo_boost.spice -- run boost.sh first" >&2; exit 2; }
grep -q '^X' ldo_boost.spice || echo "NOTE: ldo_boost.spice has no devices -- this is a CONTROL run"
: > boost_pvt.txt
for mos in mos_tt mos_ss mos_ff; do
 for res in res_typ res_bcs res_wcs; do
  for temp in -40 27 110; do
   for vin in 3.0 3.3 3.6; do
    tag="${mos}_${res}_${temp}_${vin}"
    sed -e "s|@MOS@|$mos|g" -e "s|@RES@|$res|g" -e "s|@TEMP@|$temp|g" \
        -e "s|@VIN@|$vin|g" -e "s|@M@|$M|g" tb_ldo_boost_pvt.tpl > _bp.spice
    ngspice -b _bp.spice > _bp.log 2>&1 || true
    ov=$(tr '\r' '\n' < _bp.log | grep -oE '^ov20 = [-0-9.e+]+' | head -1 | grep -oE '[-0-9.e+]+$')
    vd=$(tr '\r' '\n' < _bp.log | grep -oE '^vd20 = [-0-9.e+]+' | head -1 | grep -oE '[-0-9.e+]+$')
    vp=$(tr '\r' '\n' < _bp.log | grep -oE '^vpre = [-0-9.e+]+' | head -1 | grep -oE '[-0-9.e+]+$')
    echo "$tag ${ov:-FAIL} ${vd:-FAIL} ${vp:-FAIL}" >> boost_pvt.txt
   done
  done
 done
done
rm -f _bp.spice _bp.log
echo "corners: $(wc -l < boost_pvt.txt)"
echo "FAILED to measure: $(grep -c FAIL boost_pvt.txt || true)"
echo "--- worst overshoot ---"
sort -k2 -g -r boost_pvt.txt | head -5
echo "--- worst droop ---"
sort -k3 -g boost_pvt.txt | head -3
