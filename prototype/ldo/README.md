# Capless LDO — feasibility netlist (sg13cmos5l)

`ldo.spice` — capless LDO (PMOS pass `sg13_hv` + 5T OTA + resistive feedback +
20 pF on-chip comp), simulated headless in ngspice (IIC-OSIC-TOOLS container +
mounted PDK).

**Demonstrated (tt / 27 °C / VIN 3.3 V):** Vout 1.199 V; line reg ~0.04 mV/V;
load reg ~6.6 mV (1→20 mA) / ~15 mV (0→48 mA); load-transient droop ~100 mV,
recovers in 3.85 µs, **well-damped (stable)**. Droop is the tunable design target.
This backs the feasibility section of the proposal
([`../../doc/proposal.md`](../../doc/proposal.md), §7).

Run: `ngspice -b ldo.spice` with `PDK` / `PDK_ROOT` set and the PDK mounted, e.g.

```sh
docker run --rm -v $PWD:/work --entrypoint bash \
  hpretl/iic-osic-tools:latest -lc 'cd /work && ngspice -b ldo.spice'
```
