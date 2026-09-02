# CACE characterization

Generates the datasheet in `doc/datasheet/` — the summary shape Tim asked every Chipalooza
project for: one table per netlist source, the same rows in each, unrunnable rows marked
**Skip** rather than dropped.

⛔ **Needs a patched CACE.** Upstream declares a `.spice` template branch and does not
implement it (`err("TODO: Implement substitution for spice templates!")`), and every bench
here is `.spice`. The patch is `chipalooza/tools/cace/0001-ngspice-spice-templates.patch`
against CACE `main` @ `f8772af`. Without it `cace` fails with that message and no explanation.

## Running it

```bash
docker run --rm -v ~/chipdemo:/work -v ~/cace-spice-test:/cace \
  --user $(id -u):$(id -g) -e PYTHONPATH= hpretl/iic-osic-tools:latest --skip bash -lc '
    export PYTHONPATH=
    cd /work/sg13cmos5l_vyges_ip__ldo_capless
    PDK_ROOT=/work/pdks/ihp-open-pdk PDK=ihp-sg13g2 \
    SPICE_USERINIT_DIR=/work/pdks/ihp-open-pdk/ihp-sg13g2/libs.tech/ngspice \
      /cace/.venv-c/bin/cace cace/ldo_capless.yaml --source schematic'
```

⛔ `PDK` is the **base** `ihp-sg13g2`, not the `ihp-sg13cmos5l` overlay the models come from:
the compiled OSDI models live in the base and the PDK's own `.spiceinit` names it as
`$PDK_ROOT/$PDK`. ⛔ `PYTHONPATH` must be cleared — the IIC image sets it globally, which
defeats venv isolation and silently runs the image's own CACE instead of the patched one.

## Four things that cost time here

- 🔑 **CACE netlists the top level as a real `.subckt`**; `sim/run.sh` leaves it commented and
  flat. So the templates **instantiate** the DUT where the `sim/tb_*.spice` benches do not.
  The port order in `dc.spice` is the `.subckt` line of the generated netlist verbatim.
- ⛔ **Emit BASE units.** CACE applies the prefix in `unit:` itself, so a result pre-scaled to
  mV is reported 1000× too large and fails a limit it actually meets.
- ⛔ **An ngspice vector belongs to the plot of the analysis that made it.** A value computed
  after the first `.dc` is unreachable once the second `.dc` opens a new plot — it silently
  emitted one column instead of three. Capture each into a shell variable with `$&` when it
  exists.
- ⚠️ **`wrdata`/`echo` file naming differs by ngspice version** — 26 appends `.data` to an
  extension-less name, 46 does not. Write the suffix explicitly.

## Fidelity

The `.meas` definitions are copied from `sim/tb_ldo_dc.spice` unchanged, and the template
reproduces that bench's numbers exactly — `vo_lo 1.20896`, `vo_hi 1.20922`, `vo_noload
1.20920`, `vo_fullload 1.20894`, identical to `sim/_report_tb_ldo_dc.spice.log`. That is the
point: the datasheet and `chipalooza/tools/report.py` cannot report different numbers for the
same specification.

🔑 **It immediately earned that.** Deriving load regulation from those measurements gives
**0.26 mV**; this repository published **0.38 mV**, which is the *line*-regulation figure
(0.38 mV/V) copied one row down. Corrected in `README.md` and `doc/implementation.md`. The
specification is 20 mV, so nothing about the design changes — but it is a tenth instance of a
published figure that had stopped being re-derived.

## Scope today

Only `dc_regulation` is ported. There is **no layout**, so `layout`, `pex` and `rcx` and every
physical row (area, DRC, LVS, antenna) cannot run — CACE marks such rows Skip, which is what
its schematic-source table does for any schematic-only project. Remaining benches to convert
are listed in `chipalooza/tools/cace/ldo-port-scope.md`; phase margin needs the `script:` hook
so it shares `report.py`'s crossing definition rather than re-deriving it.
