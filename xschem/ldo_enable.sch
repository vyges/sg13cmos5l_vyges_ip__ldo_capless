v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
E {}
T {ldo_enable -- enable / power-gate with 1.2 V to 3.3 V level shift} -400 -460 0 0 0.4 0.4 {}
T {The control bus is 1.2 V and the pass device sits on 3.3 V. A 1.2 V signal cannot
turn a 3.3 V PMOS off, so the high side is level-shifted. Killing the bias alone is
not enough: with the mirrors off nothing drives eout, and a floating pass gate can
drift low and turn the device ON. Mdis forces eout to vin so 'disabled' really is.} -560 -420 0 0 0.25 0.25 {layer=15}
N 200 -270 200 -205 {lab=ls}
N 200 -205 220 -205 {lab=ls}
N 220 -205 220 -130 {lab=ls}
N 220 -130 220 -90 {lab=ls}
N 220 -90 220 -130 {lab=ls}
N 220 -130 220 -520 {lab=ls}
N 220 -520 475 -520 {lab=ls}
N 475 -520 475 -420 {lab=ls}
N 475 -420 540 -420 {lab=ls}
C {devices/lab_pin.sym} 200 -270 0 0 {name=l_net_ls sig_type=std_logic lab=ls}
C {sg13cmos5l_stdcells/sg13cmos5l_inv_1.sym} -500 60 0 0 {name=Xinv VDD=vddd VSS=vss prefix=sg13cmos5l_}
N -540 60 -590 60 {lab=en}
C {devices/lab_pin.sym} -590 60 0 1 {name=l_Xinv_A sig_type=std_logic lab=en}
N -460 60 -390 60 {lab=en_n}
C {devices/lab_pin.sym} -390 60 0 0 {name=l_Xinv_Y sig_type=std_logic lab=en_n}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} -160 60 0 0 {name=Men_bias l=0.13u w=10u ng=1 m=1 model=sg13_lv_nmos spiceprefix=X}
N -140 30 -140 -10 {lab=ibias}
C {devices/lab_pin.sym} -140 -10 0 0 {name=l_Men_bias_D sig_type=std_logic lab=ibias}
N -180 60 -230 60 {lab=en_n}
C {devices/lab_pin.sym} -230 60 0 1 {name=l_Men_bias_G sig_type=std_logic lab=en_n}
N -140 90 -140 130 {lab=vss}
C {devices/lab_pin.sym} -140 130 0 0 {name=l_Men_bias_S sig_type=std_logic lab=vss}
N -140 60 -70 60 {lab=vss}
C {devices/lab_pin.sym} -70 60 0 0 {name=l_Men_bias_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/rhigh.sym} 200 -300 0 0 {name=Rls w=1u l=700u model=rhigh body=sub! b=0 m=1 mm_ok=1 spiceprefix=X}
N 200 -330 200 -370 {lab=vin}
C {devices/lab_pin.sym} 200 -370 0 0 {name=l_Rls_P sig_type=std_logic lab=vin}
C {sg13cmos5l_pr/sg13_hv_nmos.sym} 200 -60 0 0 {name=Mls l=0.5u w=10u ng=1 m=1 model=sg13_hv_nmos spiceprefix=X}
N 180 -60 130 -60 {lab=en_n}
C {devices/lab_pin.sym} 130 -60 0 1 {name=l_Mls_G sig_type=std_logic lab=en_n}
N 220 -30 220 10 {lab=vss}
C {devices/lab_pin.sym} 220 10 0 0 {name=l_Mls_S sig_type=std_logic lab=vss}
N 220 -60 290 -60 {lab=vss}
C {devices/lab_pin.sym} 290 -60 0 0 {name=l_Mls_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/sg13_hv_pmos.sym} 560 -420 0 0 {name=Mdis l=0.5u w=20u ng=1 m=1 model=sg13_hv_pmos spiceprefix=X}
N 580 -390 580 -350 {lab=eout}
C {devices/lab_pin.sym} 580 -350 0 0 {name=l_Mdis_D sig_type=std_logic lab=eout}
N 580 -450 580 -490 {lab=vin}
C {devices/lab_pin.sym} 580 -490 0 0 {name=l_Mdis_S sig_type=std_logic lab=vin}
N 580 -420 650 -420 {lab=vin}
C {devices/lab_pin.sym} 650 -420 0 0 {name=l_Mdis_B sig_type=std_logic lab=vin}
N -540 60 -590 60 {lab=en}
C {devices/ipin.sym} -590 60 0 1 {name=p_en lab=en}
C {devices/opin.sym} -700 -260 0 0 {name=p_en_n lab=en_n}
C {devices/iopin.sym} -700 -200 0 0 {name=p_ibias lab=ibias}
C {devices/iopin.sym} -700 -140 0 0 {name=p_eout lab=eout}
C {devices/iopin.sym} -700 -80 0 0 {name=p_vin lab=vin}
C {devices/iopin.sym} -700 -20 0 0 {name=p_vddd lab=vddd}
C {devices/iopin.sym} -700 40 0 0 {name=p_vss lab=vss}
