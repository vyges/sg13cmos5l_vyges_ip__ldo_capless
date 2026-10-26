v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
E {}
T {ldo_fbtrim -- feedback divider + 5-bit binary-weighted trim} -100 -700 0 0 0.4 0.4 {}
N 0 -490 0 -440 {lab=vfb}
N 0 -440 0 -400 {lab=vfb}
N 0 -250 0 -290 {lab=t0}
N 0 -290 280 -290 {lab=t0}
N 280 -290 280 -250 {lab=t0}
N 0 -340 0 -290 {lab=t0}
N 0 -290 0 -250 {lab=t0}
N 0 -100 0 -140 {lab=t1}
N 0 -140 280 -140 {lab=t1}
N 280 -140 280 -100 {lab=t1}
N 0 -190 0 -140 {lab=t1}
N 0 -140 0 -100 {lab=t1}
N 280 -190 280 -140 {lab=t1}
N 280 -140 280 -100 {lab=t1}
N 0 50 0 10 {lab=t2}
N 0 10 280 10 {lab=t2}
N 280 10 280 50 {lab=t2}
N 0 -40 0 10 {lab=t2}
N 0 10 0 50 {lab=t2}
N 280 -40 280 10 {lab=t2}
N 280 10 280 50 {lab=t2}
N 0 200 0 160 {lab=t3}
N 0 160 280 160 {lab=t3}
N 280 160 280 200 {lab=t3}
N 0 110 0 160 {lab=t3}
N 0 160 0 200 {lab=t3}
N 280 110 280 160 {lab=t3}
N 280 160 280 200 {lab=t3}
N 0 350 0 310 {lab=t4}
N 0 310 280 310 {lab=t4}
N 280 310 280 350 {lab=t4}
N 0 260 0 310 {lab=t4}
N 0 310 0 350 {lab=t4}
N 280 260 280 310 {lab=t4}
N 280 310 280 350 {lab=t4}
N 640 -440 0 -440 {lab=vfb}
N 0 -440 0 -400 {lab=vfb}
N 640 -220 385 -220 {lab=vtrim0}
N 385 -220 320 -220 {lab=vtrim0}
N 640 -70 385 -70 {lab=vtrim1}
N 385 -70 320 -70 {lab=vtrim1}
N 640 80 385 80 {lab=vtrim2}
N 385 80 320 80 {lab=vtrim2}
N 640 230 385 230 {lab=vtrim3}
N 385 230 320 230 {lab=vtrim3}
N 640 380 385 380 {lab=vtrim4}
N 385 380 320 380 {lab=vtrim4}
C {devices/lab_pin.sym} 0 -250 0 0 {name=l_net_t0 sig_type=std_logic lab=t0}
C {devices/lab_pin.sym} 0 -100 0 0 {name=l_net_t1 sig_type=std_logic lab=t1}
C {devices/lab_pin.sym} 0 50 0 0 {name=l_net_t2 sig_type=std_logic lab=t2}
C {devices/lab_pin.sym} 0 200 0 0 {name=l_net_t3 sig_type=std_logic lab=t3}
C {devices/lab_pin.sym} 0 350 0 0 {name=l_net_t4 sig_type=std_logic lab=t4}
C {sg13cmos5l_pr/rhigh.sym} 0 -520 0 0 {name=Rtop w=1u model=rhigh body=sub! b=0 m=1 mm_ok=1 spiceprefix=X l=212u}
N 0 -550 0 -590 {lab=vout}
C {devices/lab_pin.sym} 0 -590 0 0 {name=l_Rtop_P sig_type=std_logic lab=vout}
C {sg13cmos5l_pr/rhigh.sym} 0 -370 0 0 {name=Rbase w=1u model=rhigh body=sub! b=0 m=1 mm_ok=1 spiceprefix=X l=106u}
C {sg13cmos5l_pr/rhigh.sym} 0 -220 0 0 {name=Rt0 w=1u model=rhigh body=sub! b=0 m=1 mm_ok=1 spiceprefix=X l=6.8u}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} 300 -220 0 1 {name=Msw0 l=0.13u w=20u ng=1 m=1 model=sg13_lv_nmos spiceprefix=X}
N 280 -220 230 -220 {lab=vss}
C {devices/lab_pin.sym} 230 -220 0 1 {name=l_Msw0_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/rhigh.sym} 0 -70 0 0 {name=Rt1 w=1u model=rhigh body=sub! b=0 m=1 mm_ok=1 spiceprefix=X l=13.6u}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} 300 -70 0 1 {name=Msw1 l=0.13u w=20u ng=1 m=1 model=sg13_lv_nmos spiceprefix=X}
N 280 -70 230 -70 {lab=vss}
C {devices/lab_pin.sym} 230 -70 0 1 {name=l_Msw1_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/rhigh.sym} 0 80 0 0 {name=Rt2 w=1u model=rhigh body=sub! b=0 m=1 mm_ok=1 spiceprefix=X l=27.3u}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} 300 80 0 1 {name=Msw2 l=0.13u w=20u ng=1 m=1 model=sg13_lv_nmos spiceprefix=X}
N 280 80 230 80 {lab=vss}
C {devices/lab_pin.sym} 230 80 0 1 {name=l_Msw2_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/rhigh.sym} 0 230 0 0 {name=Rt3 w=1u model=rhigh body=sub! b=0 m=1 mm_ok=1 spiceprefix=X l=54.6u}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} 300 230 0 1 {name=Msw3 l=0.13u w=20u ng=1 m=1 model=sg13_lv_nmos spiceprefix=X}
N 280 230 230 230 {lab=vss}
C {devices/lab_pin.sym} 230 230 0 1 {name=l_Msw3_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/rhigh.sym} 0 380 0 0 {name=Rt4 w=1u model=rhigh body=sub! b=0 m=1 mm_ok=1 spiceprefix=X l=109.1u}
N 0 410 0 450 {lab=vss}
C {devices/lab_pin.sym} 0 450 0 0 {name=l_Rt4_M sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} 300 380 0 1 {name=Msw4 l=0.13u w=20u ng=1 m=1 model=sg13_lv_nmos spiceprefix=X}
N 280 410 280 450 {lab=vss}
C {devices/lab_pin.sym} 280 450 0 0 {name=l_Msw4_S sig_type=std_logic lab=vss}
N 280 380 230 380 {lab=vss}
C {devices/lab_pin.sym} 230 380 0 1 {name=l_Msw4_B sig_type=std_logic lab=vss}
N 0 -550 0 -590 {lab=vout}
C {devices/iopin.sym} 0 -590 0 0 {name=p_vout lab=vout}
C {devices/opin.sym} 640 -440 0 0 {name=p_vfb lab=vfb}
C {devices/iopin.sym} 640 520 0 0 {name=p_vss lab=vss}
C {devices/ipin.sym} 640 -220 0 0 {name=p_vtrim0 lab=vtrim0}
C {devices/ipin.sym} 640 -70 0 0 {name=p_vtrim1 lab=vtrim1}
C {devices/ipin.sym} 640 80 0 0 {name=p_vtrim2 lab=vtrim2}
C {devices/ipin.sym} 640 230 0 0 {name=p_vtrim3 lab=vtrim3}
C {devices/ipin.sym} 640 380 0 0 {name=p_vtrim4 lab=vtrim4}
L 4 -100 -580 140 -580 {dash=8}
L 4 140 -580 140 -320 {dash=8}
L 4 140 -320 -100 -320 {dash=8}
L 4 -100 -320 -100 -580 {dash=8}
T {DIVIDER} -94 -606 0 0 0.3 0.3 {layer=4}
L 4 -100 -300 520 -300 {dash=8}
L 4 520 -300 520 440 {dash=8}
L 4 520 440 -100 440 {dash=8}
L 4 -100 440 -100 -300 {dash=8}
T {5-BIT TRIM (each segment shorted by its switch)} -94 -326 0 0 0.3 0.3 {layer=4}
