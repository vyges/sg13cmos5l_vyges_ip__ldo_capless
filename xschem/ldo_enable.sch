v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
E {}
T {ldo_enable -- enable / power-gate with 1.2 V to 3.3 V level shift} -800 -720 0 0 0.4 0.4 {}
T {The control bus is 1.2 V and the pass device sits on 3.3 V. A 1.2 V signal cannot
turn a 3.3 V PMOS off, so the high side is level-shifted. Killing the bias alone is
not enough: with the mirrors off nothing drives eout, and a floating pass gate can
drift low and turn the device ON. Mdis forces eout to vin so 'disabled' really is.} -800 -680 0 0 0.25 0.25 {layer=15}
N -460 60 -395 60 {lab=en_n}
N -395 60 -245 60 {lab=en_n}
N -245 60 -180 60 {lab=en_n}
N -460 60 -395 60 {lab=en_n}
N -395 60 -395 160 {lab=en_n}
N -395 160 115 160 {lab=en_n}
N 115 160 115 -60 {lab=en_n}
N 115 -60 180 -60 {lab=en_n}
N 200 -270 200 -205 {lab=ls}
N 200 -205 220 -205 {lab=ls}
N 220 -205 220 -130 {lab=ls}
N 220 -130 220 -90 {lab=ls}
N 220 -90 220 -130 {lab=ls}
N 220 -130 220 -520 {lab=ls}
N 220 -520 475 -520 {lab=ls}
N 475 -520 475 -420 {lab=ls}
N 475 -420 540 -420 {lab=ls}
N -800 60 -580 60 {lab=en}
N -580 60 -540 60 {lab=en}
N -140 -160 -140 30 {lab=ibias}
N 800 -340 580 -340 {lab=eout}
N 580 -340 580 -390 {lab=eout}
N 800 -560 580 -560 {lab=vin}
N 580 -560 580 -450 {lab=vin}
C {devices/lab_pin.sym} -460 60 0 0 {name=l_net_en_n sig_type=std_logic lab=en_n}
C {devices/lab_pin.sym} 200 -270 0 0 {name=l_net_ls sig_type=std_logic lab=ls}
C {sg13cmos5l_stdcells/sg13cmos5l_inv_1.sym} -500 60 0 0 {name=Xinv VDD=vddd VSS=vss prefix=sg13cmos5l_}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} -160 60 0 0 {name=Men_bias l=0.13u w=10u ng=1 m=1 model=sg13_lv_nmos spiceprefix=X}
N -140 90 -140 130 {lab=vss}
C {devices/lab_pin.sym} -140 130 0 0 {name=l_Men_bias_S sig_type=std_logic lab=vss}
N -140 60 -70 60 {lab=vss}
C {devices/lab_pin.sym} -70 60 0 0 {name=l_Men_bias_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/rhigh.sym} 200 -300 0 0 {name=Rls w=1u l=700u model=rhigh body=sub! b=0 m=1 mm_ok=1 spiceprefix=X}
N 200 -330 200 -370 {lab=vin}
C {devices/lab_pin.sym} 200 -370 0 0 {name=l_Rls_P sig_type=std_logic lab=vin}
C {sg13cmos5l_pr/sg13_hv_nmos.sym} 200 -60 0 0 {name=Mls l=0.5u w=10u ng=1 m=1 model=sg13_hv_nmos spiceprefix=X}
N 220 -30 220 10 {lab=vss}
C {devices/lab_pin.sym} 220 10 0 0 {name=l_Mls_S sig_type=std_logic lab=vss}
N 220 -60 290 -60 {lab=vss}
C {devices/lab_pin.sym} 290 -60 0 0 {name=l_Mls_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/sg13_hv_pmos.sym} 560 -420 0 0 {name=Mdis l=0.5u w=20u ng=1 m=1 model=sg13_hv_pmos spiceprefix=X}
N 580 -420 650 -420 {lab=vin}
C {devices/lab_pin.sym} 650 -420 0 0 {name=l_Mdis_B sig_type=std_logic lab=vin}
C {devices/ipin.sym} -800 60 0 0 {name=p_en lab=en}
C {devices/opin.sym} -320 220 0 0 {name=p_en_n lab=en_n}
C {devices/iopin.sym} -140 -160 0 0 {name=p_ibias lab=ibias}
C {devices/iopin.sym} 800 -340 0 0 {name=p_eout lab=eout}
C {devices/iopin.sym} 800 -560 0 0 {name=p_vin lab=vin}
C {devices/iopin.sym} -800 -300 0 0 {name=p_vddd lab=vddd}
C {devices/iopin.sym} -800 320 0 0 {name=p_vss lab=vss}
L 4 -600 -40 -60 -40 {dash=8}
L 4 -60 -40 -60 190 {dash=8}
L 4 -60 190 -600 190 {dash=8}
L 4 -600 190 -600 -40 {dash=8}
T {1.2 V DOMAIN} -594 -66 0 0 0.3 0.3 {layer=4}
L 4 60 -400 340 -400 {dash=8}
L 4 340 -400 340 40 {dash=8}
L 4 340 40 60 40 {dash=8}
L 4 60 40 60 -400 {dash=8}
T {LEVEL SHIFT (hv)} 66 -426 0 0 0.3 0.3 {layer=4}
L 4 420 -620 700 -620 {dash=8}
L 4 700 -620 700 -300 {dash=8}
L 4 700 -300 420 -300 {dash=8}
L 4 420 -300 420 -620 {dash=8}
T {PASS-GATE DISABLE} 426 -646 0 0 0.3 0.3 {layer=4}
