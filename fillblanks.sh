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
