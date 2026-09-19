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
C {sg13cmos5l_pr/sg13_hv_pmos.sym} -800 -200 0 0 {name=Mbp l=1u ng=1 m=1 model=sg13_hv_pmos spiceprefix=X w=4u}
C {sg13cmos5l_pr/sg13_hv_pmos.sym} -560 -200 0 0 {name=Mpl l=1u ng=1 m=1 model=sg13_hv_pmos spiceprefix=X w=2u}
C {sg13cmos5l_pr/sg13_hv_nmos.sym} -560 100 0 0 {name=Mrb l=1u ng=1 m=1 model=sg13_hv_nmos spiceprefix=X w=2u}
C {sg13cmos5l_pr/sg13_hv_pmos.sym} -220 -420 0 0 {name=Mct l=1u ng=1 m=1 model=sg13_hv_pmos spiceprefix=X w=4u}
C {sg13cmos5l_pr/sg13_hv_pmos.sym} -360 -200 0 0 {name=Mc1 l=1u ng=1 m=1 model=sg13_hv_pmos spiceprefix=X w=5u}
C {sg13cmos5l_pr/sg13_hv_pmos.sym} -80 -200 0 0 {name=Mc2 l=1u ng=1 m=1 model=sg13_hv_pmos spiceprefix=X w=5u}
C {sg13cmos5l_pr/sg13_hv_nmos.sym} -360 100 0 0 {name=Mc3 l=1u ng=1 m=1 model=sg13_hv_nmos spiceprefix=X w=10u}
C {sg13cmos5l_pr/sg13_hv_nmos.sym} -80 100 0 0 {name=Mc4 l=1u ng=1 m=1 model=sg13_hv_nmos spiceprefix=X w=10u}
C {sg13cmos5l_pr/sg13_hv_pmos.sym} 200 -200 0 0 {name=Mc6 l=1u ng=1 m=1 model=sg13_hv_pmos spiceprefix=X w=2u}
C {sg13cmos5l_pr/sg13_hv_nmos.sym} 200 100 0 0 {name=Mc5 l=1u ng=1 m=1 model=sg13_hv_nmos spiceprefix=X w=10u}
C {sg13cmos5l_pr/cap_cmomf.sym} 520 -420 0 0 {name=Cb model=cap_cmomf mmin=1 mmax=4 spiceprefix=X w=28u l=28u}
C {sg13cmos5l_pr/rhigh.sym} 520 -160 0 0 {name=Rb w=1u model=rhigh body=sub! b=0 m=1 mm_ok=1 spiceprefix=X l=2940u}
C {sg13cmos5l_pr/sg13_hv_nmos.sym} 760 100 0 0 {name=Mnb l=4u ng=1 m=1 model=sg13_hv_nmos spiceprefix=X w=1u}
C {sg13cmos5l_pr/rhigh.sym} 760 -200 0 0 {name=Rnx w=1u model=rhigh body=sub! b=0 m=1 mm_ok=1 spiceprefix=X l=735u}
C {sg13cmos5l_pr/sg13_hv_pmos.sym} 1040 -320 0 0 {name=Mve l=0.5u ng=1 m=1 model=sg13_hv_pmos spiceprefix=X w=40u}
C {sg13cmos5l_pr/sg13_hv_pmos.sym} 1040 -60 0 0 {name=Mpb l=0.5u ng=1 m=1 model=sg13_hv_pmos spiceprefix=X w=20u}
C {devices/ipin.sym} -1150 -300 0 0 {name=p_vout lab=vout}
C {devices/ipin.sym} -1150 -240 0 0 {name=p_vfb lab=vfb}
C {devices/ipin.sym} -1150 -180 0 0 {name=p_vref_ov lab=vref_ov}
C {devices/ipin.sym} -1150 -120 0 0 {name=p_ibias lab=ibias}
C {devices/iopin.sym} -1150 -60 0 0 {name=p_eout lab=eout}
C {devices/iopin.sym} -1150 0 0 0 {name=p_vin lab=vin}
C {devices/iopin.sym} -1150 60 0 0 {name=p_vss lab=vss}
N -820 100 -870 100 {lab=ibias}
N -780 -230 -780 -270 {lab=vin}
N -780 -200 -710 -200 {lab=vin}
N -540 -230 -540 -270 {lab=vin}
N -540 -200 -470 -200 {lab=vin}
N -200 -450 -200 -490 {lab=vin}
N -200 -420 -130 -420 {lab=vin}
N -380 -200 -430 -200 {lab=vfb}
N -340 -200 -270 -200 {lab=vin}
N -100 -200 -150 -200 {lab=vref_ov}
N -60 -200 10 -200 {lab=vin}
N 220 -230 220 -270 {lab=vin}
N 220 -200 290 -200 {lab=vin}
N 520 -450 520 -490 {lab=vout}
N 760 -230 760 -270 {lab=vin}
N 1060 -350 1060 -390 {lab=vin}
N 1060 -320 1130 -320 {lab=vin}
N 1060 -30 1060 10 {lab=eout}
N 1060 -60 1130 -60 {lab=vin}
C {devices/lab_pin.sym} -870 100 0 1 {name=l_Mbn_G sig_type=std_logic lab=ibias}
C {devices/lab_pin.sym} -780 -270 0 0 {name=l_Mbp_S sig_type=std_logic lab=vin}
C {devices/lab_pin.sym} -710 -200 0 0 {name=l_Mbp_B sig_type=std_logic lab=vin}
C {devices/lab_pin.sym} -540 -270 0 0 {name=l_Mpl_S sig_type=std_logic lab=vin}
C {devices/lab_pin.sym} -470 -200 0 0 {name=l_Mpl_B sig_type=std_logic lab=vin}
C {devices/lab_pin.sym} -200 -490 0 0 {name=l_Mct_S sig_type=std_logic lab=vin}
C {devices/lab_pin.sym} -130 -420 0 0 {name=l_Mct_B sig_type=std_logic lab=vin}
C {devices/lab_pin.sym} -430 -200 0 1 {name=l_Mc1_G sig_type=std_logic lab=vfb}
C {devices/lab_pin.sym} -270 -200 0 0 {name=l_Mc1_B sig_type=std_logic lab=vin}
C {devices/lab_pin.sym} -150 -200 0 1 {name=l_Mc2_G sig_type=std_logic lab=vref_ov}
C {devices/lab_pin.sym} 10 -200 0 0 {name=l_Mc2_B sig_type=std_logic lab=vin}
C {devices/lab_pin.sym} 220 -270 0 0 {name=l_Mc6_S sig_type=std_logic lab=vin}
C {devices/lab_pin.sym} 290 -200 0 0 {name=l_Mc6_B sig_type=std_logic lab=vin}
C {devices/lab_pin.sym} 520 -490 0 0 {name=l_Cb_c0 sig_type=std_logic lab=vout}
C {devices/lab_pin.sym} 760 -270 0 0 {name=l_Rnx_P sig_type=std_logic lab=vin}
C {devices/lab_pin.sym} 1060 -390 0 0 {name=l_Mve_S sig_type=std_logic lab=vin}
C {devices/lab_pin.sym} 1130 -320 0 0 {name=l_Mve_B sig_type=std_logic lab=vin}
C {devices/lab_pin.sym} 1060 10 0 0 {name=l_Mpb_D sig_type=std_logic lab=eout}
C {devices/lab_pin.sym} 1130 -60 0 0 {name=l_Mpb_B sig_type=std_logic lab=vin}
N -780 100 -780 190 {lab=vss}
N -780 130 -780 190 {lab=vss}
N -540 100 -540 190 {lab=vss}
N -540 130 -540 190 {lab=vss}
N -340 100 -340 190 {lab=vss}
N -340 130 -340 190 {lab=vss}
N -60 100 -60 190 {lab=vss}
N -60 130 -60 190 {lab=vss}
N 220 100 220 190 {lab=vss}
N 220 130 220 190 {lab=vss}
N 780 100 780 190 {lab=vss}
N 780 130 780 190 {lab=vss}
N -780 190 -540 190 {lab=vss}
N -540 190 -340 190 {lab=vss}
N -340 190 -60 190 {lab=vss}
N -60 190 220 190 {lab=vss}
N 220 190 780 190 {lab=vss}
N -820 -200 -820 -110 {lab=nbd}
N -780 -170 -780 -110 {lab=nbd}
N -780 70 -780 -110 {lab=nbd}
N -580 -200 -580 -110 {lab=nbd}
N -240 -420 -240 -110 {lab=nbd}
N 180 -200 180 -110 {lab=nbd}
N -820 -110 -780 -110 {lab=nbd}
N -780 -110 -580 -110 {lab=nbd}
N -580 -110 -240 -110 {lab=nbd}
N -240 -110 180 -110 {lab=nbd}
N -580 100 -580 20 {lab=nbl}
N -540 -170 -540 20 {lab=nbl}
N -540 70 -540 20 {lab=nbl}
N 520 -130 520 20 {lab=nbl}
N -580 20 -540 20 {lab=nbl}
N -540 20 520 20 {lab=nbl}
N -380 100 -380 -180 {lab=ncd}
N -340 -170 -340 -180 {lab=ncd}
N -340 70 -340 -180 {lab=ncd}
N -100 100 -100 -180 {lab=ncd}
N -380 -180 -340 -180 {lab=ncd}
N -340 -180 -100 -180 {lab=ncd}
N -340 -230 -460 -230 {lab=ptb}
N -200 -390 -460 -390 {lab=ptb}
N -60 -230 -460 -230 {lab=ptb}
N -460 -390 -460 -230 {lab=ptb}
N -60 -170 60 -170 {lab=nx}
N -60 70 60 70 {lab=nx}
N 180 100 60 100 {lab=nx}
N 60 -170 60 70 {lab=nx}
N 60 70 60 100 {lab=nx}
N 220 -170 360 -170 {lab=ng}
N 220 70 360 70 {lab=ng}
N 1020 -320 360 -320 {lab=ng}
N 360 -320 360 -170 {lab=ng}
N 360 -170 360 70 {lab=ng}
N 520 -390 640 -390 {lab=nb}
N 520 -190 640 -190 {lab=nb}
N 740 100 640 100 {lab=nb}
N 640 -390 640 -190 {lab=nb}
N 640 -190 640 100 {lab=nb}
N 760 -170 760 -180 {lab=nx2}
N 780 70 780 -180 {lab=nx2}
N 1020 -60 1020 -180 {lab=nx2}
N 760 -180 780 -180 {lab=nx2}
N 780 -180 1020 -180 {lab=nx2}
N 1060 -290 1060 -90 {lab=nmid}
C {devices/lab_pin.sym} 520 -390 0 0 {name=l_nb sig_type=std_logic lab=nb}
C {devices/lab_pin.sym} -820 -200 0 0 {name=l_nbd sig_type=std_logic lab=nbd}
C {devices/lab_pin.sym} -580 100 0 0 {name=l_nbl sig_type=std_logic lab=nbl}
C {devices/lab_pin.sym} -380 100 0 0 {name=l_ncd sig_type=std_logic lab=ncd}
C {devices/lab_pin.sym} 220 -170 0 0 {name=l_ng sig_type=std_logic lab=ng}
C {devices/lab_pin.sym} 1060 -290 0 0 {name=l_nmid sig_type=std_logic lab=nmid}
C {devices/lab_pin.sym} -60 -170 0 0 {name=l_nx sig_type=std_logic lab=nx}
C {devices/lab_pin.sym} 760 -170 0 0 {name=l_nx2 sig_type=std_logic lab=nx2}
C {devices/lab_pin.sym} -340 -230 0 0 {name=l_ptb sig_type=std_logic lab=ptb}
C {devices/lab_pin.sym} -780 100 0 0 {name=l_vss sig_type=std_logic lab=vss}
