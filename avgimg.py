#!/usr/bin/env python

'''

Average images with PIL.

avgimg.py input... output

We rely on numpy for capacious but fast types to hold the running sum, 
and on PIL for reading and writing, including guessing the format you 
want from the file suffix.

Todo:
+ More docs
+ Refuse to clobber an existing output file?
+ Better error-checking in general

'''

from sys import argv, exit
import Image
import time
from numpy import *

avgtype = float32 # 16 for faster and worse, 64 for slower and better

avg = array([])
# should probably be called running_sum, though, right?

n = float(len(argv)-2) # -1 for our filename, -1 for the ouput file

print 'Averaging %s images.' % (int(n))

start = time.time()

for imgfile in argv[1:-1]:
	try:
		img = Image.open(imgfile)
	except:
		print('Could not read "%s"!' % (imgfile))
		continue

	if avg.shape == (0,):
			avg = asarray(img).copy()
			avg = avg.astype(avgtype)
			avg.fill(0.0) # fixme: use a zeros() function for speed
	else:
			if img.size != (avg.shape[1], avg.shape[0]):
				exit('"%s" is not the same shape as the earlier images!' % (imgfile))
				# Wait, why do we continue on failure to open, but die if the images
				# aren't the same dimensions? Consistent this up a notch.

	avg = avg + asarray(img).astype(avgtype)/n

print 'Main loop: %s pixels per second.' % ((n * avg.shape[1] * avg.shape[0]) / (time.time() - start))

avg = avg.astype(uint8) # should add support for, like, float32 TIFFs…

avgimg = Image.fromarray(avg)

avgimg.save(argv[-1])
