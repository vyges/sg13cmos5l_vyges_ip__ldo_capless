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
N -430 -120 -380 -120 {lab=vref}
N -380 -120 -380 -200 {lab=vref}
N -60 -120 10 -120 {lab=eout}
N 10 -120 10 -160 {lab=eout}
N 270 -160 270 -300 {lab=vout}
N 270 -300 520 -300 {lab=vout}
N 520 -300 520 -90 {lab=vout}
N 200 10 200 -300 {lab=vout}
N 200 -300 520 -300 {lab=vout}
N 520 -300 520 -90 {lab=vout}
N 360 260 360 300 {lab=vfb}
N 360 300 -380 300 {lab=vfb}
N -380 300 -380 -120 {lab=vfb}
N -40 -510 -120 -510 {lab=eout}
N -120 -510 -120 -120 {lab=eout}
N -120 -120 -60 -120 {lab=eout}
N -40 -450 60 -450 {lab=vout}
N 60 -450 60 -160 {lab=vout}
N 60 -160 270 -160 {lab=vout}
C {devices/lab_pin.sym} -430 -120 0 0 {name=l_net_vref sig_type=std_logic lab=vref}
C {devices/lab_pin.sym} -60 -120 0 0 {name=l_net_eout sig_type=std_logic lab=eout}
C {devices/lab_pin.sym} 270 -160 0 0 {name=l_net_vout sig_type=std_logic lab=vout}
C {devices/lab_pin.sym} 360 260 0 0 {name=l_net_vfb sig_type=std_logic lab=vfb}
C {ldo_vref.sym} -560 -120 0 0 {name=x_vref }
N -690 -120 -740 -120 {lab=vref_bg}
C {devices/lab_pin.sym} -740 -120 0 1 {name=l_x_vref_vref_bg sig_type=std_logic lab=vref_bg}
N -560 -30 -560 10 {lab=vss}
C {devices/lab_pin.sym} -560 10 0 0 {name=l_x_vref_vss sig_type=std_logic lab=vss}
C {ldo_erramp.sym} -220 -120 0 0 {name=x_amp }
N -380 -40 -380 0 {lab=ibias}
C {devices/lab_pin.sym} -380 0 0 0 {name=l_x_amp_ibias sig_type=std_logic lab=ibias}
N -220 -290 -220 -330 {lab=vin}
C {devices/lab_pin.sym} -220 -330 0 0 {name=l_x_amp_vin sig_type=std_logic lab=vin}
N -220 50 -220 90 {lab=vss}
C {devices/lab_pin.sym} -220 90 0 0 {name=l_x_amp_vss sig_type=std_logic lab=vss}
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
C {sg13cmos5l_pr/cap_mfringe.sym} 520 -60 0 0 {name=Cout model=cap_mfringe mmin=1 mmax=4 spiceprefix=X w=93u l=93u}
N 520 -30 520 10 {lab=vss}
C {devices/lab_pin.sym} 520 10 0 0 {name=l_Cout_c2 sig_type=std_logic lab=vss}
C {devices/iopin.sym} -640 -300 0 0 {name=p_vin lab=vin}
C {devices/iopin.sym} -640 -240 0 0 {name=p_vout lab=vout}
C {devices/ipin.sym} -640 -180 0 0 {name=p_vref_bg lab=vref_bg}
C {devices/ipin.sym} -640 -120 0 0 {name=p_ibias lab=ibias}
C {devices/iopin.sym} -640 -60 0 0 {name=p_vss lab=vss}
C {devices/ipin.sym} -640 0 0 0 {name=p_vtrim0 lab=vtrim0}
C {devices/ipin.sym} -640 60 0 0 {name=p_vtrim1 lab=vtrim1}
C {devices/ipin.sym} -640 120 0 0 {name=p_vtrim2 lab=vtrim2}
C {devices/ipin.sym} -640 180 0 0 {name=p_vtrim3 lab=vtrim3}
C {devices/ipin.sym} -640 240 0 0 {name=p_vtrim4 lab=vtrim4}
