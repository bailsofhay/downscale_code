library(raster)
library(rgdal)
library(shapefiles)
library(gtools)
library(hydroGOF)
library(mgcv)
library(randomForest)
library(Metrics)

data = shapefile('/data/gpfs/assoc/gears/tree_vel/weather_stations/prcp_data/prcp_data.shp')

files = list.files(path = "/data/gpfs/assoc/gears/tree_vel/weather_stations/extract_files/pr/", pattern = ".csv", include.dirs = T, full.names = T)
files = mixedsort(files)

d = data
d$pr = NA
d$hum = NA
d$tave = NA
d$speed= NA
d$dir = NA
d$delta_60 = NA
d$delta_500 = NA
d$delta_1000 = NA
d$delta_5000 = NA
d$dem_60 = NA
d$dem_500 = NA
d$dem_1000 = NA
d$dem_5000 = NA
d$slope_60 = NA
d$slope_500 = NA
d$slope_1000 = NA
d$slope_5000 = NA




index = seq(1:432)
f = as.numeric(substr(files, 71, nchar(files)-4))

x = which(!(index %in% f))

dates = sort(unique(data$date))
dates = dates[-x]

for (i in 1:length(dates))
{
  date = dates[i]
  file = read.csv(files[i])
  file = file[,-1]
  
  if (nrow(file)>0)
  {
    good = print(paste(date, " good", sep = ""))
    x = which(data$date == date)
    d$pr[x] = file[,1]
    d$hum[x] = file[,2]
    d$tave[x] = file[,3]
    d$speed[x] = file[,4]
    d$dir[x] = file[,5]
    d$delta_60[x] = file[,6]
    d$delta_500[x] = file[,7]
    d$delta_1000[x] = file[,8]
    d$delta_5000[x] = file[,9]
    d$dem_60[x] = file[,10]
    d$dem_500[x] = file[,11]
    d$dem_1000[x] = file[,12]
    d$dem_5000[x] = file[,13]
    d$slope_60[x] = file[,14]
    d$slope_500[x] = file[,15]
    d$slope_1000[x] = file[,16]
    d$slope_5000[x] = file[,17]
    
  }
  
}


# get rid of nevada data for now
ca = grep(d$name, pattern = " CA ")
d = d[ca, ]

# convert weather station data to m/s
d$value= d$value*(1/2629743.83)*(1/1000)


d = as.data.frame(d)
d = d[complete.cases(d),]

coordinates(d) = ~coords.x1+coords.x2
projection(d) = crs(raster('/data/gpfs/assoc/gears/tree_vel/dem/ca_nv_dem_aea.tif'))


min = min(d$value, d$pr, na.rm = T)
max = max(d$value, d$pr, na.rm = T)
# outlier analysis

# sd = sd(d$value, na.rm = T)
# z = abs(d$value-mean(d$value, na.rm = T))/sd
# x = which(z<=5)
q95 = quantile(d$value, prob = 0.9997)
x = which(d$value < q95)
##########################################################

test = d
test = test[x,]
test = as.data.frame(test)

par(mfrow = c(1,2), pty = 's')
plot(d$value, d$pr, xlim = c(min, max), ylim = c(min, max))
plot(test$value, test$pr, xlim = c(min, max), ylim = c(min, max))

cor(test$value, test$pr, use = "complete.obs")


#test = as.data.frame(test)
test = test[complete.cases(test),]


min = min(test$value, test$pr, na.rm = T)
max = max(test$value, test$pr, na.rm = T)
plot(test$value, test$pr, xlim = c(min, max), ylim = c(min, max), xlab = "Weather Station", ylab ="CCSM Model", main = "")
abline(0,1, col = 'red', lwd = 2)

cor(test$value, test$pr, use = "complete.obs")



coordinates(test) = ~coords.x1+coords.x2
projection(test) = crs(raster('/data/gpfs/assoc/gears/tree_vel/dem/ca_nv_dem_aea.tif'))


########################################################
# make testing and training datasets
training_data <-test

min = min(test$value, na.rm = T)
max = max(test$value, na.rm =T)
width = (max-min)/20

sampling_bins <- seq(from = min, to = max, by = width )

training_data$bin <- cut(test$value,sampling_bins,include.lowest=T)

# Stratified random sampling per bin:
training_fraction = 0.8

require("foreach")

# This divides the data into training and testing, stratified
#	by % cover bin:
unique_bins <- sort(unique(training_data$bin))
training_data$train_test <- NA
training_testing <- foreach(i=unique_bins) %do%
{
  print(i)
  training_testing_subset_indices <- which(training_data$bin==i)
  bin_n <- length(training_testing_subset_indices)
  training_sample_indices <- sample(training_testing_subset_indices,
                                    ceiling(bin_n*training_fraction))
  testing_sample_indices <- training_testing_subset_indices[!
                                                              (training_testing_subset_indices %in% training_sample_indices)]
  
  training_data$train_test[training_sample_indices] <- "training"
  training_data$train_test[testing_sample_indices] <- "testing"
  return(NULL)
}

# Now break out the datasets:
training_dataset <- training_data[training_data$train_test=="training",]
testing_dataset <- training_data[training_data$train_test=="testing",]

