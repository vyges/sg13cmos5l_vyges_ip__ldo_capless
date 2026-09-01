#!/bin/sh
# PVT sweep -- part 1: simulate. Writes one loop-gain sweep per corner.
# Phase margin is evaluated at three loads per corner, not at no load alone: the
# no-load corner and the mid-load dip are different failures and neither bounds the other.
# Resistor corners are swept INDEPENDENTLY of the MOS corner -- see the reasoning below.
# (This header used to say they were paired, contradicting the loop it introduces.)
set -e
cd "$(dirname "$0")"
M=/foss/pdks/ihp-sg13cmos5l/libs.tech/ngspice/models
mkdir -p pvt
: > pvt/dc.txt
# Resistor corners are swept INDEPENDENTLY of the MOS corner, not paired with it.
#
# Pairing them was a guess borrowed from digital practice, where "best case" resistor means
# lowest sheet and therefore fastest. It does not carry over. In this PDK res_bcs sets
# rhigh to 1020 ohm/sq against 1360 typical, and rhigh IS the nulling resistor in the
# compensation, so a "best case" sheet moves the recovery zero UP by a third -- the worst
# case for phase margin, not the best. At ff/110C/3.0V with no load the same design measures
# 57.3 deg with res_typ, 60.7 deg with res_wcs and 40.4 deg with res_bcs: the entire
# reported shortfall came from the pairing.
#
# Poly sheet resistance and MOS drive are not the same process step and are not correlated,
# so there is no physical basis for tying them. Sweeping independently costs 3x the runs and
# finds the real worst case instead of a chosen one.
for corner in tt ss ff; do
  case $corner in
    tt) mos=mos_tt ;;
    ss) mos=mos_ss ;;
    ff) mos=mos_ff ;;
  esac
 for res in res_typ res_bcs res_wcs; do
  for temp in -40 27 110; do
    for vin in 3.0 3.3 3.6; do
     # Loads chosen where the tt/27 load sweep is thinnest -- no load, and the mid-load
     # dip. A corner sweep at no load alone reported 45.0 deg while the same design was
     # at 32.5 deg at 300 uA typical, so the two sweeps have to be crossed, not stacked.
     for iload in 0 100u 300u; do
      tag="${corner}_${res}_${temp}_${vin}_${iload}"
      sed -e "s|@MOS@|$mos|g" -e "s|@RES@|$res|g" -e "s|@TEMP@|$temp|g" \
          -e "s|@VIN@|$vin|g" -e "s|@TAG@|$tag|g" -e "s|@M@|$M|g" \
          -e "s|@ILOAD@|$iload|g" tb_ldo_pvt.tpl > _p.spice
      ngspice -b _p.spice > _p.log 2>&1 || true
      vout=$(grep -oE "^v\(vout\) = [-0-9.e+]+" _p.log | head -1 | grep -oE "[-0-9.e+]+$")
      iq=$(grep -oE "^-i\(vin\) = [-0-9.e+]+" _p.log | head -1 | grep -oE "[-0-9.e+]+$")
      echo "$tag ${vout:-fail} ${iq:-?}" >> pvt/dc.txt
     done
    done
   done
  done
done
rm -f _p.spice _p.log
echo "simulated $(wc -l < pvt/dc.txt) corners"
