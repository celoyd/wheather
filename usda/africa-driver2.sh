for col in {19..23}; do
	for gridcell in r{11..13}c$col; do
		./cell-driver.sh $gridcell &
	done;
	wait;
done;
