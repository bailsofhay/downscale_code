library(raster)
library(rgdal)
library(shapefiles)
library(gtools)
library(hydroGOF)
library(mgcv)
library(randomForest)

data = shapefile('/data/gpfs/assoc/gears/tree_vel/weather_stations/tmax_data/tmax_data.shp')

files = list.files(path = "/data/gpfs/assoc/gears/tree_vel/weather_stations/extract_files/tmax/", pattern = ".csv", include.dirs = T, full.names = T)
files = mixedsort(files)

d = data
d$tmax = NA
d$rad = NA
d$tci = NA
d$elv = NA
d$station = NA


dates = sort(unique(data$date))
for (i in 1:length(dates))
{
  date = dates[i]
  file = read.csv(files[i])
  file = file[,-1]
  
  if (nrow(file)>0)
  {
    good = print(paste(date, " good", sep = ""))
    x = which(data$date == date)
    d$tmax[x] = file[,1]
    d$rad[x] = file[,2]
    d$tci[x] = file[,3]
    d$elv[x] = file[,4]
    d$station[x] = file[,5]
  }
  
}


# get rid of nevada data for now
ca = grep(d$name, pattern = " CA ")
d = d[ca, ]

# convert weather station data to kelvins
d$value= d$value+273.15


d = as.data.frame(d)
d = d[complete.cases(d),]

coordinates(d) = ~coords.x1+coords.x2
projection(d) = crs(raster('/data/gpfs/assoc/gears/tree_vel/dem/ca_nv_dem_aea.tif'))

# outlier analysis
sd = sd(d$tmax, na.rm = T)
z = abs(d$tmax-mean(d$tmax, na.rm = T))/sd
x = which(z<=3.5)

test = d[x,]

#### check autocorrelation stuff

# temporal
time = as.numeric(gsub("_", "", test$date))
test$time = time

mdl <- lm(value~time, data = test)
#mdl <- lm(value~time, data = data)

summary(mdl)

par(mfrow=c(2,2))
plot(mdl)

par(mfrow=c(1,1))
plot(residuals(mdl))


plot(residuals(mdl),type="b")
abline(h=0,lty=3)


acf(residuals(mdl))

# test for spatial autocorrelation between station locations 
# stations = unique(test$id)
# vals = seq(1:length(stations))
# 
# test$station = NA
# for (i in 1:length(stations))
# {
#   station = stations[i]
#   x = which(test$id == station)
#   test$station[x] = vals[i]
# }
# 
# mdl = lm(value~station, data = test)
# 
# 
# summary(mdl)
# 
# par(mfrow=c(2,2))
# plot(mdl)
# 
# par(mfrow=c(1,1))
# plot(residuals(mdl))
# 
# 
# plot(residuals(mdl),type="b")
# abline(h=0,lty=3)
# 
# 
# acf(residuals(mdl))
# 
# library(spdep)
# stations= unique(coordinates(test)))
################################################################

min = min(test$value, test$tmax, na.rm = T)
max = max(test$value, test$tmax, na.rm = T)
plot(test$value, test$tmax, xlim = c(min, max), ylim = c(min, max), xlab = "Weather Station", ylab ="CCSM Model", main = "")
abline(0,1, col = 'red', lwd = 2)

cor(test$value, test$tmax)

#make a dummy station id column
# stations = unique(test$id)
# test$station = NA
# 
# for (i in 1:length(stations))
# {
#   station = stations[i]
#   x = which(test$id == station)
#   test$station[x] = i
# }
# 

s = sample(1:nrow(test), .6*nrow(test))
training =test[s,]
testing = test[-s,]

writeOGR(training, layer = "tmax_training", dsn = "/data/gpfs/assoc/gears/tree_vel/downscale/training/", driver = "ESRI Shapefile", overwrite = T)
writeOGR(testing, layer = "tmax_testing", dsn = "/data/gpfs/assoc/gears/tree_vel/downscale/training/", driver = "ESRI Shapefile", overwrite = T)


