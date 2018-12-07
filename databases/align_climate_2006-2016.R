var = "v"
files = list.files(path = paste("/projects/oa/tree_vel/climate/reprojected/modern/",var, sep = ""), pattern = ".tif", include.dirs = T, full.names = T)
files = files[277:length(files)]
names = substr(files, 52, nchar(files))

lib = print("library(gdalUtils)")
for (i in 1:length(files))
{
  file = files[i]
  name = names[i]
  align = print(paste("align_rasters(unaligned = '", file, "', reference = '/projects/oa/tree_vel/dem/raster/ca_dem_aea.tif', dstfile = '/projects/oa/tree_vel/climate/resampled/", var, "/", name, "', verbose = T, r = 'bilinear', nThreads = 20)", sep = ""))
  combine = rbind(lib, align)
  write(combine, file = paste('/projects/oa/tree_vel/climate/resampled/', var, '/qsub_files/align_', i, ".R", sep = ""))
}