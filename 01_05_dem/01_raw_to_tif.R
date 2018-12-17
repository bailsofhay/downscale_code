library(raster)

setwd("/data/gpfs/assoc/gears/tree_vel/dem/raw/nv/raw-copy")
files = list.files()

g = grep(files, pattern = "USGS")
files_bad = files[g]
files_reg = files[-g]
files_bad = substr(files_bad, 12, 18)

all_files = c(files_reg, files_bad)

outnames = substr(all_files, 1,7)


for (i in 1:length(files)) 
{
  zipfile = files[i]
  outname = outnames[i]
  outdir = paste("/data/gpfs/assoc/gears/tree_vel/dem/raw/nv/raw/", outname, sep = "")
  unzip(zipfile, exdir = outdir)
}



folders = list.files(path = '/data/gpfs/assoc/gears/tree_vel/dem/raw/nv/raw')


for (i in 1:length(folders))
{
  folder = folders[i]
  files = list.files(path = paste("/data/gpfs/assoc/gears/tree_vel/dem/raw/nv/raw/", folder, "/grd", folder, "_1/", sep = ""), include.dirs = T, full.names = T)

  r = raster(files[6])
  writeRaster(r, file = paste('/data/gpfs/assoc/gears/tree_vel/dem/raw/nv/geotiff/nv_dem_', i, '.tif', sep = ""), overwrite = T)
  done = print(paste("Finished: DEM ", i, sep = "") )

  
}



library(gdalUtils)

files = list.files(path = "/data/gpfs/assoc/gears/tree_vel/dem/raw/nv/geotiff/", pattern = ".tif", include.dirs = T, full.names = T)

mosaic_rasters(files, dst_dataset = "/data/gpfs/assoc/gears/tree_vel/dem/raw/nv/nv_dem_utm.tif", verbose = T)

library(shapefiles)
poly = shapefile('/data/gpfs/assoc/gears/tree_vel/shapefiles/ca_nv_boundary/ca_nv_boundary.shp')
r = raster('/data/gpfs/assoc/gears/tree_vel/dem/raw/nv_dem_utm.tif')
plot(r)
plot(poly, add = T)


