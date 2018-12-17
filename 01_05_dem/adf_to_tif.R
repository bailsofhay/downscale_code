library(raster)
library(rgdal)
library(gdalUtils)
library(foreach)
library(spatial.tools)


# rasterize the unzipped files

wd = setwd("/projects/oa/tree_vel/dem/unzipped/")

files = list.files(path = "/projects/oa/tree_vel/dem/unzipped/", pattern = "w001001.adf", recursive = TRUE, full.names = TRUE, include.dir = T)


names = dir()
outnames = vector()

for (i in 1:length(names))
{
  string = paste(names[i], ".tif", sep = "")
  outnames[i] = string
}


for (i in 1:length(files))
{
  batch_gdal_translate(infiles = files[i], outdir = "/projects/oa/tree_vel/dem/raster/",  outsuffix = outnames[i], verbose = TRUE )
}


wd = setwd("/projects/oa/tree_vel/dem/raster/")

files = dir()

correct_name = substr(files, 8,nchar(files))

newname = foreach(files) %do%
{
  file.rename(files, correct_name)
}


