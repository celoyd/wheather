#!/bin/zsh

# number of slices, 0th-indexed
slices=$2
echo slices: $slices

mkdir -p slice/{0..$slices};

cd raws;

# get width of first image
imgwidth=`identify -format "%w" \`ls | sort -n | head -1\``;
echo imgwidth: $imgwidth
# divide by numer of slices (add 1 back in there, cuz 0th-indexed)
myslices=`expr $slices + 1`;
echo myslices: $myslices
slicewidth=`expr $imgwidth / $myslices`;
echo slicewidth: $slicewidth

for J in *.jpg; do
	for ((slice=0; slice<=$slices; slice++)); do
		echo "slicing $J";
		cat $J | jpegtran -perfect -crop $imgwidth"x"$slicewidth+0+$(($slice * $slicewidth)) > ../slice/$slice/$J;
	done;
done;
