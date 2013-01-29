#!/usr/bin/env python

#from pxpack import pack, unpack
#from numpy import array, float16, empty
#from quality import qp
#from random import uniform
from numpy import uint8

# def saturation(c):
# 	return (max(c) - min(c))
# 
# def darkness(c):
# 	return (3*255 - sum(c))/3

def qp(c):
	s = sum(c)
	if s < 10 or s > (3*255)-3:
		return 255
	dark = (3*255 - s)/10 # CHANGE ME
	sat = (max(c) - min(c))
	#return uint8(uniform(0, 256))
	return 255 - (dark + sat)/2

