library(raster)
library(gdalUtils)
library(spatial.tools)
var = "u"
time = "rcp8"

path = paste("/projects/oa/tree_vel/climate/reprojected/", time, "/", var, "/",sep = "")

# Change the yr dates for RCP to 2070-2100
mo = add_leading_zeroes(rep(1:12, 31),2)
yr = sort(rep(2070:2100,12))
files = paste(path,"/", var,"_", yr, "_", mo, ".tif", sep = "")
#setwd(path)
#files = dir()

months = c("jan", "feb", "mar", "april", "may", "june", "july", "aug", "sept", "oct", "nov", "dec")
m = matrix(12, 31, data = files)

for (i in 1:length(months))
{
  file = m[i,]
  s = stack(file, bands = 1)
  ave = mean(s)
  
  writeRaster(ave, file = paste("/projects/oa/tree_vel/climate/monthly_ave/",time, "/", var, "/", var, "_", months[i], ".tif", sep = ""))
  done = print(paste(var, time, months[i], "done!"))
}

library(spatial.tools)

var =  "v"
time =  "rcp8"


path = paste("/projects/oa/tree_vel/climate/monthly_ave/", time, "/", var, "/",sep = "")
setwd(path)
files = dir()
months = c("april", "aug", "dec", "feb", "jan", "july", "june", "mar", "may", "nov", "oct", "sept")

for (i in 1:12)
{
  lib = print("library(gdalUtils)")
  unaligned = print(paste("unaligned = '", path, files[i],"'", sep = ""))
  reference = print("reference = '/projects/oa/tree_vel/dem/raster/dem_aea.tif'")
  dst = print(paste("dst = '/projects/oa/tree_vel/climate/monthly_resampled/", time,"/", var, "/", var, "_", months[i], ".tif'", sep = "" ))
  align = print("align_rasters(unaligned = unaligned,  reference = reference, dstfile = dst,  verbose = TRUE, nThreads = 20, r = 'bilinear')", sep = "")
  
  combine = rbind(lib, unaligned, reference, dst, align)
  write(combine, file = paste("/projects/oa/tree_vel/climate/monthly_resampled/", time, "/", var, "/qsub_files/align_", months[i], ".R", sep = ""))
}

