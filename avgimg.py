#!/usr/bin/env python

from sys import argv, exit
import Image
import time
from numpy import *

avgtype = float32

avg = array([])

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
			avg.fill(0.0)
	else:
			if img.size != (avg.shape[1], avg.shape[0]):
				exit('"%s" is not the same shape as the earlier images!' % (imgfile))

	avg = avg + asarray(img).astype(avgtype)/n

print 'Main loop: %s pixels per second.' % ((n * avg.shape[1] * avg.shape[0]) / (time.time() - start))

avg = avg.astype(uint8)

avgimg = Image.fromarray(avg)

#c = avgimg.convert('RGB')
#a = c.load()

avgimg.save(argv[-1])
