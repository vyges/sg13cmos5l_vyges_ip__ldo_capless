v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
E {}
T {ldo_ilim -- current limit: 1:1000 sense, throttle and OC flag} -900 -940 0 0 0.4 0.4 {}
T {Msense shares the pass device's gate and source, so it carries 1/1000 of the pass
current; Mref sinks a 50 uA reference. oc_n is therefore the comparison itself --
low below the limit, rising above it -- and needs no separate comparator.
The limiter ACTS: Mlim pulls the pass gate up when it trips, rather than only
raising a flag and waiting for firmware.} -900 -900 0 0 0.25 0.25 {layer=15}
N -280 -370 -280 -340 {lab=sense_d}
N -280 -340 -280 -250 {lab=sense_d}
N -540 -250 -540 -290 {lab=sense_d}
N -540 -290 -540 -340 {lab=sense_d}
N -540 -340 -280 -340 {lab=sense_d}
N -280 -340 -280 -250 {lab=sense_d}
N -580 -220 -620 -220 {lab=ibias}
N -620 -220 -620 -60 {lab=ibias}
N -620 -60 -385 -60 {lab=ibias}
N -385 -60 -320 -60 {lab=ibias}
N -280 -190 -280 -150 {lab=oc_n}
N -280 -150 -280 -130 {lab=oc_n}
N -280 -130 -280 -90 {lab=oc_n}
N -280 -90 -280 -130 {lab=oc_n}
N -280 -130 -20 -130 {lab=oc_n}
N -20 -130 -20 -90 {lab=oc_n}
N -20 -90 195 -90 {lab=oc_n}
N 195 -90 195 -60 {lab=oc_n}
N 195 -60 260 -60 {lab=oc_n}
N 260 -60 195 -60 {lab=oc_n}
N 195 -60 195 -400 {lab=oc_n}
N 195 -400 260 -400 {lab=oc_n}
N 260 -60 260 40 {lab=oc_n}
N 260 40 815 40 {lab=oc_n}
N 815 40 815 -60 {lab=oc_n}
N 815 -60 880 -60 {lab=oc_n}
N -580 200 -515 200 {lab=ilim_en_n}
N -515 200 -125 200 {lab=ilim_en_n}
N -125 200 -125 -60 {lab=ilim_en_n}
N -125 -60 -60 -60 {lab=ilim_en_n}
N 300 -370 300 -330 {lab=oc_nb}
N 300 -330 300 -130 {lab=oc_nb}
N 300 -130 300 -90 {lab=oc_nb}
N 300 -370 300 -330 {lab=oc_nb}
N 300 -330 420 -330 {lab=oc_nb}
N 420 -330 420 -640 {lab=oc_nb}
N 420 -640 535 -640 {lab=oc_nb}
N 535 -640 600 -640 {lab=oc_nb}
N 900 -270 900 -205 {lab=oc_lv}
N 900 -205 920 -205 {lab=oc_lv}
N 920 -205 920 -130 {lab=oc_lv}
N 920 -130 920 -90 {lab=oc_lv}
N 900 -270 1120 -270 {lab=oc_lv}
N 1120 -270 1120 -300 {lab=oc_lv}
N 1120 -300 1160 -300 {lab=oc_lv}
N -900 -220 -645 -220 {lab=ibias}
N -645 -220 -580 -220 {lab=ibias}
N -900 -400 -385 -400 {lab=eout}
N -385 -400 -320 -400 {lab=eout}
N 900 -420 900 -330 {lab=vddd}
C {devices/lab_pin.sym} -280 -370 0 0 {name=l_net_sense_d sig_type=std_logic lab=sense_d}
C {devices/lab_pin.sym} -280 -190 0 0 {name=l_net_oc_n sig_type=std_logic lab=oc_n}
C {devices/lab_pin.sym} -580 200 0 0 {name=l_net_ilim_en_n sig_type=std_logic lab=ilim_en_n}
C {devices/lab_pin.sym} 300 -370 0 0 {name=l_net_oc_nb sig_type=std_logic lab=oc_nb}
C {devices/lab_pin.sym} 900 -270 0 0 {name=l_net_oc_lv sig_type=std_logic lab=oc_lv}
C {sg13cmos5l_pr/sg13_hv_pmos.sym} -300 -400 0 0 {name=Msense l=0.5u ng=1 m=1 model=sg13_hv_pmos spiceprefix=X w=2u}
N -280 -430 -280 -470 {lab=vin}
C {devices/lab_pin.sym} -280 -470 0 0 {name=l_Msense_S sig_type=std_logic lab=vin}
N -280 -400 -210 -400 {lab=vin}
C {devices/lab_pin.sym} -210 -400 0 0 {name=l_Msense_B sig_type=std_logic lab=vin}
C {sg13cmos5l_pr/sg13_hv_nmos.sym} -560 -220 0 0 {name=Msd l=4u ng=1 m=1 model=sg13_hv_nmos spiceprefix=X w=1u}
N -540 -190 -540 -150 {lab=vss}
C {devices/lab_pin.sym} -540 -150 0 0 {name=l_Msd_S sig_type=std_logic lab=vss}
N -540 -220 -470 -220 {lab=vss}
C {devices/lab_pin.sym} -470 -220 0 0 {name=l_Msd_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/sg13_hv_pmos.sym} -300 -220 0 0 {name=Mcas l=0.5u ng=1 m=1 model=sg13_hv_pmos spiceprefix=X w=4u}
N -320 -220 -370 -220 {lab=vout}
C {devices/lab_pin.sym} -370 -220 0 1 {name=l_Mcas_G sig_type=std_logic lab=vout}
N -280 -220 -210 -220 {lab=vin}
C {devices/lab_pin.sym} -210 -220 0 0 {name=l_Mcas_B sig_type=std_logic lab=vin}
C {sg13cmos5l_pr/sg13_hv_nmos.sym} -300 -60 0 0 {name=Mref l=1u ng=1 m=1 model=sg13_hv_nmos spiceprefix=X w=50u}
N -280 -30 -280 10 {lab=vss}
C {devices/lab_pin.sym} -280 10 0 0 {name=l_Mref_S sig_type=std_logic lab=vss}
N -280 -60 -210 -60 {lab=vss}
C {devices/lab_pin.sym} -210 -60 0 0 {name=l_Mref_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/sg13_hv_nmos.sym} -40 -60 0 0 {name=Mdis_oc l=0.5u ng=1 m=1 model=sg13_hv_nmos spiceprefix=X w=10u}
N -20 -30 -20 10 {lab=vss}
C {devices/lab_pin.sym} -20 10 0 0 {name=l_Mdis_oc_S sig_type=std_logic lab=vss}
N -20 -60 50 -60 {lab=vss}
C {devices/lab_pin.sym} 50 -60 0 0 {name=l_Mdis_oc_B sig_type=std_logic lab=vss}
C {sg13cmos5l_stdcells/sg13cmos5l_inv_1.sym} -620 200 0 0 {name=Xinv_ie VDD=vddd VSS=vss prefix=sg13cmos5l_}
N -660 200 -710 200 {lab=ilim_en}
C {devices/lab_pin.sym} -710 200 0 1 {name=l_Xinv_ie_A sig_type=std_logic lab=ilim_en}
C {sg13cmos5l_pr/sg13_hv_pmos.sym} 280 -400 0 0 {name=Mocp l=0.5u ng=1 m=1 model=sg13_hv_pmos spiceprefix=X w=4u}
N 300 -430 300 -470 {lab=vin}
C {devices/lab_pin.sym} 300 -470 0 0 {name=l_Mocp_S sig_type=std_logic lab=vin}
N 300 -400 370 -400 {lab=vin}
C {devices/lab_pin.sym} 370 -400 0 0 {name=l_Mocp_B sig_type=std_logic lab=vin}
C {sg13cmos5l_pr/sg13_hv_nmos.sym} 280 -60 0 0 {name=Mocn l=0.5u ng=1 m=1 model=sg13_hv_nmos spiceprefix=X w=2u}
N 300 -30 300 10 {lab=vss}
C {devices/lab_pin.sym} 300 10 0 0 {name=l_Mocn_S sig_type=std_logic lab=vss}
N 300 -60 370 -60 {lab=vss}
C {devices/lab_pin.sym} 370 -60 0 0 {name=l_Mocn_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/sg13_hv_pmos.sym} 620 -640 0 0 {name=Mlim l=0.5u ng=1 m=1 model=sg13_hv_pmos spiceprefix=X w=20u}
N 640 -610 640 -570 {lab=eout}
C {devices/lab_pin.sym} 640 -570 0 0 {name=l_Mlim_D sig_type=std_logic lab=eout}
N 640 -670 640 -710 {lab=vin}
C {devices/lab_pin.sym} 640 -710 0 0 {name=l_Mlim_S sig_type=std_logic lab=vin}
N 640 -640 710 -640 {lab=vin}
C {devices/lab_pin.sym} 710 -640 0 0 {name=l_Mlim_B sig_type=std_logic lab=vin}
C {sg13cmos5l_pr/rhigh.sym} 900 -300 0 0 {name=Roc w=1u l=140u model=rhigh body=sub! b=0 m=1 mm_ok=1 spiceprefix=X}
C {sg13cmos5l_pr/sg13_hv_nmos.sym} 900 -60 0 0 {name=Moc l=0.5u ng=1 m=1 model=sg13_hv_nmos spiceprefix=X w=10u}
N 920 -30 920 10 {lab=vss}
C {devices/lab_pin.sym} 920 10 0 0 {name=l_Moc_S sig_type=std_logic lab=vss}
N 920 -60 990 -60 {lab=vss}
C {devices/lab_pin.sym} 990 -60 0 0 {name=l_Moc_B sig_type=std_logic lab=vss}
C {sg13cmos5l_stdcells/sg13cmos5l_inv_2.sym} 1200 -300 0 0 {name=Xinv_oc VDD=vddd VSS=vss prefix=sg13cmos5l_}
N 1240 -300 1310 -300 {lab=oc}
C {devices/lab_pin.sym} 1310 -300 0 0 {name=l_Xinv_oc_Y sig_type=std_logic lab=oc}
C {devices/iopin.sym} -900 -400 0 0 {name=p_eout lab=eout}
N -320 -220 -370 -220 {lab=vout}
C {devices/ipin.sym} -370 -220 0 1 {name=p_vout lab=vout}
C {devices/ipin.sym} -900 -220 0 0 {name=p_ibias lab=ibias}
N -660 200 -710 200 {lab=ilim_en}
C {devices/ipin.sym} -710 200 0 1 {name=p_ilim_en lab=ilim_en}
N 1240 -300 1310 -300 {lab=oc}
C {devices/opin.sym} 1310 -300 0 0 {name=p_oc lab=oc}
C {devices/iopin.sym} -900 -720 0 0 {name=p_vin lab=vin}
C {devices/iopin.sym} 900 -420 0 0 {name=p_vddd lab=vddd}
C {devices/iopin.sym} -900 300 0 0 {name=p_vss lab=vss}
L 4 -680 -480 -180 -480 {dash=8}
L 4 -180 -480 -180 -160 {dash=8}
L 4 -180 -160 -680 -160 {dash=8}
L 4 -680 -160 -680 -480 {dash=8}
T {SENSE} -674 -506 0 0 0.3 0.3 {layer=4}
L 4 -380 -140 40 -140 {dash=8}
L 4 40 -140 40 20 {dash=8}
L 4 40 20 -380 20 {dash=8}
L 4 -380 20 -380 -140 {dash=8}
T {COMPARE (oc_n)} -374 -166 0 0 0.3 0.3 {layer=4}
L 4 -720 140 -460 140 {dash=8}
L 4 -460 140 -460 260 {dash=8}
L 4 -460 260 -720 260 {dash=8}
L 4 -720 260 -720 140 {dash=8}
T {ENABLE} -714 114 0 0 0.3 0.3 {layer=4}
L 4 180 -720 720 -720 {dash=8}
L 4 720 -720 720 0 {dash=8}
L 4 720 0 180 0 {dash=8}
L 4 180 0 180 -720 {dash=8}
T {THROTTLE} 186 -746 0 0 0.3 0.3 {layer=4}
L 4 800 -460 1330 -460 {dash=8}
L 4 1330 -460 1330 20 {dash=8}
L 4 1330 20 800 20 {dash=8}
L 4 800 20 800 -460 {dash=8}
T {OC FLAG (1.2 V)} 806 -486 0 0 0.3 0.3 {layer=4}
