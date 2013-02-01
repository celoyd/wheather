#!/bin/zsh

mkdir -p cube/{$1..$2}

for slice in {$1..$2}; do
    python buff-cube.py slice/$slice/*.jpg cube/$slice/ &
done

wait
