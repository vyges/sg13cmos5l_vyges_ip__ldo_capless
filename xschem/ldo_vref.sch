v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
E {}
T {ldo_vref -- reference divider, 1.2 V bandgap -> 0.6 V} -300 -280 0 0 0.4 0.4 {}
C {sg13cmos5l_pr/rhigh.sym} 0 -200 0 0 {name=R1 w=1u l=212u model=rhigh body=sub! b=0 m=1 mm_ok=1 spiceprefix=X}
N 0 -230 0 -270 {lab=vref_bg}
C {devices/lab_pin.sym} 0 -270 0 0 {name=l_R1_P sig_type=std_logic lab=vref_bg}
N 0 -170 0 -130 {lab=vref}
C {devices/lab_pin.sym} 0 -130 0 0 {name=l_R1_M sig_type=std_logic lab=vref}
C {sg13cmos5l_pr/rhigh.sym} 0 -50 0 0 {name=R2a w=1u l=21.1u model=rhigh body=sub! b=0 m=1 mm_ok=1 spiceprefix=X}
N 0 -80 0 -120 {lab=vref}
C {devices/lab_pin.sym} 0 -120 0 0 {name=l_R2a_P sig_type=std_logic lab=vref}
N 0 -20 0 20 {lab=vref_pg}
C {devices/lab_pin.sym} 0 20 0 0 {name=l_R2a_M sig_type=std_logic lab=vref_pg}
C {sg13cmos5l_pr/rhigh.sym} 0 160 0 0 {name=R2b w=1u l=190.5u model=rhigh body=sub! b=0 m=1 mm_ok=1 spiceprefix=X}
N 0 130 0 90 {lab=vref_pg}
C {devices/lab_pin.sym} 0 90 0 0 {name=l_R2b_P sig_type=std_logic lab=vref_pg}
N 0 190 0 230 {lab=vss}
C {devices/lab_pin.sym} 0 230 0 0 {name=l_R2b_M sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/cap_cmomf.sym} 240 -50 0 0 {name=Cf model=cap_cmomf w=10u l=10u mmin=1 mmax=4 spiceprefix=X}
N 240 -80 240 -120 {lab=vref}
C {devices/lab_pin.sym} 240 -120 0 0 {name=l_Cf_c1 sig_type=std_logic lab=vref}
N 240 -20 240 20 {lab=vss}
C {devices/lab_pin.sym} 240 20 0 0 {name=l_Cf_c2 sig_type=std_logic lab=vss}
N 0 -230 0 -270 {lab=vref_bg}
C {devices/ipin.sym} 0 -270 0 0 {name=p_vref_bg lab=vref_bg}
C {devices/opin.sym} -400 -160 0 0 {name=p_vref lab=vref}
C {devices/opin.sym} -400 -100 0 0 {name=p_vref_pg lab=vref_pg}
C {devices/iopin.sym} -400 -40 0 0 {name=p_vss lab=vss}
