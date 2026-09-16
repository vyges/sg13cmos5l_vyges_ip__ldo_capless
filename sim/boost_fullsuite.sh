#!/bin/sh
# boost_fullsuite.sh -- run the SIX PUBLISHED benches against the slew-boost prototype, so
# every datasheet row is re-measured rather than only the ones the boost was aimed at.
#
# ⛔ WHY THIS EXISTS. The boost has been judged on overshoot, droop, quiescent current, PSRR,
# startup and phase margin. The block publishes more than that: dropout, trim range and
# monotonicity, current-limit trip, line and load regulation, PGOOD and OC. A fix that cured
# the over-voltage and broke the current limit would be worse than the defect, and nothing
# run so far would have noticed. The precedent is in this repository's own history -- a gate
# driver that fixed nothing and cost 424 mV of dropout, found only because the whole sweep
# was re-run.
#
# It works by building the boosted netlist the published benches already read, rather than by
# writing new benches:
#
#   1. netlist the schematics exactly as sim/run.sh does
#   2. apply the vref divider tap (ldo_vref gains vref_ov; XR1 splits, same total length)
#   3. insert the boost devices into the TOP-LEVEL section, where XCc/XCout/XMpre already live
#   4. regenerate ldo_cells.spice from the patched netlist, so the AC bench sees the tap
#   5. patch tb_ldo_ac.spice, which instantiates the blocks by hand and so needs the extra
#      port and the boost fragment explicitly
#   6. run the six published benches and emit the datasheet check
#
# ⚠️ This MUTATES sim/netlist/ and sim/ldo_cells.spice in place. Run it in a scratch copy of
# the tree, never in one whose numbers are being published. It refuses to run if the working
# tree is a git checkout with staged or modified content, because that is the case where the
# mutation would be mistaken for a result.
#
#   cd sim && sh boost_fullsuite.sh          # with the boost
#   cd sim && sh boost_fullsuite.sh none     # CONTROL: the vref tap only, no boost devices
#
# 🔑 The `none` mode exists because the tap and the boost are two changes, and when a
# published figure moves it is otherwise impossible to say which one moved it. It applies the
# divider split and inserts nothing.
#
# ⛔ AND IT DOES NOT RE-RUN THE PVT SWEEPS, so quiescent current and phase margin come from
# whatever is in sim/pvt/ -- which, in a tree made with `cp -a`, is the ORIGINAL's data. Both
# rows read "ok" against baseline numbers the first time this was run. Run sim/run_pvt.sh in
# the same tree before believing either of them.
set -e
cd "$(dirname "$0")/.."
if [ -d .git ] && ! git diff --quiet 2>/dev/null; then
  echo "FAILED: working tree has modifications. This script rewrites sim/netlist/ in place;" >&2
  echo "        run it in a scratch copy so a mutated netlist cannot be read as a result." >&2
  exit 2
fi
PDK_ROOT="${PDK_ROOT:-/foss/pdks}"; PDK="${PDK:-ihp-sg13g2}"; export PDK_ROOT PDK
if [ -z "${SPICE_USERINIT_DIR:-}" ]; then
  SPICE_USERINIT_DIR="$PDK_ROOT/$PDK/libs.tech/ngspice"; export SPICE_USERINIT_DIR
fi
if [ "$1" = none ]; then
  NB=0; echo "CONTROL: vref tap only, no boost devices"
else
  [ -f sim/ldo_boost.spice ] || { echo "FAILED: no sim/ldo_boost.spice -- run hybboost.sh first" >&2; exit 2; }
  NB=$(grep -c '^X' sim/ldo_boost.spice)
  [ "$NB" -gt 0 ] || { echo "FAILED: sim/ldo_boost.spice has no devices" >&2; exit 2; }
  echo "boost fragment: $NB devices"
fi

mkdir -p sim/netlist
for cell in ldo_vref ldo_erramp ldo_pass ldo_fbtrim ldo_enable ldo_pgood ldo_ilim ldo_capless; do
  (cd xschem && xschem --rcfile ./xschemrc -n -q -s "$cell.sch" >/dev/null 2>&1)
  [ -s "sim/netlist/$cell.spice" ] || { echo "FAILED: no netlist for $cell" >&2; exit 2; }
done

