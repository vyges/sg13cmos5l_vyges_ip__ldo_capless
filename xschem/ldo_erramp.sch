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
N -100 -330 -100 -420 {lab=vin}
N -100 -420 -100 -400 {lab=vin}
N -100 -400 140 -400 {lab=vin}
N 140 -400 140 -420 {lab=vin}
N 140 -420 140 -330 {lab=vin}
N -140 -300 -190 -300 {lab=n3}
N -190 -300 -190 -230 {lab=n3}
N -190 -230 -100 -230 {lab=n3}
N -100 -230 -100 -270 {lab=n3}
N 100 -300 35 -300 {lab=n3}
N 35 -300 35 -250 {lab=n3}
N 35 -250 -100 -250 {lab=n3}
N -100 -250 -100 -230 {lab=n3}
N -100 -230 -100 -270 {lab=n3}
N -100 -270 -100 -230 {lab=n3}
N -100 -230 -100 -190 {lab=n3}
N -100 -190 -100 -150 {lab=n3}
N 140 -270 140 -230 {lab=eout}
N 140 -230 140 -190 {lab=eout}
N 140 -190 140 -150 {lab=eout}
N -100 -90 -100 0 {lab=ntail}
N -100 0 -100 -40 {lab=ntail}
N -100 -40 140 -40 {lab=ntail}
N 140 -40 140 0 {lab=ntail}
N 140 0 140 -90 {lab=ntail}
N 20 10 20 -40 {lab=ntail}
N 20 -40 -100 -40 {lab=ntail}
N -100 -40 -100 0 {lab=ntail}
N -100 0 -100 -90 {lab=ntail}
N 20 70 20 160 {lab=vss}
N 20 160 20 150 {lab=vss}
N 20 150 -300 150 {lab=vss}
N -300 150 -300 160 {lab=vss}
N -300 160 -300 70 {lab=vss}
N -340 40 -390 40 {lab=ibias}
N -390 40 -390 -30 {lab=ibias}
N -390 -30 -300 -30 {lab=ibias}
N -300 -30 -300 10 {lab=ibias}
N -20 40 -85 40 {lab=ibias}
N -85 40 -85 -20 {lab=ibias}
N -85 -20 -300 -20 {lab=ibias}
N -300 -20 -300 -30 {lab=ibias}
N -300 -30 -300 10 {lab=ibias}
C {devices/lab_pin.sym} -100 -330 0 0 {name=l_net_vin sig_type=std_logic lab=vin}
C {devices/lab_pin.sym} -140 -300 0 0 {name=l_net_n3 sig_type=std_logic lab=n3}
C {devices/lab_pin.sym} 140 -270 0 0 {name=l_net_eout sig_type=std_logic lab=eout}
C {devices/lab_pin.sym} -100 -90 0 0 {name=l_net_ntail sig_type=std_logic lab=ntail}
C {devices/lab_pin.sym} 20 70 0 0 {name=l_net_vss sig_type=std_logic lab=vss}
C {devices/lab_pin.sym} -340 40 0 0 {name=l_net_ibias sig_type=std_logic lab=ibias}
C {sg13cmos5l_pr/sg13_hv_pmos.sym} -120 -300 0 0 {name=M3 l=1u w=10u ng=1 m=1 model=sg13_hv_pmos spiceprefix=X}
N -100 -300 -30 -300 {lab=vin}
C {devices/lab_pin.sym} -30 -300 0 0 {name=l_M3_B sig_type=std_logic lab=vin}
C {sg13cmos5l_pr/sg13_hv_pmos.sym} 120 -300 0 0 {name=M4 l=1u w=10u ng=1 m=1 model=sg13_hv_pmos spiceprefix=X}
N 140 -300 210 -300 {lab=vin}
C {devices/lab_pin.sym} 210 -300 0 0 {name=l_M4_B sig_type=std_logic lab=vin}
C {sg13cmos5l_pr/sg13_hv_nmos.sym} -120 -120 0 0 {name=M1 l=1u w=10u ng=1 m=1 model=sg13_hv_nmos spiceprefix=X}
N -140 -120 -190 -120 {lab=vfb}
C {devices/lab_pin.sym} -190 -120 0 1 {name=l_M1_G sig_type=std_logic lab=vfb}
N -100 -120 -30 -120 {lab=vss}
C {devices/lab_pin.sym} -30 -120 0 0 {name=l_M1_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/sg13_hv_nmos.sym} 120 -120 0 0 {name=M2 l=1u w=10u ng=1 m=1 model=sg13_hv_nmos spiceprefix=X}
N 100 -120 50 -120 {lab=vref}
C {devices/lab_pin.sym} 50 -120 0 1 {name=l_M2_G sig_type=std_logic lab=vref}
N 140 -120 210 -120 {lab=vss}
C {devices/lab_pin.sym} 210 -120 0 0 {name=l_M2_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/sg13_hv_nmos.sym} 0 40 0 0 {name=Mt l=1u w=2u ng=1 m=1 model=sg13_hv_nmos spiceprefix=X}
N 20 40 90 40 {lab=vss}
C {devices/lab_pin.sym} 90 40 0 0 {name=l_Mt_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/sg13_hv_nmos.sym} -320 40 0 0 {name=Mr l=1u w=2u ng=1 m=1 model=sg13_hv_nmos spiceprefix=X}
N -300 40 -230 40 {lab=vss}
C {devices/lab_pin.sym} -230 40 0 0 {name=l_Mr_B sig_type=std_logic lab=vss}
N 100 -120 50 -120 {lab=vref}
C {devices/ipin.sym} 50 -120 0 1 {name=p_vref lab=vref}
N -140 -120 -190 -120 {lab=vfb}
C {devices/ipin.sym} -190 -120 0 1 {name=p_vfb lab=vfb}
N -340 40 -390 40 {lab=ibias}
C {devices/ipin.sym} -390 40 0 1 {name=p_ibias lab=ibias}
N 140 -270 140 -230 {lab=eout}
C {devices/opin.sym} 140 -230 0 0 {name=p_eout lab=eout}
C {devices/iopin.sym} -620 -260 0 0 {name=p_vin lab=vin}
C {devices/iopin.sym} -620 -200 0 0 {name=p_vss lab=vss}
