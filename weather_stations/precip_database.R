library(raster)
library(shapefiles)
library(rgdal)
library(spatial.tools)
library(gtools)

pr_files = list.files(path = "/data/gpfs/assoc/gears/tree_vel/climate/resampled/pr/", pattern = ".tif", include.dirs = T, full.names = T)
pr_files = mixedsort(pr_files)

speed_files = list.files(path = "/data/gpfs/assoc/gears/tree_vel/climate/resampled/wind/speed/", pattern = ".tif", include.dirs = T, full.names = T)
speed_files = mixedsort(speed_files)


dir_files = list.files(path = "/data/gpfs/assoc/gears/tree_vel/climate/resampled/wind/direction/", pattern = ".tif", include.dirs = T, full.names = T)
dir_files = mixedsort(dir_files)

delta_60_files = list.files(path = "/data/gpfs/assoc/gears/tree_vel/climate/resampled/wind/delta/60m/", pattern = ".tif", include.dirs = T, full.names = T)
delta_60_files = mixedsort(delta_60_files)


delta_500_files = list.files(path = "/data/gpfs/assoc/gears/tree_vel/climate/resampled/wind/delta/500m/", pattern = ".tif", include.dirs = T, full.names = T)
delta_500_files = mixedsort(delta_500_files)


delta_1000_files = list.files(path = "/data/gpfs/assoc/gears/tree_vel/climate/resampled/wind/delta/1000m/", pattern = ".tif", include.dirs = T, full.names = T)
delta_1000_files = mixedsort(delta_1000_files)


delta_5000_files = list.files(path = "/data/gpfs/assoc/gears/tree_vel/climate/resampled/wind/delta/5000m/", pattern = ".tif", include.dirs = T, full.names = T)
delta_5000_files = mixedsort(delta_5000_files)

dem_60_files = "/data/gpfs/assoc/gears/tree_vel/dem/ca_nv_dem_aea.tif"
dem_500_files = "/data/gpfs/assoc/gears/tree_vel/dem/ca_nv_dem_500m.tif"
dem_1000_files = "/data/gpfs/assoc/gears/tree_vel/dem/ca_nv_dem_1000m.tif"
dem_5000_files = "/data/gpfs/assoc/gears/tree_vel/dem/ca_nv_dem_5000m.tif"

slope_60_files = "/data/gpfs/assoc/gears/tree_vel/dem/ca_nv_slope.tif"
slope_500_files = "/data/gpfs/assoc/gears/tree_vel/dem/ca_nv_slope_500m.tif"
slope_1000_files = "/data/gpfs/assoc/gears/tree_vel/dem/ca_nv_slope_1000m.tif"
slope_5000_files = "/data/gpfs/assoc/gears/tree_vel/dem/ca_nv_slope_5000m.tif"

data = shapefile('/data/gpfs/assoc/gears/tree_vel/weather_stations/prcp_data/prcp_data.shp')

vals = seq(1:456)

years = sort(rep(1982:2019, 12))
months = add_leading_zeroes(rep(1:12, 38), 2)
dates = paste(years, months, sep = "_")
data$pr = NA
data$speed = NA
data$dir = NA
data$delta_60 = NA
data$delta_500 = NA
data$delta_1000 = NA
data$delta_5000 = NA
data$dem_60 = NA
data$dem_500 = NA
data$dem_1000 = NA
data$dem_5000 = NA
data$slope_60 = NA
data$slope_500 = NA
data$slope_1000 = NA
data$slope_5000 = NA


for (i in 1:length(pr_files))
{
  # go by date
  working = print(paste("working on: ", dates[i], sep = ""))
  date = dates[i]
  pr = raster(pr_files[i])
  speed = raster(speed_files[i])
  dir = raster(dir_files[i])
  delta_60 = raster(delta_60_files[i])
  delta_500 = raster(delta_500_files[i])
  delta_1000 = raster(delta_1000_files[i])
  delta_5000 = raster(delta_5000_files[i])
  dem_60 = raster(dem_60_files)
  dem_500 = raster(dem_500_files)
  dem_1000 = raster(dem_1000_files)
  dem_5000 = raster(dem_5000_files)
  slope_60 = raster(slope_60_files)
  slope_500 = raster(slope_500_files)
  slope_1000 = raster(slope_1000_files)
  slope_5000 = raster(slope_5000_files)
  
  s = stack(pr, speed, dir, delta_60, delta_500, delta_1000, delta_5000, dem_60, dem_500, dem_1000, dem_5000, slope_60, slope_500, slope_1000, slope_5000)
  index = which(data$date == date)
  
  if (length(index) > 0)
  {
    d = data[index,]
    xy = as.data.frame(coordinates(d))
    coordinates(xy) = ~coords.x1+coords.x2
    projection(xy) = crs(s)
    
    ex = as.data.frame(extract(s, xy))
    names(ex) = c("pr", "speed", "dir", "delta_60", "delta_500", "delta_1000", "delta_5000", "dem_60", "dem_500", "dem_1000", "dem_5000", "slope_60", "slope_500", "slope_1000", "slope_5000")

    write.csv(ex, file = paste("/data/gpfs/assoc/gears/tree_vel/weather_stations/extracted_files/pr/pr_", slurm_id, ".csv", sep = ""))
  }
  
}


files = list.files(path = "/data/gpfs/assoc/gears/tree_vel/weather_stations/extract_files/pr/", pattern = ".csv", include.dirs = T, full.names = T)
files = mixedsort(files)

data = shapefile('/data/gpfs/assoc/gears/tree_vel/weather_stations/prcp_data/prcp_data.shp')
data$pr = NA
data$speed = NA
data$dir = NA
data$delta_60 = NA
data$delta_500 = NA
data$delta_1000 = NA
data$delta_5000 = NA
data$dem_60 = NA
data$dem_500 = NA
data$dem_1000 = NA
data$dem_5000 = NA
data$slope_60 = NA
data$slope_500 = NA
data$slope_1000 = NA
data$slope_5000 = NA

dates = sort(unique(data$date))

for (i in 1:length(dates))
{
  date = dates[i]
  file = read.csv(files[i])
  file = file[,-1]
  
  index = which(data$date == date)
  
  if (nrow(file) == length(index))
  {
        data[index, 6:20] = file
        
  } else {
    bad = print(paste("bad file ", i, sep = ""))}
  
}

d = as.data.frame(data)
d = d[complete.cases(d),]

summary(d$value)
summary(d$pr)

d$value = d$value*(1/1000)*(1/2629743.83)
coordinates(d) = ~coords.x1+coords.x2
projection(d) = crs(raster('/data/gpfs/assoc/gears/tree_vel/dem/ca_nv_dem_aea.tif'))


writeOGR(d, layer = "pr_database", dsn = "/data/gpfs/assoc/gears/tree_vel/weather_stations/prcp_data/", driver = "ESRI Shapefile", overwrite = T)


# outlier analysis
sd = sd(d$value, na.rm = T)
z = abs(d$value-mean(d$value, na.rm = T))/sd

bad = which(z>5)
test = d
test = test[-bad,]

sd = sd(test$pr, na.rm = T)
z = abs(test$pr - mean(test$pr, na.rm = T))/sd

bad = which(z > 5)
test = test[-bad,]

min = min(d$value, d$pr, na.rm = T)
max = max(d$value, d$pr, na.rm = T)

plot(d$value, d$pr, xlim = c(min, max), ylim = c(min, max))
plot(test$value, test$pr, xlim = c(min, max), ylim = c(min, max))







