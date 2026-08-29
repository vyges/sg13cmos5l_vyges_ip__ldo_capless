v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
E {}
T {ldo_erramp -- 5T OTA error amplifier (sg13_hv, 3.3 V domain)} -420 -420 0 0 0.4 0.4 {}
T {Tail current is mirrored from the harness iDAC through the ibias pin: the harness
pushes current IN and Mr develops the gate voltage locally. Do NOT substitute a local
voltage bias -- the tail is meant to track the harness iDAC scale (IB_SEL), and output
accuracy is meant to inherit the harness bandgap rather than anything generated on-slot.} -420 -390 0 0 0.25 0.25 {layer=15}
T {Loop sense: vfb up -> M1 current up -> n3 down -> M4 gate down -> eout up
-> pass PMOS turns off -> vout down.  Swapping the M1/M2 gates inverts the
loop and the regulator latches to a rail.} 200 -320 0 0 0.25 0.25 {layer=15}
C {sg13cmos5l_pr/sg13_hv_pmos.sym} -180 -470 0 0 {name=M3 l=1u w=10u ng=1 m=1 model=sg13_hv_pmos spiceprefix=X}
N -160 -440 -160 -400 {lab=n3}
C {devices/lab_pin.sym} -160 -400 0 0 {name=l_M3_D sig_type=std_logic lab=n3}
N -200 -470 -250 -470 {lab=n3}
C {devices/lab_pin.sym} -250 -470 0 1 {name=l_M3_G sig_type=std_logic lab=n3}
N -160 -500 -160 -540 {lab=vin}
C {devices/lab_pin.sym} -160 -540 0 0 {name=l_M3_S sig_type=std_logic lab=vin}
N -160 -470 -10 -470 {lab=vin}
C {devices/lab_pin.sym} -10 -470 0 0 {name=l_M3_B sig_type=std_logic lab=vin}
C {sg13cmos5l_pr/sg13_hv_pmos.sym} 180 -470 0 0 {name=M4 l=1u w=10u ng=1 m=1 model=sg13_hv_pmos spiceprefix=X}
N 200 -440 200 -400 {lab=eout}
C {devices/lab_pin.sym} 200 -400 0 0 {name=l_M4_D sig_type=std_logic lab=eout}
N 160 -470 110 -470 {lab=n3}
C {devices/lab_pin.sym} 110 -470 0 1 {name=l_M4_G sig_type=std_logic lab=n3}
N 200 -500 200 -540 {lab=vin}
C {devices/lab_pin.sym} 200 -540 0 0 {name=l_M4_S sig_type=std_logic lab=vin}
N 200 -470 350 -470 {lab=vin}
C {devices/lab_pin.sym} 350 -470 0 0 {name=l_M4_B sig_type=std_logic lab=vin}
C {sg13cmos5l_pr/sg13_hv_nmos.sym} -180 -180 0 0 {name=M1 l=1u w=10u ng=1 m=1 model=sg13_hv_nmos spiceprefix=X}
N -160 -210 -160 -250 {lab=n3}
C {devices/lab_pin.sym} -160 -250 0 0 {name=l_M1_D sig_type=std_logic lab=n3}
N -200 -180 -250 -180 {lab=vfb}
C {devices/lab_pin.sym} -250 -180 0 1 {name=l_M1_G sig_type=std_logic lab=vfb}
N -160 -150 -160 -110 {lab=ntail}
C {devices/lab_pin.sym} -160 -110 0 0 {name=l_M1_S sig_type=std_logic lab=ntail}
N -160 -180 -10 -180 {lab=vss}
C {devices/lab_pin.sym} -10 -180 0 0 {name=l_M1_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/sg13_hv_nmos.sym} 180 -180 0 0 {name=M2 l=1u w=10u ng=1 m=1 model=sg13_hv_nmos spiceprefix=X}
N 200 -210 200 -250 {lab=eout}
C {devices/lab_pin.sym} 200 -250 0 0 {name=l_M2_D sig_type=std_logic lab=eout}
N 160 -180 110 -180 {lab=vref}
C {devices/lab_pin.sym} 110 -180 0 1 {name=l_M2_G sig_type=std_logic lab=vref}
N 200 -150 200 -110 {lab=ntail}
C {devices/lab_pin.sym} 200 -110 0 0 {name=l_M2_S sig_type=std_logic lab=ntail}
N 200 -180 350 -180 {lab=vss}
C {devices/lab_pin.sym} 350 -180 0 0 {name=l_M2_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/sg13_hv_nmos.sym} 0 110 0 0 {name=Mt l=1u w=2u ng=1 m=1 model=sg13_hv_nmos spiceprefix=X}
N 20 80 20 40 {lab=ntail}
C {devices/lab_pin.sym} 20 40 0 0 {name=l_Mt_D sig_type=std_logic lab=ntail}
N -20 110 -70 110 {lab=ibias}
C {devices/lab_pin.sym} -70 110 0 1 {name=l_Mt_G sig_type=std_logic lab=ibias}
N 20 140 20 180 {lab=vss}
C {devices/lab_pin.sym} 20 180 0 0 {name=l_Mt_S sig_type=std_logic lab=vss}
N 20 110 170 110 {lab=vss}
C {devices/lab_pin.sym} 170 110 0 0 {name=l_Mt_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/sg13_hv_nmos.sym} -540 110 0 0 {name=Mr l=1u w=2u ng=1 m=1 model=sg13_hv_nmos spiceprefix=X}
N -520 80 -520 40 {lab=ibias}
C {devices/lab_pin.sym} -520 40 0 0 {name=l_Mr_D sig_type=std_logic lab=ibias}
N -560 110 -610 110 {lab=ibias}
C {devices/lab_pin.sym} -610 110 0 1 {name=l_Mr_G sig_type=std_logic lab=ibias}
N -520 140 -520 180 {lab=vss}
C {devices/lab_pin.sym} -520 180 0 0 {name=l_Mr_S sig_type=std_logic lab=vss}
N -520 110 -370 110 {lab=vss}
C {devices/lab_pin.sym} -370 110 0 0 {name=l_Mr_B sig_type=std_logic lab=vss}
C {devices/ipin.sym} -1120 -540 0 0 {name=p_vref lab=vref}
C {devices/ipin.sym} -1120 -480 0 0 {name=p_vfb lab=vfb}
C {devices/ipin.sym} -1120 -420 0 0 {name=p_ibias lab=ibias}
C {devices/opin.sym} -1120 -360 0 0 {name=p_eout lab=eout}
C {devices/iopin.sym} -1120 -300 0 0 {name=p_vin lab=vin}
C {devices/iopin.sym} -1120 -240 0 0 {name=p_vss lab=vss}
