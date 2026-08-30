v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
E {}
T {ldo_ilim -- current limit: 1:1000 sense, throttle and OC flag} -400 -460 0 0 0.4 0.4 {}
T {Msense shares the pass device's gate and source, so it carries 1/1000 of the pass
current; Mref sinks a 50 uA reference. oc_n is therefore the comparison itself --
low below the limit, rising above it -- and needs no separate comparator.
The limiter ACTS: Mlim pulls the pass gate up when it trips, rather than only
raising a flag and waiting for firmware.} -880 -560 0 0 0.25 0.25 {layer=15}
C {sg13cmos5l_pr/sg13_hv_pmos.sym} -300 -400 0 0 {name=Msense l=0.5u ng=1 m=1 model=sg13_hv_pmos spiceprefix=X w=2u}
N -280 -370 -280 -330 {lab=oc_n}
C {devices/lab_pin.sym} -280 -330 0 0 {name=l_Msense_D sig_type=std_logic lab=oc_n}
N -320 -400 -370 -400 {lab=eout}
C {devices/lab_pin.sym} -370 -400 0 1 {name=l_Msense_G sig_type=std_logic lab=eout}
N -280 -430 -280 -470 {lab=vin}
C {devices/lab_pin.sym} -280 -470 0 0 {name=l_Msense_S sig_type=std_logic lab=vin}
N -280 -400 -210 -400 {lab=vin}
C {devices/lab_pin.sym} -210 -400 0 0 {name=l_Msense_B sig_type=std_logic lab=vin}
C {sg13cmos5l_pr/sg13_hv_nmos.sym} -300 -60 0 0 {name=Mref l=1u ng=1 m=1 model=sg13_hv_nmos spiceprefix=X w=160u}
N -280 -90 -280 -130 {lab=oc_n}
C {devices/lab_pin.sym} -280 -130 0 0 {name=l_Mref_D sig_type=std_logic lab=oc_n}
N -320 -60 -370 -60 {lab=ibias}
C {devices/lab_pin.sym} -370 -60 0 1 {name=l_Mref_G sig_type=std_logic lab=ibias}
N -280 -30 -280 10 {lab=vss}
C {devices/lab_pin.sym} -280 10 0 0 {name=l_Mref_S sig_type=std_logic lab=vss}
N -280 -60 -210 -60 {lab=vss}
C {devices/lab_pin.sym} -210 -60 0 0 {name=l_Mref_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/sg13_hv_nmos.sym} -40 -60 0 0 {name=Mdis_oc l=0.5u ng=1 m=1 model=sg13_hv_nmos spiceprefix=X w=10u}
N -20 -90 -20 -130 {lab=oc_n}
C {devices/lab_pin.sym} -20 -130 0 0 {name=l_Mdis_oc_D sig_type=std_logic lab=oc_n}
N -60 -60 -110 -60 {lab=ilim_en_n}
C {devices/lab_pin.sym} -110 -60 0 1 {name=l_Mdis_oc_G sig_type=std_logic lab=ilim_en_n}
N -20 -30 -20 10 {lab=vss}
C {devices/lab_pin.sym} -20 10 0 0 {name=l_Mdis_oc_S sig_type=std_logic lab=vss}
N -20 -60 50 -60 {lab=vss}
C {devices/lab_pin.sym} 50 -60 0 0 {name=l_Mdis_oc_B sig_type=std_logic lab=vss}
C {sg13cmos5l_stdcells/sg13cmos5l_inv_1.sym} -620 200 0 0 {name=Xinv_ie VDD=vddd VSS=vss prefix=sg13cmos5l_}
N -660 200 -710 200 {lab=ilim_en}
C {devices/lab_pin.sym} -710 200 0 1 {name=l_Xinv_ie_A sig_type=std_logic lab=ilim_en}
N -580 200 -510 200 {lab=ilim_en_n}
C {devices/lab_pin.sym} -510 200 0 0 {name=l_Xinv_ie_Y sig_type=std_logic lab=ilim_en_n}
C {sg13cmos5l_pr/sg13_hv_pmos.sym} 280 -400 0 0 {name=Mocp l=0.5u ng=1 m=1 model=sg13_hv_pmos spiceprefix=X w=4u}
N 300 -370 300 -330 {lab=oc_nb}
C {devices/lab_pin.sym} 300 -330 0 0 {name=l_Mocp_D sig_type=std_logic lab=oc_nb}
N 260 -400 210 -400 {lab=oc_n}
C {devices/lab_pin.sym} 210 -400 0 1 {name=l_Mocp_G sig_type=std_logic lab=oc_n}
N 300 -430 300 -470 {lab=vin}
C {devices/lab_pin.sym} 300 -470 0 0 {name=l_Mocp_S sig_type=std_logic lab=vin}
N 300 -400 370 -400 {lab=vin}
C {devices/lab_pin.sym} 370 -400 0 0 {name=l_Mocp_B sig_type=std_logic lab=vin}
C {sg13cmos5l_pr/sg13_hv_nmos.sym} 280 -60 0 0 {name=Mocn l=0.5u ng=1 m=1 model=sg13_hv_nmos spiceprefix=X w=2u}
N 300 -90 300 -130 {lab=oc_nb}
C {devices/lab_pin.sym} 300 -130 0 0 {name=l_Mocn_D sig_type=std_logic lab=oc_nb}
N 260 -60 210 -60 {lab=oc_n}
C {devices/lab_pin.sym} 210 -60 0 1 {name=l_Mocn_G sig_type=std_logic lab=oc_n}
N 300 -30 300 10 {lab=vss}
C {devices/lab_pin.sym} 300 10 0 0 {name=l_Mocn_S sig_type=std_logic lab=vss}
N 300 -60 370 -60 {lab=vss}
C {devices/lab_pin.sym} 370 -60 0 0 {name=l_Mocn_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/sg13_hv_pmos.sym} 620 -640 0 0 {name=Mlim l=0.5u ng=1 m=1 model=sg13_hv_pmos spiceprefix=X w=20u}
N 640 -610 640 -570 {lab=eout}
C {devices/lab_pin.sym} 640 -570 0 0 {name=l_Mlim_D sig_type=std_logic lab=eout}
N 600 -640 550 -640 {lab=oc_nb}
C {devices/lab_pin.sym} 550 -640 0 1 {name=l_Mlim_G sig_type=std_logic lab=oc_nb}
N 640 -670 640 -710 {lab=vin}
C {devices/lab_pin.sym} 640 -710 0 0 {name=l_Mlim_S sig_type=std_logic lab=vin}
N 640 -640 710 -640 {lab=vin}
C {devices/lab_pin.sym} 710 -640 0 0 {name=l_Mlim_B sig_type=std_logic lab=vin}
C {sg13cmos5l_pr/rhigh.sym} 900 -300 0 0 {name=Roc w=1u l=140u model=rhigh body=sub! b=0 m=1 mm_ok=1 spiceprefix=X}
N 900 -330 900 -370 {lab=vddd}
C {devices/lab_pin.sym} 900 -370 0 0 {name=l_Roc_P sig_type=std_logic lab=vddd}
N 900 -270 900 -230 {lab=oc_lv}
C {devices/lab_pin.sym} 900 -230 0 0 {name=l_Roc_M sig_type=std_logic lab=oc_lv}
C {sg13cmos5l_pr/sg13_hv_nmos.sym} 900 -60 0 0 {name=Moc l=0.5u ng=1 m=1 model=sg13_hv_nmos spiceprefix=X w=10u}
N 920 -90 920 -130 {lab=oc_lv}
C {devices/lab_pin.sym} 920 -130 0 0 {name=l_Moc_D sig_type=std_logic lab=oc_lv}
N 880 -60 830 -60 {lab=oc_n}
C {devices/lab_pin.sym} 830 -60 0 1 {name=l_Moc_G sig_type=std_logic lab=oc_n}
N 920 -30 920 10 {lab=vss}
C {devices/lab_pin.sym} 920 10 0 0 {name=l_Moc_S sig_type=std_logic lab=vss}
N 920 -60 990 -60 {lab=vss}
C {devices/lab_pin.sym} 990 -60 0 0 {name=l_Moc_B sig_type=std_logic lab=vss}
C {sg13cmos5l_stdcells/sg13cmos5l_inv_2.sym} 1200 -300 0 0 {name=Xinv_oc VDD=vddd VSS=vss prefix=sg13cmos5l_}
N 1160 -300 1110 -300 {lab=oc_lv}
C {devices/lab_pin.sym} 1110 -300 0 1 {name=l_Xinv_oc_A sig_type=std_logic lab=oc_lv}
N 1240 -300 1310 -300 {lab=oc}
C {devices/lab_pin.sym} 1310 -300 0 0 {name=l_Xinv_oc_Y sig_type=std_logic lab=oc}
C {devices/iopin.sym} -960 -320 0 0 {name=p_eout lab=eout}
C {devices/ipin.sym} -960 -260 0 0 {name=p_ibias lab=ibias}
N -660 200 -710 200 {lab=ilim_en}
C {devices/ipin.sym} -710 200 0 1 {name=p_ilim_en lab=ilim_en}
N 1240 -300 1310 -300 {lab=oc}
C {devices/opin.sym} 1310 -300 0 0 {name=p_oc lab=oc}
C {devices/iopin.sym} -960 -200 0 0 {name=p_vin lab=vin}
C {devices/iopin.sym} -960 -140 0 0 {name=p_vddd lab=vddd}
C {devices/iopin.sym} -960 -80 0 0 {name=p_vss lab=vss}
