* ldo_ovboost.tpl -- PROTOTYPE over-voltage slew boost. Successor to ldo_boost.tpl.
*
* WHY THE PREVIOUS ONE STOPPED. ldo_boost.tpl senses dv/dt at vout with a high-pass, and an
* edge detector cannot distinguish an output rising because the load was released from an
* output rising because the loop is correcting a droop. Both are rising edges. It cleared
* the over-voltage at all 81 transient corners and then drove the output NEGATIVE at five of
* them -- every one at 110 C with res_bcs, where a lower threshold and a quarter-shorter
* time constant together let it fire on the recovery and fight the loop.
*
* 🔑 THE FIX IS TO SENSE THE ERROR, NOT THE SLEW. vfb against vref says WHERE the output is,
* not which way it is going. During a recovery the output is BELOW its regulation point and
* rising; after a release it is ABOVE it. A comparator with its threshold above vref fires on
* the second and is blind to the first, by construction rather than by timing.
*
* WHAT THAT DELETES, which is most of the previous circuit and all of its coupling:
*   XCb / XRb       gone -- there is no high-pass, so no time constant to get wrong
*   the PGOOD gate  gone -- startup never crosses an ABOVE-nominal threshold, so there is
*                   nothing to gate. PGOOD goes back to being a status bit rather than a
*                   signal the regulator's transient behaviour depends on.
*   the ibias kick  gone -- nothing is clamped, so nothing steals from the 1 uA reference
*   the vddd tie    gone -- no standard cell, no lv device, so the boost no longer needs the
*                   1.2 V rail to bring the block up
* ⟹ It also removes ~2.3 % of slot area: the 1 pF XCb and the 2940 um XRb were the bulk of
* the previous version and the comparator replaces them with eight small devices.
*
* THE THRESHOLD IS RATIOMETRIC, AND THAT IS THE POINT. vref_ov is a tap on the EXISTING
* reference divider, not a second divider: splitting XR1 into XR1a + XR1b with the same total
* length leaves vref untouched to the last digit, costs no extra current, and makes the
* offset a resistor ratio that tracks vref over process and temperature. A second divider
* would neither track nor be free. ⛔ An offset built by skewing the input pair instead --
* the obvious alternative -- is a Vgs mismatch BY DESIGN, and the previous version died at
* corners; an offset that drifts with the corner is the last thing this circuit needs.
*
* @ROV@ sets the offset: the drop across XR1b, referred to vout through the feedback divider
* (ratio ~0.496, so 50 mV at vfb is ~100 mV at vout). 1.2 V across 212 um of XR1 puts roughly
* 2.83 mV on every micron of it.
*
* WHY THERE IS A SECOND STAGE, measured rather than assumed. The first attempt drove XMpb
* straight from the comparator output and it conducted at the operating point: v(nx) came
* back at 1.86 V, Iq at 393 uA against 35.8, and the output 30 mV low while XM5 sank the
* ~357 uA XMpb was pushing into eout. The cause is structural, not a sizing error -- a
* pMOS-input pair's output cannot rise above its own TAIL node, which sits a Vsg below vin.
* XMpb's source IS vin, so a pMOS switch driven from that node can never be turned off, and
* no choice of offset would have changed it.
*
* XMc5/XMc6 are a common-source stage with a pMOS load to vin, so ng reaches vin exactly and
* XMpb's Vsg goes to zero. The pair's inputs are swapped against the first attempt so the
* extra inversion lands the right way round.
*
* POLARITY, since it is the whole circuit:
*   vfb BELOW vref_ov -> XMc1's gate is lower -> conducts harder -> the mirror sinks more
*                        than XMc2 sources -> nx LOW -> XMc5 off -> XMc6 pulls ng to vin
*                        -> XMpb OFF, Vsg = 0. This is the operating point, so XMpb adds NO
*                        gm to the loop -- the property a wider XM6 could not have, and the
*                        entire reason for this topology.
*   vfb ABOVE vref_ov -> XMc2 wins -> nx HIGH -> XMc5 on -> ng LOW -> XMpb on -> eout up
*                        -> pass device off.
*
* The second stage is free at DC: with XMc5 off nothing sinks XMc6's current, so ng sits at
* vin and the branch carries nothing. It draws current only while the boost is firing.
*
* Substituted and verified by sim/ovboost.sh, which also performs the XR1 split and checks it.
* --------------------------------------------------------------------------------------
* Bias leg: a plain DC mirror off the 1 uA reference. ⚠️ This is ordinary use of a bias node
* -- a steady leg, not the transient clamp that cost the previous version 90 mV of droop.
XMbn nbd  ibias vss vss sg13_hv_nmos w=@WBN@ l=1u ng=1 m=1 mm_ok=1
XMbp nbd  nbd   vin vin sg13_hv_pmos w=@WBP@ l=1u ng=1 m=1 mm_ok=1
* Comparator: pMOS input pair, nMOS mirror load. pMOS inputs because both gates sit near
* 0.6 V, where an hv nMOS pair would be at the edge of conduction.
XMct ptb  nbd   vin vin sg13_hv_pmos w=@WCT@ l=1u ng=1 m=1 mm_ok=1
XMc1 ncd  vfb     ptb vin sg13_hv_pmos w=@WCI@ l=1u ng=1 m=1 mm_ok=1
XMc2 nx   vref_ov ptb vin sg13_hv_pmos w=@WCI@ l=1u ng=1 m=1 mm_ok=1
XMc3 ncd  ncd   vss vss sg13_hv_nmos w=@WCM@ l=1u ng=1 m=1 mm_ok=1
XMc4 nx   ncd   vss vss sg13_hv_nmos w=@WCM@ l=1u ng=1 m=1 mm_ok=1
* Second stage -- gets ng all the way to vin, which the comparator node cannot.
XMc5 ng   nx    vss vss sg13_hv_nmos w=@WC5@ l=1u ng=1 m=1 mm_ok=1
XMc6 ng   nbd   vin vin sg13_hv_pmos w=@WC6@ l=1u ng=1 m=1 mm_ok=1
* Output stage: off at the operating point, drives eout up.
XMpb eout ng    vin vin sg13_hv_pmos w=@WPB@ l=0.5u ng=1 m=1 mm_ok=1
