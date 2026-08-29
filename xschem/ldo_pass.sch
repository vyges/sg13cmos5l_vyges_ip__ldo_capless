v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
E {}
T {ldo_pass -- PMOS pass device array (sg13_hv, W=100u x 20)} -260 -220 0 0 0.4 0.4 {}
C {sg13cmos5l_pr/sg13_hv_pmos.sym} 0 -110 0 0 {name=Mpass l=0.5u w=100u ng=1 m=20 model=sg13_hv_pmos spiceprefix=X}
N 20 -80 20 -40 {lab=vout}
C {devices/lab_pin.sym} 20 -40 0 0 {name=l_Mpass_D sig_type=std_logic lab=vout}
N -20 -110 -70 -110 {lab=eout}
C {devices/lab_pin.sym} -70 -110 0 1 {name=l_Mpass_G sig_type=std_logic lab=eout}
N 20 -140 20 -180 {lab=vin}
C {devices/lab_pin.sym} 20 -180 0 0 {name=l_Mpass_S sig_type=std_logic lab=vin}
N 20 -110 170 -110 {lab=vin}
C {devices/lab_pin.sym} 170 -110 0 0 {name=l_Mpass_B sig_type=std_logic lab=vin}
C {devices/ipin.sym} -580 -220 0 0 {name=p_eout lab=eout}
C {devices/iopin.sym} -580 -160 0 0 {name=p_vin lab=vin}
C {devices/iopin.sym} -580 -100 0 0 {name=p_vout lab=vout}
