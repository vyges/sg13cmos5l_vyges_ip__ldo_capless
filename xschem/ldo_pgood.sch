v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
E {}
T {ldo_pgood -- power-good comparator (lv domain, 1.2 V logic out)} -400 -460 0 0 0.4 0.4 {}
T {Both inputs sit at ~0.6 V. That is BELOW the hv threshold and comfortably above
the lv one, so this comparator must be lv and must run from the 1.2 V rail --
the mirror image of the error amplifier, whose inputs sit at the same voltage but
which needed a PMOS pair on 3.3 V. Same constraint, opposite answer.} -820 -520 0 0 0.25 0.25 {layer=15}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} -120 -220 0 0 {name=M1 l=0.5u ng=1 m=1 model=sg13_lv_nmos spiceprefix=X w=10u}
N -100 -250 -100 -290 {lab=cn}
C {devices/lab_pin.sym} -100 -290 0 0 {name=l_M1_D sig_type=std_logic lab=cn}
N -140 -220 -190 -220 {lab=vpg}
C {devices/lab_pin.sym} -190 -220 0 1 {name=l_M1_G sig_type=std_logic lab=vpg}
N -100 -190 -100 -150 {lab=ptail}
C {devices/lab_pin.sym} -100 -150 0 0 {name=l_M1_S sig_type=std_logic lab=ptail}
N -100 -220 -30 -220 {lab=vss}
C {devices/lab_pin.sym} -30 -220 0 0 {name=l_M1_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} 180 -220 0 0 {name=M2 l=0.5u ng=1 m=1 model=sg13_lv_nmos spiceprefix=X w=10u}
N 200 -250 200 -290 {lab=cmp}
C {devices/lab_pin.sym} 200 -290 0 0 {name=l_M2_D sig_type=std_logic lab=cmp}
N 160 -220 110 -220 {lab=vfb}
C {devices/lab_pin.sym} 110 -220 0 1 {name=l_M2_G sig_type=std_logic lab=vfb}
N 200 -190 200 -150 {lab=ptail}
C {devices/lab_pin.sym} 200 -150 0 0 {name=l_M2_S sig_type=std_logic lab=ptail}
N 200 -220 270 -220 {lab=vss}
C {devices/lab_pin.sym} 270 -220 0 0 {name=l_M2_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/sg13_lv_pmos.sym} -120 -520 0 0 {name=M3 l=0.5u ng=1 m=1 model=sg13_lv_pmos spiceprefix=X w=10u}
N -100 -490 -100 -450 {lab=cn}
C {devices/lab_pin.sym} -100 -450 0 0 {name=l_M3_D sig_type=std_logic lab=cn}
N -140 -520 -190 -520 {lab=cn}
C {devices/lab_pin.sym} -190 -520 0 1 {name=l_M3_G sig_type=std_logic lab=cn}
N -100 -550 -100 -590 {lab=vddd}
C {devices/lab_pin.sym} -100 -590 0 0 {name=l_M3_S sig_type=std_logic lab=vddd}
N -100 -520 -30 -520 {lab=vddd}
C {devices/lab_pin.sym} -30 -520 0 0 {name=l_M3_B sig_type=std_logic lab=vddd}
C {sg13cmos5l_pr/sg13_lv_pmos.sym} 180 -520 0 0 {name=M4 l=0.5u ng=1 m=1 model=sg13_lv_pmos spiceprefix=X w=10u}
N 200 -490 200 -450 {lab=cmp}
C {devices/lab_pin.sym} 200 -450 0 0 {name=l_M4_D sig_type=std_logic lab=cmp}
N 160 -520 110 -520 {lab=cn}
C {devices/lab_pin.sym} 110 -520 0 1 {name=l_M4_G sig_type=std_logic lab=cn}
N 200 -550 200 -590 {lab=vddd}
C {devices/lab_pin.sym} 200 -590 0 0 {name=l_M4_S sig_type=std_logic lab=vddd}
N 200 -520 270 -520 {lab=vddd}
C {devices/lab_pin.sym} 270 -520 0 0 {name=l_M4_B sig_type=std_logic lab=vddd}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} 30 60 0 0 {name=Mt l=0.5u ng=1 m=1 model=sg13_lv_nmos spiceprefix=X w=4u}
N 50 30 50 -10 {lab=ptail}
C {devices/lab_pin.sym} 50 -10 0 0 {name=l_Mt_D sig_type=std_logic lab=ptail}
N 10 60 -40 60 {lab=ibias}
C {devices/lab_pin.sym} -40 60 0 1 {name=l_Mt_G sig_type=std_logic lab=ibias}
N 50 90 50 130 {lab=vss}
C {devices/lab_pin.sym} 50 130 0 0 {name=l_Mt_S sig_type=std_logic lab=vss}
N 50 60 120 60 {lab=vss}
C {devices/lab_pin.sym} 120 60 0 0 {name=l_Mt_B sig_type=std_logic lab=vss}
C {sg13cmos5l_stdcells/sg13cmos5l_inv_2.sym} 560 -220 0 0 {name=Xout VDD=vddd VSS=vss prefix=sg13cmos5l_}
N 520 -220 470 -220 {lab=cmp}
C {devices/lab_pin.sym} 470 -220 0 1 {name=l_Xout_A sig_type=std_logic lab=cmp}
N 600 -220 670 -220 {lab=pgood}
C {devices/lab_pin.sym} 670 -220 0 0 {name=l_Xout_Y sig_type=std_logic lab=pgood}
N 160 -220 110 -220 {lab=vfb}
C {devices/ipin.sym} 110 -220 0 1 {name=p_vfb lab=vfb}
C {devices/ipin.sym} -900 -300 0 0 {name=p_vpg lab=vpg}
C {devices/ipin.sym} -900 -240 0 0 {name=p_ibias lab=ibias}
C {devices/opin.sym} -900 -180 0 0 {name=p_pgood lab=pgood}
C {devices/iopin.sym} -900 -120 0 0 {name=p_vddd lab=vddd}
C {devices/iopin.sym} -900 -60 0 0 {name=p_vss lab=vss}
