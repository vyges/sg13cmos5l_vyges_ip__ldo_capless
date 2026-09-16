#!/bin/sh
# boost.sh -- PROTOTYPE driver: substitute a slew-boost sizing into ldo_boost.tpl and run
# tb_ldo_boost.spice against it.
#
# Same discipline as m6sweep.sh and for the same reason: every token is substituted and
# then CHECKED, because an intervention that fails to land silently reports the unmodified
# circuit as a fix. Here that would be worse than with a width sweep -- the boost is off at
# DC by design, so "no leftover @TOKEN@" is the only evidence that it exists at all.
#
#   cd sim && sh boost.sh CB RB WNB LNB RNX WPB
#   cd sim && sh boost.sh 28u 1470u 1u 2u 1470u 20u
set -e
cd "$(dirname "$0")"
CB=${1:-28u}; RB=${2:-1470u}; WNB=${3:-1u}; LNB=${4:-4u}; RNX=${5:-735u}; WPB=${6:-20u}; WGT=${7:-5u}
[ -f ldo_boost.tpl ] || { echo "FAILED: no ldo_boost.tpl" >&2; exit 2; }

# `none` is the CONTROL: the same bench with no boost at all. Without it, every number this
# script prints is unattributed -- the startup behaviour in particular could be the block's
# own and was never measured, because the repository tests enable only as two DC operating
# points. A control that is not run is an assumption.
if [ "$1" = none ]; then
  echo '* no boost -- CONTROL run, see boost.sh' > ldo_boost.spice
  echo "=== CONTROL: no boost ==="
  ngspice -b tb_ldo_boost.spice 2>&1 | tr '\r' '\n' \
    | grep -iE '^(iq|ov[0-9]+|vd[0-9]+|vpre|psrr_[0-9]+k|vstart|vstpk|tstart|v\(n[bx]\)|v\(eout\)|v\(vout\)) *=' || true
  exit 0
fi
sed -e "s|@CB@|$CB|g" -e "s|@RB@|$RB|g" -e "s|@WNB@|$WNB|g" \
    -e "s|@LNB@|$LNB|g" -e "s|@RNX@|$RNX|g" -e "s|@WPB@|$WPB|g" \
    -e "s|@WGT@|$WGT|g" ldo_boost.tpl > ldo_boost.spice
if grep -q '@[A-Z]*@' ldo_boost.spice; then
  echo "FAILED: unsubstituted token left in ldo_boost.spice" >&2
  grep -n '@[A-Z]*@' ldo_boost.spice >&2
  exit 2
fi
# Five devices, no more and no less -- a sed that mangled a line would still leave no token.
n=$(grep -c '^X' ldo_boost.spice)
[ "$n" = 7 ] || { echo "FAILED: ldo_boost.spice has $n devices, expected 7" >&2; exit 2; }
echo "=== Cb=$CB Rb=$RB Mnb=$WNB/$LNB Rnx=$RNX Mpb=$WPB gate=$WGT ==="
ngspice -b tb_ldo_boost.spice 2>&1 | tr '\r' '\n' \
  | grep -iE '^(iq|ov[0-9]+|vd[0-9]+|vpre|nxmin|psrr_[0-9]+k|vstart|vstpk|tstart|v\(n[bx]\)|v\(eout\)|v\(vout\)) *=' || true
