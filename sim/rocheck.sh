#!/bin/sh
# rocheck -- DIAGNOSTIC. Does raising ro move the loop gain AT ALL, and WHERE in frequency?
#
# The cascode question turns entirely on this. Scaling W and L together raises ro with L
# while gm follows W/L and stays put. Three outcomes, and they mean different things:
#   - DC gain rises ~= the ro ratio, 1 kHz does not  -> ro is real but has expired by 1 kHz.
#     A cascode pulls the same lever and cannot help the PSRR spec. Negative result STANDS.
#   - DC gain rises AND 1 kHz rises                  -> ro IS the lever; a cascode is worth building.
#   - DC gain does NOT rise                          -> the substitution never raised ro and the
#     whole x1/x2/x4 sweep tested nothing.  ⛔ That outcome VOIDS the committed conclusion.
#
# ⛔ The x1 row is the integrity check, not filler: it must reproduce the published
# 82.47 dB loop gain / 35.07 dB PSRR / 338.2 mV droop. If it does not, this environment is
# not the one those numbers came from and nothing here is comparable to them.
#
# ============================ WHAT THIS FOUND ============================
#
# ✅ ro IS REAL AND IT EXPIRES BELOW 100 Hz. 4x L raised the DC gain 11.12 dB against the
# 12.0 dB predicted, and moved the dominant pole 19.55 -> 5.96 Hz -- the same factor, in the
# opposite direction. Above the pole the two cancel and the gain is gm/C, with no ro in it.
# At 1 kHz, 51x above the pole, 4x the device size is worth +0.69 dB.
#
# ⟹ A cascode pulls exactly this lever, so it buys gain at 1 Hz and nothing at 1 kHz, which
# is where the PSRR specification is. Recorded in full in tb_ldo_psrr.spice.
#
# Run: the benches need the IHP PDK, so this runs inside the sim container with the repo on
# /work and the PDK on /pdks:
#
#   docker run --rm -v <repo>:/work -v <ihp-open-pdk>:/pdks:ro -u $(id -u):$(id -g) \
#     ghcr.io/vyges-tools/vyges-iic-osic-tools:iic-latest-loom0.1.14 --skip \
#     bash -lc 'sh /work/sim/rocheck.sh'
#
# ⚠️ PDK=ihp-sg13cmos5l here, not the ihp-sg13g2 that run.sh defaults to: on the PDK tree
# this was measured against, the cap_cmomf OSDI model resolves under the cmos5l variant only,
# and under the base it fails with "Unable to find definition of model cap_cmomf_mod" AFTER
# netlisting has already succeeded -- which looks like a netlist bug and is not one.
set -e
export PDK_ROOT=/pdks PDK=ihp-sg13cmos5l
export SPICE_USERINIT_DIR=$PDK_ROOT/$PDK/libs.tech/ngspice
# Scratch inside ONE container invocation; a second `docker run` would not see it.
W=$(mktemp -d); export W
trap "rm -rf $W" EXIT
cd "$(dirname "$0")"
cp netlist/ldo_capless.spice $W/ro_keep.spice
trap "cp $W/ro_keep.spice netlist/ldo_capless.spice; awk '/^\\.subckt/{p=1} p' netlist/ldo_capless.spice > ldo_cells.spice; rm -rf $W" EXIT
for k in 1 4; do
  cp $W/ro_keep.spice netlist/ldo_capless.spice
  w1=$((5*k)); w3=$((10*k))
  sed -i "s|^XM1 n3 vref ptail vin sg13_hv_pmos w=[0-9.]*u l=[0-9.]*u|XM1 n3 vref ptail vin sg13_hv_pmos w=${w1}u l=${k}u|" netlist/ldo_capless.spice
  sed -i "s|^XM2 eout1 vfb ptail vin sg13_hv_pmos w=[0-9.]*u l=[0-9.]*u|XM2 eout1 vfb ptail vin sg13_hv_pmos w=${w1}u l=${k}u|" netlist/ldo_capless.spice
  sed -i "s|^XM3 n3 n3 vss vss sg13_hv_nmos w=[0-9.]*u l=[0-9.]*u|XM3 n3 n3 vss vss sg13_hv_nmos w=${w3}u l=${k}u|" netlist/ldo_capless.spice
  sed -i "s|^XM4 eout1 n3 vss vss sg13_hv_nmos w=[0-9.]*u l=[0-9.]*u|XM4 eout1 n3 vss vss sg13_hv_nmos w=${w3}u l=${k}u|" netlist/ldo_capless.spice
  # ⛔ A check that cannot fail proves nothing: confirm all four took, by the NEW length.
  n=$(grep -cE "^XM[1234] .* (sg13_hv_pmos|sg13_hv_nmos) w=[0-9]*u l=${k}u" netlist/ldo_capless.spice)
  [ "$n" = 4 ] || { echo "FAILED substitution k=$k (matched $n of 4)"; exit 2; }
  awk "/^\.subckt/{p=1} p" netlist/ldo_capless.spice > ldo_cells.spice
  rm -f loop_001m.csv
  ngspice -b tb_ldo_ac.spice   > $W/ac_$k.log   2>&1 || true
  ngspice -b tb_ldo_psrr.spice > $W/psrr_$k.log 2>&1 || true
  ngspice -b tb_ldo_perf.spice > $W/perf_$k.log 2>&1 || true
  [ -f loop_001m.csv ] || { echo "k=$k: no loop_001m.csv written"; exit 2; }
  cp loop_001m.csv $W/loop_$k.csv
done
python3 - << "PY"
import numpy as np, re, os
W = os.environ["W"]
def g(tag, path):
    t = open(path, errors="ignore").read().replace("\r", "\n")
    m = re.search(r"^%s\s*=?\s*([-0-9.eE+]+)" % tag, t, re.M)
    return float(m.group(1)) if m else float("nan")
print("BASELINE INTEGRITY (x1 must match the published numbers)")
print("  %-16s %12s %12s" % ("", "measured", "published"))
print("  %-16s %12.2f %12s" % ("PSRR @1 kHz dB", -g("p1k", W + "/psrr_1.log"), "35.07"))
pre, dr = g("vo_pre", W + "/perf_1.log"), g("vo_droop", W + "/perf_1.log")
print("  %-16s %12.1f %12s" % ("droop mV", (pre - dr) * 1000, "338.2"))
a = np.loadtxt(W + "/loop_1.csv"); b = np.loadtxt(W + "/loop_4.csv")
print("  %-16s %12.2f %12s" % ("loop gain @1k dB", np.interp(1e3, a[:, 0], a[:, 1]), "82.47"))
print("\nLOOP GAIN vs FREQUENCY, 1 mA load (dB)")
print("  %-12s %10s %10s %9s" % ("f Hz", "x1", "x4 (ro up ~4x)", "delta"))
for f in [a[0, 0], 10, 100, 1e3, 1e4, 1e5, 1e6]:
    print("  %-12.0f %10.2f %10.2f %+9.2f"
          % (f, np.interp(f, a[:, 0], a[:, 1]), np.interp(f, b[:, 0], b[:, 1]),
             np.interp(f, b[:, 0], b[:, 1]) - np.interp(f, a[:, 0], a[:, 1])))
print("\n  4x L raises ro ~4x = +12.0 dB. That is what DC gain must rise by if the lever works.")
PY
