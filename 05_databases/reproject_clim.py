
workspace = "P:\\akpaleo\\archived_climate\\modern\\rename\\ts\\"
import os
files = sorted(os.listdir(workspace))
#f = files[300:672]

import arcpy
from arcpy import env
env.workspace = workspace

outdir = "P:\\akpaleo\\archived_climate\\modern\\reprojected\\" 

outfile = []
for i in range(0, len(f)):
	name = f[i]
	dir = outdir
	outname = dir+name
	outfile.append(outname)

for i in range(0,len(f)):
	infc = f[i]
	sr = arcpy.SpatialReference("WGS 1984")
	arcpy.DefineProjection_management(infc, sr)
	
for i in range(0, len(f)):
	infc = f[i]
	outfc = outfile[i]
	arcpy.ProjectRaster_management(infc, outfc, "D:\\Users\\bdmorri2\\test3.tif", "#","#", "WGS_1984_(ITRF00)_To_NAD_1983","#","#")

