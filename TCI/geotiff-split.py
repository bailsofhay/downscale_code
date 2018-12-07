import os, sys, string, math
#import gdal
#from gdalconst import *

# chop a ned tif into pieces, used in pitremove
# usage: python geotiff-split.py input_tif xsize ysize output_dir
# constraints:
# 1. each piece has max size 2gb, otherwise, taudem woes. typically, 72751 x 51395
# 2. output_dir must exist
# output: a dir with split tif files
# TODO: use pure python impl

if __name__ == '__main__':

	infile = sys.argv[1]
	width = int(sys.argv[2])
	height = int(sys.argv[3])
	outdir = sys.argv[4]
	if not os.path.isdir(outdir):
		print "Output dir must exist: " + outdir
		sys.exit(1)
	# decompose raster into blocks
	bmaxsize = 20000 * 20000 # max num pixels in a block: 400M pixels ~= 1.6GB, if each pixel is a 4-byte float
	bnum = (width * height) // bmaxsize + 1
	# number of blocks along x and y dim. xbnum * ybnum = bnum; xbnum / ybnum = width / height
	xbnum = int(math.ceil(math.sqrt(bnum * width / height)))
	ybnum = int(math.ceil(math.sqrt(bnum * height / width)))
	if xbnum == 0:
		xbnum = 1
	if ybnum == 0:
		ybnum = 1
	xsize = width // xbnum
	ysize = height // ybnum
	xleftover = width % xbnum
	yleftover = height % ybnum
	print "splitting tif " + infile + " (" + str(width) + "x" + str(height) + "=" + str(width*height) + " cells) to output dir " + outdir
	print "max block size limit " + str(bmaxsize) + ". leftover: x - " + str(xleftover) + ", y - " + str(yleftover)
	# now smoothe remainder throughout tiles, not just put them in last one
	dimx = [xsize] * xbnum * ybnum
	dimy = [ysize] * xbnum * ybnum
	for i in range(ybnum):
		for j in range(xbnum):
			if i < yleftover:
				dimy[i*xbnum + j] += 1
			if j < xleftover:
				dimx[i*xbnum + j] += 1
	# verify we are doing the right thing, debug purpose
	numCells = 0
	bmaxsize2 = 0
	header=""
	for j in range(xbnum):
		header  += "\t00000000" + str(j)
	print header
	for i in range(ybnum):
		rowstr= str(i) + "\t"
		for j in range(xbnum):
			bcells = dimx[i*xbnum + j] * dimy[i*xbnum + j]
			numCells += bcells
			if bcells > bmaxsize2:
				bmaxsize2 = numCells
			rowstr += str(dimx[i*xbnum + j]) + "x" + str(dimy[i*xbnum + j]) + "\t"
		print rowstr
	print "split plan: " + str(xbnum) + "x" + str(ybnum) + " blocks, " + str(numCells) + " cells in total; max block size " + str(bmaxsize2)
	# create split geotiff files
	infname = os.path.basename(infile)
	inflist = string.split(infname, '.')
	inflist_len = len(inflist)
	if inflist_len > 1:
		inflist.pop(inflist_len - 1) # remove suffix
	fname = string.join(inflist, '.')
	xoffset = 0 # offset in pixels, x
	yoffset = 0 # offset in pixels, y
	for i in range(ybnum):
		for j in range(xbnum):
			#cmd = "gdal_translate -of GTIFF -srcwin " + str(xoffset) + " " + str(yoffset) + " " + str(dimx[i*xbnum + j]) + " " + str(dimy[i*xbnum + j]) + " " + infile + " " + outdir + os.sep + fname + "_" + str(i) + "_" + str(j) + ".tif"
			cmd = "gdal_translate -of GTIFF -a_nodata -3.4028234663852886e+38 -srcwin " + str(xoffset) + " " + str(yoffset) + " " + str(dimx[i*xbnum + j]) + " " + str(dimy[i*xbnum + j]) + " " + infile + " " + outdir + os.sep + fname + "_" + str(i) + "_" + str(j) + ".tif"
			print cmd
			os.system(cmd)
			xoffset += dimx[i*xbnum + j]
		yoffset += dimy[i*xbnum + j]
		xoffset = 0
#for i in range(0, width, tilesize):
#    for j in range(0, height, tilesize):
#        gdaltranString = "gdal_translate -of GTIFF -srcwin "+str(i)+", "+str(j)+", "+str(tilesize)+", " \
#            +str(tilesize)+" utm.tif utm_"+str(i)+"_"+str(j)+".tif"
#        os.system(gdaltranString)