# Now create a training dataset using balanced sampling (ONLY FOR RF):
balanced_size = 1000
training_dataset_rf <- foreach(i = unique_bins,.combine="rbind") %do%
{
  print(i)
  training_indices <- which(training_dataset$bin==i)
  bin_n <- length(training_indices)
  balanced_training <- training_dataset[training_indices,]
  if(bin_n < balanced_size)
  {
    # UPSAMPLE
    balanced_training_new_indices <- sample(training_indices,balanced_size,replace=T)
    balanced_training <- training_dataset[balanced_training_new_indices,]
  }
  if(bin_n > balanced_size)
  {
    # DOWNSAMPLE
    balanced_training_new_indices <- sample(training_indices,balanced_size,replace=F)
    balanced_training <- training_dataset[balanced_training_new_indices,]
  }
  
  return(balanced_training)
}

training = training_dataset_rf
testing = testing_dataset

writeOGR(training, layer = "pr_training", dsn = "/data/gpfs/assoc/gears/tree_vel/downscale/training/", driver = "ESRI Shapefile", overwrite = T)
writeOGR(testing, layer = "pr_testing", dsn = "/data/gpfs/assoc/gears/tree_vel/downscale/training/", driver = "ESRI Shapefile", overwrite = T)



training = shapefile('/data/gpfs/assoc/gears/tree_vel/downscale/training/pr_training.shp')
testing = shapefile('/data/gpfs/assoc/gears/tree_vel/downscale/training/pr_testing.shp')
training$value_cube = (training$value)^(3)
testing$value_cube = (testing$value)^(3)


training = as.data.frame(training)
training$date = as.numeric(gsub("_", "", training$date))
testing = as.data.frame(testing)
testing$date = as.numeric(gsub("_", "", testing$date))
training = training[complete.cases(training),]
testing = testing[complete.cases(testing),]


# transformations
# training$tave_trans = -2*(training$tave)-(training$tave)^2
# training$dir_trans = -2*(training$dir)-(training$dir)^2
# training$delta_5000_trans = -2*(training$delta_5000)-(training$delta_5000)^2
# 
# training$pr = training$pr+0.001
# training$pr_trans = log(training$pr)
# 
# training$hum = training$hum+0.001
# training$hum_trans = log2(training$hum)
# 
# training$speed = training$speed+0.001
# training$speed_trans = (-1*training$speed)^2#logit(training$speed, min = 0, max = 12)
# 
# training$slope_60 = training$slope_60+0.001
# training$slope_60_trans = log(training$slope_60)
# 
# 
# testing$tave_trans = -2*(testing$tave)-(testing$tave)^2
# testing$dir_trans = -2*(testing$dir)-(testing$dir)^2
# testing$delta_5000_trans = -2*(testing$delta_5000)-(testing$delta_5000)^2
# 
# testing$pr = testing$pr+0.001
# testing$pr_trans = log(testing$pr)
# 
# testing$hum = testing$hum+0.001
# testing$hum_trans = log2(testing$hum)
# 
# testing$speed = testing$speed+0.001
# testing$speed_trans = (-1*testing$speed)^2#logit(testing$speed, min = 0, max = 12)
# 
# testing$slope_60 = testing$slope_60+0.001
# testing$slope_60_trans = log(testing$slope_60)



# test to see which variables are most important at which scales:

rf1 = randomForest(value_cube~pr+hum+tave+speed+dir+delta_60+delta_500+delta_1000+delta_5000+dem_60+dem_500+dem_1000+dem_5000+slope_60+slope_500+slope_1000+slope_5000+ocean+tci, data = training, na.action = na.omit, ntree = 500)

#rf2 = randomForest(value~pr+hum+tave+speed+dir+delta_5000+dem_5000+slope_60, data = training, na.action = na.omit, ntree = 500)

step = step(glm(value_cube~pr+hum+tave+speed+dir+delta_60+delta_500+delta_1000+delta_5000+dem_60+dem_500+dem_1000+dem_5000+slope_60+slope_500+slope_1000+slope_5000+ocean+tci, data = training, na.action = na.omit), direction = "backward")
# slope

rf2 = randomForest(value_cube~tave+slope_1000+dir+pr+speed+hum+delta_500+dem_5000, data = training, na.action = na.omit, ntree = 500)

# par(mfrow = c(1,1), pty = 's')
# partialPlot(rf2, training, "coords.x1", plot = T)

vars = c("tave", "slope_1000", "dir", "pr", "speed", "hum", "delta_500", "dem_5000")

par(mfrow = c(2,4), pty = 's')

training = as.data.frame(training)
training = training[complete.cases(training),]

for (i in 1:8)
{
  partialPlot(rf1, training, vars[i], plot = T, xlab = vars[i], ylab = "Precip", main = "")
}

# most important variables: tave, dir, hum, pr, delta_5000, dem_5000, speed, slope_60



# glm model

glm1 = glm(value_cube~tave+hum+slope_500+pr+ocean+delta_500+dem_5000+tci, data = training, na.action = na.omit)

pr = predict(glm1, newdata = testing, na.action = na.pass)
pr = pr^(1/3)

cor(pr, testing$value, use = "complete.obs")

rmse = function(error)
{
  sqrt(mean(error^2, na.rm = T))
}

rmse(pr-testing$value)
bias(pr, testing$value)



