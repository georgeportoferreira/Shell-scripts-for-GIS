#!/bin/bash
#
# ***************************************************************************
# Name                 : Footprint
# Description          : Create footprint of image with GeoJSON format
#
# Arguments: 
# $1: Image
#
# Dependencies         : gdal 1.10.1(gdal_calc.py, gdal_sieve.py, gdal_edit.py and gdal_polygonize.py)
#
# ***************************************************************************
# begin                : 2015-03-02 (yyyy-mm-dd)
# copyright            : (C) 2015 by Luiz Motta
# email                : motta dot luiz at gmail.com
# ***************************************************************************
#
# Revisions
#
# 0000-00-00:
# - None
#
# ***************************************************************************
#
# Example:
#   footprint.sh LC8_229-066_20140724_LGN00_r6g5b4.tif
#
# ***************************************************************************
# *                                                                         *
# *   This program is free software; you can redistribute it and/or modify  *
# *   it under the terms of the GNU General Public License as published by  *
# *   the Free Software Foundation; either version 2 of the License, or     *
# *   (at your option) any later version.                                   *
# *                                                                         *
# ***************************************************************************
#
msg_error(){
  local name_script=$(basename $0)
  echo "Usage: $name_script <image> <outsize>" >&2
  echo "<image> is the image for calculate footprint" >&2
}
#
totalargs=1
#
if [ $# -ne $totalargs ] ; then
  msg_error
  exit 1
fi
#
in_img=$1
#
if [ ! -f "$in_img" ]; then
  echo "The file '$in_img' not exist" >&2
  exit 1
fi
#
dir_img=$(dirname $in_img)
basename_img=$(basename $in_img)
name_img=${basename_img%.*}
#
footprint_geojson=$dir_img"/"$name_img".geojson"
zero_one_img=$dir_img"/"$name_img"_0x1.tif"
sieve_img=$dir_img"/"$name_img"_0x1_sieve.tif"
#
if [ -f $footprint_geojson ]; then
 rm $footprint_geojson
fi
# Processing
printf "'$name_img'...1"
gdal_calc.py -A $in_img --A_band 1 --type Byte --calc "A>0" --outfile $zero_one_img >/dev/null
printf ".2"
gdal_sieve.py -q -st 100 -8 $zero_one_img -nomask $sieve_img
gdal_edit.py -a_nodata 0 $sieve_img
printf ".3"
gdal_polygonize.py $sieve_img -q -b 1 -f "GeoJSON" $footprint_geojson
sed -i 's/{ "DN": 1 }/{ "image": "'$name_img'" }/g' $footprint_geojson
printf ".created: $footprint_geojson\n"
# Cleanup
rm $zero_one_img $sieve_img
