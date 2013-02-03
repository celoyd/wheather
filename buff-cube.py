#!/usr/bin/env python

'''

Main python driver for the sorting.

buff-cube.py images* output-directory

'''

from pxpack import pack, unpack
import Image
from sys import argv, exit
import os.path
from numpy import uint32, empty
#import time

paths = argv[1:-1]
count = len(paths) # number of images to process
clean = count/4 + 2 # how many images to output

'''
For speed, we don't want to re-sort the pixel solid every time we add a new
image, but for space, we don't want to store pixels we know we aren't going
to use. So we re-sort every margin_len new images. Smaller is slower but more
space-efficient.

To do:
+ Completely overhaul
+ Variable names
+ Comments
+ Optimization

Basically, I patched this together in a series of fugue states. It works,
but it needs a lot of work.

Incidentally, if numpypy ever supports .sort(), we can use pypy and this whole 
thing should be significantly faster.
'''
margin_len = 8

print 'sorting %s images down to %s' % (count, clean-1)

outdir = argv[-1]
if not os.path.isdir(outdir):
	print 'no such dir %s' % (outdir)
	exit(1)
else:
	print 'output dir:' + outdir
size = None
a = None # who the hell named these variables?

margin_ptr = 0

for c in range(count):
	try:
		img = Image.open(paths[c])
		i = img.load()
	except IOError as e:
		print "Error:", e
		print 'skipping %s' % (paths[c])
		continue

	print 'loading %s' % (paths[c])

	if size == None:
		size = img.size
		a = empty([size[1], size[0], clean + margin_len], dtype=uint32)
		a.fill(0xffff88ff) # sentinel bad value
	
	for x in range(size[0]):
		for y in range(size[1]):
			a[y, x, clean-1+margin_ptr+1] = pack(i[x, y])
	
	margin_ptr += 1
	
	if margin_ptr == margin_len:
		a.sort()
		margin_ptr = 0

if not (a == None):
	a.sort() # possibly unnecessary, but it's not like we're optimizing heavily

	for c in range(clean-1):
		jmg = Image.new('RGB', img.size)
		j = jmg.load()
		for x in range(img.size[0]):
			for y in range(img.size[1]):
				j[x, y] = unpack(a[y, x, c])
		#print 'saving %s' % (c)
		jmg.save('%s/%s.png' % (outdir, c))
	print "Finished sorting."
else:
	print "No images to process"
