v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
E {}
T {ldo_vref -- reference divider, 1.2 V bandgap -> 0.6 V} -340 -520 0 0 0.4 0.4 {}
N 0 -320 0 -270 {lab=vref_ov}
N 0 -270 0 -230 {lab=vref_ov}
N 0 -170 0 -120 {lab=vref}
N 0 -120 0 -80 {lab=vref}
N 0 -20 0 45 {lab=vref_pg}
N 0 45 0 90 {lab=vref_pg}
N 0 90 0 130 {lab=vref_pg}
N 0 -80 0 -120 {lab=vref}
N 0 -120 -240 -120 {lab=vref}
N -240 -120 -240 -80 {lab=vref}
N 0 190 0 260 {lab=vss}
N 0 260 -240 260 {lab=vss}
N -240 260 -240 45 {lab=vss}
N -240 45 -240 -20 {lab=vss}
N 500 -280 0 -280 {lab=vref_ov}
N 0 -280 0 -230 {lab=vref_ov}
N 500 -120 0 -120 {lab=vref}
N 0 -120 0 -80 {lab=vref}
N 500 70 0 70 {lab=vref_pg}
N 0 70 0 130 {lab=vref_pg}
N 500 260 0 260 {lab=vss}
N 0 260 0 190 {lab=vss}
C {sg13cmos5l_pr/rhigh.sym} 0 -350 0 0 {name=R1a w=1u l=194.4u model=rhigh body=sub! b=0 m=1 mm_ok=1 spiceprefix=X}
N 0 -380 0 -420 {lab=vref_bg}
C {devices/lab_pin.sym} 0 -420 0 0 {name=l_R1a_P sig_type=std_logic lab=vref_bg}
C {sg13cmos5l_pr/rhigh.sym} 0 -200 0 0 {name=R1b w=1u l=17.6u model=rhigh body=sub! b=0 m=1 mm_ok=1 spiceprefix=X}
C {sg13cmos5l_pr/rhigh.sym} 0 -50 0 0 {name=R2a w=1u l=21.1u model=rhigh body=sub! b=0 m=1 mm_ok=1 spiceprefix=X}
C {sg13cmos5l_pr/rhigh.sym} 0 160 0 0 {name=R2b w=1u l=190.5u model=rhigh body=sub! b=0 m=1 mm_ok=1 spiceprefix=X}
C {sg13cmos5l_pr/cap_cmomf.sym} -240 -50 0 0 {name=Cf model=cap_cmomf w=10u l=10u mmin=1 mmax=4 spiceprefix=X}
N 0 -380 0 -420 {lab=vref_bg}
C {devices/ipin.sym} 0 -420 0 0 {name=p_vref_bg lab=vref_bg}
C {devices/opin.sym} 500 -120 0 0 {name=p_vref lab=vref}
C {devices/opin.sym} 500 70 0 0 {name=p_vref_pg lab=vref_pg}
C {devices/iopin.sym} 500 260 0 0 {name=p_vss lab=vss}
C {devices/opin.sym} 500 -280 0 0 {name=p_vref_ov lab=vref_ov}
L 4 -90 -440 160 -440 {dash=8}
L 4 160 -440 160 230 {dash=8}
L 4 160 230 -90 230 {dash=8}
L 4 -90 230 -90 -440 {dash=8}
T {DIVIDER (one chain, three taps)} -84 -466 0 0 0.3 0.3 {layer=4}
L 4 -330 -150 -150 -150 {dash=8}
L 4 -150 -150 -150 50 {dash=8}
L 4 -150 50 -330 50 {dash=8}
L 4 -330 50 -330 -150 {dash=8}
T {FILTER CAP} -324 -176 0 0 0.3 0.3 {layer=4}
