#!/bin/sh
# What pitch can the pass-device array actually be built at? Answered by DRC, not assumed.
#
# ⛔ THE SWEEP MUST CONTAIN A FAILING ROW or it proves nothing, and this script exits
# non-zero if every row comes back clean. A resistor-pitch sweep in this project once
# returned 0 violations at every pitch because the deck arguments were guessed and the deck
# never read the layout.
#
# ⚠️ OVERLAP IS THE WRONG FALSIFICATION -- learned here, 2026-09-17. Placing identical devices
# ON TOP of each other produced ZERO violations, because coincident geometry MERGES into
# shapes that still satisfy every width and spacing rule. Overlapping two transistors is an
# LVS error, not a DRC one. The falsifying case has to be geometry that stays SEPARATE and
# too close: a small POSITIVE gap.
#
# ⛔ AND COUNT VIOLATIONS FROM <items>, NOT FROM <name> ELEMENTS. The report database lists
# every rule it knows in a <categories> block whether or not it fired, so grepping rule names
# counts DEFINITIONS and reports the same three rules at every pitch. Parse the items.
#
#   sh tools/passdrc.sh 0.02 0.1 0.3 0.62 1.0 0
set -e
PDK=/pdks/ihp-sg13cmos5l
export KLAYOUT_PATH=$PDK/libs.tech/klayout
DECK=$PDK/libs.tech/klayout/tech/drc/ihp-sg13cmos5l.drc
cd /work
mkdir -p layout
NG=${NG:-1}; COLS=${COLS:-8}; ROWS=${ROWS:-1}
SAWFAIL=no
printf "%-8s %-14s %7s   %s\n" gap bbox items rules
for gap in "$@"; do
  klayout -zz -r tools/layout_pass.py -rd ng=$NG -rd cols=$COLS -rd rows=$ROWS \
          -rd gap=$gap -rd out=/work/layout/p.gds > layout/gen.log 2>&1 || \
          { echo "generate FAILED at gap=$gap"; tail -3 layout/gen.log; exit 2; }
  BB=$(awk '/^bbox/{printf "%.2fx%.1f",$2,$4}' layout/gen.log)
  rm -f /work/layout/p.lyrdb
  klayout -b -r $DECK -rd input=/work/layout/p.gds -rd topcell=pass_array \
          -rd report=/work/layout/p.lyrdb -rd log=/work/layout/p.drc.log > layout/drc.out 2>&1 || true
  [ -f /work/layout/p.lyrdb ] || { echo "NO REPORT DATABASE at gap=$gap -- deck did not run";
                                   tail -5 layout/drc.out; exit 2; }
  OUT=$(python3 - "$gap" "$BB" << 'PY'
import sys, xml.etree.ElementTree as ET
from collections import Counter
gap, bb = sys.argv[1], sys.argv[2]
items = ET.parse("/work/layout/p.lyrdb").getroot().find("items")
n = 0 if items is None else len(items)
c = Counter()
if items is not None:
    for it in items:
        c[it.findtext("category", "?").strip().strip("'")] += 1
rules = " ".join("%s(%d)" % (k, v) for k, v in c.most_common(4)) if n else "clean"
print("%-8s %-14s %7d   %s" % (gap, bb, n, rules))
sys.exit(1 if n else 0)
PY
) && FAILED=no || FAILED=yes
  echo "$OUT"
  [ "$FAILED" = yes ] && SAWFAIL=yes || true
done
if [ "$SAWFAIL" != yes ]; then
  echo
  echo "⛔ EVERY ROW CAME BACK CLEAN, including the tightest. That is not a result."
  echo "   Either the deck is not reading this layout or the sweep never reached an"
  echo "   illegal spacing. Tighten the first gap and re-run before believing any of it."
  exit 2
fi
