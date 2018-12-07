
library(spatial.tools)
library(raster)

var = "pr"
yr = sort(rep(1985:2015, 12))
mo = add_leading_zeroes(rep(1:12,31 ),2)
yrmo = paste(yr, "_", mo, sep = "")
time = gsub("_", "", yrmo)


for ( i in 1:372)
{
  lib = print("library(raster)")
  lib2 = print("library(gdalUtils)")
  lib3 = print("library(shapefiles)")
  
  date = print(paste("DATE = ",time[i], sep = ""))
  weather1 = print("weather = shapefile('/projects/oa/tree_vel/weather_station/shapefile/ca_weather_data_aea/ca_weather_data_w_precip.shp')")
  #weather2 = print("weather$DATE = substr(weather$DATE, 1, nchar(weather$DATE)-2)")
  
  
  row = print("index = which(weather$DATE == DATE)")
  xy1 = print("xy = coordinates(weather)")
  xy2 = print("xy = xy[index,]")
  
  
  
  #align rasters function
  s = print("source('/projects/oa/akpaleo/R/functions/align_rasters.R')")
  
  
  dem = print("demfilename = '/projects/oa/tree_vel/dem/raster/ca_dem_aea.tif'")
  filename = print(paste("filename = '/projects/oa/tree_vel/climate/reprojected/modern/", var, "/", var, "_", yrmo[i], ".tif'", sep = ""))
  
  run = print(paste("align_rasters(unaligned = filename, reference = demfilename, dstfile = '/projects/oa/tree_vel/scratch/", var, "_resample/", var, "_", yrmo[i], ".tif', r = 'bilinear', nThreads = 1, verbose = TRUE)", sep = ""))
  
  
  
  
  r = print(paste("r = raster('/projects/oa/tree_vel/scratch/", var, "_resample/", var, "_", yrmo[i] , ".tif ')", sep = ""))
  extract = print("extract = extract(r, xy)")
  DATE2 = print("DATE  = rep(DATE, nrow(xy))")
  
  combine = print("combine = cbind(DATE, xy, extract)")
  csv = print(paste("write.csv(combine, file = '/projects/oa/tree_vel/climate/extracted_climate/", var, "/", var, "_", yrmo[i], ".csv')",  sep = ""))
  
  quit = print("quit()")
  no = print("n")
  
  full.combine = rbind( lib, lib2, lib3, date, weather1, row, xy1, xy2, s, dem, filename, run,  r, extract, DATE2, combine, csv, quit, no)
  write(full.combine, file = paste("/projects/oa/tree_vel/climate/extracted_climate/qsub_files/", var, "/extract_climate_", i, ".R", sep = ""))
  qsub = print(paste("R CMD BATCH /projects/oa/tree_vel/climate/extracted_climate/qsub_files/", var, "/extract_climate_", i, ".R", sep = ""))
  delete = print(paste("rm /gpfs/largeblockFS/project/oa/tree_vel/scratch/", var, "_resample/", var, "_", yrmo[i], ".tif", sep = ""))
  combine2 = rbind(qsub, delete)
  write(combine2, file = paste("/projects/oa/tree_vel/climate/extracted_climate/qsub_files/", var, "/R_CMD_", i, ".sh", sep = ""))
}






