#!/usr/bin/env python

from pxpack import pack, unpack
import Image
from sys import argv, exit
import os.path
from numpy import uint32, empty
#import time

paths = argv[1:-1]
count = len(paths)
clean = count/4 + 2

margin_len = 8

print 'sorting %s images down to %s' % (count, clean-1)

outdir = argv[-1]
if not os.path.isdir(outdir):
	print 'no such dir %s' % (outdir)
	exit(1)

size = None
a = None

margin_ptr = 0

for c in range(count):
	print 'opening %s' % (paths[c])
	
	try:
		img = Image.open(paths[c])
		i = img.load()
	except:
		print 'skipping %s' % (paths[c])
		continue
	
	if size == None:
		size = img.size
		a = empty([size[1], size[0], clean +margin_len], dtype=uint32)
		a.fill(0xffff88ff)
	
	for x in range(size[0]):
		for y in range(size[1]):
			a[y, x, clean-1+margin_ptr+1] = pack(i[x, y])
	
	margin_ptr += 1
	
	if margin_ptr == margin_len:
		a.sort()
		margin_ptr = 0

# if margin_ptr
a.sort()

for c in range(clean-1):
	jmg = Image.new('RGB', img.size)
	j = jmg.load()
	for x in range(img.size[0]):
		for y in range(img.size[1]):
			j[x, y] = unpack(a[y, x, c])
	print 'saving %s' % (c)
	jmg.save('%s/%s.png' % (outdir, c))
