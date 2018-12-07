library(raster)
library(rgdal)
library(shapefiles)
library(gtools)
library(hydroGOF)
library(mgcv)
library(randomForest)

# data = shapefile('/data/gpfs/assoc/gears/tree_vel/weather_stations/tmin_data/tmin_data.shp')
# 
# files = list.files(path = "/data/gpfs/assoc/gears/tree_vel/weather_stations/extract_files/tmin/", pattern = ".csv", include.dirs = T, full.names = T)
# files = mixedsort(files)
# 
# d = data
# d$tmin = NA
# d$rad = NA
# d$tci = NA
# d$elv = NA
# d$station = NA
# 
# 
# dates = sort(unique(data$date))
# for (i in 1:length(dates))
# {
#   date = dates[i]
#   file = read.csv(files[i])
#   file = file[,-1]
#   
#   if (nrow(file)>0)
#   {
#     good = print(paste(date, " good", sep = ""))
#     x = which(data$date == date)
#     d$tmin[x] = file[,1]
#     d$rad[x] = file[,2]
#     d$tci[x] = file[,3]
#     d$elv[x] = file[,4]
#     d$station[x] = file[,5]
#   }
#   
# }
# 
# 
# # get rid of nevada data for now
# ca = grep(d$name, pattern = " CA ")
# d = d[ca, ]
# 
# # convert weather station data to kelvins
# d$value= d$value+273.15
# 
# 
# d = as.data.frame(d)
# d = d[complete.cases(d),]
# 
# coordinates(d) = ~coords.x1+coords.x2
# projection(d) = crs(raster('/data/gpfs/assoc/gears/tree_vel/dem/ca_nv_dem_aea.tif'))
# 
# # outlier analysis
# sd = sd(d$tmin, na.rm = T)
# z = abs(d$tmin-mean(d$tmin, na.rm = T))/sd
# x = which(z<=3.5)
# 
# test = d[x,]
# 
# #### check autocorrelation stuff
# 
# # temporal
# time = as.numeric(gsub("_", "", test$date))
# test$tmine = time


dem = raster('/data/gpfs/assoc/gears/tree_vel/dem/nearest_weather_station_500.tif')
cell = which(!(is.na(dem[])))
dem[cell]  = NA

stations = unique(coordinates(test))
stations= as.data.frame(stations)
names(stations) = c("x", "y")
coordinates(stations) = ~x+y
projection(stations) = crs(dem)

cells = cellFromXY(dem, xy = coordinates(stations))
dem[cells] = cells

dist = distance(dem)
direct <- direction(dem, from=FALSE)


rna <- is.na(dem)
na.x <- init(rna, 'x')
na.y <- init(rna, 'y')


co.x <- na.x + dist * sin(direct)
co.y <- na.y + dist * cos(direct)

co <- cbind(co.x[], co.y[]) 

NAVals <- raster::extract(dem, co, method='simple') 
r.NAVals <- rna # initiate new raster
r.NAVals[] <- NAVals # store values in raster

r.filled <- cover(x=dem, y= r.NAVals)
writeRaster(r.filled , file = "/data/gpfs/assoc/gears/tree_vel/dem/ca_nv_nearest_neighbors_500_filled.tif")
