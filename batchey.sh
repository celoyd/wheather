# fetch and process all tiles
for row in {1..19}; do
	if [ $row -lt 10 ]; then
		row="0"$row
	fi
	for column in {0..39}; do
		rm -r raws/ >/dev/null 2>&1
		rm -r slice/ >/dev/null 2>&1
		rm -r cube/ >/dev/null 2>&1
		rm -r final-slices/ >/dev/null 2>&1

		if [ $column -lt 10 ]; then
			column="0"$column
		fi
		identifier="r"$row"c"$column

		bash dothestuff.sh "2km" 2012 150 180 "http://lance-modis.eosdis.nasa.gov/imagery/subsets/RRGlobal_$identifier/\$day/RRGlobal_$identifier.\$day.terra.\$res.jpg" 4 "RRGlobal_$identifier"
	done
done

# patch holes with white pngs
for row in {0..19}; do
	if [ $row -lt 10 ]; then
		row="0"$row
	fi
	for column in {0..39}; do
		if [ $column -lt 10 ]; then
			column="0"$column
		fi
		identifier="r"$row"c"$column

		if [ ! -f RRGlobal_$identifier.png ]; then
			cp white.png RRGlobal_$identifier.png
		fi
	done
done

# stitch tiles
montagestring=""
for row in {19..0}; do
	if [ $row -lt 10 ]; then
		row="0"$row
	fi
	for column in {0..39}; do
		if [ $column -lt 10 ]; then
			column="0"$column
		fi
		identifier="r"$row"c"$column

		montagestring=$montagestring" RRGlobal_"$identifier".png"
	done
done
#echo $montagestring
montage -mode concatenate -tile 40x20 $montagestring montage.png