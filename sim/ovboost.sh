#!/bin/sh
# ovboost.sh -- PROTOTYPE driver for ldo_ovboost.tpl, the over-voltage slew boost.
#
# Two substitutions, both verified, because this one reaches INTO the netlist rather than
# only appending to it:
#
#   1. ldo_ovboost.tpl -> ldo_boost.spice, with the device sizes filled in.
#   2. ldo_vref's XR1 split into XR1a + XR1b, so the comparator threshold is a tap on the
#      EXISTING divider. That means editing the subcircuit, its port list AND its
#      instantiation -- three edits that must all land or the netlist is quietly wrong.
#
# ⛔ The split preserves the TOTAL length. XR1 is 212u; XR1a + XR1b must still be 212u or
# vref itself moves, and every published figure in this repository is referenced to vref.
# The check below enforces it arithmetically rather than trusting the arithmetic above.
#
#   cd sim && sh ovboost.sh ROV WBN WBP WCT WCI WCM WPB
#   cd sim && sh ovboost.sh 17.6 4u 4u 4u 5u 10u 20u
set -e
cd "$(dirname "$0")"
ROV=${1:-17.6}; WBN=${2:-4u}; WBP=${3:-4u}; WCT=${4:-4u}
WCI=${5:-5u}; WCM=${6:-10u}; WPB=${7:-20u}; WC5=${8:-10u}; WC6=${9:-2u}
SRC=netlist/ldo_capless.spice
VAR=netlist/ldo_capless_ov.spice
[ -f ldo_ovboost.tpl ] || { echo "FAILED: no ldo_ovboost.tpl" >&2; exit 2; }
[ -f "$SRC" ] || { echo "FAILED: no $SRC -- run sim/run.sh first" >&2; exit 2; }

R1TOT=212
ROVB=$(awk -v t=$R1TOT -v o=$ROV 'BEGIN{printf "%.4g", t-o}')
sum=$(awk -v a=$ROVB -v b=$ROV 'BEGIN{printf "%.4g", a+b}')
[ "$sum" = "$R1TOT" ] || { echo "FAILED: XR1a+XR1b = $sum, must be $R1TOT or vref moves" >&2; exit 2; }

# --- 1. the fragment
sed -e "s|@ROV@|$ROV|g" -e "s|@WBN@|$WBN|g" -e "s|@WBP@|$WBP|g" -e "s|@WCT@|$WCT|g" \
    -e "s|@WCI@|$WCI|g" -e "s|@WCM@|$WCM|g" -e "s|@WPB@|$WPB|g" \
    -e "s|@WC5@|$WC5|g" -e "s|@WC6@|$WC6|g" ldo_ovboost.tpl > ldo_boost.spice
if grep -q '@[A-Z]*@' ldo_boost.spice; then
  echo "FAILED: unsubstituted token in ldo_boost.spice" >&2; grep -n '@[A-Z]*@' ldo_boost.spice >&2; exit 2
fi
n=$(grep -c '^X' ldo_boost.spice)
[ "$n" = 10 ] || { echo "FAILED: ldo_boost.spice has $n devices, expected 10" >&2; exit 2; }

# --- 2. the divider tap, all three edits
sed -e "s|^\.subckt ldo_vref vref_bg vref vss vref_pg\$|.subckt ldo_vref vref_bg vref vss vref_pg vref_ov|" \
    -e "s|^XR1 vref_bg vref sub! rhigh w=1u l=212u.*\$|XR1a vref_bg vref_ov sub! rhigh w=1u l=${ROVB}u m=1 b=0 mm_ok=1\nXR1b vref_ov vref sub! rhigh w=1u l=${ROV}u m=1 b=0 mm_ok=1|" \
    -e "s|^x_vref vref_bg vref vss vref_pg ldo_vref\$|x_vref vref_bg vref vss vref_pg vref_ov ldo_vref|" \
    "$SRC" > "$VAR"

# ⛔ Each edit checked separately. A sed that matches nothing exits 0 and leaves the netlist
# looking fine -- and this one would then elaborate with vref_ov floating, which reads as a
# comparator that simply never fires rather than as an error.
grep -q '^\.subckt ldo_vref vref_bg vref vss vref_pg vref_ov$' "$VAR" \
  || { echo "FAILED: ldo_vref port list not extended" >&2; exit 2; }
grep -q "^XR1a vref_bg vref_ov " "$VAR" || { echo "FAILED: XR1a not written" >&2; exit 2; }
grep -q "^XR1b vref_ov vref "   "$VAR" || { echo "FAILED: XR1b not written" >&2; exit 2; }
grep -q '^XR1 vref_bg vref '    "$VAR" && { echo "FAILED: original XR1 still present" >&2; exit 2; }
grep -q '^x_vref vref_bg vref vss vref_pg vref_ov ldo_vref$' "$VAR" \
  || { echo "FAILED: x_vref instantiation not extended" >&2; exit 2; }

echo "=== offset=${ROV}u of 212u (XR1a=${ROVB}u) bias=$WBN/$WBP tail=$WCT pair=$WCI mirror=$WCM Mpb=$WPB ==="
ngspice -b tb_ldo_ovboost.spice 2>&1 | tr '\r' '\n' \
  | grep -iE '^(iq|ov[0-9]+|vd[0-9]+|vpre|vstart|vstpk|tstart|psrr_[0-9]+k|nxmax|ngmin|ngdroop|vfbmax|v\(n[a-z]*\)|v\(vref[_a-z]*\)|v\(vfb\)|v\(eout\)|v\(vout\)) *=' || true
