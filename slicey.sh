#!/bin/zsh

mkdir -p slice/{0..7};

cd $1
for J in *.jpg; do
	for step in {0..7}; do 
		cat $J | jpegtran -perfect -crop 1024x128+0+$(($step * 128)) > ../slice/$step/$J;
	done;
done;