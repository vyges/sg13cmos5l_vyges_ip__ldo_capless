v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
E {}
T {ldo_fbtrim -- feedback divider + 5-bit binary-weighted trim} -420 -420 0 0 0.4 0.4 {}
N 0 -490 0 -440 {lab=vfb}
N 0 -440 0 -400 {lab=vfb}
N 0 -250 0 -290 {lab=t0}
N 0 -290 280 -290 {lab=t0}
N 280 -290 280 -250 {lab=t0}
N 0 -190 0 -125 {lab=t1}
N 0 -125 280 -125 {lab=t1}
N 280 -125 280 -100 {lab=t1}
N 280 -100 280 -190 {lab=t1}
N 0 -340 0 -290 {lab=t0}
N 0 -290 0 -250 {lab=t0}
N 0 -100 0 -140 {lab=t1}
N 0 -140 280 -140 {lab=t1}
N 280 -140 280 -100 {lab=t1}
N 0 -40 0 25 {lab=t2}
N 0 25 280 25 {lab=t2}
N 280 25 280 50 {lab=t2}
N 280 50 280 -40 {lab=t2}
N 0 -190 0 -140 {lab=t1}
N 0 -140 0 -100 {lab=t1}
N 0 50 0 10 {lab=t2}
N 0 10 280 10 {lab=t2}
N 280 10 280 50 {lab=t2}
N 0 110 0 175 {lab=t3}
N 0 175 280 175 {lab=t3}
N 280 175 280 200 {lab=t3}
N 280 200 280 110 {lab=t3}
N 0 -40 0 10 {lab=t2}
N 0 10 0 50 {lab=t2}
N 0 200 0 160 {lab=t3}
N 0 160 280 160 {lab=t3}
N 280 160 280 200 {lab=t3}
N 0 260 0 325 {lab=t4}
N 0 325 280 325 {lab=t4}
N 280 325 280 350 {lab=t4}
N 280 350 280 260 {lab=t4}
N 0 110 0 160 {lab=t3}
N 0 160 0 200 {lab=t3}
N 0 350 0 310 {lab=t4}
N 0 310 280 310 {lab=t4}
N 280 310 280 350 {lab=t4}
N 0 410 0 475 {lab=vss}
N 0 475 280 475 {lab=vss}
N 280 475 280 500 {lab=vss}
N 280 500 280 410 {lab=vss}
N 0 260 0 310 {lab=t4}
N 0 310 0 350 {lab=t4}
C {devices/lab_pin.sym} 0 -490 0 0 {name=l_net_vfb sig_type=std_logic lab=vfb}
C {devices/lab_pin.sym} 0 -250 0 0 {name=l_net_t0 sig_type=std_logic lab=t0}
C {devices/lab_pin.sym} 0 -190 0 0 {name=l_net_t1 sig_type=std_logic lab=t1}
C {devices/lab_pin.sym} 0 -40 0 0 {name=l_net_t2 sig_type=std_logic lab=t2}
C {devices/lab_pin.sym} 0 110 0 0 {name=l_net_t3 sig_type=std_logic lab=t3}
C {devices/lab_pin.sym} 0 260 0 0 {name=l_net_t4 sig_type=std_logic lab=t4}
C {devices/lab_pin.sym} 0 410 0 0 {name=l_net_vss sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/rhigh.sym} 0 -520 0 0 {name=Rtop w=1u model=rhigh body=sub! b=0 m=1 mm_ok=1 spiceprefix=X l=212u}
N 0 -550 0 -590 {lab=vout}
C {devices/lab_pin.sym} 0 -590 0 0 {name=l_Rtop_P sig_type=std_logic lab=vout}
C {sg13cmos5l_pr/rhigh.sym} 0 -370 0 0 {name=Rbase w=1u model=rhigh body=sub! b=0 m=1 mm_ok=1 spiceprefix=X l=106u}
C {sg13cmos5l_pr/rhigh.sym} 0 -220 0 0 {name=Rt0 w=1u model=rhigh body=sub! b=0 m=1 mm_ok=1 spiceprefix=X l=6.8u}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} 260 -220 0 0 {name=Msw0 l=0.13u w=20u ng=1 m=1 model=sg13_lv_nmos spiceprefix=X}
N 240 -220 190 -220 {lab=vtrim0}
C {devices/lab_pin.sym} 190 -220 0 1 {name=l_Msw0_G sig_type=std_logic lab=vtrim0}
N 280 -220 350 -220 {lab=vss}
C {devices/lab_pin.sym} 350 -220 0 0 {name=l_Msw0_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/rhigh.sym} 0 -70 0 0 {name=Rt1 w=1u model=rhigh body=sub! b=0 m=1 mm_ok=1 spiceprefix=X l=13.6u}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} 260 -70 0 0 {name=Msw1 l=0.13u w=20u ng=1 m=1 model=sg13_lv_nmos spiceprefix=X}
N 240 -70 190 -70 {lab=vtrim1}
C {devices/lab_pin.sym} 190 -70 0 1 {name=l_Msw1_G sig_type=std_logic lab=vtrim1}
N 280 -70 350 -70 {lab=vss}
C {devices/lab_pin.sym} 350 -70 0 0 {name=l_Msw1_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/rhigh.sym} 0 80 0 0 {name=Rt2 w=1u model=rhigh body=sub! b=0 m=1 mm_ok=1 spiceprefix=X l=27.3u}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} 260 80 0 0 {name=Msw2 l=0.13u w=20u ng=1 m=1 model=sg13_lv_nmos spiceprefix=X}
N 240 80 190 80 {lab=vtrim2}
C {devices/lab_pin.sym} 190 80 0 1 {name=l_Msw2_G sig_type=std_logic lab=vtrim2}
N 280 80 350 80 {lab=vss}
C {devices/lab_pin.sym} 350 80 0 0 {name=l_Msw2_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/rhigh.sym} 0 230 0 0 {name=Rt3 w=1u model=rhigh body=sub! b=0 m=1 mm_ok=1 spiceprefix=X l=54.6u}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} 260 230 0 0 {name=Msw3 l=0.13u w=20u ng=1 m=1 model=sg13_lv_nmos spiceprefix=X}
N 240 230 190 230 {lab=vtrim3}
C {devices/lab_pin.sym} 190 230 0 1 {name=l_Msw3_G sig_type=std_logic lab=vtrim3}
N 280 230 350 230 {lab=vss}
C {devices/lab_pin.sym} 350 230 0 0 {name=l_Msw3_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/rhigh.sym} 0 380 0 0 {name=Rt4 w=1u model=rhigh body=sub! b=0 m=1 mm_ok=1 spiceprefix=X l=109.1u}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} 260 380 0 0 {name=Msw4 l=0.13u w=20u ng=1 m=1 model=sg13_lv_nmos spiceprefix=X}
N 240 380 190 380 {lab=vtrim4}
C {devices/lab_pin.sym} 190 380 0 1 {name=l_Msw4_G sig_type=std_logic lab=vtrim4}
N 280 380 350 380 {lab=vss}
C {devices/lab_pin.sym} 350 380 0 0 {name=l_Msw4_B sig_type=std_logic lab=vss}
N 0 -550 0 -590 {lab=vout}
C {devices/iopin.sym} 0 -590 0 0 {name=p_vout lab=vout}
N 0 -490 0 -450 {lab=vfb}
C {devices/opin.sym} 0 -450 0 0 {name=p_vfb lab=vfb}
C {devices/iopin.sym} -560 -300 0 0 {name=p_vss lab=vss}
C {devices/ipin.sym} -560 -240 0 0 {name=p_vtrim0 lab=vtrim0}
C {devices/ipin.sym} -560 -180 0 0 {name=p_vtrim1 lab=vtrim1}
C {devices/ipin.sym} -560 -120 0 0 {name=p_vtrim2 lab=vtrim2}
C {devices/ipin.sym} -560 -60 0 0 {name=p_vtrim3 lab=vtrim3}
C {devices/ipin.sym} -560 0 0 0 {name=p_vtrim4 lab=vtrim4}
