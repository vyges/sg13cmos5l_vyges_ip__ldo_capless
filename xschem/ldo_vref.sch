v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
E {}
T {ldo_vref -- reference divider, 1.2 V bandgap -> 0.6 V} -300 -280 0 0 0.4 0.4 {}
N 0 -170 0 -80 {lab=vref}
N 0 -80 0 -115 {lab=vref}
N 0 -115 240 -115 {lab=vref}
N 240 -115 240 -80 {lab=vref}
N 0 -20 0 60 {lab=vss}
N 0 60 240 60 {lab=vss}
N 240 60 240 -20 {lab=vss}
C {devices/lab_pin.sym} 0 -170 0 0 {name=l_net_vref sig_type=std_logic lab=vref}
C {devices/lab_pin.sym} 0 -20 0 0 {name=l_net_vss sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/rhigh.sym} 0 -200 0 0 {name=R1 w=1u l=212u model=rhigh body=sub! b=0 m=1 mm_ok=1 spiceprefix=X}
N 0 -230 0 -270 {lab=vref_bg}
C {devices/lab_pin.sym} 0 -270 0 0 {name=l_R1_P sig_type=std_logic lab=vref_bg}
C {sg13cmos5l_pr/rhigh.sym} 0 -50 0 0 {name=R2 w=1u l=212u model=rhigh body=sub! b=0 m=1 mm_ok=1 spiceprefix=X}
C {sg13cmos5l_pr/cap_mfringe.sym} 240 -50 0 0 {name=Cf model=cap_mfringe w=10u l=10u mmin=1 mmax=4 spiceprefix=X}
N 0 -230 0 -270 {lab=vref_bg}
C {devices/ipin.sym} 0 -270 0 0 {name=p_vref_bg lab=vref_bg}
C {devices/opin.sym} -400 -160 0 0 {name=p_vref lab=vref}
C {devices/iopin.sym} -400 -100 0 0 {name=p_vss lab=vss}
