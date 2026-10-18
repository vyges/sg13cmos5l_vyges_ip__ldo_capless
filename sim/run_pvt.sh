#!/bin/sh
# PVT sweep -- part 1: simulate. Writes one loop-gain sweep per corner.
# Phase margin is evaluated at three loads per corner, not at no load alone: the
# no-load corner and the mid-load dip are different failures and neither bounds the other.
# Resistor corners are swept INDEPENDENTLY of the MOS corner -- see the reasoning below.
# (This header used to say they were paired, contradicting the loop it introduces.)
set -e
cd "$(dirname "$0")"
# PDK location -- see sim/run.sh for why BOTH the overlay and the base are needed.
# Exported because the generated deck reaches the stdcell library through $PDK_ROOT
# directly, not through @M@.
PDK_ROOT="${PDK_ROOT:-/foss/pdks}"
PDK="${PDK:-ihp-sg13cmos5l}"   # the process this IP targets; see sim/run.sh
export PDK_ROOT PDK
if [ -z "${SPICE_USERINIT_DIR:-}" ]; then
  SPICE_USERINIT_DIR="$PDK_ROOT/$PDK/libs.tech/ngspice"
  export SPICE_USERINIT_DIR
fi
for d in ihp-sg13cmos5l "$PDK"; do
  if [ ! -d "$PDK_ROOT/$d" ]; then
    echo "FAILED: no $d under PDK_ROOT=$PDK_ROOT (need the overlay AND the base)" >&2
    exit 2
  fi
done
M="$PDK_ROOT/ihp-sg13cmos5l/libs.tech/ngspice/models"
# Points are independent runs, so they go in parallel (PVT_JOBS, as the PLL's sweep). The
# sweep is enumerated first and executed second, and dc.txt is written in the enumeration
# order afterwards, so the file is the same whichever point finishes first. 243 decks
# serially took long enough on the extracted netlist (the post-layout gate) to matter.
JOBS="${PVT_JOBS:-8}"
mkdir -p pvt
rm -f pvt/_pt_*
: > pvt/_order
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
 for res in res_typ res_bcs res_wcs; do
  for temp in -40 27 110; do
    for vin in 3.0 3.3 3.6; do
     # Loads chosen where the tt/27 load sweep is thinnest -- no load, and the mid-load
     # dip. A corner sweep at no load alone reported 45.0 deg while the same design was
     # at 32.5 deg at 300 uA typical, so the two sweeps have to be crossed, not stacked.
     for iload in 0 100u 300u; do
      echo "$corner $res $temp $vin $iload" >> pvt/_order
     done
    done
  done
 done
done
export M
# one point per call of pvt_point.sh: deck, run, and its dc line in pvt/_pt_<tag>
xargs -P "$JOBS" -L 1 sh ./pvt_point.sh < pvt/_order
: > pvt/dc.txt
while read -r corner res temp vin iload; do
  f="pvt/_pt_${corner}_${res}_${temp}_${vin}_${iload}"
  if [ -s "$f" ]; then cat "$f" >> pvt/dc.txt; else echo "${corner}_${res}_${temp}_${vin}_${iload} fail ?" >> pvt/dc.txt; fi
done < pvt/_order
rm -f pvt/_pt_* pvt/_order
echo "simulated $(wc -l < pvt/dc.txt) corners"
