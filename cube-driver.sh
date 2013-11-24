#!/usr/bin/env zsh
# if only one arg, use it twice

if [ $# -eq 1 ]
then
	2=$1
fi

mkdir -p $(eval echo cube/{$1..$2})
#echo "cube?"
#echo `ls cube/`

for ((slice=$1; slice<=$2; slice++)); do
	./buff-cube.py slice/$slice/*.jpg cube/$slice/ &
done

wait
