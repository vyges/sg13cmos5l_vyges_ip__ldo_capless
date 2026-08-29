v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
E {}
T {ldo_fbtrim -- feedback divider + 5-bit binary-weighted trim} -420 -420 0 0 0.4 0.4 {}
C {sg13cmos5l_pr/rhigh.sym} 0 -540 0 0 {name=Rtop w=1u model=rhigh body=sub! b=0 m=1 mm_ok=1 spiceprefix=X l=212u}
N 0 -570 0 -610 {lab=vout}
C {devices/lab_pin.sym} 0 -610 0 0 {name=l_Rtop_P sig_type=std_logic lab=vout}
N 0 -510 0 -470 {lab=vfb}
C {devices/lab_pin.sym} 0 -470 0 0 {name=l_Rtop_M sig_type=std_logic lab=vfb}
C {sg13cmos5l_pr/rhigh.sym} 0 -320 0 0 {name=Rbase w=1u model=rhigh body=sub! b=0 m=1 mm_ok=1 spiceprefix=X l=106u}
N 0 -350 0 -390 {lab=vfb}
C {devices/lab_pin.sym} 0 -390 0 0 {name=l_Rbase_P sig_type=std_logic lab=vfb}
N 0 -290 0 -250 {lab=t0}
C {devices/lab_pin.sym} 0 -250 0 0 {name=l_Rbase_M sig_type=std_logic lab=t0}
C {sg13cmos5l_pr/rhigh.sym} 0 -110 0 0 {name=Rt0 w=1u model=rhigh body=sub! b=0 m=1 mm_ok=1 spiceprefix=X l=6.8u}
N 0 -140 0 -180 {lab=t0}
C {devices/lab_pin.sym} 0 -180 0 0 {name=l_Rt0_P sig_type=std_logic lab=t0}
N 0 -80 0 -40 {lab=t1}
C {devices/lab_pin.sym} 0 -40 0 0 {name=l_Rt0_M sig_type=std_logic lab=t1}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} 320 -110 0 0 {name=Msw0 l=0.13u w=20u ng=1 m=1 model=sg13_lv_nmos spiceprefix=X}
N 340 -140 340 -180 {lab=t0}
C {devices/lab_pin.sym} 340 -180 0 0 {name=l_Msw0_D sig_type=std_logic lab=t0}
N 300 -110 250 -110 {lab=vtrim0}
C {devices/lab_pin.sym} 250 -110 0 1 {name=l_Msw0_G sig_type=std_logic lab=vtrim0}
N 340 -80 340 -40 {lab=t1}
C {devices/lab_pin.sym} 340 -40 0 0 {name=l_Msw0_S sig_type=std_logic lab=t1}
N 340 -110 490 -110 {lab=vss}
C {devices/lab_pin.sym} 490 -110 0 0 {name=l_Msw0_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/rhigh.sym} 0 110 0 0 {name=Rt1 w=1u model=rhigh body=sub! b=0 m=1 mm_ok=1 spiceprefix=X l=13.6u}
N 0 80 0 40 {lab=t1}
C {devices/lab_pin.sym} 0 40 0 0 {name=l_Rt1_P sig_type=std_logic lab=t1}
N 0 140 0 180 {lab=t2}
C {devices/lab_pin.sym} 0 180 0 0 {name=l_Rt1_M sig_type=std_logic lab=t2}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} 320 110 0 0 {name=Msw1 l=0.13u w=20u ng=1 m=1 model=sg13_lv_nmos spiceprefix=X}
N 340 80 340 40 {lab=t1}
C {devices/lab_pin.sym} 340 40 0 0 {name=l_Msw1_D sig_type=std_logic lab=t1}
N 300 110 250 110 {lab=vtrim1}
C {devices/lab_pin.sym} 250 110 0 1 {name=l_Msw1_G sig_type=std_logic lab=vtrim1}
N 340 140 340 180 {lab=t2}
C {devices/lab_pin.sym} 340 180 0 0 {name=l_Msw1_S sig_type=std_logic lab=t2}
N 340 110 490 110 {lab=vss}
C {devices/lab_pin.sym} 490 110 0 0 {name=l_Msw1_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/rhigh.sym} 0 320 0 0 {name=Rt2 w=1u model=rhigh body=sub! b=0 m=1 mm_ok=1 spiceprefix=X l=27.3u}
N 0 290 0 250 {lab=t2}
C {devices/lab_pin.sym} 0 250 0 0 {name=l_Rt2_P sig_type=std_logic lab=t2}
N 0 350 0 390 {lab=t3}
C {devices/lab_pin.sym} 0 390 0 0 {name=l_Rt2_M sig_type=std_logic lab=t3}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} 320 320 0 0 {name=Msw2 l=0.13u w=20u ng=1 m=1 model=sg13_lv_nmos spiceprefix=X}
N 340 290 340 250 {lab=t2}
C {devices/lab_pin.sym} 340 250 0 0 {name=l_Msw2_D sig_type=std_logic lab=t2}
N 300 320 250 320 {lab=vtrim2}
C {devices/lab_pin.sym} 250 320 0 1 {name=l_Msw2_G sig_type=std_logic lab=vtrim2}
N 340 350 340 390 {lab=t3}
C {devices/lab_pin.sym} 340 390 0 0 {name=l_Msw2_S sig_type=std_logic lab=t3}
N 340 320 490 320 {lab=vss}
C {devices/lab_pin.sym} 490 320 0 0 {name=l_Msw2_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/rhigh.sym} 0 540 0 0 {name=Rt3 w=1u model=rhigh body=sub! b=0 m=1 mm_ok=1 spiceprefix=X l=54.6u}
N 0 510 0 470 {lab=t3}
C {devices/lab_pin.sym} 0 470 0 0 {name=l_Rt3_P sig_type=std_logic lab=t3}
N 0 570 0 610 {lab=t4}
C {devices/lab_pin.sym} 0 610 0 0 {name=l_Rt3_M sig_type=std_logic lab=t4}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} 320 540 0 0 {name=Msw3 l=0.13u w=20u ng=1 m=1 model=sg13_lv_nmos spiceprefix=X}
N 340 510 340 470 {lab=t3}
C {devices/lab_pin.sym} 340 470 0 0 {name=l_Msw3_D sig_type=std_logic lab=t3}
N 300 540 250 540 {lab=vtrim3}
C {devices/lab_pin.sym} 250 540 0 1 {name=l_Msw3_G sig_type=std_logic lab=vtrim3}
N 340 570 340 610 {lab=t4}
C {devices/lab_pin.sym} 340 610 0 0 {name=l_Msw3_S sig_type=std_logic lab=t4}
N 340 540 490 540 {lab=vss}
C {devices/lab_pin.sym} 490 540 0 0 {name=l_Msw3_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/rhigh.sym} 0 760 0 0 {name=Rt4 w=1u model=rhigh body=sub! b=0 m=1 mm_ok=1 spiceprefix=X l=109.1u}
N 0 730 0 690 {lab=t4}
C {devices/lab_pin.sym} 0 690 0 0 {name=l_Rt4_P sig_type=std_logic lab=t4}
N 0 790 0 830 {lab=vss}
C {devices/lab_pin.sym} 0 830 0 0 {name=l_Rt4_M sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} 320 760 0 0 {name=Msw4 l=0.13u w=20u ng=1 m=1 model=sg13_lv_nmos spiceprefix=X}
N 340 730 340 690 {lab=t4}
C {devices/lab_pin.sym} 340 690 0 0 {name=l_Msw4_D sig_type=std_logic lab=t4}
N 300 760 250 760 {lab=vtrim4}
C {devices/lab_pin.sym} 250 760 0 1 {name=l_Msw4_G sig_type=std_logic lab=vtrim4}
N 340 790 340 830 {lab=vss}
C {devices/lab_pin.sym} 340 830 0 0 {name=l_Msw4_S sig_type=std_logic lab=vss}
N 340 760 490 760 {lab=vss}
C {devices/lab_pin.sym} 490 760 0 0 {name=l_Msw4_B sig_type=std_logic lab=vss}
C {devices/iopin.sym} -1010 -540 0 0 {name=p_vout lab=vout}
C {devices/opin.sym} -1010 -480 0 0 {name=p_vfb lab=vfb}
C {devices/iopin.sym} -1010 -420 0 0 {name=p_vss lab=vss}
C {devices/ipin.sym} -1010 -360 0 0 {name=p_vtrim0 lab=vtrim0}
C {devices/ipin.sym} -1010 -300 0 0 {name=p_vtrim1 lab=vtrim1}
C {devices/ipin.sym} -1010 -240 0 0 {name=p_vtrim2 lab=vtrim2}
C {devices/ipin.sym} -1010 -180 0 0 {name=p_vtrim3 lab=vtrim3}
C {devices/ipin.sym} -1010 -120 0 0 {name=p_vtrim4 lab=vtrim4}
