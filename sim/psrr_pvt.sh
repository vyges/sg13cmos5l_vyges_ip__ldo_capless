#!/bin/sh
# psrr_pvt -- PSRR across PVT. A specification needs corner margin, not a typical number.
#
# ⛔ WHY THIS EXISTS. run_pvt.sh sweeps 243 corners for PHASE MARGIN; its AC stimulus is the
# loop-breaking injection, so it says nothing about supply rejection. Every PSRR number in
# this repository was a single typical-corner measurement. Respecifying PSRR off one corner
# would set a limit the block cannot hold across process and temperature.
#
# 🔑 It derives each corner from tb_ldo_psrr.spice ITSELF -- header, sources and all, with
# only the corner lines substituted -- rather than from a copy. A template drifts from the
# bench it was copied out of; this cannot.
#
# Corner axes follow run_pvt.sh, including its reasoning that RES is swept INDEPENDENTLY of
# MOS because sheet resistance and MOS drive are different process steps.
# ⚠️ Loads differ: run_pvt.sh uses 0/100u/300u because phase margin is worst near no load.
# PSRR tracks loop gain, which falls as the load RISES, so this spans the operating range.
set -e
export PDK_ROOT=/pdks PDK=ihp-sg13cmos5l
export SPICE_USERINIT_DIR=$PDK_ROOT/$PDK/libs.tech/ngspice
cd "$(dirname "$0")"
W=$(mktemp -d); trap 'rm -rf $W' EXIT
OUT=_psrr_pvt.txt
: > "$OUT"
n=0
for mos in tt ss ff; do
 for res in res_typ res_bcs res_wcs; do
  for temp in -40 27 110; do
   for vin in 3.0 3.3 3.6; do
    for iload in 100u 1m 50m; do
      n=$((n+1))
      # Everything above .control, verbatim from the bench, with the corner substituted.
      sed -e "s|cornerMOShv.lib mos_tt|cornerMOShv.lib mos_$mos|" \
          -e "s|cornerMOSlv.lib mos_tt|cornerMOSlv.lib mos_$mos|" \
          -e "s|cornerRES.lib res_typ|cornerRES.lib $res|" \
          -e "s|^Vin     vin     0 DC 3.3 AC 1|Vin     vin     0 DC $vin AC 1|" \
          -e "s|^Iload   vout    0 DC 1m|Iload   vout    0 DC $iload|" \
          tb_ldo_psrr.spice | sed -n '1,/^\.control/p' | sed '$d' > $W/c.spice
      # ⛔ A substitution that silently misses leaves the TYPICAL corner and the sweep then
      # reports 243 identical passes. Check each one took.
      for pat in "mos_$mos" "cornerRES.lib $res" "DC $vin AC 1" "DC $iload"; do
        grep -q -- "$pat" $W/c.spice || { echo "FAILED subst [$pat] at corner $mos/$res/$temp/$vin/$iload"; exit 2; }
      done
      cat >> $W/c.spice << CTRL
.temp $temp
.control
  op
  ac dec 20 10 100meg
  let rej = -db(v(vout))
  meas ac p100  FIND rej AT=100
  meas ac p1k   FIND rej AT=1k
  meas ac p10k  FIND rej AT=10k
  meas ac worst MIN rej FROM=10 TO=100meg
  * 🔑 Where rejection runs out altogether. A specification that stops at 10 kHz has to say
  * where it stops being true, and that frequency moves with corner just as the values do.
  meas ac f0db WHEN rej=0 FALL=1
  print p100 p1k p10k worst f0db
.endc
.end
CTRL
      ngspice -b $W/c.spice > $W/o.log 2>&1 || true
      v() { tr '\r' '\n' < $W/o.log | grep -oE "^$1 *=? *[-0-9.e+]+" | head -1 | grep -oE "[-0-9.e+]+$"; }
      row="$mos $res $temp $vin $iload $(v p100) $(v p1k) $(v p10k) $(v worst) $(v f0db)"
      set -- $row
      [ $# -eq 10 ] || { echo "FAILED: no measurement at corner $mos/$res/$temp/$vin/$iload"; \
                        echo "  ngspice said:"; tail -5 $W/o.log | sed "s|^|    |"; exit 2; }
      echo "$row" >> "$OUT"
    done
   done
  done
 done
done
echo "simulated $n corners" >> "$OUT"
python3 - "$OUT" << 'PY'
import sys
rows = []
for ln in open(sys.argv[1]):
    f = ln.split()
    if len(f) == 10:
        try:
            rows.append((f[:5], [float(x) for x in f[5:]]))
        except ValueError:
            pass
print("PSRR across %d corners (dB, rejection: higher is better)" % len(rows))
print("%-10s %9s %9s %9s" % ("", "100 Hz", "1 kHz", "10 kHz"))
for i, nm in enumerate(("100 Hz", "1 kHz", "10 kHz")):
    pass
for i, lbl in enumerate(("min", "max")):
    pick = min if lbl == "min" else max
    vals = [pick(r[1][j] for r in rows) for j in range(3)]
    print("%-10s %9.2f %9.2f %9.2f" % (lbl, *vals))
for j, nm in enumerate(("100 Hz", "1 kHz", "10 kHz")):
    w = min(rows, key=lambda r: r[1][j])
    print("worst %-7s %8.2f dB at %s" % (nm, w[1][j], "/".join(w[0])))
w = min(rows, key=lambda r: r[1][3])
print("\nworst rejection anywhere in band: %.2f dB at %s" % (w[1][3], "/".join(w[0])))
f0 = [r[1][4] for r in rows if r[1][4] > 0]
if f0:
    lo = min(rows, key=lambda r: r[1][4] if r[1][4] > 0 else 9e9)
    print("rejection reaches 0 dB between %.4g and %.4g Hz across corners"
          % (min(f0), max(f0)))
    print("  earliest at %s" % "/".join(lo[0]))
PY
