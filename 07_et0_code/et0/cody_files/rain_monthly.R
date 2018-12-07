require("raster")
require("spatial.tools")
require("gtools")

source('/data/gpfs/assoc/gears/tree_vel/02_code/R/functions/snow_calc_function.R')

slurm_id = as.numeric(Sys.getenv('SLURM_ARRAY_TASK_ID'))

#months = add_leading_zeroes(1:24, 2)
months = add_leading_zeroes(rep(1:12, 5),2)
years = sort(rep(2014:2018, 12))
dates = paste(years, months, sep = "_")


is = sort(rep(1:4, 4))
js = rep(1:4, 4)
indexs = paste("_", is, "_", js, sep = "")

# Input files
files = list.files(path = '/data/gpfs/assoc/gears/tree_vel/01_analysis/step4_et0/et0/monthly/input_files/et0_inputs', pattern = '.tif', include.dirs = T, full.names = T)

x = grep(files, pattern = paste( indexs[slurm_id], ".tif", sep = ""))
file = mixedsort(files[x])

precipitation_files = subset(brick(file[1]),2)
for (i in 2:length(file))
{
  r = brick(file[i])
  precip = subset(r, 2)
  precipitation_files = stack(precipitation_files, precip)
}

tmean_files = subset(brick(file[1]), 3)
for (i in 2:length(file))
{
  r = brick(file[i])
  tmean = subset(r, 3)
  tmean_files = stack(tmean_files, tmean)
}

rad_files = subset(brick(file[1]), 7)
for (i in 2:length(file))
{
  r = brick(file[i])
  rad = subset(r, 5)
  rad_files = stack(rad_files, rad)
}


for (i in 1:60)
{
  precipitation_raw=precipitation_files
  tmean_raw=tmean_files
  rad_raw=rad_files
  
  j = i
  # if (i > 12) 
  # {
  #   j = i -12
  # } else {
  #   j = i
  # }
  radiation = subset(rad_raw, j)
  tmean = subset(tmean_raw, j)-273.15
  ppt = subset(precipitation_raw, j)
  
  if (i == 1)
  {
    snowpack_prev = NULL
  } else {
    snowpack_prev = rain_rasters$snowpack
  }
  
  print(paste("working on: ", dates[i], indexs[slurm_id], sep = ""))
  
  rain_rasters = snow_calc_function(tmean = tmean, radiation = radiation, ppt = ppt, snowpack_prev = snowpack_prev)
  
  
  writeRaster(rain_rasters$snow, file = paste('/data/gpfs/assoc/gears/tree_vel/01_analysis/step4_et0/et0/monthly/rain_files/snow//snow_', dates[i],  indexs[slurm_id], ".tif", sep =''), overwrite = TRUE)
  writeRaster(rain_rasters$rain, file = paste('/data/gpfs/assoc/gears/tree_vel/01_analysis/step4_et0/et0/monthly/rain_files/rain//rain_', dates[i],indexs[slurm_id], ".tif", sep =''), overwrite = TRUE)
  writeRaster(rain_rasters$snowpack, file = paste('/data/gpfs/assoc/gears/tree_vel/01_analysis/step4_et0/et0/monthly/rain_files/snowpack//snowpack_', dates[i], indexs[slurm_id], ".tif", sep =''), overwrite = TRUE)
  writeRaster(rain_rasters$input, file = paste('/data/gpfs/assoc/gears/tree_vel/01_analysis/step4_et0/et0/monthly/rain_files/input//input_', dates[i], indexs[slurm_id], ".tif", sep =''), overwrite = TRUE)
  writeRaster(rain_rasters$albedo, file = paste('/data/gpfs/assoc/gears/tree_vel/01_analysis/step4_et0/et0/monthly/rain_files/albedo//albedo_', dates[i], indexs[slurm_id], ".tif", sep =''), overwrite = TRUE)
  writeRaster(rain_rasters$melt, file = paste('/data/gpfs/assoc/gears/tree_vel/01_analysis/step4_et0/et0/monthly/rain_files/melt//melt_', dates[i], indexs[slurm_id], ".tif", sep =''), overwrite = TRUE)
  
  print(paste("finished: ", dates[i], indexs[slurm_id], sep = ""))
  
}

