from numpy import uint8

# def saturation(c):
# 	return (max(c) - min(c))

# def darkness(c):
# 	return (3*255 - sum(c))

def qp(c):
	s = sum(c)
	if s < 10 or s > (3*255)-3: # (near-)black and (near-)white are always bad
		return 255
	dark = (3*255 - s)/10 # CHANGE ME
	sat = (max(c) - min(c))

	return 255 - (dark + sat)/2
