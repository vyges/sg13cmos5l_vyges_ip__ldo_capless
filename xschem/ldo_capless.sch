v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
E {}
T {ldo_capless -- capless LDO, 3.3 V in -> 1.0-1.8 V trimmed out} -1300 -820 0 0 0.4 0.4 {}
T {Signal path: vref_bg (1.2 V harness bandgap) -> ldo_vref halves it to 0.6 V -> ldo_erramp
compares against vfb -> eout drives the ldo_pass PMOS array -> vout -> ldo_fbtrim divides
back to vfb with 5-bit trim.  Cc is the Miller compensation around the pass device; Cout is
the on-chip stabilising capacitor that replaces the external one this topology does without.} -1300 -780 0 0 0.25 0.25 {layer=15}
N -770 -120 -705 -120 {lab=vref}
N -705 -120 -650 -120 {lab=vref}
N -650 -120 -610 -120 {lab=vref}
N -290 0 -170 0 {lab=eout}
N -170 0 -130 0 {lab=eout}
N -290 0 -220 0 {lab=eout}
N -220 0 -220 -370 {lab=eout}
N -220 -370 -200 -370 {lab=eout}
N -200 -370 -200 -330 {lab=eout}
N -200 -270 -200 -205 {lab=vout}
N -200 -205 195 -205 {lab=vout}
N 195 -205 195 0 {lab=vout}
N 195 0 130 0 {lab=vout}
N 130 0 195 0 {lab=vout}
N 195 0 360 0 {lab=vout}
N 360 0 360 20 {lab=vout}
N 360 20 360 60 {lab=vout}
N 130 0 195 0 {lab=vout}
N 195 0 640 0 {lab=vout}
N 640 0 640 50 {lab=vout}
N 640 50 640 90 {lab=vout}
N 250 200 250 10 {lab=vout}
N 250 10 250 0 {lab=vout}
N 250 0 195 0 {lab=vout}
N 195 0 130 0 {lab=vout}
N 410 450 470 450 {lab=vfb}
N 470 450 470 780 {lab=vfb}
N 470 780 -700 780 {lab=vfb}
N -700 780 -700 -40 {lab=vfb}
N -700 -40 -675 -40 {lab=vfb}
N -675 -40 -610 -40 {lab=vfb}
N -1300 -120 -1070 -120 {lab=vref_bg}
N -1070 -120 -1030 -120 {lab=vref_bg}
N 1100 0 195 0 {lab=vout}
N 195 0 130 0 {lab=vout}
N -1300 1060 -1100 1060 {lab=en}
N -1100 1060 -1060 1060 {lab=en}
N 1100 1400 -40 1400 {lab=pgood}
N -40 1400 -40 1100 {lab=pgood}
N -40 1100 -155 1100 {lab=pgood}
N 1100 1160 570 1160 {lab=oc}
N 570 1160 570 1155 {lab=oc}
N 570 1155 430 1155 {lab=oc}
N -300 290 50 290 {lab=vtrim0}
N 50 290 90 290 {lab=vtrim0}
N -300 370 25 370 {lab=vtrim1}
N 25 370 90 370 {lab=vtrim1}
N -300 450 0 450 {lab=vtrim2}
N 0 450 90 450 {lab=vtrim2}
N -300 530 -25 530 {lab=vtrim3}
N -25 530 90 530 {lab=vtrim3}
N -300 610 -50 610 {lab=vtrim4}
N -50 610 90 610 {lab=vtrim4}
C {devices/lab_pin.sym} -770 -120 0 0 {name=l_net_vref sig_type=std_logic lab=vref}
C {devices/lab_pin.sym} -290 0 0 0 {name=l_net_eout sig_type=std_logic lab=eout}
C {devices/lab_pin.sym} 410 450 0 0 {name=l_net_vfb sig_type=std_logic lab=vfb}
C {ldo_vref.sym} -900 -120 0 0 {name=x_vref }
N -860 -30 -860 10 {lab=vref_pg}
C {devices/lab_pin.sym} -860 10 0 0 {name=l_x_vref_vref_pg sig_type=std_logic lab=vref_pg}
N -940 -30 -940 10 {lab=vss}
C {devices/lab_pin.sym} -940 10 0 0 {name=l_x_vref_vss sig_type=std_logic lab=vss}
N -900 -210 -900 -250 {lab=vref_ov}
C {devices/lab_pin.sym} -900 -250 0 0 {name=l_x_vref_vref_ov sig_type=std_logic lab=vref_ov}
C {ldo_erramp.sym} -450 0 0 0 {name=x_amp }
N -610 40 -610 80 {lab=ibias}
C {devices/lab_pin.sym} -610 80 0 0 {name=l_x_amp_ibias sig_type=std_logic lab=ibias}
N -610 120 -610 160 {lab=en_n}
C {devices/lab_pin.sym} -610 160 0 0 {name=l_x_amp_en_n sig_type=std_logic lab=en_n}
N -450 -210 -450 -250 {lab=vin}
C {devices/lab_pin.sym} -450 -250 0 0 {name=l_x_amp_vin sig_type=std_logic lab=vin}
N -450 210 -450 250 {lab=vss}
C {devices/lab_pin.sym} -450 250 0 0 {name=l_x_amp_vss sig_type=std_logic lab=vss}
C {ldo_pass.sym} 0 0 0 0 {name=x_pass }
N 0 -90 0 -130 {lab=vin}
C {devices/lab_pin.sym} 0 -130 0 0 {name=l_x_pass_vin sig_type=std_logic lab=vin}
C {ldo_fbtrim.sym} 250 450 0 0 {name=x_fb }
N 250 700 250 740 {lab=vss}
C {devices/lab_pin.sym} 250 740 0 0 {name=l_x_fb_vss sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/cap_cmomf.sym} -200 -300 0 0 {name=Cc model=cap_cmomf mmin=1 mmax=4 spiceprefix=X w=69.15u l=40u}
C {ldo_boost.sym} 1000 -300 0 0 {name=x_boost }
N 855 -420 855 -460 {lab=vout}
C {devices/lab_pin.sym} 855 -460 0 0 {name=l_x_boost_vout sig_type=std_logic lab=vout}
N 855 -340 855 -380 {lab=vfb}
C {devices/lab_pin.sym} 855 -380 0 0 {name=l_x_boost_vfb sig_type=std_logic lab=vfb}
N 855 -260 855 -220 {lab=vref_ov}
C {devices/lab_pin.sym} 855 -220 0 0 {name=l_x_boost_vref_ov sig_type=std_logic lab=vref_ov}
N 855 -180 855 -140 {lab=ibias}
C {devices/lab_pin.sym} 855 -140 0 0 {name=l_x_boost_ibias sig_type=std_logic lab=ibias}
N 1145 -300 1215 -300 {lab=eout}
C {devices/lab_pin.sym} 1215 -300 0 0 {name=l_x_boost_eout sig_type=std_logic lab=eout}
N 1000 -510 1000 -550 {lab=vin}
C {devices/lab_pin.sym} 1000 -550 0 0 {name=l_x_boost_vin sig_type=std_logic lab=vin}
N 1000 -90 1000 -50 {lab=vss}
C {devices/lab_pin.sym} 1000 -50 0 0 {name=l_x_boost_vss sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/sg13_hv_nmos.sym} 620 120 0 0 {name=Mpre l=1u w=20u ng=1 m=1 model=sg13_hv_nmos spiceprefix=X}
N 600 120 550 120 {lab=ibias}
C {devices/lab_pin.sym} 550 120 0 1 {name=l_Mpre_G sig_type=std_logic lab=ibias}
N 640 150 640 190 {lab=vss}
C {devices/lab_pin.sym} 640 190 0 0 {name=l_Mpre_S sig_type=std_logic lab=vss}
N 640 120 710 120 {lab=vss}
C {devices/lab_pin.sym} 710 120 0 0 {name=l_Mpre_B sig_type=std_logic lab=vss}
C {ldo_enable.sym} -900 1100 0 0 {name=x_en }
N -740 1140 -740 1180 {lab=en_n}
C {devices/lab_pin.sym} -740 1180 0 0 {name=l_x_en_en_n sig_type=std_logic lab=en_n}
N -1060 1140 -1060 1180 {lab=ibias}
C {devices/lab_pin.sym} -1060 1180 0 0 {name=l_x_en_ibias sig_type=std_logic lab=ibias}
N -740 1060 -740 1020 {lab=eout}
C {devices/lab_pin.sym} -740 1020 0 0 {name=l_x_en_eout sig_type=std_logic lab=eout}
N -950 970 -950 930 {lab=vin}
C {devices/lab_pin.sym} -950 930 0 0 {name=l_x_en_vin sig_type=std_logic lab=vin}
N -850 970 -850 930 {lab=vddd}
C {devices/lab_pin.sym} -850 930 0 0 {name=l_x_en_vddd sig_type=std_logic lab=vddd}
N -900 1230 -900 1270 {lab=vss}
C {devices/lab_pin.sym} -900 1270 0 0 {name=l_x_en_vss sig_type=std_logic lab=vss}
C {ldo_pgood.sym} -300 1100 0 0 {name=x_pg }
N -445 1020 -445 980 {lab=vfb}
C {devices/lab_pin.sym} -445 980 0 0 {name=l_x_pg_vfb sig_type=std_logic lab=vfb}
N -445 1100 -495 1100 {lab=vref_pg}
C {devices/lab_pin.sym} -495 1100 0 1 {name=l_x_pg_vpg sig_type=std_logic lab=vref_pg}
N -445 1180 -445 1220 {lab=ibias}
C {devices/lab_pin.sym} -445 1220 0 0 {name=l_x_pg_ibias sig_type=std_logic lab=ibias}
N -300 930 -300 890 {lab=vddd}
C {devices/lab_pin.sym} -300 890 0 0 {name=l_x_pg_vddd sig_type=std_logic lab=vddd}
N -300 1270 -300 1310 {lab=vss}
C {devices/lab_pin.sym} -300 1310 0 0 {name=l_x_pg_vss sig_type=std_logic lab=vss}
C {ldo_ilim.sym} 300 1100 0 0 {name=x_il }
N 430 1045 430 1005 {lab=eout}
C {devices/lab_pin.sym} 430 1005 0 0 {name=l_x_il_eout sig_type=std_logic lab=eout}
N 170 1180 170 1220 {lab=vout}
C {devices/lab_pin.sym} 170 1220 0 0 {name=l_x_il_vout sig_type=std_logic lab=vout}
N 170 1020 170 980 {lab=ibias}
C {devices/lab_pin.sym} 170 980 0 0 {name=l_x_il_ibias sig_type=std_logic lab=ibias}
N 170 1100 120 1100 {lab=ilim_en}
C {devices/lab_pin.sym} 120 1100 0 1 {name=l_x_il_ilim_en sig_type=std_logic lab=ilim_en}
N 260 930 260 890 {lab=vin}
C {devices/lab_pin.sym} 260 890 0 0 {name=l_x_il_vin sig_type=std_logic lab=vin}
N 340 930 340 890 {lab=vddd}
C {devices/lab_pin.sym} 340 890 0 0 {name=l_x_il_vddd sig_type=std_logic lab=vddd}
N 300 1270 300 1310 {lab=vss}
C {devices/lab_pin.sym} 300 1310 0 0 {name=l_x_il_vss sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/cap_cmomf.sym} 360 90 0 0 {name=Cout model=cap_cmomf mmin=1 mmax=4 spiceprefix=X w=125u l=125u}
N 360 120 360 160 {lab=vss}
C {devices/lab_pin.sym} 360 160 0 0 {name=l_Cout_c1 sig_type=std_logic lab=vss}
C {devices/iopin.sym} -1300 -520 0 0 {name=p_vin lab=vin}
C {devices/iopin.sym} 1100 0 0 0 {name=p_vout lab=vout}
C {devices/ipin.sym} -1300 -120 0 0 {name=p_vref_bg lab=vref_bg}
C {devices/ipin.sym} -1300 -440 0 0 {name=p_ibias lab=ibias}
C {devices/ipin.sym} -1300 1060 0 0 {name=p_en lab=en}
C {devices/iopin.sym} -1300 -480 0 0 {name=p_vddd lab=vddd}
C {devices/iopin.sym} -1300 1560 0 0 {name=p_vss lab=vss}
C {devices/opin.sym} 1100 1400 0 0 {name=p_pgood lab=pgood}
C {devices/ipin.sym} -1300 1480 0 0 {name=p_ilim_en lab=ilim_en}
C {devices/opin.sym} 1100 1160 0 0 {name=p_oc lab=oc}
C {devices/ipin.sym} -300 290 0 0 {name=p_vtrim0 lab=vtrim0}
C {devices/ipin.sym} -300 370 0 0 {name=p_vtrim1 lab=vtrim1}
C {devices/ipin.sym} -300 450 0 0 {name=p_vtrim2 lab=vtrim2}
C {devices/ipin.sym} -300 530 0 0 {name=p_vtrim3 lab=vtrim3}
C {devices/ipin.sym} -300 610 0 0 {name=p_vtrim4 lab=vtrim4}
L 4 -1080 -260 -720 -260 {dash=8}
L 4 -720 -260 -720 80 {dash=8}
L 4 -720 80 -1080 80 {dash=8}
L 4 -1080 80 -1080 -260 {dash=8}
T {REFERENCE} -1074 -286 0 0 0.3 0.3 {layer=4}
L 4 -680 -420 500 -420 {dash=8}
L 4 500 -420 500 820 {dash=8}
L 4 500 820 -680 820 {dash=8}
L 4 -680 820 -680 -420 {dash=8}
T {REGULATION LOOP} -674 -446 0 0 0.3 0.3 {layer=4}
L 4 720 -560 1260 -560 {dash=8}
L 4 1260 -560 1260 -40 {dash=8}
L 4 1260 -40 720 -40 {dash=8}
L 4 720 -40 720 -560 {dash=8}
T {SLEW BOOST} 726 -586 0 0 0.3 0.3 {layer=4}
L 4 540 20 760 20 {dash=8}
L 4 760 20 760 200 {dash=8}
L 4 760 200 540 200 {dash=8}
L 4 540 200 540 20 {dash=8}
T {PRELOAD} 546 -6 0 0 0.3 0.3 {layer=4}
L 4 -1100 880 620 880 {dash=8}
L 4 620 880 620 1340 {dash=8}
L 4 620 1340 -1100 1340 {dash=8}
L 4 -1100 1340 -1100 880 {dash=8}
T {SUPERVISORY (enable, power-good, current limit)} -1094 854 0 0 0.3 0.3 {layer=4}
