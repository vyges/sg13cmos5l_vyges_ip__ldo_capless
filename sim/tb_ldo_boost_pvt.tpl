* tb_ldo_boost_pvt.tpl -- transient corner template for the slew boost.
*
* ⛔ WHY THIS EXISTS. The boost is a LARGE-SIGNAL circuit: XMpb is off at the operating
* point and is turned on by the edge, so its strength is set by how far XMnb is driven past
* threshold -- which moves with process, temperature and supply far more than a
* small-signal quantity does. The 243-corner AC sweep says the boost costs no phase margin;
* it says nothing at all about whether the boost still FIRES at ss/-40 C.
*
* The precedent is the reason: widening XM6 cleared the release at the typical corner and
* put nine of 243 corners under the phase-margin minimum. A fix verified at one corner is
* not verified.
.lib @M@/cornerMOShv.lib @MOS@
.lib @M@/cornerMOSlv.lib @MOS@
.include @M@/cap_cmomf.lib
.lib @M@/cornerRES.lib @RES@
.include $PDK_ROOT/ihp-sg13cmos5l/libs.ref/sg13cmos5l_stdcell/spice/sg13cmos5l_stdcell.spice
.global sub!
.include ../sim/netlist/ldo_capless.spice
.include ldo_boost.spice
.temp @TEMP@
Vin     vin     0 DC @VIN@
Vrefbg  vref_bg 0 1.2
Vss     vss     0 0
Vsub    sub!    0 0
Vddd    vddd    0 1.2
Ven     en      0 1.2
Vilim   ilim_en 0 0
Ibias   0       ibias DC 1u
Iload   vout    0 PULSE(1m 20m 20u 1u 1u 20u 60u)
Vt0 vtrim0 0 0
Vt1 vtrim1 0 0
Vt2 vtrim2 0 0
Vt3 vtrim3 0 0
Vt4 vtrim4 0 1.2
.control
  tran 5n 60u
  meas tran vpre FIND v(vout) AT=19u
  meas tran ov20 MAX  v(vout) FROM=41u TO=52u
  meas tran vd20 MIN  v(vout) FROM=20u TO=30u
  print vpre ov20 vd20
.endc
.end
