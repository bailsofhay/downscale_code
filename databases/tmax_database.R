library(raster)
library(rgdal)
library(shapefiles)
library(gtools)
library(hydroGOF)
library(mgcv)
library(randomForest)

# data = shapefile('/data/gpfs/assoc/gears/tree_vel/weather_stations/tmax_data/tmax_data.shp')
# 
# files = list.files(path = "/data/gpfs/assoc/gears/tree_vel/weather_stations/extract_files/tmax/", pattern = ".csv", include.dirs = T, full.names = T)
# files = mixedsort(files)
# 
# d = data
# d$tmax = NA
# d$rad = NA
# d$tci = NA
# d$elv = NA
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
#     d$tmax[x] = file[,1]
#     d$rad[x] = file[,2]
#     d$tci[x] = file[,3]
#     d$elv[x] = file[,4]
# 
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
# sd = sd(d$tmax, na.rm = T)
# z = abs(d$tmax-mean(d$tmax, na.rm = T))/sd
# x = which(z<=3.5)
# 
# test = d[x,]
# 
# min = min(d$value, d$tmax, na.rm = T)
# max = max(d$value, d$tmax, na.rm = T)
# 
# par(mfrow = c(1,2), pty = 's')
# plot(d$value, d$tmax, xlim = c(min, max), ylim = c(min, max), xlab = "Weather Station", ylab ="CCSM Model", main = "")
# abline(0,1, col = 'red', lwd = 2)
#        
# plot(test$value, test$tmax, xlim = c(min, max), ylim = c(min, max), xlab = "Weather Station", ylab ="CCSM Model", main = "")
# abline(0,1, col = 'red', lwd = 2)
# 
# cor(test$value, test$tmax)
# 
# s = sample(1:nrow(test), .8*nrow(test))
# training =test[s,]
# testing = test[-s,]
# 
# writeOGR(training, layer = "tmax_training", dsn = "/data/gpfs/assoc/gears/tree_vel/downscale/training/", driver = "ESRI Shapefile", overwrite = T)
# writeOGR(testing, layer = "tmax_testing", dsn = "/data/gpfs/assoc/gears/tree_vel/downscale/training/", driver = "ESRI Shapefile", overwrite = T)

pairs(~tmax+rad+tci+elv,data=test)

# check linearity
gam1 = gam(value~s(tmax)+s(rad)+s(tci)+s(elv), data = training, na.action = na.omit)

par(mfrow = c(2,2), pty = 's')
plot(gam1)

# check variable importance
#library(randomForestSRC)

#rf1 = rfsrc(value~tmax+rad+tci+elv, data = training, na.action = "na.omit", ntree =1000, importance = T)

# create glm model

training = shapefile('/data/gpfs/assoc/gears/tree_vel/downscale/training/tmax_training.shp')
testing = shapefile('/data/gpfs/assoc/gears/tree_vel/downscale/training/tmax_testing.shp')


glm1 = glm(value~tmax+rad+tci+elv, data = training, na.action = na.omit)
pr1 = predict(glm1, newdata = testing, na.action = na.pass)

cor(pr1, testing$value, use = "complete.obs")

rmse = function(error)
{
  sqrt(mean(error^2, na.rm = T))
}

rmse(pr1-testing$value)
pbias(pr1, testing$value)

min = min(pr1, testing$value, na.rm = T)
max = max(pr1, testing$value, na.rm = T)

par(mfrow = c(1,2), pty = 's')
plot(training$value, training$tmax, xlim = c(min, max), ylim = c(min, max), xlab = "Weather Station", ylab = "CCSM Model", main = "")
abline(0,1, col = 'red', lwd = 2)

plot(testing$value, pr1, xlim = c(min, max), ylim = c(min, max), xlab = "Observed", ylab = "Predicted", main = "")
abline(0,1, col = 'red', lwd = 2)

save(glm1, file ="/data/gpfs/assoc/gears/tree_vel/downscale/code/glm1_tmax.RData")

