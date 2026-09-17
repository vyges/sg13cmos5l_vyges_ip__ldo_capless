#!/bin/sh
# Reproduce every simulated number in this repository from a clean clone.
#
# Netlists the xschem hierarchy and runs the testbenches. Requires an environment
# with xschem, ngspice and the ihp-sg13cmos5l PDK under $PDK_ROOT (any IIC-OSIC-TOOLS
# derived container provides this; we use ghcr.io/vyges-tools/vyges-iic-osic-tools).
#
#   sh sim/run.sh
#
# Exit status is the verdict: 0 every bench ran, non-zero one or more failed.
cd "$(dirname "$0")/.." || exit 2

# PDK location. Every testbench references `$PDK_ROOT` rather than a fixed path, and
# ngspice expands environment variables in .include/.lib itself -- so this has to be
# EXPORTED, not merely set, and it has to be the bare `$PDK_ROOT` form: ngspice reads
# `${PDK_ROOT}` as a variable literally named `{PDK_ROOT}` and fails.
#
#   sh sim/run.sh                              # /foss/pdks, any IIC-OSIC-TOOLS container
#   PDK_ROOT=/path/to/pdks sh sim/run.sh       # anywhere else
#
# 🔑 TWO PDKs have to sit under the same root, and this is not obvious from our netlists:
# the models and stdcells come from the ihp-sg13cmos5l OVERLAY, but the compiled OSDI
# models (psp103, r3_cmc, mosvar) live in the ihp-sg13g2 BASE and reach the overlay as
# symlinks. The PDK's own .spiceinit resolves them as `$PDK_ROOT/$PDK`, and ngspice finds
# that file through SPICE_USERINIT_DIR. Point PDK_ROOT at a tree holding only the overlay
# and those links dangle -- observed as `Error opening osdi lib
# "$PDK_ROOT/ihp-sg13g2/.../psp103.osdi"` followed by every bench aborting. The check
# below catches it first and says which PDK is missing.
#
# ℹ️ $PDK may be EITHER variant since the CMOS5L migration into IHP-Open-PDK (2026-09-01):
# the overlay now carries all six OSDI files -- two of its own and four symlinked into the
# base -- so they resolve whichever variant $PDK names, which is what upstream means by
# "use $PDK to switch between the PDKs". Verified at dev@17dc8dc: PDK=ihp-sg13cmos5l runs
# this suite with no OSDI errors and byte-identical measurements. It was NOT true before
# the merge, when neither directory held all six. The default below stays on the base
# because that is what every published number here was measured with.
PDK_ROOT="${PDK_ROOT:-/foss/pdks}"
PDK="${PDK:-ihp-sg13g2}"
export PDK_ROOT PDK
# Set only if the caller has not: outside IIC-OSIC-TOOLS nothing else points ngspice at
# the .spiceinit that loads the OSDI libraries.
# ⛔ "Only if the caller has not" IS A TRAP INSIDE IIC-OSIC-TOOLS, and it cost a full debug
# cycle on 2026-09-17. The container already EXPORTS SPICE_USERINIT_DIR pointing at its own
# bundled /foss/pdks, so this guard sees it set and leaves it alone -- even when the caller
# has explicitly passed a different PDK_ROOT. ngspice then reads the image's .spiceinit,
# loads the image's OSDI models, and every bench dies with
#   Unable to find definition of model cap_cmomf_mod
# AFTER netlisting has already succeeded, which reads as a netlist bug and is not one.
# ⟹ If you override PDK_ROOT, override SPICE_USERINIT_DIR with it:
#   PDK_ROOT=/pdks PDK=ihp-sg13cmos5l SPICE_USERINIT_DIR=/pdks/ihp-sg13cmos5l/libs.tech/ngspice
if [ -z "${SPICE_USERINIT_DIR:-}" ]; then
  SPICE_USERINIT_DIR="$PDK_ROOT/$PDK/libs.tech/ngspice"
  export SPICE_USERINIT_DIR
elif [ "${SPICE_USERINIT_DIR}" != "$PDK_ROOT/$PDK/libs.tech/ngspice" ]; then
  echo "note: SPICE_USERINIT_DIR=$SPICE_USERINIT_DIR does not match PDK_ROOT=$PDK_ROOT/$PDK." >&2
  echo "      ngspice will load OSDI models from the former. If benches fail with" >&2
  echo "      'Unable to find definition of model ...', that is why." >&2
fi
for d in ihp-sg13cmos5l "$PDK"; do
  if [ ! -d "$PDK_ROOT/$d" ]; then
    echo "FAILED: no $d under PDK_ROOT=$PDK_ROOT" >&2
    echo "        PDK_ROOT must contain BOTH the ihp-sg13cmos5l overlay (models," >&2
    echo "        stdcells) and the $PDK base (compiled OSDI models)" >&2
    exit 2
  fi
