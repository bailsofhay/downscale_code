library(raster)
library(shapefiles)
library(spatial.tools)

data = shapefile('/projects/oa/tree_vel/weather_station/shapefile/ca_weather_data_aea/ca_weather_data_aea.shp')

# extract only data from 1985-2015
i = which(data$DATE >=198501 & data$DATE <=201512)
data = data[i,]

# correct data to m/s and Kelvin
data$PRCP = data$PRCP/2629743.83
data$TAVG = data$TAVG+273.15
data$TMIN = data$TMIN+273.15
data$TMAX = data$TMAX+273.15

xy = as.data.frame(coordinates(data))
data$x = xy$coords.x1
data$y = xy$coords.x2


# extract tci values
tci = raster("/projects/oa/tree_vel/tci/tci.tif")
coords = cbind(data$x, data$y)
e = extract(tci, coords)
tci = e
data$tci = tci

# extract elevation
elv = raster('/projects/oa/tree_vel/dem/raster/ca_dem_aea.tif')
e = extract(elv, coords)
elv = e
data$elv = elv

# extract slope
slp = raster('/projects/oa/tree_vel/dem/raster/ca_slope_aea.tif')
e = extract(slp, coords)
slp = e
data$slp = slp

# extract aspect
asp = raster('/projects/oa/tree_vel/dem/raster/ca_aspect_aea.tif')
e = extract(asp, coords)
asp = e
data$asp = asp

# extract out rad data for models
rad_files = list.files(path = "/projects/oa/tree_vel/radiation/aligned/", pattern = ".tif", include.dirs = T, full.names = T)
order = c(5,4,8,1,9,7,6,2,12,11,10,3)
rad_files = rad_files[order]
months = add_leading_zeroes(c(1,2,3,4,5,6,7,8,9,10,11,12))
date = as.character(substr(data$DATE,5,6))

rad_data = data.frame()
for (i in 1:length(rad_files))
{
  month = months[i]
  file = raster(rad_files[i])
  mo = which(date == month)
  coords = data[mo, 7:8]
  e = extract(file, coords)
  combine = as.data.frame(cbind(data$DATE[mo], coords$coords.x1, coords$coords.x2, e))
  names(combine) = c("DATE", "x", "y", "rad")
  rad_data = rbind(rad_data, combine)
}

# order to line up the correct files with radiation by date and location
data = data[order(data$DATE, data$x, data$y), ]
rad_data = rad_data[order(rad_data$DATE, rad_data$x, rad_data$y), ]
data$rad = rad_data$rad

write.csv(data, file = "/projects/oa/tree_vel/weather_station/ca_weather_data_1985-2015.csv")

# add tmean data
files = list.files(path = "/projects/oa/tree_vel/climate/extracted_climate/ts/", pattern = ".csv", include.dirs = T, full.names = T)

ts = data.frame()
for (i in 1:length(files))
{
  file = read.csv(files[i])
  names(file) = c("X", "DATE", "x", "y", "ts")
  ts = rbind(ts, file)
}

ts = ts[order(ts$DATE, ts$x, ts$y), ]
data$ts = ts$ts

# add tmin data
files = list.files(path = "/projects/oa/tree_vel/climate/extracted_climate/tmin/", pattern = ".csv", include.dirs = T, full.names = T)

tmin = data.frame()
for (i in 1:length(files))
{
  file = read.csv(files[i])
  names(file) = c("X", "DATE", "x", "y", "tmin")
  tmin = rbind(tmin, file)
}

tmin = tmin[order(tmin$DATE, tmin$x, tmin$y), ]
data$tmin = tmin$tmin

# add tmax data
files = list.files(path = "/projects/oa/tree_vel/climate/extracted_climate/tmax/", pattern = ".csv", include.dirs = T, full.names = T)

tmax = data.frame()
for (i in 1:length(files))
{
  file = read.csv(files[i])
  names(file) = c("X", "DATE", "x", "y", "tmax")
  tmax = rbind(tmax, file)
}

tmax = tmax[order(tmax$DATE, tmax$x, tmax$y), ]
data$tmax = tmax$tmax


s = seq(1:nrow(data))
r = sample(s, nrow(data)*.8)
training = data[r,]
testing = data[-r,]
data = training

# remove outliers from tmin, tmax, ts, and pr climate model data
ts_sd = sd(data$ts, na.rm = T)
tmin_sd = sd(data$tmin, na.rm = T)
tmax_sd = sd(data$tmax, na.rm = T)
z_ts = (abs(data$ts-mean(data$ts, na.rm = T)))/ts_sd
z_tmin = (abs(data$tmin-mean(data$tmin, na.rm = T)))/tmin_sd
z_tmax = (abs(data$tmax-mean(data$tmax, na.rm = T)))/tmax_sd
out_ts = which(z_ts >=3)
out_tmin = which(z_tmin >=4)
out_tmax = which(z_tmax >=3)

good_data = data
good_data$ts[out_ts] = NA
good_data$tmin[out_tmin] = NA
good_data$tmax[out_tmax] = NA

# remove outliers from weather station data
TAVG_sd = sd(data$TAVG, na.rm = T)
TMIN_sd = sd(data$TMIN, na.rm = T)
TMAX_sd = sd(data$TMAX, na.rm = T)
z_TAVG = (abs(data$TAVG-mean(data$TAVG, na.rm = T)))/TAVG_sd
z_TMIN = (abs(data$TMIN-mean(data$TMIN, na.rm = T)))/TMIN_sd
z_TMAX = (abs(data$TMAX-mean(data$TMAX, na.rm = T)))/TMAX_sd
out_TAVG = which(z_TAVG >=3)
out_TMIN = which(z_TMIN >=4)
out_TMAX = which(z_TMAX >=3)

good_data$TAVG[out_TAVG] = NA
good_data$TMIN[out_TMIN] = NA
good_data$TMAX[out_TMAX] = NA

write.csv(data, file = "/projects/oa/tree_vel/downscale/training/training_temp.csv")
write.csv(testing, file = "/projects/oa/tree_vel/downscale/training/testing_temp.csv")
# plot data
par(mfrow = c(2,2), pty = "s")

plot(good_data$TAVG, good_data$ts, xlab = "TAVG Weather Station", ylab = "TAVG climate model", main = "TAVG DATA", xlim = c(260,315), ylim = c(260, 315))
abline(0,1,col = "red")
       
plot(good_data$TMIN, good_data$tmin, xlab = "TMIN Weather Station", ylab = "TMIN climate model", main = "TMIN DATA", xlim = c(240,310), ylim = c(240, 310))
abline(0,1,col = "red")  

plot(good_data$TMAX, good_data$tmax, xlab = "TMAX Weather Station", ylab = "TMAX climate model", main = "TMAX DATA", xlim = c(270, 340), ylim = c(270, 340))
abline(0,1,col ="red")



# add precip data
files = list.files(path = "/projects/oa/tree_vel/climate/extracted_climate/pr/", pattern = ".csv", include.dirs = T, full.names = T)

pr = data.frame()
for (i in 1:length(files))
{
  file = read.csv(files[i])
  names(file) = c("X", "DATE", "x", "y", "pr")
  pr = rbind(pr, file)
}

pr = pr[order(pr$DATE, pr$x, pr$y), ]
data$pr = pr$pr