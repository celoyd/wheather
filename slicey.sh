#!/bin/zsh

mkdir -p slice/{0..7};

cd $1

# get first file in dir
file=`ls -1 | head -1`
# get image dimensions of file
width=`identify -format "%w" $file`
height=`identify -format "%h" $file`

for J in *.jpg; do
	echo "slicing" $J;
	# divide height by number of slices to get height of each slice
	sliceheight=`expr $height / 8`
	for step in {0..7}; do 
		offset_height=$(($step * $sliceheight))
		if [ $step -eq 7 ]
		then
			# make last slice height the remaining height, to account for rounding
			sliceheight=$(($height - $offset_height))
		fi
		crop_params=$width"x"$sliceheight"+0+"$offset_height
		#echo "crop:" $crop_params
		#cat $J | jpegtran -perfect -crop 1024x128+0+$(($step * 128)) > ../slice/$step/$J;
		cat $J | jpegtran -perfect -crop $crop_params > ../slice/$step/$J;
	done;
done;