done
mkdir -p sim/netlist

# ⚠️ No `set -e` around the netlist step: xschem returns non-zero on a perfectly clean
# netlist, so aborting on its status skips everything after it and the benches then read
# whatever was already on disk.
# ⛔ All EIGHT cells, not five. ldo_enable, ldo_pgood and ldo_ilim were missing here while
# the private runner netlisted them, so this script could not have produced the enable,
# power-good or current-limit numbers this repository publishes.
for cell in ldo_vref ldo_erramp ldo_pass ldo_fbtrim ldo_enable ldo_pgood ldo_ilim ldo_boost ldo_capless; do
  echo "netlist: $cell"
  (cd xschem && xschem --rcfile ./xschemrc -n -q -s "$cell.sch" >/dev/null 2>&1)
  if [ ! -s "sim/netlist/$cell.spice" ]; then
    echo "FAILED: xschem produced no netlist for $cell" >&2
    exit 2
  fi
done

# 🔑 The sub-cell .subckt definitions come from the TOP-LEVEL netlist, not from netlisting
# each cell on its own: xschem comments out a cell's own .subckt line when that cell is the
# top, so including one of those puts its devices at top scope instead of defining a
# subcircuit.
# ⛔ This step used to live only in a private runner, so `sim/run.sh` could not reproduce a
# single number from a clean clone -- it stopped at "Could not find include file
# ldo_cells.spice" on the FIRST bench, which under `set -e` also meant the other five were
# never run at all.
awk '/^\.subckt/{p=1} p' sim/netlist/ldo_capless.spice > sim/ldo_cells.spice
if ! grep -q '^\.subckt' sim/ldo_cells.spice; then
  echo "FAILED: no .subckt definitions extracted from sim/netlist/ldo_capless.spice" >&2
  exit 2
fi
echo "cells:   $(grep -c '^\.subckt' sim/ldo_cells.spice) subcircuits -> sim/ldo_cells.spice"

# Run every bench and report a verdict for each. ⚠️ Stopping at the first failure hides the
# state of all the others.
# ⛔ Each bench's output is KEPT, as sim/_report_<bench>.log, because tools/datasheet.py
# reads those logs -- it derives every published figure from them rather than transcribing
# any. Without them `python3 tools/datasheet.py --check` cannot run at all: it stops at
# "no such bench log ... run sim/run.sh first", which is exactly what this script had just
# done. The documented sequence in doc/datasheet/README.md was therefore broken from a
# clean clone, and the drift guard the repository relies on could not be exercised by
# anyone who had not already produced those logs some other way.
# ⚠️ Redirect rather than `tee`: a pipe would report the exit status of tee, and this
# script's verdict is its exit status.
# ⛔ The bench set is NAMED, not globbed. `sim/tb_*.spice` used to be the set, and adding
# diagnostic benches to sim/ silently enrolled them here -- three of them read an input
# that only their own driver generates (m6sweep.sh, m6ac.sh, boost.sh), so from a clean
# clone this script would have run them, failed, and returned a non-zero verdict on a
# design that is fine.
#
# PUBLISHED is what this repository publishes numbers from, and rc is the verdict on those.
# DIAGNOSTIC exists so that a bench cannot be added to sim/ and quietly belong to neither
# list: the guard below fails if one appears that is not accounted for, which is the only
# way a named set stays honest as the directory grows.
PUBLISHED="tb_ldo_ac tb_ldo_dc tb_ldo_ilim_lowvin tb_ldo_perf tb_ldo_status tb_ldo_trim"
DIAGNOSTIC="tb_ldo_overshoot tb_ldo_slewtest tb_ldo_m6sweep tb_ldo_ac_m6 tb_ldo_boost tb_ldo_ovboost tb_ldo_hybboost tb_ldo_droop tb_ldo_psrr"
for tb in sim/tb_*.spice; do
  n=$(basename "$tb" .spice)
  case " $PUBLISHED $DIAGNOSTIC " in
    *" $n "*) ;;
    *) echo "FAILED: sim/$n.spice is in neither PUBLISHED nor DIAGNOSTIC in run.sh." >&2
       echo "        Add it to one: silently skipping a bench is how a suite stops" >&2
       echo "        covering what it appears to cover." >&2
       exit 2 ;;
  esac
done
echo "benches:  $(echo $PUBLISHED | wc -w) published, $(echo $DIAGNOSTIC | wc -w) diagnostic (run by their own drivers)"

rc=0
for n in $PUBLISHED; do
  tb="sim/$n.spice"
  b=$(basename "$tb")
  echo "=== $b ==="
  if (cd sim && ngspice -b "$b" > "_report_$b.log" 2>&1); then :; else
    echo "FAILED: $b" >&2
    rc=1
  fi
  cat "sim/_report_$b.log"
done
exit $rc
