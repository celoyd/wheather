#!/usr/bin/env python

'''
Pack a pixel into 32 bits with its quality in the high bits.
'''

from numpy import uint32
from qp import qp

x8  = uint32(8)
x10 = uint32(16)
x18 = uint32(24)
xff = uint32(255)

def pack(rgb):
	r, g, b = rgb
	q = qp(rgb)
	
	# This looks weird but benches fast:
	return uint32(
		  (q<<24)
		+ (r<<16)
		+ (g<<8)
		+  b
	)

def unpack(i):
	#q = (i >> x18) & xff
	r = (i >> x10) & xff
	g = (i >> x8)  & xff
	b =  i &  xff
	return (r, g, b)
