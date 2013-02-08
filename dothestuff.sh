#!/bin/bash

# wheather master control program
# usage:
# bash dothestuff.sh [res(olution): 2km | 1km | 500m | 250m] [year, eg: 2012] [day_start: 0-365] [day_end: 0-365]

res=$1
year=$2
day_start=$3
day_end=$4
path=$5
slices=$6
output=$7

# set defaults if arguments are not included
if [ -z "$7" ]; then
	output="final.png"
fi
if [ -z "$6" ]; then
	# use 8 slices, 0th-indexed
	slices=7
else
	slices=$(( $6 - 1 ))
fi
#echo "slices:" $slices
if [ -z "$3" ]; then
	# pick a northern-hemisphere-centric summer range
	day_start=180
	day_end=210
	echo "Setting day range to 180..210"
fi
if [ -z "$2" ]; then
	year="2012"
	echo "Setting year to "$year"."
fi
if [ -z "$1" ]; then
	res="2km"
	echo "Setting resolution to "$res"."
fi


mkdir raws
cd raws

for day in $(eval echo $year"{$day_start..$day_end}"); do

	if [ -z "$5" ]; then

		# The "path" variable is a generic form of the filepath to be fetched and processed.
		# Note the $day and $res variables in the filename.
		
		# spain	#path="http://lance-modis.eosdis.nasa.gov/imagery/subsets/RRGlobal_r14c19/$day/RRGlobal_r14c19.$day.terra.$res.jpg"

		# new zealand
		path="http://lance-modis.eosdis.nasa.gov/imagery/subsets/RRGlobal_r05c39/$day/RRGlobal_r05c39.$day.terra.$res.jpg"
		
		# brittany	#path="http://lance-modis.eosdis.nasa.gov/imagery/subsets/RRGlobal_r15c19/$day/RRGlobal_r15c19.$day.terra.$res.jpg"

		# horn of africa	#path="http://lance-modis.eosdis.nasa.gov/imagery/subsets/RRGlobal_r06c22/$day/RRGlobal_r06c22.$day.terra.$res.jpg";

		# sudan
		#path="http://lance-modis.eosdis.nasa.gov/imagery/subsets/?subset=Sudan.$day.terra.$res.jpg"
	else
		path=$5
		# parse escaped variable names in passed path
		path=`eval echo \$path`
	fi
	# handle dynamic URIs such as "/?subset=Sudan.$day.terra.$res.jpg"
	# look for an equals sign in the path - if it exists, set the 
	# output filename to whatever comes after the equals sign
	regex='(?<=\=).*'
	outfile=`echo $path | grep -oP $regex`
	echo "downloading: "$path
	# test for existence of the file
	statuscode=$(curl --write-out %{http_code} --silent --output /dev/null $path)
	if [ $statuscode == "404" ]; then
		echo "-- 404 --"
		continue # go to the next iteration of the for loop
	fi
	if [[ $outfile ]]; then
		# specify an output path
		curl -o $outfile $path;
	else
		# use the default curl output behavior
		curl -O $path;
	fi
done

cd ..
zsh slicey.sh raws $slices
zsh cube-driver.sh 0 $slices
mkdir final-slices

# brace expansion happens before variable expansion - resort to eval echo
for slice in $(eval echo {0..$slices}); do
	echo "averaging slice # "$slice
	python avgimg.py cube/$slice/* final-slices/$slice.png;
done
montage -mode concatenate -tile 1x $(eval echo final-slices/{0..$slices}.png) $output.png
echo "wrote file: $output.png"