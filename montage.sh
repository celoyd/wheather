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
