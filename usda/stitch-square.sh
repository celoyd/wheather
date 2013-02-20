#!/bin/bash
SQUARE=$1;
mkdir -p tmp;
for step in {0..3}; do
    convert \
      -average \
      $SQUARE/cube/$step/{0..15}.png \
      tmp/$step.png;
done; 
montage \
   -mode concatenate \
   -tile 1x4 \
   tmp/{0..3}.png \
   $SQUARE-rendered.png

GEOREF=$(ls -1S  $SQUARE/RRGlobal* |  head -n 1);
DATE=$(echo $GEOREF | sed -E 's_^([^\.]+)\.([^\.]+)\..*$_\2_g');
GLOBAL_REF=$(echo $GEOREF | sed -E 's_^([^/]+)/([^\.]+)\.([^\.]+)\..*$_\2_g');
IMG_STEM=$(echo ${GEOREF%.jpg} | sed -E 's_^[^/]+/(.*)$_\1_g');

wget \
   -O $SQUARE-rendered.pgw \
   http://lance-modis.eosdis.nasa.gov/imagery/subsets/$GLOBAL_REF/$DATE/$IMG_STEM.jgw

gdalwarp \
    -s_srs EPSG:4326\
    -multi \
    -wm 3000\
    -r lanczos \
    -t_srs EPSG:900913 \
    -co COMPRESS=LZW \
    -co TILED=YES \
    $SQUARE-rendered.png \
    $SQUARE-rendered.tif
gdaladdo \
    -r cubic \
    $SQUARE-rendered.tif \
    2 4 8 16 32 64 128 256 512 1024
rm -rf tmp
