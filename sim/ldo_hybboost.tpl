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
* ⛔ WHAT THIS DOES NOT FIX, AND IT IS THE REMAINING DEFECT. XCb couples vout onto nb, and
* nb is biased at the shared ibias node through XRb -- so every large excursion at vout pulls
* current through XRb and perturbs the 1 uA reference. The veto cannot help: it gates
* INJECTION INTO eout, while this is a disturbance of the BIAS, upstream of everything.
*
* Measured, over 81 transient corners: no corner reaches the rail, against 81 of 81 without
* the boost -- but four still drive the output negative during the load STEP, all at 110 C
* with res_bcs. Three separate results say it is this coupling and not the output drive:
*
*   - weakening XMve/XMpb fivefold changes those corners by under a millivolt (-0.591 V
*     against -0.591 V), so the boost is not slamming the output down
*   - the same corner with the vref split but NO boost returns 0.4322296 V, bit-identical to
*     the untouched control, so the divider split is innocent
*   - res_bcs is the lowest sheet, which makes XRb ~25 % smaller and the current it steals
*     ~25 % larger, and 110 C is where the amplifier can least afford to lose bias
*
* ⟹ NEXT: give nb a LOCAL threshold reference instead of the shared ibias node -- a
* diode-connected replica off the XMbn/XMbp leg that already exists here. The disturbance
* then lands on a local node that nothing else depends on. Until that is done this topology
* is not adoptable, however good the typical corner looks.
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
XCb  vout nb    cap_cmomf w=@CB@ l=@CB@ mmin=1 mmax=4 subblock=0 m=1 mm_ok=1
XRb  nb   ibias sub! rhigh w=1u l=@RB@ m=1 b=0 mm_ok=1
XMnb nx2  nb    vss vss sg13_hv_nmos w=@WNB@ l=@LNB@ ng=1 m=1 mm_ok=1
XRnx vin  nx2   sub! rhigh w=1u l=@RNX@ m=1 b=0 mm_ok=1
* Output stack: BOTH must conduct. XMve is the veto (over-voltage), XMpb the drive (edge).
XMve nmid ng    vin  vin sg13_hv_pmos w=@WVE@ l=0.5u ng=1 m=1 mm_ok=1
XMpb eout nx2   nmid vin sg13_hv_pmos w=@WPB@ l=0.5u ng=1 m=1 mm_ok=1
