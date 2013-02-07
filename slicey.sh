#!/bin/zsh

slices=$2
# if no argument passed, set slices to 8
if [ -z "$2" ]; then
	# (0th-indexed = 7)
	slices=8
fi

#mkdir -p slice/{0..7};
mkdir -p $(eval echo slice/{0..$slices})

cd $1

# get first file in dir
file=`ls -1 | head -1`

if [ `identify -format %m $file` != "JPEG" ]; then
	exit("$file is not a jpg!")
fi
# get image dimensions of file
width=`identify -format "%w" $file`
height=`identify -format "%h" $file`

for J in *.jpg; do
	echo "slicing" $J;
	# divide height by number of slices to get height of each slice
	sliceplus=`expr $slices + 1`
	sliceheight=`expr $height / $sliceplus`
	for step in $(eval echo {0..$slices}); do 
		offset_height=$(($step * $sliceheight))
		# if the last slice:
		if [ $step -eq $slices ]; then
			# make last slice height the remaining height, to account for rounding
			sliceheight=$(($height - $offset_height))
		fi
		crop_params=$width"x"$sliceheight"+0+"$offset_height
		#echo "crop:" $crop_params
		#cat $J | jpegtran -perfect -crop 1024x128+0+$(($step * 128)) > ../slice/$step/$J;
		cat $J | jpegtran -perfect -crop $crop_params > ../slice/$step/$J;
	done;
done;