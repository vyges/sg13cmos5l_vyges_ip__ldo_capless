v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
E {}
T {ldo_pgood -- power-good comparator (lv domain, 1.2 V logic out)} -820 -800 0 0 0.4 0.4 {}
T {Both inputs sit at ~0.6 V. That is BELOW the hv threshold and comfortably above
the lv one, so this comparator must be lv and must run from the 1.2 V rail --
the mirror image of the error amplifier, whose inputs sit at the same voltage but
which needed a PMOS pair on 3.3 V. Same constraint, opposite answer.} -820 -760 0 0 0.25 0.25 {layer=15}
N -100 -490 -100 -450 {lab=cn}
N -100 -450 -100 -290 {lab=cn}
N -100 -290 -100 -250 {lab=cn}
N 200 -490 200 -450 {lab=cmp}
N 200 -450 200 -290 {lab=cmp}
N 200 -290 200 -250 {lab=cmp}
N -140 -520 -200 -520 {lab=cn}
N -200 -520 -200 -450 {lab=cn}
N -200 -450 -100 -450 {lab=cn}
N -100 -450 -100 -490 {lab=cn}
N -140 -520 -140 -620 {lab=cn}
N -140 -620 95 -620 {lab=cn}
N 95 -620 95 -520 {lab=cn}
N 95 -520 160 -520 {lab=cn}
N -100 -190 -100 -100 {lab=ptail}
N -100 -100 200 -100 {lab=ptail}
N 200 -100 200 -190 {lab=ptail}
N 50 30 50 -10 {lab=ptail}
N 50 -10 50 -100 {lab=ptail}
N 50 -100 -100 -100 {lab=ptail}
N -100 -100 -100 -190 {lab=ptail}
N 200 -250 200 -290 {lab=cmp}
N 200 -290 480 -290 {lab=cmp}
N 480 -290 480 -220 {lab=cmp}
N 480 -220 520 -220 {lab=cmp}
N -500 -220 -205 -220 {lab=vpg}
N -205 -220 -140 -220 {lab=vpg}
N -500 60 -55 60 {lab=ibias}
N -55 60 10 60 {lab=ibias}
N 800 -220 665 -220 {lab=pgood}
N 665 -220 600 -220 {lab=pgood}
C {devices/lab_pin.sym} -100 -490 0 0 {name=l_net_cn sig_type=std_logic lab=cn}
C {devices/lab_pin.sym} 200 -490 0 0 {name=l_net_cmp sig_type=std_logic lab=cmp}
C {devices/lab_pin.sym} -100 -190 0 0 {name=l_net_ptail sig_type=std_logic lab=ptail}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} -120 -220 0 0 {name=M1 l=0.5u ng=1 m=1 model=sg13_lv_nmos spiceprefix=X w=10u}
N -100 -220 -30 -220 {lab=vss}
C {devices/lab_pin.sym} -30 -220 0 0 {name=l_M1_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} 180 -220 0 0 {name=M2 l=0.5u ng=1 m=1 model=sg13_lv_nmos spiceprefix=X w=10u}
N 160 -220 110 -220 {lab=vfb}
C {devices/lab_pin.sym} 110 -220 0 1 {name=l_M2_G sig_type=std_logic lab=vfb}
N 200 -220 270 -220 {lab=vss}
C {devices/lab_pin.sym} 270 -220 0 0 {name=l_M2_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/sg13_lv_pmos.sym} -120 -520 0 0 {name=M3 l=0.5u ng=1 m=1 model=sg13_lv_pmos spiceprefix=X w=10u}
N -100 -550 -100 -590 {lab=vddd}
C {devices/lab_pin.sym} -100 -590 0 0 {name=l_M3_S sig_type=std_logic lab=vddd}
N -100 -520 -30 -520 {lab=vddd}
C {devices/lab_pin.sym} -30 -520 0 0 {name=l_M3_B sig_type=std_logic lab=vddd}
C {sg13cmos5l_pr/sg13_lv_pmos.sym} 180 -520 0 0 {name=M4 l=0.5u ng=1 m=1 model=sg13_lv_pmos spiceprefix=X w=10u}
N 200 -550 200 -590 {lab=vddd}
C {devices/lab_pin.sym} 200 -590 0 0 {name=l_M4_S sig_type=std_logic lab=vddd}
N 200 -520 270 -520 {lab=vddd}
C {devices/lab_pin.sym} 270 -520 0 0 {name=l_M4_B sig_type=std_logic lab=vddd}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} 30 60 0 0 {name=Mt l=0.5u ng=1 m=1 model=sg13_lv_nmos spiceprefix=X w=40u}
N 50 90 50 130 {lab=vss}
C {devices/lab_pin.sym} 50 130 0 0 {name=l_Mt_S sig_type=std_logic lab=vss}
N 50 60 120 60 {lab=vss}
C {devices/lab_pin.sym} 120 60 0 0 {name=l_Mt_B sig_type=std_logic lab=vss}
C {sg13cmos5l_stdcells/sg13cmos5l_inv_2.sym} 560 -220 0 0 {name=Xout VDD=vddd VSS=vss prefix=sg13cmos5l_}
N 160 -220 110 -220 {lab=vfb}
C {devices/ipin.sym} 110 -220 0 1 {name=p_vfb lab=vfb}
C {devices/ipin.sym} -500 -220 0 0 {name=p_vpg lab=vpg}
C {devices/ipin.sym} -500 60 0 0 {name=p_ibias lab=ibias}
C {devices/opin.sym} 800 -220 0 0 {name=p_pgood lab=pgood}
C {devices/iopin.sym} -500 -660 0 0 {name=p_vddd lab=vddd}
C {devices/iopin.sym} -500 200 0 0 {name=p_vss lab=vss}
L 4 -260 -660 300 -660 {dash=8}
L 4 300 -660 300 -430 {dash=8}
L 4 300 -430 -260 -430 {dash=8}
L 4 -260 -430 -260 -660 {dash=8}
T {MIRROR LOAD} -254 -686 0 0 0.3 0.3 {layer=4}
L 4 -260 -300 300 -300 {dash=8}
L 4 300 -300 300 -80 {dash=8}
L 4 300 -80 -260 -80 {dash=8}
L 4 -260 -80 -260 -300 {dash=8}
T {INPUT PAIR} -254 -326 0 0 0.3 0.3 {layer=4}
L 4 -80 -20 160 -20 {dash=8}
L 4 160 -20 160 140 {dash=8}
L 4 160 140 -80 140 {dash=8}
L 4 -80 140 -80 -20 {dash=8}
T {TAIL} -74 -46 0 0 0.3 0.3 {layer=4}
L 4 420 -320 700 -320 {dash=8}
L 4 700 -320 700 -140 {dash=8}
L 4 700 -140 420 -140 {dash=8}
L 4 420 -140 420 -320 {dash=8}
T {OUTPUT} 426 -346 0 0 0.3 0.3 {layer=4}
