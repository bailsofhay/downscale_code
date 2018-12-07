library(raster)
library(ncdf4)
library(spatial.tools)
library(gdalUtils)
library(RNetCDF)

setwd('/data/gpfs/assoc/gears/tree_vel/climate/raw/cam2/')

vars = c("pr", "ts", "tmin", "tmax", "u", "v", "rad", "relhum")
# for historical data
files = list.files(pattern = "rcp")
files = files[c(1,5,6,7,8,9,4,3)]

yrs = sort(rep(2005:2100, 12))
yrs  = sort(rep(yrs, 26))
mos = sort(add_leading_zeroes(rep(1:12, 26), 2))
mos = (rep(mos, 96))
#dates = paste(yrs, mos, sep = "")
pressure = rep(1:26, 1140)
dates = paste(yrs, mos, pressure, sep = "_")
# length dates for layered surfaces = 29952

var = "v"
subset = get_subdatasets(files[6], names_only = TRUE, verbose = FALSE)[1]
b = brick(subset)
names(b) = dates

# number of layers = 1152 for normal surfaces: 29952 for layered surfaces --> 26 layers
sub = subset(b, subset = 20281:29952)#781:1152)
#names(sub) = dates

index = seq(from = 26, to = 9672, by = 26)
sub = subset(sub, subset = index)

months = add_leading_zeroes(1:12, 2)



for (j in 1:12)
{
  working = print(paste("working on: ", months[j], sep = ""))
  index = seq(from = j, to = (360+j), by = 12)
  r = subset(sub, subset = index)
  mean = mean(r, na.rm = T)
  writeRaster(mean, file = paste('/data/gpfs/assoc/gears/tree_vel/climate/renamed/averages/future/', var, "/", var , "_",months[j], '_future.tif', sep = ""), overwrite = T)
  #test[j] = j+(j*25)    
}



# reproject and rotate coarse files



library(raster)
var = "v"

ref = raster('/data/gpfs/assoc/gears/tree_vel/dem/raw/ca_nv_dem_utm.tif')

files = list.files(path = paste('/data/gpfs/assoc/gears/tree_vel/climate/renamed/averages/future/', var, sep = ""), pattern = ".tif", include.dirs = T, full.names = T)

extent = c(-180, 180, -90, 90)

for (i in 1:length(files))
{
  r = raster(files[i])
  
  r = rotate(r)
  extent(r) = extent
  projection(r) = crs(ref)
  
  writeRaster(r, file = paste("/data/gpfs/assoc/gears/tree_vel/climate/reprojected/average/future/", var, "/", var, "_", add_leading_zeroes(i, 2), "_future.tif", sep = ""), overwrite = T)  
}


