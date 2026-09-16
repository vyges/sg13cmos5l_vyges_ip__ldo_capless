v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
E {}
T {ldo_boost -- load-release slew boost -- over-voltage veto x dv/dt drive} -1000 -640 0 0 0.4 0.4 {}
T {Mve and Mpb are IN SERIES from vin to eout. Mve is the veto: it conducts only when
vfb is above vref_ov, i.e. the output is above its regulation point. Mpb is the
drive: it conducts on a fast rising edge at vout. Both are off at the operating
point, so neither adds gm to the regulation loop -- which is the property a wider
XM6 could not have, and the whole reason this cell exists.} -1000 -600 0 0 0.25 0.25 {layer=15}
C {sg13cmos5l_pr/sg13_hv_nmos.sym} -800 100 0 0 {name=Mbn l=1u ng=1 m=1 model=sg13_hv_nmos spiceprefix=X w=4u}
N -780 70 -780 30 {lab=nbd}
C {devices/lab_pin.sym} -780 30 0 0 {name=l_Mbn_D sig_type=std_logic lab=nbd}
N -820 100 -870 100 {lab=ibias}
C {devices/lab_pin.sym} -870 100 0 1 {name=l_Mbn_G sig_type=std_logic lab=ibias}
N -780 130 -780 170 {lab=vss}
C {devices/lab_pin.sym} -780 170 0 0 {name=l_Mbn_S sig_type=std_logic lab=vss}
N -780 100 -710 100 {lab=vss}
C {devices/lab_pin.sym} -710 100 0 0 {name=l_Mbn_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/sg13_hv_pmos.sym} -800 -200 0 0 {name=Mbp l=1u ng=1 m=1 model=sg13_hv_pmos spiceprefix=X w=4u}
N -780 -170 -780 -130 {lab=nbd}
C {devices/lab_pin.sym} -780 -130 0 0 {name=l_Mbp_D sig_type=std_logic lab=nbd}
N -820 -200 -870 -200 {lab=nbd}
C {devices/lab_pin.sym} -870 -200 0 1 {name=l_Mbp_G sig_type=std_logic lab=nbd}
N -780 -230 -780 -270 {lab=vin}
C {devices/lab_pin.sym} -780 -270 0 0 {name=l_Mbp_S sig_type=std_logic lab=vin}
N -780 -200 -710 -200 {lab=vin}
C {devices/lab_pin.sym} -710 -200 0 0 {name=l_Mbp_B sig_type=std_logic lab=vin}
C {sg13cmos5l_pr/sg13_hv_pmos.sym} -560 -200 0 0 {name=Mpl l=1u ng=1 m=1 model=sg13_hv_pmos spiceprefix=X w=2u}
N -540 -170 -540 -130 {lab=nbl}
C {devices/lab_pin.sym} -540 -130 0 0 {name=l_Mpl_D sig_type=std_logic lab=nbl}
N -580 -200 -630 -200 {lab=nbd}
C {devices/lab_pin.sym} -630 -200 0 1 {name=l_Mpl_G sig_type=std_logic lab=nbd}
N -540 -230 -540 -270 {lab=vin}
C {devices/lab_pin.sym} -540 -270 0 0 {name=l_Mpl_S sig_type=std_logic lab=vin}
N -540 -200 -470 -200 {lab=vin}
C {devices/lab_pin.sym} -470 -200 0 0 {name=l_Mpl_B sig_type=std_logic lab=vin}
C {sg13cmos5l_pr/sg13_hv_nmos.sym} -560 100 0 0 {name=Mrb l=1u ng=1 m=1 model=sg13_hv_nmos spiceprefix=X w=2u}
N -540 70 -540 30 {lab=nbl}
C {devices/lab_pin.sym} -540 30 0 0 {name=l_Mrb_D sig_type=std_logic lab=nbl}
N -580 100 -630 100 {lab=nbl}
C {devices/lab_pin.sym} -630 100 0 1 {name=l_Mrb_G sig_type=std_logic lab=nbl}
N -540 130 -540 170 {lab=vss}
C {devices/lab_pin.sym} -540 170 0 0 {name=l_Mrb_S sig_type=std_logic lab=vss}
N -540 100 -470 100 {lab=vss}
C {devices/lab_pin.sym} -470 100 0 0 {name=l_Mrb_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/sg13_hv_pmos.sym} -220 -420 0 0 {name=Mct l=1u ng=1 m=1 model=sg13_hv_pmos spiceprefix=X w=4u}
N -200 -390 -200 -350 {lab=ptb}
C {devices/lab_pin.sym} -200 -350 0 0 {name=l_Mct_D sig_type=std_logic lab=ptb}
N -240 -420 -290 -420 {lab=nbd}
C {devices/lab_pin.sym} -290 -420 0 1 {name=l_Mct_G sig_type=std_logic lab=nbd}
N -200 -450 -200 -490 {lab=vin}
C {devices/lab_pin.sym} -200 -490 0 0 {name=l_Mct_S sig_type=std_logic lab=vin}
N -200 -420 -130 -420 {lab=vin}
C {devices/lab_pin.sym} -130 -420 0 0 {name=l_Mct_B sig_type=std_logic lab=vin}
C {sg13cmos5l_pr/sg13_hv_pmos.sym} -360 -200 0 0 {name=Mc1 l=1u ng=1 m=1 model=sg13_hv_pmos spiceprefix=X w=5u}
N -340 -170 -340 -130 {lab=ncd}
C {devices/lab_pin.sym} -340 -130 0 0 {name=l_Mc1_D sig_type=std_logic lab=ncd}
N -380 -200 -430 -200 {lab=vfb}
C {devices/lab_pin.sym} -430 -200 0 1 {name=l_Mc1_G sig_type=std_logic lab=vfb}
N -340 -230 -340 -270 {lab=ptb}
C {devices/lab_pin.sym} -340 -270 0 0 {name=l_Mc1_S sig_type=std_logic lab=ptb}
N -340 -200 -270 -200 {lab=vin}
C {devices/lab_pin.sym} -270 -200 0 0 {name=l_Mc1_B sig_type=std_logic lab=vin}
C {sg13cmos5l_pr/sg13_hv_pmos.sym} -80 -200 0 0 {name=Mc2 l=1u ng=1 m=1 model=sg13_hv_pmos spiceprefix=X w=5u}
N -60 -170 -60 -130 {lab=nx}
C {devices/lab_pin.sym} -60 -130 0 0 {name=l_Mc2_D sig_type=std_logic lab=nx}
N -100 -200 -150 -200 {lab=vref_ov}
C {devices/lab_pin.sym} -150 -200 0 1 {name=l_Mc2_G sig_type=std_logic lab=vref_ov}
N -60 -230 -60 -270 {lab=ptb}
C {devices/lab_pin.sym} -60 -270 0 0 {name=l_Mc2_S sig_type=std_logic lab=ptb}
N -60 -200 10 -200 {lab=vin}
C {devices/lab_pin.sym} 10 -200 0 0 {name=l_Mc2_B sig_type=std_logic lab=vin}
C {sg13cmos5l_pr/sg13_hv_nmos.sym} -360 100 0 0 {name=Mc3 l=1u ng=1 m=1 model=sg13_hv_nmos spiceprefix=X w=10u}
N -340 70 -340 30 {lab=ncd}
C {devices/lab_pin.sym} -340 30 0 0 {name=l_Mc3_D sig_type=std_logic lab=ncd}
N -380 100 -430 100 {lab=ncd}
C {devices/lab_pin.sym} -430 100 0 1 {name=l_Mc3_G sig_type=std_logic lab=ncd}
N -340 130 -340 170 {lab=vss}
C {devices/lab_pin.sym} -340 170 0 0 {name=l_Mc3_S sig_type=std_logic lab=vss}
N -340 100 -270 100 {lab=vss}
C {devices/lab_pin.sym} -270 100 0 0 {name=l_Mc3_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/sg13_hv_nmos.sym} -80 100 0 0 {name=Mc4 l=1u ng=1 m=1 model=sg13_hv_nmos spiceprefix=X w=10u}
N -60 70 -60 30 {lab=nx}
C {devices/lab_pin.sym} -60 30 0 0 {name=l_Mc4_D sig_type=std_logic lab=nx}
N -100 100 -150 100 {lab=ncd}
C {devices/lab_pin.sym} -150 100 0 1 {name=l_Mc4_G sig_type=std_logic lab=ncd}
N -60 130 -60 170 {lab=vss}
C {devices/lab_pin.sym} -60 170 0 0 {name=l_Mc4_S sig_type=std_logic lab=vss}
N -60 100 10 100 {lab=vss}
C {devices/lab_pin.sym} 10 100 0 0 {name=l_Mc4_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/sg13_hv_pmos.sym} 200 -200 0 0 {name=Mc6 l=1u ng=1 m=1 model=sg13_hv_pmos spiceprefix=X w=2u}
N 220 -170 220 -130 {lab=ng}
C {devices/lab_pin.sym} 220 -130 0 0 {name=l_Mc6_D sig_type=std_logic lab=ng}
N 180 -200 130 -200 {lab=nbd}
C {devices/lab_pin.sym} 130 -200 0 1 {name=l_Mc6_G sig_type=std_logic lab=nbd}
N 220 -230 220 -270 {lab=vin}
C {devices/lab_pin.sym} 220 -270 0 0 {name=l_Mc6_S sig_type=std_logic lab=vin}
N 220 -200 290 -200 {lab=vin}
C {devices/lab_pin.sym} 290 -200 0 0 {name=l_Mc6_B sig_type=std_logic lab=vin}
C {sg13cmos5l_pr/sg13_hv_nmos.sym} 200 100 0 0 {name=Mc5 l=1u ng=1 m=1 model=sg13_hv_nmos spiceprefix=X w=10u}
N 220 70 220 30 {lab=ng}
C {devices/lab_pin.sym} 220 30 0 0 {name=l_Mc5_D sig_type=std_logic lab=ng}
N 180 100 130 100 {lab=nx}
C {devices/lab_pin.sym} 130 100 0 1 {name=l_Mc5_G sig_type=std_logic lab=nx}
N 220 130 220 170 {lab=vss}
C {devices/lab_pin.sym} 220 170 0 0 {name=l_Mc5_S sig_type=std_logic lab=vss}
N 220 100 290 100 {lab=vss}
C {devices/lab_pin.sym} 290 100 0 0 {name=l_Mc5_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/cap_cmomf.sym} 520 -420 0 0 {name=Cb model=cap_cmomf mmin=1 mmax=4 spiceprefix=X w=28u l=28u}
N 520 -450 520 -490 {lab=vout}
C {devices/lab_pin.sym} 520 -490 0 0 {name=l_Cb_c0 sig_type=std_logic lab=vout}
N 520 -390 520 -350 {lab=nb}
C {devices/lab_pin.sym} 520 -350 0 0 {name=l_Cb_c1 sig_type=std_logic lab=nb}
C {sg13cmos5l_pr/rhigh.sym} 520 -160 0 0 {name=Rb w=1u model=rhigh body=sub! b=0 m=1 mm_ok=1 spiceprefix=X l=2940u}
N 520 -190 520 -230 {lab=nb}
C {devices/lab_pin.sym} 520 -230 0 0 {name=l_Rb_P sig_type=std_logic lab=nb}
N 520 -130 520 -90 {lab=nbl}
C {devices/lab_pin.sym} 520 -90 0 0 {name=l_Rb_M sig_type=std_logic lab=nbl}
C {sg13cmos5l_pr/sg13_hv_nmos.sym} 760 100 0 0 {name=Mnb l=4u ng=1 m=1 model=sg13_hv_nmos spiceprefix=X w=1u}
N 780 70 780 30 {lab=nx2}
C {devices/lab_pin.sym} 780 30 0 0 {name=l_Mnb_D sig_type=std_logic lab=nx2}
N 740 100 690 100 {lab=nb}
C {devices/lab_pin.sym} 690 100 0 1 {name=l_Mnb_G sig_type=std_logic lab=nb}
N 780 130 780 170 {lab=vss}
C {devices/lab_pin.sym} 780 170 0 0 {name=l_Mnb_S sig_type=std_logic lab=vss}
N 780 100 850 100 {lab=vss}
C {devices/lab_pin.sym} 850 100 0 0 {name=l_Mnb_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/rhigh.sym} 760 -200 0 0 {name=Rnx w=1u model=rhigh body=sub! b=0 m=1 mm_ok=1 spiceprefix=X l=735u}
N 760 -230 760 -270 {lab=vin}
C {devices/lab_pin.sym} 760 -270 0 0 {name=l_Rnx_P sig_type=std_logic lab=vin}
N 760 -170 760 -130 {lab=nx2}
C {devices/lab_pin.sym} 760 -130 0 0 {name=l_Rnx_M sig_type=std_logic lab=nx2}
C {sg13cmos5l_pr/sg13_hv_pmos.sym} 1040 -320 0 0 {name=Mve l=0.5u ng=1 m=1 model=sg13_hv_pmos spiceprefix=X w=40u}
N 1060 -290 1060 -250 {lab=nmid}
C {devices/lab_pin.sym} 1060 -250 0 0 {name=l_Mve_D sig_type=std_logic lab=nmid}
N 1020 -320 970 -320 {lab=ng}
C {devices/lab_pin.sym} 970 -320 0 1 {name=l_Mve_G sig_type=std_logic lab=ng}
N 1060 -350 1060 -390 {lab=vin}
C {devices/lab_pin.sym} 1060 -390 0 0 {name=l_Mve_S sig_type=std_logic lab=vin}
N 1060 -320 1130 -320 {lab=vin}
C {devices/lab_pin.sym} 1130 -320 0 0 {name=l_Mve_B sig_type=std_logic lab=vin}
C {sg13cmos5l_pr/sg13_hv_pmos.sym} 1040 -60 0 0 {name=Mpb l=0.5u ng=1 m=1 model=sg13_hv_pmos spiceprefix=X w=20u}
N 1060 -30 1060 10 {lab=eout}
C {devices/lab_pin.sym} 1060 10 0 0 {name=l_Mpb_D sig_type=std_logic lab=eout}
N 1020 -60 970 -60 {lab=nx2}
C {devices/lab_pin.sym} 970 -60 0 1 {name=l_Mpb_G sig_type=std_logic lab=nx2}
N 1060 -90 1060 -130 {lab=nmid}
C {devices/lab_pin.sym} 1060 -130 0 0 {name=l_Mpb_S sig_type=std_logic lab=nmid}
N 1060 -60 1130 -60 {lab=vin}
C {devices/lab_pin.sym} 1130 -60 0 0 {name=l_Mpb_B sig_type=std_logic lab=vin}
C {devices/ipin.sym} -1150 -300 0 0 {name=p_vout lab=vout}
C {devices/ipin.sym} -1150 -240 0 0 {name=p_vfb lab=vfb}
C {devices/ipin.sym} -1150 -180 0 0 {name=p_vref_ov lab=vref_ov}
C {devices/ipin.sym} -1150 -120 0 0 {name=p_ibias lab=ibias}
C {devices/iopin.sym} -1150 -60 0 0 {name=p_eout lab=eout}
C {devices/iopin.sym} -1150 0 0 0 {name=p_vin lab=vin}
C {devices/iopin.sym} -1150 60 0 0 {name=p_vss lab=vss}
