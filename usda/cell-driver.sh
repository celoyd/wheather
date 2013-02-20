for cell in $@; do
	mkdir $cell;
	cd $cell;
	for date in 2012{001..366}; do 
		curl -O "http://lance-modis.eosdis.nasa.gov/imagery/subsets/RRGlobal_$cell/$date/RRGlobal_$cell.$date.{terra,aqua}.250m.jpg"; 
	done;
	cd ..;
	./render_cell.sh $cell;
done;
