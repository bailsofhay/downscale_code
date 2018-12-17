# Stuff to install:
install.packages("raster")
install.packages("ncdf")
install.packages("gdalUtils")
install.packages('spatial.tools')
library("gdalUtils")
library(raster)
library(ncdf)
library(foreach)
library(spatial.tools)


setwd("P:\\akpaleo\\raster\\climate\\CCSM4\\Modern\\NC_files")
dir()


# All files:

allfiles = dir(pattern=glob2rx("*.nc*"))

test_brick <- brick(allfiles[16])

plot(test_brick$X1979.01.16)


# gdalinfo the first file (first time you run this this can take some time):
ncfile_temp_info <- gdalinfo(allfiles[16])
meta = ncfile_temp_info[10:30]






sfQuickInit()
nchur <- foreach(filenames=allfiles,.packages=c("raster", "tools")) %dopar%
{
  outputfilename <- basename(file_path_sans_ext(filenames)) # STRIP OFF .NC
  outdir <- "P:\\akpaleo\\raster\\climate\\CCSM4\\Paleo\\geotiff"
  outfile <- paste(outdir,outputfilename,".tif", sep="")
  mybrick <- brick(filenames)
  newfile <- writeRaster(mybrick, outfile)
  
}
sfQuickStop()


basename(file_path_sans_ext(filenames))

outputfilename <- 

  
  
  
# allfiles = dir(pattern=glob2rx("*Amo*"))
#file.rename(allfiles, paste(allfiles,".nc",sep = ""))
