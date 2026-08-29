v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
E {}
T {ldo_erramp -- 5T OTA error amplifier, PMOS input pair (sg13_hv, 3.3 V domain)} -400 -460 0 0 0.4 0.4 {}
T {The input common mode is 0.6 V, set by the reference the trim range requires.
That is below the hv NMOS threshold, so an NMOS pair here never leaves
subthreshold -- it limps at 27 C and fails at -40 C. A PMOS pair sees about
1.8 V of Vsg at the same common mode. Do not 'simplify' this back to an NMOS
pair; the room-temperature bench will not show the problem.} -900 -560 0 0 0.25 0.25 {layer=15}
N -480 -380 -480 -470 {lab=vin}
N -480 -470 -480 -450 {lab=vin}
N -480 -450 -230 -450 {lab=vin}
N -230 -450 -230 -470 {lab=vin}
N -230 -470 -230 -380 {lab=vin}
N -520 -350 -570 -350 {lab=pbias}
N -570 -350 -570 -280 {lab=pbias}
N -570 -280 -480 -280 {lab=pbias}
N -480 -280 -480 -320 {lab=pbias}
N -480 -320 -480 -280 {lab=pbias}
N -480 -280 -480 -20 {lab=pbias}
N -480 -20 -480 20 {lab=pbias}
N -520 -350 -520 -280 {lab=pbias}
N -520 -280 -335 -280 {lab=pbias}
N -335 -280 -335 -350 {lab=pbias}
N -335 -350 -270 -350 {lab=pbias}
N -230 -320 -230 -250 {lab=ptail}
N -230 -250 -80 -250 {lab=ptail}
N -80 -250 -80 -300 {lab=ptail}
N -80 -300 -80 -210 {lab=ptail}
N -80 -210 -80 -300 {lab=ptail}
N -80 -300 -80 -250 {lab=ptail}
N -80 -250 170 -250 {lab=ptail}
N 170 -250 170 -300 {lab=ptail}
N 170 -300 170 -210 {lab=ptail}
N -80 -150 -80 -110 {lab=n3}
N -80 -110 -80 -20 {lab=n3}
N -80 -20 -80 20 {lab=n3}
N -120 50 -170 50 {lab=n3}
N -170 50 -170 -20 {lab=n3}
N -170 -20 -80 -20 {lab=n3}
N -80 -20 -80 20 {lab=n3}
N -120 50 -120 140 {lab=n3}
N -120 140 65 140 {lab=n3}
N 65 140 65 50 {lab=n3}
N 65 50 130 50 {lab=n3}
N 170 -150 170 -110 {lab=eout1}
N 170 -110 170 -20 {lab=eout1}
N 170 -20 170 20 {lab=eout1}
N 170 20 300 -20 {lab=eout1}
N 300 -20 300 50 {lab=eout1}
N 300 50 365 50 {lab=eout1}
N 365 50 430 50 {lab=eout1}
N 470 20 470 -20 {lab=eout}
N 470 -20 470 -280 {lab=eout}
N 470 -280 470 -320 {lab=eout}
N 760 -170 760 -105 {lab=nzc}
N 760 -105 760 -30 {lab=nzc}
N 760 -30 760 10 {lab=nzc}
N -520 -350 -520 -520 {lab=pbias}
N -520 -520 365 -520 {lab=pbias}
N 365 -520 365 -350 {lab=pbias}
N 365 -350 430 -350 {lab=pbias}
N -770 50 -820 50 {lab=ibias}
N -820 50 -820 -20 {lab=ibias}
N -820 -20 -730 -20 {lab=ibias}
N -730 -20 -730 20 {lab=ibias}
N -770 50 -770 140 {lab=ibias}
N -770 140 -585 140 {lab=ibias}
N -585 140 -585 50 {lab=ibias}
N -585 50 -520 50 {lab=ibias}
N -730 80 -730 170 {lab=vss}
N -730 170 -730 200 {lab=vss}
N -730 200 170 200 {lab=vss}
N 170 200 170 170 {lab=vss}
N 170 170 170 80 {lab=vss}
C {devices/lab_pin.sym} -480 -380 0 0 {name=l_net_vin sig_type=std_logic lab=vin}
C {devices/lab_pin.sym} -520 -350 0 0 {name=l_net_pbias sig_type=std_logic lab=pbias}
C {devices/lab_pin.sym} -230 -320 0 0 {name=l_net_ptail sig_type=std_logic lab=ptail}
C {devices/lab_pin.sym} -80 -150 0 0 {name=l_net_n3 sig_type=std_logic lab=n3}
C {devices/lab_pin.sym} 170 -150 0 0 {name=l_net_eout1 sig_type=std_logic lab=eout1}
C {devices/lab_pin.sym} 470 20 0 0 {name=l_net_eout sig_type=std_logic lab=eout}
C {devices/lab_pin.sym} 760 -170 0 0 {name=l_net_nzc sig_type=std_logic lab=nzc}
C {devices/lab_pin.sym} -770 50 0 0 {name=l_net_ibias sig_type=std_logic lab=ibias}
C {devices/lab_pin.sym} -730 80 0 0 {name=l_net_vss sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/sg13_hv_pmos.sym} -500 -350 0 0 {name=Mp0 l=1u ng=1 m=1 model=sg13_hv_pmos spiceprefix=X w=4u}
N -480 -350 -410 -350 {lab=vin}
C {devices/lab_pin.sym} -410 -350 0 0 {name=l_Mp0_B sig_type=std_logic lab=vin}
C {sg13cmos5l_pr/sg13_hv_pmos.sym} -250 -350 0 0 {name=Mtail l=1u ng=1 m=1 model=sg13_hv_pmos spiceprefix=X w=4u}
N -230 -350 -160 -350 {lab=vin}
C {devices/lab_pin.sym} -160 -350 0 0 {name=l_Mtail_B sig_type=std_logic lab=vin}
C {sg13cmos5l_pr/sg13_hv_pmos.sym} -100 -180 0 0 {name=M1 l=1u ng=1 m=1 model=sg13_hv_pmos spiceprefix=X w=20u}
N -120 -180 -170 -180 {lab=vref}
C {devices/lab_pin.sym} -170 -180 0 1 {name=l_M1_G sig_type=std_logic lab=vref}
N -80 -180 -10 -180 {lab=vin}
C {devices/lab_pin.sym} -10 -180 0 0 {name=l_M1_B sig_type=std_logic lab=vin}
C {sg13cmos5l_pr/sg13_hv_pmos.sym} 150 -180 0 0 {name=M2 l=1u ng=1 m=1 model=sg13_hv_pmos spiceprefix=X w=20u}
N 130 -180 80 -180 {lab=vfb}
C {devices/lab_pin.sym} 80 -180 0 1 {name=l_M2_G sig_type=std_logic lab=vfb}
N 170 -180 240 -180 {lab=vin}
C {devices/lab_pin.sym} 240 -180 0 0 {name=l_M2_B sig_type=std_logic lab=vin}
C {sg13cmos5l_pr/sg13_hv_nmos.sym} -100 50 0 0 {name=M3 l=1u ng=1 m=1 model=sg13_hv_nmos spiceprefix=X w=10u}
N -80 80 -80 120 {lab=vss}
C {devices/lab_pin.sym} -80 120 0 0 {name=l_M3_S sig_type=std_logic lab=vss}
N -80 50 -10 50 {lab=vss}
C {devices/lab_pin.sym} -10 50 0 0 {name=l_M3_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/sg13_hv_nmos.sym} 150 50 0 0 {name=M4 l=1u ng=1 m=1 model=sg13_hv_nmos spiceprefix=X w=10u}
N 170 50 240 50 {lab=vss}
C {devices/lab_pin.sym} 240 50 0 0 {name=l_M4_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/sg13_hv_nmos.sym} 450 50 0 0 {name=M5 l=1u ng=1 m=1 model=sg13_hv_nmos spiceprefix=X w=10u}
N 470 80 470 120 {lab=vss}
C {devices/lab_pin.sym} 470 120 0 0 {name=l_M5_S sig_type=std_logic lab=vss}
N 470 50 540 50 {lab=vss}
C {devices/lab_pin.sym} 540 50 0 0 {name=l_M5_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/sg13_hv_pmos.sym} 450 -350 0 0 {name=M6 l=1u ng=1 m=1 model=sg13_hv_pmos spiceprefix=X w=2u}
N 470 -380 470 -420 {lab=vin}
C {devices/lab_pin.sym} 470 -420 0 0 {name=l_M6_S sig_type=std_logic lab=vin}
N 470 -350 540 -350 {lab=vin}
C {devices/lab_pin.sym} 540 -350 0 0 {name=l_M6_B sig_type=std_logic lab=vin}
C {sg13cmos5l_pr/cap_mfringe.sym} 760 -200 0 0 {name=Cm model=cap_mfringe w=102u l=102u mmin=1 mmax=4 spiceprefix=X}
N 760 -230 760 -270 {lab=eout}
C {devices/lab_pin.sym} 760 -270 0 0 {name=l_Cm_c1 sig_type=std_logic lab=eout}
C {sg13cmos5l_pr/rhigh.sym} 760 40 0 0 {name=Rz w=1u l=35.2u model=rhigh body=sub! b=0 m=1 mm_ok=1 spiceprefix=X}
N 760 70 760 110 {lab=eout1}
C {devices/lab_pin.sym} 760 110 0 0 {name=l_Rz_M sig_type=std_logic lab=eout1}
C {sg13cmos5l_pr/sg13_hv_nmos.sym} -500 50 0 0 {name=Mn1 l=1u ng=1 m=1 model=sg13_hv_nmos spiceprefix=X w=2u}
N -480 80 -480 120 {lab=vss}
C {devices/lab_pin.sym} -480 120 0 0 {name=l_Mn1_S sig_type=std_logic lab=vss}
N -480 50 -410 50 {lab=vss}
C {devices/lab_pin.sym} -410 50 0 0 {name=l_Mn1_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/sg13_hv_nmos.sym} -750 50 0 0 {name=Mr l=1u ng=1 m=1 model=sg13_hv_nmos spiceprefix=X w=2u}
N -730 50 -660 50 {lab=vss}
C {devices/lab_pin.sym} -660 50 0 0 {name=l_Mr_B sig_type=std_logic lab=vss}
N -120 -180 -170 -180 {lab=vref}
C {devices/ipin.sym} -170 -180 0 1 {name=p_vref lab=vref}
N 130 -180 80 -180 {lab=vfb}
C {devices/ipin.sym} 80 -180 0 1 {name=p_vfb lab=vfb}
C {devices/ipin.sym} -1000 -300 0 0 {name=p_ibias lab=ibias}
N 470 20 470 -20 {lab=eout}
C {devices/opin.sym} 470 -20 0 0 {name=p_eout lab=eout}
C {devices/iopin.sym} -1000 -240 0 0 {name=p_vin lab=vin}
C {devices/iopin.sym} -1000 -180 0 0 {name=p_vss lab=vss}
