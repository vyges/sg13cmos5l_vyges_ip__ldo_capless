#!/bin/sh
# pvt_point.sh <corner> <res> <temp> <vin> <iload> -- ONE point of sim/run_pvt.sh's sweep.
# Writes pvt/_pt_<tag> ("<tag> <vout> <iq>") and pvt/<tag>.csv (the bench's wrdata). Run from
# sim/ with M (the models directory) exported, as run_pvt.sh does; its own deck and log
# names carry the tag, so points can run side by side.
corner=$1 res=$2 temp=$3 vin=$4 iload=$5
tag="${corner}_${res}_${temp}_${vin}_${iload}"
sed -e "s|@MOS@|mos_$corner|g" -e "s|@RES@|$res|g" -e "s|@TEMP@|$temp|g" \
    -e "s|@VIN@|$vin|g" -e "s|@TAG@|$tag|g" -e "s|@M@|$M|g" \
    -e "s|@ILOAD@|$iload|g" tb_ldo_pvt.tpl > "_p_$tag.spice"
ngspice -b "_p_$tag.spice" > "_p_$tag.log" 2>&1 || true
vout=$(grep -oE "^v\(vout\) = [-0-9.e+]+" "_p_$tag.log" | head -1 | grep -oE "[-0-9.e+]+$")
iq=$(grep -oE "^-i\(vin\) = [-0-9.e+]+" "_p_$tag.log" | head -1 | grep -oE "[-0-9.e+]+$")
echo "$tag ${vout:-fail} ${iq:-?}" > "pvt/_pt_$tag"
rm -f "_p_$tag.spice" "_p_$tag.log"
