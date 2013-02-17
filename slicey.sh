#!/bin/zsh

mkdir -p slice/{0..7};

cd raws;

for J in *.jpg; do
	for slice in {0..7}; do
		echo "slicing $J";
		cat $J | jpegtran -perfect -crop 1024x128+0+$(($slice * 128)) > ../slice/$step/$J;
	done;
done;
