v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
E {}
T {ldo_vref -- reference divider, 1.2 V bandgap -> 0.6 V} -300 -280 0 0 0.4 0.4 {}
C {sg13cmos5l_pr/rhigh.sym} 0 -250 0 0 {name=R1 w=1u l=212u model=rhigh body=sub! b=0 m=1 mm_ok=1 spiceprefix=X}
N 0 -280 0 -320 {lab=vref_bg}
C {devices/lab_pin.sym} 0 -320 0 0 {name=l_R1_P sig_type=std_logic lab=vref_bg}
N 0 -220 0 -180 {lab=vref}
C {devices/lab_pin.sym} 0 -180 0 0 {name=l_R1_M sig_type=std_logic lab=vref}
C {sg13cmos5l_pr/rhigh.sym} 0 0 0 0 {name=R2 w=1u l=212u model=rhigh body=sub! b=0 m=1 mm_ok=1 spiceprefix=X}
N 0 -30 0 -70 {lab=vref}
C {devices/lab_pin.sym} 0 -70 0 0 {name=l_R2_P sig_type=std_logic lab=vref}
N 0 30 0 70 {lab=vss}
C {devices/lab_pin.sym} 0 70 0 0 {name=l_R2_M sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/cap_mfringe.sym} 360 0 0 0 {name=Cf model=cap_mfringe w=10u l=10u mmin=1 mmax=4 spiceprefix=X}
N 360 -30 360 -70 {lab=vref}
C {devices/lab_pin.sym} 360 -70 0 0 {name=l_Cf_c1 sig_type=std_logic lab=vref}
N 360 30 360 70 {lab=vss}
C {devices/lab_pin.sym} 360 70 0 0 {name=l_Cf_c2 sig_type=std_logic lab=vss}
C {devices/ipin.sym} -720 -290 0 0 {name=p_vref_bg lab=vref_bg}
C {devices/opin.sym} -720 -230 0 0 {name=p_vref lab=vref}
C {devices/iopin.sym} -720 -170 0 0 {name=p_vss lab=vss}
