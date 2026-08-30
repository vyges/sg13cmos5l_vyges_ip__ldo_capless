v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
E {}
T {ldo_capless -- capless LDO, 3.3 V in -> 1.0-1.8 V trimmed out} -500 -420 0 0 0.4 0.4 {}
T {Signal path: vref_bg (1.2 V harness bandgap) -> ldo_vref halves it to 0.6 V -> ldo_erramp
compares against vfb -> eout drives the ldo_pass PMOS array -> vout -> ldo_fbtrim divides
back to vfb with 5-bit trim.  Cc is the Miller compensation around the pass device; Cout is
the on-chip stabilising capacitor that replaces the external one this topology does without.} -500 -380 0 0 0.25 0.25 {layer=15}
N -430 -200 -420 -200 {lab=vref}
N -420 -200 -420 -240 {lab=vref}
N -420 -240 -380 -240 {lab=vref}
N -60 -120 -30 -120 {lab=eout}
N -30 -120 -30 -160 {lab=eout}
N -30 -160 10 -160 {lab=eout}
N 270 -160 335 -160 {lab=vout}
N 335 -160 335 -300 {lab=vout}
N 335 -300 520 -300 {lab=vout}
N 520 -300 520 -130 {lab=vout}
N 520 -130 520 -90 {lab=vout}
N 200 10 200 -300 {lab=vout}
N 200 -300 520 -300 {lab=vout}
N 520 -300 520 -130 {lab=vout}
N 520 -130 520 -90 {lab=vout}
N 360 260 360 300 {lab=vfb}
N 360 300 -445 300 {lab=vfb}
N -445 300 -445 -160 {lab=vfb}
N -445 -160 -380 -160 {lab=vfb}
N -40 -510 -120 -510 {lab=eout}
N -120 -510 -120 -120 {lab=eout}
N -120 -120 80 -120 {lab=eout}
N 80 -120 -60 -120 {lab=eout}
N -40 -450 -40 -385 {lab=vout}
N -40 -385 60 -385 {lab=vout}
N 60 -385 60 -160 {lab=vout}
N 60 -160 335 -160 {lab=vout}
N 335 -160 270 -160 {lab=vout}
C {devices/lab_pin.sym} -430 -200 0 0 {name=l_net_vref sig_type=std_logic lab=vref}
C {devices/lab_pin.sym} -60 -120 0 0 {name=l_net_eout sig_type=std_logic lab=eout}
C {devices/lab_pin.sym} 270 -160 0 0 {name=l_net_vout sig_type=std_logic lab=vout}
C {devices/lab_pin.sym} 360 260 0 0 {name=l_net_vfb sig_type=std_logic lab=vfb}
C {ldo_vref.sym} -560 -200 0 0 {name=x_vref }
N -690 -200 -740 -200 {lab=vref_bg}
C {devices/lab_pin.sym} -740 -200 0 1 {name=l_x_vref_vref_bg sig_type=std_logic lab=vref_bg}
N -560 -110 -560 -70 {lab=vss}
C {devices/lab_pin.sym} -560 -70 0 0 {name=l_x_vref_vss sig_type=std_logic lab=vss}
C {ldo_erramp.sym} -220 -120 0 0 {name=x_amp }
N -380 -80 -380 -40 {lab=ibias}
C {devices/lab_pin.sym} -380 -40 0 0 {name=l_x_amp_ibias sig_type=std_logic lab=ibias}
N -380 0 -380 40 {lab=en_n}
C {devices/lab_pin.sym} -380 40 0 0 {name=l_x_amp_en_n sig_type=std_logic lab=en_n}
N -220 -330 -220 -370 {lab=vin}
C {devices/lab_pin.sym} -220 -370 0 0 {name=l_x_amp_vin sig_type=std_logic lab=vin}
N -220 90 -220 130 {lab=vss}
C {devices/lab_pin.sym} -220 130 0 0 {name=l_x_amp_vss sig_type=std_logic lab=vss}
C {ldo_pass.sym} 140 -160 0 0 {name=x_pass }
N 140 -250 140 -290 {lab=vin}
C {devices/lab_pin.sym} 140 -290 0 0 {name=l_x_pass_vin sig_type=std_logic lab=vin}
C {ldo_fbtrim.sym} 200 260 0 0 {name=x_fb }
N 200 510 200 550 {lab=vss}
C {devices/lab_pin.sym} 200 550 0 0 {name=l_x_fb_vss sig_type=std_logic lab=vss}
N 40 100 40 60 {lab=vtrim0}
C {devices/lab_pin.sym} 40 60 0 0 {name=l_x_fb_vtrim0 sig_type=std_logic lab=vtrim0}
N 40 180 40 140 {lab=vtrim1}
C {devices/lab_pin.sym} 40 140 0 0 {name=l_x_fb_vtrim1 sig_type=std_logic lab=vtrim1}
N 40 260 -10 260 {lab=vtrim2}
C {devices/lab_pin.sym} -10 260 0 1 {name=l_x_fb_vtrim2 sig_type=std_logic lab=vtrim2}
N 40 340 40 380 {lab=vtrim3}
C {devices/lab_pin.sym} 40 380 0 0 {name=l_x_fb_vtrim3 sig_type=std_logic lab=vtrim3}
N 40 420 40 460 {lab=vtrim4}
C {devices/lab_pin.sym} 40 460 0 0 {name=l_x_fb_vtrim4 sig_type=std_logic lab=vtrim4}
C {sg13cmos5l_pr/cap_mfringe.sym} -40 -480 0 0 {name=Cc model=cap_mfringe mmin=1 mmax=4 spiceprefix=X w=30u l=30u}
C {sg13cmos5l_pr/sg13_hv_nmos.sym} 700 120 0 0 {name=Mpre l=1u w=2u ng=1 m=1 model=sg13_hv_nmos spiceprefix=X}
N 720 90 720 50 {lab=vout}
C {devices/lab_pin.sym} 720 50 0 0 {name=l_Mpre_D sig_type=std_logic lab=vout}
N 680 120 630 120 {lab=ibias}
C {devices/lab_pin.sym} 630 120 0 1 {name=l_Mpre_G sig_type=std_logic lab=ibias}
N 720 150 720 190 {lab=vss}
C {devices/lab_pin.sym} 720 190 0 0 {name=l_Mpre_S sig_type=std_logic lab=vss}
N 720 120 790 120 {lab=vss}
C {devices/lab_pin.sym} 790 120 0 0 {name=l_Mpre_B sig_type=std_logic lab=vss}
C {ldo_enable.sym} -780 560 0 0 {name=x_en }
N -940 520 -940 480 {lab=en}
C {devices/lab_pin.sym} -940 480 0 0 {name=l_x_en_en sig_type=std_logic lab=en}
N -620 600 -620 640 {lab=en_n}
C {devices/lab_pin.sym} -620 640 0 0 {name=l_x_en_en_n sig_type=std_logic lab=en_n}
N -940 600 -940 640 {lab=ibias}
C {devices/lab_pin.sym} -940 640 0 0 {name=l_x_en_ibias sig_type=std_logic lab=ibias}
N -620 520 -620 480 {lab=eout}
C {devices/lab_pin.sym} -620 480 0 0 {name=l_x_en_eout sig_type=std_logic lab=eout}
N -830 430 -830 390 {lab=vin}
C {devices/lab_pin.sym} -830 390 0 0 {name=l_x_en_vin sig_type=std_logic lab=vin}
N -730 430 -730 390 {lab=vddd}
C {devices/lab_pin.sym} -730 390 0 0 {name=l_x_en_vddd sig_type=std_logic lab=vddd}
N -780 690 -780 730 {lab=vss}
C {devices/lab_pin.sym} -780 730 0 0 {name=l_x_en_vss sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/cap_mfringe.sym} 520 -60 0 0 {name=Cout model=cap_mfringe mmin=1 mmax=4 spiceprefix=X w=93u l=93u}
N 520 -30 520 10 {lab=vss}
C {devices/lab_pin.sym} 520 10 0 0 {name=l_Cout_c2 sig_type=std_logic lab=vss}
C {devices/iopin.sym} -640 -300 0 0 {name=p_vin lab=vin}
C {devices/iopin.sym} -640 -240 0 0 {name=p_vout lab=vout}
C {devices/ipin.sym} -640 -180 0 0 {name=p_vref_bg lab=vref_bg}
C {devices/ipin.sym} -640 -120 0 0 {name=p_ibias lab=ibias}
C {devices/ipin.sym} -640 -60 0 0 {name=p_en lab=en}
C {devices/iopin.sym} -640 0 0 0 {name=p_vddd lab=vddd}
C {devices/iopin.sym} -640 60 0 0 {name=p_vss lab=vss}
C {devices/ipin.sym} -640 120 0 0 {name=p_vtrim0 lab=vtrim0}
C {devices/ipin.sym} -640 180 0 0 {name=p_vtrim1 lab=vtrim1}
C {devices/ipin.sym} -640 240 0 0 {name=p_vtrim2 lab=vtrim2}
C {devices/ipin.sym} -640 300 0 0 {name=p_vtrim3 lab=vtrim3}
C {devices/ipin.sym} -640 360 0 0 {name=p_vtrim4 lab=vtrim4}
