library(raster)
library(ncdf4)
library(spatial.tools)
library(gdalUtils)
library(RNetCDF)

setwd('/data/gpfs/assoc/gears/tree_vel/climate/raw/cam2/')

vars = c("pr", "rad", "tmax", "tmin", "ts", "u", "v")
# for historical data
files = list.files(pattern = ".nc")
files = files[c(1,3,5,7,9,11, 13)]

yrs = sort(rep(2006:2019, 12))
mos = add_leading_zeroes(rep(1:12, 14), 2)
dates = paste(yrs, mos, sep = "")


# 1585 date start for 198501-2005


  var = "u"
  subset = get_subdatasets(files[7], names_only = TRUE, verbose = FALSE)[1]
  b = brick(subset)

  #test = vector()
  for (j in 1:168)
  {
    r = stack(b, layers = (j+(j*25)))
    writeRaster(r, file = paste('/data/gpfs/assoc/gears/tree_vel/climate/renamed/relhum/relhum_', dates[j], '.tif', sep = ""), overwrite = T)
    #test[j] = j+(j*25)    
    }
  
  

ncfile_info <- gdalinfo(files[4])
#[16] "  NETCDF_DIM_plev_VALUES={100000,92500,85000,70000,60000,50000,40000,30000,25000,20000,15000,10000,7000,5000,3000,2000,1000}" 


setwd('/data/gpfs/assoc/gears/tree_vel/climate/raw/')

vars = c("pr", "rad", "tmax", "tmin", "ts", "u", "v")

# for rcp8.5 data
files = list.files(pattern = ".nc")
files = files[c(2,4,6,8, 10, 12, 14)]

yrs = sort(rep(2006:2020, 12))
mos = add_leading_zeroes(rep(1:12, 15), 2)
dates = paste(yrs, mos, sep = "")


# 180 date end for 2006-2020
for (i in 1:length(files))
{
  var = vars[i]
  b = brick(files[i])
  
  for (j in 1:180)
  {
    r = stack(b, layers = j)
    writeRaster(r, file = paste('/data/gpfs/assoc/gears/tree_vel/climate/renamed/', var, '/',var, '_', dates[j], '.tif', sep = ""), overwrite = T)
    
  }
  
}
