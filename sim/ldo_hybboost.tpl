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
* ⚠️ What this does NOT remove is XCb coupling the startup ramp into the ibias node through
* XRb. That was measured at 3.0 V of startup overshoot when the gate was moved out of the nb
* clamp, and it is independent of what gates the output. If startup misbehaves here, that is
* the cause and nb needs a bias that is not the shared reference.
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
