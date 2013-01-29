#!/usr/bin/env python

from numpy import uint32 #, binary_repr
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

'''
for i in range(1000000):
	t = (i%256, (i+23)%256, (i+199)%256)
	p = pack(t)
	#print bin(int(p))
	#print binary_repr(p, width=32)
	u = unpack(p)
	if t != u:
		print t, u
'''