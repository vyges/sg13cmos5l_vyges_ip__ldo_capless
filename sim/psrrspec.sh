#!/bin/sh
# psrrspec -- DIAGNOSTIC. What shape is the PSRR curve REALLY, across the whole band?
#
# The published relation PSRR(f) = 47 dB - |T(f)| is tabulated from 10 Hz to 10 kHz only.
# Above that the block goes ABOVE UNITY -- +1.6 dB at 100 kHz, +4.4 dB at 1 MHz -- and a
# constant 47 dB coupling does not predict that: at 100 kHz the loop still has 29.5 dB, which
# would put rejection at 17.5 dB, not -1.6. So the relation breaks somewhere and this finds
# where.
#
# 🔑 THE DISCRIMINATOR, and it decides how PSRR can honestly be respecified:
#   - coupling CONSTANT at 47 dB across the band -> PSRR is the loop's own -20 dB/dec slope
#     reflected, and the spec is a mask with that shape. One mechanism, already understood.
#   - coupling RISES above 10 kHz -> the high-frequency end is a SECOND mechanism, and a mask
#     fitted to the low end would understate it. It would have to be specified separately.
set -e
export PDK_ROOT=/pdks PDK=ihp-sg13cmos5l
export SPICE_USERINIT_DIR=$PDK_ROOT/$PDK/libs.tech/ngspice
cd "$(dirname "$0")"
W=$(mktemp -d); export W; trap 'rm -rf $W' EXIT
ngspice -b tb_ldo_psrr.spice > $W/psrr.log 2>&1 || true
ngspice -b tb_ldo_ac.spice   > $W/ac.log   2>&1 || true
python3 - << 'PY'
import numpy as np
# psrr_nodes.csv columns: f a_vout | f a_eout | f a_ptail | f a_eout1 | f a_vref
d = np.loadtxt("psrr_nodes.csv")
f, vout, eout = d[:, 0], d[:, 1], d[:, 3]
L = np.loadtxt("loop_001m.csv")
lf, lg, lp = L[:, 0], L[:, 1], L[:, 3]
# ⛔ SIGN. Rejection is -db(vout); the open-loop coupling the loop divides down is
# |T| MINUS rejection, not plus. Getting this backwards reads 183 dB of coupling at 10 Hz.
print("%-10s %9s %9s %11s %9s" % ("f Hz", "PSRR dB", "|T| dB", "coupling", "eout dB"))
print("%-10s %9s %9s %11s %9s" % ("", "(-vout)", "loop gain", "|T|-PSRR", "vs vin"))
for ff in [10, 100, 1e3, 1e4, 3e4, 1e5, 3e5, 1e6, 3e6, 1e7]:
    p_ = -np.interp(ff, f, vout)
    t = np.interp(ff, lf, lg)
    print("%-10.0f %9.2f %9.2f %11.2f %9.2f"
          % (ff, p_, t, t - p_, np.interp(ff, f, eout)))
r = -vout
i = int(np.argmin(r))
print("\nWORST rejection %.2f dB at %.4g Hz" % (r[i], f[i]))
for thr in (40, 30, 20, 10, 0):
    k = np.where(r < thr)[0]
    print("  falls below %3d dB at %.4g Hz" % (thr, f[k[0]])
          if len(k) else "  never below %d dB" % thr)
# 🔑 IS THE ABOVE-UNITY REGION CLOSED-LOOP PEAKING? Reconstruct 1/(1+T) from the MEASURED
# loop magnitude and phase and compare its shape to the measured supply response. Phase
# margin at crossover is not the test -- phase keeps rolling ABOVE crossover, and |1+T| can
# dip below 1 there even when the margin at crossover is comfortable.
# ⛔ The test must be able to FAIL: if the peak of 1/(1+T) lands at a different frequency or
# a different height than the measured PSRR minimum, the mechanism is something else.
T = 10 ** (lg / 20.0) * np.exp(1j * np.radians(lp))
cl = 1.0 / (1.0 + T)                     # closed-loop supply shaping
cl_db = 20 * np.log10(np.abs(cl))
k = np.where(lg <= 0)[0]
if len(k):
    j = k[0]
    ugf = np.interp(0, [lg[j], lg[j-1]], [lf[j], lf[j-1]])
    pm = 180 + np.interp(0, [lg[j], lg[j-1]], [lp[j], lp[j-1]])
    print("\n1 mA loop: UGF %.4g Hz, phase margin %.2f deg" % (ugf, pm))
m = int(np.argmax(cl_db))
print("peak of 1/(1+T):   %+.2f dB at %.4g Hz  (%.2fx UGF)"
      % (cl_db[m], lf[m], lf[m] / ugf))
print("measured PSRR min: %+.2f dB at %.4g Hz  (%.2fx UGF)"
      % (-r[i], f[i], f[i] / ugf))
print("\nOPEN-LOOP coupling backed out as (vout/vin)*(1+T) -- should be SMOOTH if the")
print("bump belongs to 1/(1+T) and not to the coupling path itself:")
h = np.interp(lf, f, vout) - cl_db      # dB: closed response minus the 1/(1+T) shaping
for ff in [1e3, 1e4, 1e5, 3e5, 1e6, 2e6, 3e6]:
    print("  %-9.0f Hz  H_open %+7.2f dB   1/(1+T) %+6.2f dB   vout/vin %+6.2f dB"
          % (ff, np.interp(ff, lf, h), np.interp(ff, lf, cl_db), np.interp(ff, f, vout)))
PY
