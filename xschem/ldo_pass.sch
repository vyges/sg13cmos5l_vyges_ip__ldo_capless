v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
E {}
T {ldo_pass -- PMOS pass device array (sg13_hv, W=100u x 64)} -300 -320 0 0 0.4 0.4 {}
N -270 -110 -85 -110 {lab=eout}
N -85 -110 -20 -110 {lab=eout}
N 20 -250 20 -140 {lab=vin}
N 20 50 20 -80 {lab=vout}
C {sg13cmos5l_pr/sg13_hv_pmos.sym} 0 -110 0 0 {name=Mpass l=0.5u w=100u ng=1 m=64 model=sg13_hv_pmos spiceprefix=X}
N 20 -110 90 -110 {lab=vin}
C {devices/lab_pin.sym} 90 -110 0 0 {name=l_Mpass_B sig_type=std_logic lab=vin}
C {devices/ipin.sym} -270 -110 0 0 {name=p_eout lab=eout}
C {devices/iopin.sym} 20 -250 0 0 {name=p_vin lab=vin}
C {devices/iopin.sym} 20 50 0 0 {name=p_vout lab=vout}
