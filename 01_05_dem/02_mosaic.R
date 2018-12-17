library(raster)
library(gdalUtils)


setwd("/projects/oa/tree_vel/dem/raster/raw_tiles/")

files = list.files(path = "/projects/oa/tree_vel/dem/raster/raw_tiles/", full.names = TRUE)


mosaic_rasters(files, dst_dataset = "/projects/oa/tree_vel/dem/raster/dem_unprojected.tif", verbose = TRUE)


