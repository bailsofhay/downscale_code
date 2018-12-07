require("raster")
require("spatial.tools")

source('/data/gpfs/assoc/gears/tree_vel/R/functions/snow_calc_function.R')

slurm_id = as.numeric(Sys.getenv('SLURM_ARRAY_TASK_ID'))

months = add_leading_zeroes(1:24, 2)

is = sort(rep(1:4, 3))
js = rep(1:3, 4)
indexs = paste("_", is, "_", js, sep = "")

# Input files

precipitation_files=list.files("/data/gpfs/assoc/gears/tree_vel/et0/average/future/inputs/pr/", pattern = indexs[slurm_id], include.dirs = T, full.names = T)

tmean_files = list.files("/data/gpfs/assoc/gears/tree_vel/et0/average/future/inputs/tave/", pattern = indexs[slurm_id], include.dirs = T, full.names = T)

rad_files = list.files("/data/gpfs/assoc/gears/tree_vel/et0/average/future/inputs/rad/", pattern = indexs[slurm_id], include.dirs = T, full.names = T)



for (i in 1:24)
{
  precipitation_raw=stack(precipitation_files)
  tmean_raw=stack(tmean_files)
  rad_raw=stack(rad_files)
  
  if (i > 12) 
  {
    j = i -12
  } else {
    j = i
  }
  radiation = subset(rad_raw, j)
  tmean = subset(tmean_raw, j)-273.15
  ppt = subset(precipitation_raw, j)
  
  if (i == 1)
  {
    snowpack_prev = NULL
  } else {
    snowpack_prev = rain_rasters$snowpack
  }
  
  print(paste("working on: ", months[i], indexs[slurm_id], sep = ""))
  
  rain_rasters = snow_calc_function(tmean = tmean, radiation = radiation, ppt = ppt, snowpack_prev = snowpack_prev)
  
  
  writeRaster(rain_rasters$snow, file = paste('/data/gpfs/assoc/gears/tree_vel/et0/average/future/rain_files/snow//snow_', months[i],  indexs[slurm_id], "_future.tif", sep =''), overwrite = TRUE)
  writeRaster(rain_rasters$rain, file = paste('/data/gpfs/assoc/gears/tree_vel/et0/average/future/rain_files/rain//rain_', months[i], indexs[slurm_id], "_future.tif", sep =''), overwrite = TRUE)
  writeRaster(rain_rasters$snowpack, file = paste('/data/gpfs/assoc/gears/tree_vel/et0/average/future/rain_files/snowpack//snowpack_', months[i], indexs[slurm_id], "_future.tif", sep =''), overwrite = TRUE)
  writeRaster(rain_rasters$input, file = paste('/data/gpfs/assoc/gears/tree_vel/et0/average/future/rain_files/input//input_', months[i], indexs[slurm_id], "_future.tif", sep =''), overwrite = TRUE)
  writeRaster(rain_rasters$albedo, file = paste('/data/gpfs/assoc/gears/tree_vel/et0/average/future/rain_files/albedo//albedo_', months[i], indexs[slurm_id], "_future.tif", sep =''), overwrite = TRUE)
  writeRaster(rain_rasters$melt, file = paste('/data/gpfs/assoc/gears/tree_vel/et0/average/future/rain_files/melt//melt_', months[i], indexs[slurm_id], "_future.tif", sep =''), overwrite = TRUE)
  
  print(paste("finished: ", months[i], indexs[slurm_id], sep = ""))
  
}


# for (i in 1:12)
# {
#   precipitation_raw=stack(precipitation_files)
#   tmean_raw=stack(tmean_files)
#   rad_raw=stack(rad_files)
#   
#   for (j in 1:24)
#   {
#     if (j > 12) 
#     {
#       i = j-12
#     } else {
#       i = j
#     }
#     
#     radiation = subset(rad_raw, i)
#     tmean = subset(tmean_raw, i)-273.15
#     ppt = subset(precipitation_raw, i)
#     
#     if (j == 1)
#     {
#       snowpack_prev = NULL
#     } else {
#       snowpack_prev = rain_rasters$snowpack
#     }
#     
#     print(paste("working on: ", months[j], indexs[slurm_id], sep = ""))
#     
#     rain_rasters = snow_calc_function(tmean = tmean, radiation = radiation, ppt = ppt, snowpack_prev = snowpack_prev)
#     
#     
#     writeRaster(rain_rasters$snow, file = paste('/data/gpfs/assoc/gears/tree_vel/et0/average/future/rain_files/snow//snow_', months[j], '_', indexs[slurm_id], "_future.tif", sep =''), overwrite = TRUE)
#     writeRaster(rain_rasters$rain, file = paste('/data/gpfs/assoc/gears/tree_vel/et0/average/future/rain_files/rain//rain_', months[j], '_', indexs[slurm_id], "_future.tif", sep =''), overwrite = TRUE)
#     writeRaster(rain_rasters$snowpack, file = paste('/data/gpfs/assoc/gears/tree_vel/et0/average/future/rain_files/snowpack//snowpack_', months[j], '_', indexs[slurm_id], "_future.tif", sep =''), overwrite = TRUE)
#     writeRaster(rain_rasters$input, file = paste('/data/gpfs/assoc/gears/tree_vel/et0/average/future/rain_files/input//input_', months[j], '_', indexs[slurm_id], "_future.tif", sep =''), overwrite = TRUE)
#     writeRaster(rain_rasters$albedo, file = paste('/data/gpfs/assoc/gears/tree_vel/et0/average/future/rain_files/albedo//albedo_', months[j], '_', indexs[slurm_id], "_future.tif", sep =''), overwrite = TRUE)
#     writeRaster(rain_rasters$melt, file = paste('/data/gpfs/assoc/gears/tree_vel/et0/average/future/rain_files/melt//melt_', months[j], '_', indexs[slurm_id], "_future.tif", sep =''), overwrite = TRUE)
#     
#     print(paste("finished: ", months[j], indexs[slurm_id], sep = ""))
#     
#   }}
#   
# 
#   