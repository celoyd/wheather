#!/bin/zsh

# set options: [res(olution): 2km | 1km | 250m] [year, eg: 2012] [day_start: 0-365] [day_end: 0-365] (no 500m? weird)
# whole earth: rows 0-40
# whole earth: cols 0-20
startrow=14
endrow=15
startcol=20
endcol=21
res="1km"
year=2013
day_start=180
day_end=210

function timer()
{
  if [[ $# -eq 0 ]]; then
        echo $(date '+%s')
    else
        local  stime=$1
        etime=$(date '+%s')

        if [[ -z "$stime" ]]; then stime=$etime; fi

        dt=$((etime - stime))
        ds=$((dt % 60))
        dm=$(((dt / 60) % 60))
        dh=$((dt / 3600))
        printf '%d:%02d:%02d' $dh $dm $ds
    fi
}
tmr=$(timer)
# fetch and process tiles
width=`expr $endrow - $startrow + 1`
height=`expr $endcol - $startcol + 1`
for ((row=$startrow; row<=$endrow; row++)); do
	if [ $row -lt 10 ]; then
		row="0"$row
	fi
	for ((column=$startcol; column<=$endcol; column++)); do
		rm -r raws/ >/dev/null 2>&1
		rm -r slice/ >/dev/null 2>&1
		rm -r cube/ >/dev/null 2>&1
		rm -r final-slices/ >/dev/null 2>&1

		if [ $column -lt 10 ]; then
			column="0"$column
		fi
		identifier="r"$row"c"$column

		bash dothestuff.sh $res $year $day_start $day_end "http://lance-modis.eosdis.nasa.gov/imagery/subsets/RRGlobal_$identifier/\$day/RRGlobal_$identifier.\$day.terra.\$res.jpg" 8 "RRGlobal_$identifier"
	done
done

# patch holes with white pngs
for ((row=$startrow; row<=$endrow; row++)); do
	if [ $row -lt 10 ]; then
		row="0"$row
	fi
	for ((column=$startcol; column<=$endcol; column++)); do
		if [ $column -lt 10 ]; then
			column="0"$column
		fi
		identifier="r"$row"c"$column

		if [ ! -f RRGlobal_$identifier.png ]; then
      echo "RRGlobal_"$identifier".png not found"
			cp white.jpg RRGlobal_$identifier".png"
		fi
	done
done

# stitch tiles
montagestring=""
# why is this backwards? not sure anymore
for ((row=$endrow; row>=$startrow; row--)); do
	if [ $row -lt 10 ]; then
		row="0"$row
	fi
	for ((column=$startcol; column<=$endcol; column++)); do
		if [ $column -lt 10 ]; then
			column="0"$column
		fi
		identifier="r"$row"c"$column

		montagestring=$montagestring" RRGlobal_"$identifier".png"
	done
done
echo $montagestring
montage -mode concatenate -tile $width"x"$height $montagestring montage.png

printf 'Elapsed time: %s\n' $(timer $tmr) 

