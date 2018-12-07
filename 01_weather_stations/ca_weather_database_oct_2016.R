old_files = list.files(path = "/projects/oa/tree_vel/weather_station/raw/all_states/", pattern = ".csv", include.dirs = T, full.names = T)

old_data = data.frame()
for (i in 1:length(old_files))
{
  file = old_files[i]
  data = read.csv(file)
  old_data = rbind(old_data, data)
}

ca = grep(old_data$STATION_NAME, pattern = " CA ")
old_data = old_data[,c(2,4,5,6,7,10,8,9)]
names = c("station", "lat", "long", "date", "prcp", "tavg", "tmax", "tmin")
names(old_data) = names

date = old_data$date
date = as.numeric(substr(date, 1, 6))
old_data$date = date

# reclassify NA's
pr_na = which(old_data$prcp == -9999)
old_data$prcp[pr_na] = NA

tave_na = which(old_data$tavg == -9999)
old_data$tavg[tave_na] = NA

tmin_na = which(old_data$tmin == -9999)
old_data$tmin[tmin_na] = NA

tmax_na = which(old_data$tmax == -9999)
old_data$tmax[tmax_na] = NA

# convert precip from tenths of mm to meter
prcp = old_data$prcp
prcp = prcp/1000 # mm to meter
prcp = prcp/10 # get out of 10ths of m
prcp = prcp/(2629743.83) # m/s
old_data$prcp = prcp

# fix temperatures so they are not in tenths to celcius
tave = old_data$tavg
tave = tave/10
old_data$tavg = tave

tmin = old_data$tmin
tmin = tmin/10
old_data$tmin = tmin

tmax = old_data$tmax
tmax = tmax/10
old_data$tmax = tmax

#write.csv(old_data, file = "/projects/oa/tree_vel/weather_station/ca_weather_data_1975-2005.csv")



new_files = list.files('/projects/oa/tree_vel/weather_station/raw/ca/', pattern = ".csv", include.dirs = T, full.names = T)

new_data = data.frame()
for (i in 1:length(new_files))
{
  file = new_files[i]
  data = read.csv(file)
  new_data = rbind(new_data, data)
}

new_data = new_data[,c(2,3,4,6,7,8,9,10)]
# fix date
date = new_data$DATE
date = as.numeric(gsub(pattern = "-", replacement = "", x = date))
new_data$DATE = date

# fix precip from inches to m
prcp = new_data$PRCP
prcp = prcp*(0.0254) # to m/month
prcp = prcp/(2629743.83) # m/s
new_data$PRCP = prcp

# fix temperature from F to C
tavg = new_data$TAVG
tavg = (tavg - 32)*(5/9)
new_data$TAVG = tavg

tmin = new_data$TMIN
tmin = (tmin - 32)*(5/9)
new_data$TMIN = tmin

tmax = new_data$TMAX
tmax = (tmax - 32)*(5/9)
new_data$TMAX = tmax


names = c("station", "LATITUDE", "LONGITUDE", "DATE", "PRCP", "TAVG", "TMAX", "TMIN")
names(new_data) = names
names(old_data) = names

write.csv(new_data, file = "/projects/oa/tree_vel/weather_station/ca_weather_data_2006-2016.csv")

data = rbind(as.data.frame(old_data), as.data.frame(new_data))
i = which(data$DATE >= 198501 & data$DATE <= 201512)
data = data[i,]
#write.csv(data, file = "/projects/oa/tree_vel/weather_station/ca_weather_data_1975-2016.csv")

# make database into shapefile
library(sp)
library(rgdal)
x = as.numeric(as.vector(data$LONGITUDE))
y = as.numeric(as.vector(data$LATITUDE))
xy = paste(x,y, sep = "")
na = grep(xy, pattern = "NA")
x = x[-na]
y = y[-na]
data.fix = data[-na,]
data.fix$LONGITUDE = x
data.fix$LATITUDE = y

coordinates(data.fix) = ~LONGITUDE+LATITUDE
library(raster)
r1 = raster('/projects/oa/tree_vel/dem/raster/ca_dem_utm.tif')
r2 = raster('/projects/oa/tree_vel/dem/raster/ca_dem_aea.tif')

projection(data.fix) = crs(r1)
data.aea = spTransform(data.fix, CRS = crs(r2))
writeOGR(data.aea, dsn = "/projects/oa/tree_vel/weather_station/shapefile/ca_weather_data_aea", layer = "ca_weather_data_w_precip", driver = "ESRI Shapefile")

