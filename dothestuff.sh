#!/bin/zsh

# usage:
# zsh dothestuff.sh [resolution: 2km | 1km | 500m | 250m]
res=$1
year=$2
day_start=$3
day_end=$4
if [ -z "$3" ]
then
	# pick a northern-hemisphere-centric summer range
	day_start=180
	day_end=210
	echo "Setting day range to 180..210"
fi
if [ -z "$2" ]
then
	year="2012"
	echo "Setting year to "$year"."
fi
if [ -z "$1" ]
then
	res="2km"
	echo "Setting resolution to "$res"."
fi
mkdir raws
cd raws

for day in $(eval echo $year"{$day_start..$day_end}"); do
	echo "day: "$day
	path="http://lance-modis.eosdis.nasa.gov/imagery/subsets/RRGlobal_r06c22/$day/RRGlobal_r06c22.$day.terra.$res.jpg";
	#path="http://lance-modis.eosdis.nasa.gov/imagery/subsets/?subset=Sudan.$day.terra.$res.jpg"

	# handle dynamic URIs such as "/?subset=Sudan.$day.terra.$res.jpg"
	# look for an equals sign in the path - if it exists, set the 
	# output filename to anything after the equals sign
	regex='(?<=\=).*'
	outfile=`echo $path | grep -oP $regex`
	if [[ $outfile ]]; then
		# specify an output path
		curl -o $outfile $path;
	else
		# use the default curl output behavior
		curl -O $path;
	fi
done
cd ..
zsh slicey.sh raws
zsh cube-driver.sh 0 7
mkdir final-slices
for slice in {0..7}; do python avgimg.py cube/$slice/* final-slices/$slice.png; done
montage -mode concatenate -tile 1x final-slices/{0..7}.png final.png
echo "Finished!"