#!/bin/bash

VRT="$1"
RED="$2"
GREEN="$3"
BLUE="$4"

declare -a LUT=("$RED" "$GREEN" "$BLUE");
gdalbuildvrt  \
   -q -srcnodata "0 0 0" \
   -vrtnodata "0 0 0" \
   $VRT  /root/usda_grid/*-rendered.tif
sed -i "s~<SourceBand>1</SourceBand>~<SourceBand>1</SourceBand><LUT>${LUT[0]}</LUT>~g" $VRT
sed -i "s~<SourceBand>2</SourceBand>~<SourceBand>2</SourceBand><LUT>${LUT[1]}</LUT>~g" $VRT
sed -i "s~<SourceBand>3</SourceBand>~<SourceBand>3</SourceBand><LUT>${LUT[2]}</LUT>~g" $VRT
