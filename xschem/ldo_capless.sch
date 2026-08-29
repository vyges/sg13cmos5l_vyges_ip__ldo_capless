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
C {ldo_vref.sym} -540 -180 0 0 {name=x_vref }
N -670 -180 -720 -180 {lab=vref_bg}
C {devices/lab_pin.sym} -720 -180 0 1 {name=l_x_vref_vref_bg sig_type=std_logic lab=vref_bg}
N -410 -180 -260 -180 {lab=vref}
C {devices/lab_pin.sym} -260 -180 0 0 {name=l_x_vref_vref sig_type=std_logic lab=vref}
N -540 -90 -540 -50 {lab=vss}
C {devices/lab_pin.sym} -540 -50 0 0 {name=l_x_vref_vss sig_type=std_logic lab=vss}
C {ldo_erramp.sym} 0 -180 0 0 {name=x_amp }
N -160 -260 -160 -300 {lab=vref}
C {devices/lab_pin.sym} -160 -300 0 0 {name=l_x_amp_vref sig_type=std_logic lab=vref}
N -160 -180 -210 -180 {lab=vfb}
C {devices/lab_pin.sym} -210 -180 0 1 {name=l_x_amp_vfb sig_type=std_logic lab=vfb}
N -160 -100 -160 -60 {lab=ibias}
C {devices/lab_pin.sym} -160 -60 0 0 {name=l_x_amp_ibias sig_type=std_logic lab=ibias}
N 160 -180 310 -180 {lab=eout}
C {devices/lab_pin.sym} 310 -180 0 0 {name=l_x_amp_eout sig_type=std_logic lab=eout}
N 0 -350 0 -390 {lab=vin}
C {devices/lab_pin.sym} 0 -390 0 0 {name=l_x_amp_vin sig_type=std_logic lab=vin}
N 0 -10 0 30 {lab=vss}
C {devices/lab_pin.sym} 0 30 0 0 {name=l_x_amp_vss sig_type=std_logic lab=vss}
C {ldo_pass.sym} 540 -250 0 0 {name=x_pass }
N 410 -250 360 -250 {lab=eout}
C {devices/lab_pin.sym} 360 -250 0 1 {name=l_x_pass_eout sig_type=std_logic lab=eout}
N 540 -340 540 -380 {lab=vin}
C {devices/lab_pin.sym} 540 -380 0 0 {name=l_x_pass_vin sig_type=std_logic lab=vin}
N 670 -250 820 -250 {lab=vout}
C {devices/lab_pin.sym} 820 -250 0 0 {name=l_x_pass_vout sig_type=std_logic lab=vout}
C {ldo_fbtrim.sym} 540 220 0 0 {name=x_fb }
N 540 -30 540 -70 {lab=vout}
C {devices/lab_pin.sym} 540 -70 0 0 {name=l_x_fb_vout sig_type=std_logic lab=vout}
N 700 220 850 220 {lab=vfb}
C {devices/lab_pin.sym} 850 220 0 0 {name=l_x_fb_vfb sig_type=std_logic lab=vfb}
N 540 470 540 510 {lab=vss}
C {devices/lab_pin.sym} 540 510 0 0 {name=l_x_fb_vss sig_type=std_logic lab=vss}
N 380 60 380 20 {lab=vtrim0}
C {devices/lab_pin.sym} 380 20 0 0 {name=l_x_fb_vtrim0 sig_type=std_logic lab=vtrim0}
N 380 140 380 100 {lab=vtrim1}
C {devices/lab_pin.sym} 380 100 0 0 {name=l_x_fb_vtrim1 sig_type=std_logic lab=vtrim1}
N 380 220 330 220 {lab=vtrim2}
C {devices/lab_pin.sym} 330 220 0 1 {name=l_x_fb_vtrim2 sig_type=std_logic lab=vtrim2}
N 380 300 380 340 {lab=vtrim3}
C {devices/lab_pin.sym} 380 340 0 0 {name=l_x_fb_vtrim3 sig_type=std_logic lab=vtrim3}
N 380 380 380 420 {lab=vtrim4}
C {devices/lab_pin.sym} 380 420 0 0 {name=l_x_fb_vtrim4 sig_type=std_logic lab=vtrim4}
C {sg13cmos5l_pr/cap_mfringe.sym} 270 -470 0 0 {name=Cc model=cap_mfringe mmin=1 mmax=4 spiceprefix=X w=30u l=30u}
N 270 -500 270 -540 {lab=eout}
C {devices/lab_pin.sym} 270 -540 0 0 {name=l_Cc_c1 sig_type=std_logic lab=eout}
N 270 -440 270 -400 {lab=vout}
C {devices/lab_pin.sym} 270 -400 0 0 {name=l_Cc_c2 sig_type=std_logic lab=vout}
C {sg13cmos5l_pr/cap_mfringe.sym} 1010 -110 0 0 {name=Cout model=cap_mfringe mmin=1 mmax=4 spiceprefix=X w=93u l=93u}
N 1010 -140 1010 -180 {lab=vout}
C {devices/lab_pin.sym} 1010 -180 0 0 {name=l_Cout_c1 sig_type=std_logic lab=vout}
N 1010 -80 1010 -40 {lab=vss}
C {devices/lab_pin.sym} 1010 -40 0 0 {name=l_Cout_c2 sig_type=std_logic lab=vss}
C {devices/iopin.sym} -1150 -540 0 0 {name=p_vin lab=vin}
C {devices/iopin.sym} -1150 -480 0 0 {name=p_vout lab=vout}
C {devices/ipin.sym} -1150 -420 0 0 {name=p_vref_bg lab=vref_bg}
C {devices/ipin.sym} -1150 -360 0 0 {name=p_ibias lab=ibias}
C {devices/iopin.sym} -1150 -300 0 0 {name=p_vss lab=vss}
C {devices/ipin.sym} -1150 -240 0 0 {name=p_vtrim0 lab=vtrim0}
C {devices/ipin.sym} -1150 -180 0 0 {name=p_vtrim1 lab=vtrim1}
C {devices/ipin.sym} -1150 -120 0 0 {name=p_vtrim2 lab=vtrim2}
C {devices/ipin.sym} -1150 -60 0 0 {name=p_vtrim3 lab=vtrim3}
C {devices/ipin.sym} -1150 0 0 0 {name=p_vtrim4 lab=vtrim4}