# check linearity
gam1 = gam(value~s(tmax)+s(rad)+s(tci)+s(elv), data = training, na.action = na.omit)
# 
par(mfrow = c(2,2), pty = 's')
plot(gam1)

# check variable importance
library(randomForest)
# 
rf1 = randomForest(value~tmax+rad+tci+elv, data = training, na.action = na.omit, ntree =500)
save(rf1, file = "/data/gpfs/assoc/gears/tree_vel/downscale/code/tmax_rf1.RData")
# create glm model

training = shapefile('/data/gpfs/assoc/gears/tree_vel/downscale/training/tmax_training.shp')
testing = shapefile('/data/gpfs/assoc/gears/tree_vel/downscale/training/tmax_testing.shp')


station = raster('/data/gpfs/assoc/gears/tree_vel/dem/ca_nv_nearest_weather_station_60m.tif')
training$station = extract(station, training)
testing$station = extract(station, testing)
testing$date = as.numeric(gsub("_", "", testing$date))
training$date = as.numeric(gsub("_", "", training$date))
training = as.data.frame(training)
testing = as.data.frame(testing)

# lme1 = lme(fixed = value~tmax+rad+tci+elv, data = training, random = ~1|station, na.action = na.omit)
# pr = predict(lme1, newdata = testing, na.action = na.pass)
# 
# cor(pr, testing$value, use = "complete.obs")
# rmse = function(error)
# { sqrt(mean(error^2, na.rm = T))}
# rmse(pr-testing$value)
# bias(testing$value, pr)
# 
# plot(testing$value, pr, xlim = c(min(testing$value, pr, na.rm = T), max(testing$value, pr, na.rm = T)), xlab = "Observed", ylab = "Predicted", main = "")
# abline(0,1, col = 'red', lwd = 2)
# 
# save(lme1, file = "/data/gpfs/assoc/gears/tree_vel/downscale/code/tmax_lme1.Rdata")
# 
# t = lme(fixed = value~tmax+rad+tci+elv, data = training, random = ~tmax+rad+tci+elv|station, na.action = na.omit)
library(Metrics)

glm1 = glm(value~tmax+rad+tci+elv+coords.x1+coords.x2, data = training, na.action = na.omit)
pr1 = predict(glm1, newdata = testing, na.action = na.pass)

cor(pr1, testing$value, use = "complete.obs")

rmse = function(error)
{
  sqrt(mean(error^2, na.rm = T))
}

rmse(pr1-testing$value)
bias(pr1, testing$value)

min = min(pr1, testing$value, na.rm = T)
max = max(pr1, testing$value, na.rm = T)

par(mfrow = c(1,2), pty = 's')
plot(training$value, training$tmax, xlim = c(min, max), ylim = c(min, max), xlab = "Weather Station", ylab = "CCSM Model", main = "")
abline(0,1, col = 'red', lwd = 2)

plot(testing$value, pr1, xlim = c(min, max), ylim = c(min, max), xlab = "Observed", ylab = "Predicted", main = "")
abline(0,1, col = 'red', lwd = 2)

save(glm1, file ="/data/gpfs/assoc/gears/tree_vel/downscale/code/glm1_tmax.RData")


# 
# 
# library(nlme)
# library(Metrics)
# training  = as.data.frame(training)
# testing = as.data.frame(testing)
# lme1 = lme(fixed = value~tmax+rad+tci+elv, data = training, random = ~1|station, na.action = na.omit)
# pr = predict(lme1, newdata = testing, na.action = na.pass)
# 
# cor(pr, testing$value, use = "complete.obs")
# rmse = function(error)
# { sqrt(mean(error^2, na.rm = T))}
# rmse(pr-testing$value)
# bias(testing$value, pr)
# 
# plot(testing$value, pr, xlim = c(min(testing$value, pr, na.rm = T), max(testing$value, pr, na.rm = T)), xlab = "Observed", ylab = "Predicted", main = "")
# abline(0,1, col = 'red', lwd = 2)
# 
# save(lme1, file = "/data/gpfs/assoc/gears/tree_vel/downscale/code/tmax_lme1.Rdata")
