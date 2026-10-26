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
N -840 -170 -840 -130 {lab=nbd}
N -840 -130 -840 30 {lab=nbd}
N -840 30 -840 70 {lab=nbd}
N -880 -200 -930 -200 {lab=nbd}
N -930 -200 -930 -130 {lab=nbd}
N -930 -130 -840 -130 {lab=nbd}
N -840 -130 -840 -170 {lab=nbd}
N -600 -170 -600 -130 {lab=nbl}
N -600 -130 -600 30 {lab=nbl}
N -600 30 -600 70 {lab=nbl}
N -640 100 -690 100 {lab=nbl}
N -690 100 -690 30 {lab=nbl}
N -690 30 -600 30 {lab=nbl}
N -600 30 -600 70 {lab=nbl}
N -200 -390 -200 -350 {lab=ptb}
N -200 -350 -200 -320 {lab=ptb}
N -200 -320 -340 -320 {lab=ptb}
N -340 -320 -340 -230 {lab=ptb}
N -200 -390 -200 -350 {lab=ptb}
N -200 -350 -200 -320 {lab=ptb}
N -200 -320 -60 -320 {lab=ptb}
N -60 -320 -60 -230 {lab=ptb}
N -340 -170 -340 -130 {lab=ncd}
N -340 -130 -340 30 {lab=ncd}
N -340 30 -340 70 {lab=ncd}
N -380 100 -430 100 {lab=ncd}
N -430 100 -430 30 {lab=ncd}
N -430 30 -340 30 {lab=ncd}
N -340 30 -340 70 {lab=ncd}
N -60 -170 -60 -130 {lab=nx}
N -60 -130 -60 30 {lab=nx}
N -60 30 -60 70 {lab=nx}
N 220 -170 220 -130 {lab=ng}
N 220 -130 220 30 {lab=ng}
N 220 30 220 70 {lab=ng}
N 520 -390 520 -325 {lab=nb}
N 520 -325 520 -230 {lab=nb}
N 520 -230 520 -190 {lab=nb}
N 760 -170 760 -105 {lab=nx2}
N 760 -105 780 -105 {lab=nx2}
N 780 -105 780 30 {lab=nx2}
N 780 30 780 70 {lab=nx2}
N 1060 -290 1060 -250 {lab=nmid}
N 1060 -250 1060 -180 {lab=nmid}
N 1060 -180 1060 -90 {lab=nmid}
N -1100 100 -945 100 {lab=ibias}
N -945 100 -880 100 {lab=ibias}
C {devices/lab_pin.sym} -840 -170 0 0 {name=l_net_nbd sig_type=std_logic lab=nbd}
C {devices/lab_pin.sym} -600 -170 0 0 {name=l_net_nbl sig_type=std_logic lab=nbl}
C {devices/lab_pin.sym} -200 -390 0 0 {name=l_net_ptb sig_type=std_logic lab=ptb}
C {devices/lab_pin.sym} -340 -170 0 0 {name=l_net_ncd sig_type=std_logic lab=ncd}
C {devices/lab_pin.sym} -60 -170 0 0 {name=l_net_nx sig_type=std_logic lab=nx}
C {devices/lab_pin.sym} 220 -170 0 0 {name=l_net_ng sig_type=std_logic lab=ng}
C {devices/lab_pin.sym} 520 -390 0 0 {name=l_net_nb sig_type=std_logic lab=nb}
C {devices/lab_pin.sym} 760 -170 0 0 {name=l_net_nx2 sig_type=std_logic lab=nx2}
C {devices/lab_pin.sym} 1060 -290 0 0 {name=l_net_nmid sig_type=std_logic lab=nmid}
C {sg13cmos5l_pr/sg13_hv_nmos.sym} -860 100 0 0 {name=Mbn l=1u ng=1 m=1 model=sg13_hv_nmos spiceprefix=X w=4u}
N -840 130 -840 170 {lab=vss}
C {devices/lab_pin.sym} -840 170 0 0 {name=l_Mbn_S sig_type=std_logic lab=vss}
N -840 100 -770 100 {lab=vss}
C {devices/lab_pin.sym} -770 100 0 0 {name=l_Mbn_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/sg13_hv_pmos.sym} -860 -200 0 0 {name=Mbp l=1u ng=1 m=1 model=sg13_hv_pmos spiceprefix=X w=4u}
N -840 -230 -840 -270 {lab=vin}
C {devices/lab_pin.sym} -840 -270 0 0 {name=l_Mbp_S sig_type=std_logic lab=vin}
N -840 -200 -770 -200 {lab=vin}
C {devices/lab_pin.sym} -770 -200 0 0 {name=l_Mbp_B sig_type=std_logic lab=vin}
C {sg13cmos5l_pr/sg13_hv_pmos.sym} -620 -200 0 0 {name=Mpl l=1u ng=1 m=1 model=sg13_hv_pmos spiceprefix=X w=2u}
N -640 -200 -690 -200 {lab=nbd}
C {devices/lab_pin.sym} -690 -200 0 1 {name=l_Mpl_G sig_type=std_logic lab=nbd}
N -600 -230 -600 -270 {lab=vin}
C {devices/lab_pin.sym} -600 -270 0 0 {name=l_Mpl_S sig_type=std_logic lab=vin}
N -600 -200 -530 -200 {lab=vin}
C {devices/lab_pin.sym} -530 -200 0 0 {name=l_Mpl_B sig_type=std_logic lab=vin}
C {sg13cmos5l_pr/sg13_hv_nmos.sym} -620 100 0 0 {name=Mrb l=1u ng=1 m=1 model=sg13_hv_nmos spiceprefix=X w=2u}
N -600 130 -600 170 {lab=vss}
C {devices/lab_pin.sym} -600 170 0 0 {name=l_Mrb_S sig_type=std_logic lab=vss}
N -600 100 -530 100 {lab=vss}
C {devices/lab_pin.sym} -530 100 0 0 {name=l_Mrb_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/sg13_hv_pmos.sym} -220 -420 0 0 {name=Mct l=1u ng=1 m=1 model=sg13_hv_pmos spiceprefix=X w=4u}
N -240 -420 -290 -420 {lab=nbd}
C {devices/lab_pin.sym} -290 -420 0 1 {name=l_Mct_G sig_type=std_logic lab=nbd}
N -200 -450 -200 -490 {lab=vin}
C {devices/lab_pin.sym} -200 -490 0 0 {name=l_Mct_S sig_type=std_logic lab=vin}
N -200 -420 -130 -420 {lab=vin}
C {devices/lab_pin.sym} -130 -420 0 0 {name=l_Mct_B sig_type=std_logic lab=vin}
C {sg13cmos5l_pr/sg13_hv_pmos.sym} -360 -200 0 0 {name=Mc1 l=1u ng=1 m=1 model=sg13_hv_pmos spiceprefix=X w=5u}
N -380 -200 -430 -200 {lab=vfb}
C {devices/lab_pin.sym} -430 -200 0 1 {name=l_Mc1_G sig_type=std_logic lab=vfb}
N -340 -200 -270 -200 {lab=vin}
C {devices/lab_pin.sym} -270 -200 0 0 {name=l_Mc1_B sig_type=std_logic lab=vin}
C {sg13cmos5l_pr/sg13_hv_pmos.sym} -80 -200 0 0 {name=Mc2 l=1u ng=1 m=1 model=sg13_hv_pmos spiceprefix=X w=5u}
N -100 -200 -150 -200 {lab=vref_ov}
C {devices/lab_pin.sym} -150 -200 0 1 {name=l_Mc2_G sig_type=std_logic lab=vref_ov}
N -60 -200 10 -200 {lab=vin}
C {devices/lab_pin.sym} 10 -200 0 0 {name=l_Mc2_B sig_type=std_logic lab=vin}
C {sg13cmos5l_pr/sg13_hv_nmos.sym} -360 100 0 0 {name=Mc3 l=1u ng=1 m=1 model=sg13_hv_nmos spiceprefix=X w=10u}
N -340 130 -340 170 {lab=vss}
C {devices/lab_pin.sym} -340 170 0 0 {name=l_Mc3_S sig_type=std_logic lab=vss}
N -340 100 -270 100 {lab=vss}
C {devices/lab_pin.sym} -270 100 0 0 {name=l_Mc3_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/sg13_hv_nmos.sym} -80 100 0 0 {name=Mc4 l=1u ng=1 m=1 model=sg13_hv_nmos spiceprefix=X w=10u}
N -100 100 -150 100 {lab=ncd}
C {devices/lab_pin.sym} -150 100 0 1 {name=l_Mc4_G sig_type=std_logic lab=ncd}
N -60 130 -60 170 {lab=vss}
C {devices/lab_pin.sym} -60 170 0 0 {name=l_Mc4_S sig_type=std_logic lab=vss}
N -60 100 10 100 {lab=vss}
C {devices/lab_pin.sym} 10 100 0 0 {name=l_Mc4_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/sg13_hv_pmos.sym} 200 -200 0 0 {name=Mc6 l=1u ng=1 m=1 model=sg13_hv_pmos spiceprefix=X w=2u}
N 180 -200 130 -200 {lab=nbd}
C {devices/lab_pin.sym} 130 -200 0 1 {name=l_Mc6_G sig_type=std_logic lab=nbd}
N 220 -230 220 -270 {lab=vin}
C {devices/lab_pin.sym} 220 -270 0 0 {name=l_Mc6_S sig_type=std_logic lab=vin}
N 220 -200 290 -200 {lab=vin}
C {devices/lab_pin.sym} 290 -200 0 0 {name=l_Mc6_B sig_type=std_logic lab=vin}
C {sg13cmos5l_pr/sg13_hv_nmos.sym} 200 100 0 0 {name=Mc5 l=1u ng=1 m=1 model=sg13_hv_nmos spiceprefix=X w=10u}
N 180 100 130 100 {lab=nx}
C {devices/lab_pin.sym} 130 100 0 1 {name=l_Mc5_G sig_type=std_logic lab=nx}
N 220 130 220 170 {lab=vss}
C {devices/lab_pin.sym} 220 170 0 0 {name=l_Mc5_S sig_type=std_logic lab=vss}
N 220 100 290 100 {lab=vss}
C {devices/lab_pin.sym} 290 100 0 0 {name=l_Mc5_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/cap_cmomf.sym} 520 -420 0 0 {name=Cb model=cap_cmomf mmin=1 mmax=4 spiceprefix=X w=28u l=28u}
N 520 -450 520 -490 {lab=vout}
C {devices/lab_pin.sym} 520 -490 0 0 {name=l_Cb_c0 sig_type=std_logic lab=vout}
C {sg13cmos5l_pr/rhigh.sym} 520 -160 0 0 {name=Rb w=1u model=rhigh body=sub! b=0 m=1 mm_ok=1 spiceprefix=X l=2940u}
N 520 -130 520 -90 {lab=nbl}
C {devices/lab_pin.sym} 520 -90 0 0 {name=l_Rb_M sig_type=std_logic lab=nbl}
C {sg13cmos5l_pr/sg13_hv_nmos.sym} 760 100 0 0 {name=Mnb l=4u ng=1 m=1 model=sg13_hv_nmos spiceprefix=X w=1u}
N 740 100 690 100 {lab=nb}
C {devices/lab_pin.sym} 690 100 0 1 {name=l_Mnb_G sig_type=std_logic lab=nb}
N 780 130 780 170 {lab=vss}
C {devices/lab_pin.sym} 780 170 0 0 {name=l_Mnb_S sig_type=std_logic lab=vss}
N 780 100 850 100 {lab=vss}
C {devices/lab_pin.sym} 850 100 0 0 {name=l_Mnb_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/rhigh.sym} 760 -200 0 0 {name=Rnx w=1u model=rhigh body=sub! b=0 m=1 mm_ok=1 spiceprefix=X l=735u}
N 760 -230 760 -270 {lab=vin}
C {devices/lab_pin.sym} 760 -270 0 0 {name=l_Rnx_P sig_type=std_logic lab=vin}
C {sg13cmos5l_pr/sg13_hv_pmos.sym} 1040 -320 0 0 {name=Mve l=0.5u ng=1 m=1 model=sg13_hv_pmos spiceprefix=X w=40u}
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
N 1060 -60 1130 -60 {lab=vin}
C {devices/lab_pin.sym} 1130 -60 0 0 {name=l_Mpb_B sig_type=std_logic lab=vin}
N 520 -450 520 -490 {lab=vout}
C {devices/ipin.sym} 520 -490 0 0 {name=p_vout lab=vout}
N -380 -200 -430 -200 {lab=vfb}
C {devices/ipin.sym} -430 -200 0 1 {name=p_vfb lab=vfb}
N -100 -200 -150 -200 {lab=vref_ov}
C {devices/ipin.sym} -150 -200 0 1 {name=p_vref_ov lab=vref_ov}
C {devices/ipin.sym} -1100 100 0 0 {name=p_ibias lab=ibias}
N 1060 -30 1060 10 {lab=eout}
C {devices/iopin.sym} 1060 10 0 0 {name=p_eout lab=eout}
C {devices/iopin.sym} -1100 -560 0 0 {name=p_vin lab=vin}
C {devices/iopin.sym} -1100 260 0 0 {name=p_vss lab=vss}
L 4 -960 -280 -500 -280 {dash=8}
L 4 -500 -280 -500 180 {dash=8}
L 4 -500 180 -960 180 {dash=8}
L 4 -960 180 -960 -280 {dash=8}
T {BIAS} -954 -306 0 0 0.3 0.3 {layer=4}
L 4 -440 -500 0 -500 {dash=8}
L 4 0 -500 0 180 {dash=8}
L 4 0 180 -440 180 {dash=8}
L 4 -440 180 -440 -500 {dash=8}
T {OV COMPARATOR (vfb vs vref_ov)} -434 -526 0 0 0.3 0.3 {layer=4}
L 4 120 -280 300 -280 {dash=8}
L 4 300 -280 300 180 {dash=8}
L 4 300 180 120 180 {dash=8}
L 4 120 180 120 -280 {dash=8}
T {VETO} 126 -306 0 0 0.3 0.3 {layer=4}
L 4 440 -500 620 -500 {dash=8}
L 4 620 -500 620 -90 {dash=8}
L 4 620 -90 440 -90 {dash=8}
L 4 440 -90 440 -500 {dash=8}
T {dV/dt SENSE (Cb-Rb)} 446 -526 0 0 0.3 0.3 {layer=4}
L 4 680 -280 860 -280 {dash=8}
L 4 860 -280 860 180 {dash=8}
L 4 860 180 680 180 {dash=8}
L 4 680 180 680 -280 {dash=8}
T {DRIVE} 686 -306 0 0 0.3 0.3 {layer=4}
L 4 960 -400 1160 -400 {dash=8}
L 4 1160 -400 1160 40 {dash=8}
L 4 1160 40 960 40 {dash=8}
L 4 960 40 960 -400 {dash=8}
T {BOOST (Mve x Mpb)} 966 -426 0 0 0.3 0.3 {layer=4}
