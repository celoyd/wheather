#!/bin/zsh
# if only one arg, use it twice
if [ $# -eq 1 ]
then
	2=$1
fi
mkdir -p cube/{$1..$2}

for slice in {$1..$2}; do
	python buff-cube.py slice/$slice/*.jpg cube/$slice/
done