# ⚠️ SPLITTING XR1 MOVES FOUR PUBLISHED FIGURES, and the boost does not. Two segments
# totalling 212 um are slightly more resistive than one of 212 um -- a second set of end
# effects -- so vref falls about 0.025 %. Measured with the tap and NO boost devices, which
# is what makes the attribution certain rather than likely:
#
#   trim low 0.999746 / 1.0000   trim high 1.79743 / 1.7979
#   load reg 0.27 / 0.26         dropout 149.736 / 149.3
#
# All four are bit-identical with and without the boost, and every one still passes its spec
# bound -- only the published NUMBERS move. The boost's own contribution to any published row
# is 0.12 mV of load-step droop.
#
# ⛔ COMPENSATING THE DRAWN LENGTH WAS TRIED AND IS NOT THE ANSWER. R1TOT=211.89 restores the
# low trim code to 0.999982 and leaves the other three drifting by 0.05 mV, 0.01 mV and
# 0.07 mV. Closing those means fitting drawn geometry to a model's end resistance in the
# fourth decimal -- and this block has already had its resistor corners move once under a PDK
# re-pin, which would undo the fit silently. The figures are guarded to the precision they
# were published at, which is exactly the gate working: a real design change moved them, so
# on adoption the four get REPUBLISHED rather than fudged.
#
# R1TOT stays overridable for anyone who wants to re-examine that, and defaults to the honest
# 212. ⛔ Use enough precision: %.4g rounded 194.29 and 194.35 to the same 194.3, which made
# two different totals produce bit-identical results and briefly looked like the knob was dead.
R1TOT="${R1TOT:-212}"
R1A=$(awk -v t="$R1TOT" 'BEGIN{printf "%.8g", t-17.6}')
N=sim/netlist/ldo_capless.spice
sed -i \
  -e "s|^\.subckt ldo_vref vref_bg vref vss vref_pg\$|.subckt ldo_vref vref_bg vref vss vref_pg vref_ov|" \
  -e "s|^XR1 vref_bg vref sub! rhigh w=1u l=212u.*\$|XR1a vref_bg vref_ov sub! rhigh w=1u l=${R1A}u m=1 b=0 mm_ok=1\nXR1b vref_ov vref sub! rhigh w=1u l=17.6u m=1 b=0 mm_ok=1|" \
  -e "s|^x_vref vref_bg vref vss vref_pg ldo_vref\$|x_vref vref_bg vref vss vref_pg vref_ov ldo_vref|" "$N"
# ⛔ Every edit checked. A sed that matches nothing exits 0, and the bench would then run the
# UNBOOSTED design and report its numbers as the boosted ones.
grep -q '^\.subckt ldo_vref vref_bg vref vss vref_pg vref_ov$' "$N" || { echo "FAILED: vref port" >&2; exit 2; }
grep -q '^XR1a vref_bg vref_ov ' "$N" || { echo "FAILED: XR1a" >&2; exit 2; }
grep -q '^x_vref vref_bg vref vss vref_pg vref_ov ldo_vref$' "$N" || { echo "FAILED: x_vref" >&2; exit 2; }

# Boost devices into the top-level section, immediately before its commented .ends.
if [ "$NB" -gt 0 ]; then
awk -v f=sim/ldo_boost.spice '
  /^\*\*\.ends/ && !done { while ((getline l < f) > 0) if (l ~ /^X/) print l; done=1 }
  { print }' "$N" > "$N.tmp" && mv "$N.tmp" "$N"
INS=$(awk '/^\*\*\.ends/{exit} /^XM(pl|rb|nb|ve|pb|bn|bp|ct|c[1-6])|^XCb|^XRb|^XRnx/{n++} END{print n+0}' "$N")
[ "$INS" = "$NB" ] || { echo "FAILED: inserted $INS boost devices into the top level, expected $NB" >&2; exit 2; }
echo "inserted:       $INS devices into the top-level section"
fi

awk '/^\.subckt/{p=1} p' "$N" > sim/ldo_cells.spice
grep -q '^\.subckt ldo_vref vref_bg vref vss vref_pg vref_ov$' sim/ldo_cells.spice \
  || { echo "FAILED: ldo_cells.spice did not pick up the tap" >&2; exit 2; }

sed -i -e "s|^x_vref vref_bg vref vss vref_pg ldo_vref\$|x_vref vref_bg vref vss vref_pg vref_ov ldo_vref|" sim/tb_ldo_ac.spice
grep -q '^x_vref vref_bg vref vss vref_pg vref_ov ldo_vref$' sim/tb_ldo_ac.spice || { echo "FAILED: ac bench x_vref" >&2; exit 2; }
if [ "$NB" -gt 0 ]; then
  sed -i -e "s|^\.include ldo_cells\.spice\$|.include ldo_cells.spice\n.include ldo_boost.spice|" sim/tb_ldo_ac.spice
  grep -q '^\.include ldo_boost\.spice$' sim/tb_ldo_ac.spice || { echo "FAILED: ac bench not patched" >&2; exit 2; }
fi

rc=0
for n in tb_ldo_ac tb_ldo_dc tb_ldo_ilim_lowvin tb_ldo_perf tb_ldo_status tb_ldo_trim; do
  echo "=== $n ==="
  if (cd sim && ngspice -b "$n.spice" > "_report_$n.spice.log" 2>&1); then :; else
    echo "FAILED: $n" >&2; rc=1
  fi
done
echo "=== datasheet check: every row, published against re-measured ==="
python3 tools/datasheet.py --check || true
exit $rc
