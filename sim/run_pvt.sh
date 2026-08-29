#!/bin/sh
# PVT sweep -- part 1: simulate. Writes one loop-gain sweep per corner.
# Phase margin is evaluated at NO external load, which the load sweep showed to be
# the worst case for this topology. Resistor corners are paired pessimistically with
# the MOS corner rather than swept independently: slow silicon with worst-case sheet.
set -e
cd "$(dirname "$0")"
M=/foss/pdks/ihp-sg13cmos5l/libs.tech/ngspice/models
mkdir -p pvt
: > pvt/dc.txt
for corner in tt ss ff; do
  case $corner in
    tt) mos=mos_tt; res=res_typ ;;
    ss) mos=mos_ss; res=res_wcs ;;
    ff) mos=mos_ff; res=res_bcs ;;
  esac
  for temp in -40 27 110; do
    for vin in 3.0 3.3 3.6; do
      tag="${corner}_${temp}_${vin}"
      sed -e "s|@MOS@|$mos|g" -e "s|@RES@|$res|g" -e "s|@TEMP@|$temp|g" \
          -e "s|@VIN@|$vin|g" -e "s|@TAG@|$tag|g" -e "s|@M@|$M|g" tb_ldo_pvt.tpl > _p.spice
      ngspice -b _p.spice > _p.log 2>&1 || true
      vout=$(grep -oE "^v\(vout\) = [-0-9.e+]+" _p.log | head -1 | grep -oE "[-0-9.e+]+$")
      iq=$(grep -oE "^-i\(vin\) = [-0-9.e+]+" _p.log | head -1 | grep -oE "[-0-9.e+]+$")
      echo "$tag ${vout:-fail} ${iq:-?}" >> pvt/dc.txt
    done
  done
done
rm -f _p.spice _p.log
echo "simulated $(wc -l < pvt/dc.txt) corners"
