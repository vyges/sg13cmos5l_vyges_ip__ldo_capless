* ldo_hybboost.tpl -- PROTOTYPE. The dv/dt boost with an over-voltage VETO.
*
* Third topology, and it exists because the first two each got half of it right.
*
* ldo_boost.tpl senses dv/dt and responds INSTANTLY -- a capacitor needs no threshold to be
* crossed. It cleared the over-voltage at all 81 transient corners. It failed at five of them
* because an edge detector cannot tell a release from the loop recovering out of a droop, and
* fired against the loop.
*
* ldo_ovboost.tpl senses the ERROR and is perfectly blind to the recovery -- measured, ng sat
* at 3.2999 V for the whole droop window, which is the failure mode gone by construction. But
* on its own it is too slow AND too violent: vfb has to rise ~100 mV before anything happens,
* by which time the output is at 3.2 V and rising at 5.6 V/us, and then a bang-bang
* comparator slams the pass device fully off and the loop rings between -2.4 V and +3.1 V.
*
* 🔑 SO USE EACH FOR WHAT IT IS GOOD AT. The dv/dt path decides HOW HARD and WHEN, with no
* threshold delay. The comparator decides WHETHER, and it only has to be settled before the
* release arrives -- so its speed, the thing that sank it as a standalone, stops mattering.
* XMve and XMpb are in series from vin to eout: current reaches eout only when the output is
* ABOVE its regulation point AND rising quickly.
*
*   startup          comparator says no  -> no injection, whatever the edge does
*                    ⟹ the PGOOD gate is not needed, so PGOOD goes back to being a status
*                      bit and the 1.2 V vddd rail is not in the startup path
*   droop recovery   comparator says no  -> the five-corner failure cannot occur
*   load release     both say yes        -> full dv/dt response, instantly
*
* ⛔ THE DEFECT THIS USED TO HAVE, AND WHAT FIXED IT. XRb originally returned to the shared
* ibias node, so every large excursion at vout pulled current through it and stole from the
* 1 uA reference. Over 81 transient corners that showed up as four driving the output
* NEGATIVE during the load STEP, all at 110 C with res_bcs -- the lowest sheet, which makes
* XRb smaller and the theft larger, at the temperature where the amplifier can least afford
* it. The veto could never have fixed it: it gates injection into eout, while this was a
* disturbance of the bias, upstream of everything.
*
* ⛔ It also is not the output drive, which is what it looked like. Weakening XMve/XMpb
* fivefold moved those corners by under a millivolt (-0.591 V against -0.591 V), and the same
* corner with the vref split but no boost at all returned 0.4322296 V, bit-identical to the
* untouched control. Both had to be ruled out before the bias was.
*
* ✅ XMpl/XMrb give nb a LOCAL replica of that threshold, so the injected charge lands on a
* node nothing else reads. Measured over the same 81 corners:
*
*   at the rail        0, against 81 of 81 with no boost
*   negative droop     0, against 4 with the shared reference and 5 with dv/dt alone
*   worst overshoot    573 mV, at ss/res_bcs/110 C/3.0 V
*   droop at the corners that used to fail   0.4321 V against the control's 0.4322 -- the
*                                            boost no longer perturbs the load step at all
*
* And at the typical corner it is better than every predecessor on every row: 1 to 20 mA
* release at 234 mV against 2083 mV, droop 338.2 mV against the block's own 338.1, PSRR
* unchanged to five figures, startup settling at exactly its final value with no overshoot
* and no gate, Iq 41.5 uA against a 60 uA budget.
*
* ⚠️ THE ONE THING TO WATCH IS PHASE MARGIN, and it is not comfortable. The 243-corner
* minimum is 45.10 deg against a 45 deg specification -- it passes, with no corner below, but
* the block's own margin was 45.62 and each addition has spent some: 46.04 with dv/dt alone,
* 45.49 with the shared reference, 45.10 now. **0.10 deg of slack is not a margin**, and
* anything further added to this node needs to be paid for out of the compensation rather
* than out of what is left here.
*
* Substituted and verified by sim/hybboost.sh.
* --------------------------------------------------------------------------------------
XMbn nbd  ibias vss vss sg13_hv_nmos w=@WBN@ l=1u ng=1 m=1 mm_ok=1
XMbp nbd  nbd   vin vin sg13_hv_pmos w=@WBP@ l=1u ng=1 m=1 mm_ok=1
XMct ptb  nbd   vin vin sg13_hv_pmos w=@WCT@ l=1u ng=1 m=1 mm_ok=1
XMc1 ncd  vfb     ptb vin sg13_hv_pmos w=@WCI@ l=1u ng=1 m=1 mm_ok=1
XMc2 nx   vref_ov ptb vin sg13_hv_pmos w=@WCI@ l=1u ng=1 m=1 mm_ok=1
XMc3 ncd  ncd   vss vss sg13_hv_nmos w=@WCM@ l=1u ng=1 m=1 mm_ok=1
XMc4 nx   ncd   vss vss sg13_hv_nmos w=@WCM@ l=1u ng=1 m=1 mm_ok=1
XMc5 ng   nx    vss vss sg13_hv_nmos w=@WC5@ l=1u ng=1 m=1 mm_ok=1
XMc6 ng   nbd   vin vin sg13_hv_pmos w=@WC6@ l=1u ng=1 m=1 mm_ok=1

* dv/dt front end, unchanged from ldo_boost.tpl -- the sizing that cleared all 81 corners.
* Local threshold reference. ⛔ XRb used to return to the shared ibias node, which is what
* made every large excursion at vout steal from the 1 uA reference -- the four-corner defect
* above. XMrb is a diode-connected replica of the reference device fed by its own mirror leg
* off nbd, so it sits at the same ~0.68 V and XMnb is biased at the same point, but the
* charge XCb pushes through XRb now lands on a node NOTHING ELSE READS.
* ⚠️ It has to be a diode, not a resistor divider: the point is a low impedance that absorbs
* the injected current with a small voltage shift, which a divider would not.
XMpl nbl  nbd   vin vin sg13_hv_pmos w=@WPL@ l=1u ng=1 m=1 mm_ok=1
XMrb nbl  nbl   vss vss sg13_hv_nmos w=@WRB@ l=1u ng=1 m=1 mm_ok=1
XCb  vout nb    cap_cmomf w=@CB@ l=@CB@ mmin=1 mmax=4 subblock=0 m=1 mm_ok=1
XRb  nb   nbl   sub! rhigh w=1u l=@RB@ m=1 b=0 mm_ok=1
XMnb nx2  nb    vss vss sg13_hv_nmos w=@WNB@ l=@LNB@ ng=1 m=1 mm_ok=1
XRnx vin  nx2   sub! rhigh w=1u l=@RNX@ m=1 b=0 mm_ok=1
* Output stack: BOTH must conduct. XMve is the veto (over-voltage), XMpb the drive (edge).
XMve nmid ng    vin  vin sg13_hv_pmos w=@WVE@ l=0.5u ng=1 m=1 mm_ok=1
XMpb eout nx2   nmid vin sg13_hv_pmos w=@WPB@ l=0.5u ng=1 m=1 mm_ok=1
