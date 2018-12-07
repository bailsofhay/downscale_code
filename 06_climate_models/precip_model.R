library(mgcv)
library(randomForest)
library(raster)
library(shapefiles)
library(rgdal)

data = shapefile('/data/gpfs/assoc/gears/tree_vel/weather_stations/prcp_data/pr_database.shp')
store = data

# library(spdep)
# 
# stations = unique(coordinates(data))
# x = seq(1:nrow(stations))
# 
# nb = tri2nb(coordinates(training), row.names = NULL)
# listw = nb2listw(nb, glist=NULL, style="W", zero.policy=NULL)
# 
# 
# moran_t = moran.test(x, listw, randomisation=TRUE, zero.policy=NULL, alternative="greater", rank = FALSE, na.action=na.fail, spChk=NULL, adjust.n=TRUE)

## yes there is positive spatial autocorrelation  between the stations


test = store



data = test
val_cube = data$value^(1/3)
pr_cube = data$pr^(1/3)


data$val_cube = val_cube
data$pr_cube = pr_cube


training_data <- data
min = min(training_data$value, na.rm = T)
max = max(training_data$value, na.rm = T)
sampling_bins <- seq(from  = min, to = max, by = (max-min)/14)

training_data$bin <- cut(training_data$value,sampling_bins,include.lowest=T)

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
balanced_size = 5000
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

# writeOGR(training, layer = "pr_training", dsn = "/data/gpfs/assoc/gears/tree_vel/downscale/training_data/", driver = "ESRI Shapefile", overwrite = T)
# writeOGR(testing, layer = "pr_testing", dsn = "/data/gpfs/assoc/gears/tree_vel/downscale/training_data/", driver = "ESRI Shapefile", overwrite = T)
# 
# # figure out what variables are important
# rf1 = randomForest(val_cube~pr_cube+speed+dir+delta_60+delta_500+delta_1000+delta_5000+dem_60+dem_500+dem_1000+dem_5000+slope_60+slope_500+slope_1000+slope_5000, data = training, na.action = na.omit, ntree = 1000)
# save(rf1, file = "/data/gpfs/assoc/gears/tree_vel/downscale/code/pr_rf1.RData")
# 
# 
# # determine if behaving linearly
# gam1 = gam(val_cube~s(pr_cube)+s(speed)+s(dir)+s(delta_60)+s(dem_5000)+s(slope_500), data = training, na.action = na.omit)
# save(gam1, file = "/data/gpfs/assoc/gears/tree_vel/downscale/code/pr_gam1.RData")
# 
# 
# par(mfrow = c(2,3))
# plot(gam1)
# 
# t = training
# t$dir = sin(t$dir)
# t$slope_500 = log(t$slope_500, na.rm = T)
# 
# 
# gam2 = gam(val_cube~s(pr_cube)+s(speed)+s(dir)+s(delta_60)+s(dem_5000)+s(slope_500), data = t, na.action = na.omit)
# plot(gam2)
# 

# final model data
training$dir_sin = sin(training$dir)
training$slope_log = log(training$slope_500)
dummy = rep(1, nrow(training))
training$dummy = dummy
dates = training$date
dates = gsub("_", "", dates)
training$dates = dates


testing$dir_sin = sin(testing$dir)
testing$slope_log = log(testing$slope_500)
dummy = rep(1, nrow(testing))
testing$dummy = dummy
dates = testing$date
dates = gsub("_", "", dates)
testing$dates = dates

writeOGR(training, layer = "pr_training", dsn = "/data/gpfs/assoc/gears/tree_vel/downscale/training_data/", driver = "ESRI Shapefile", overwrite = T)
writeOGR(testing, layer = "pr_testing", dsn = "/data/gpfs/assoc/gears/tree_vel/downscale/training_data/", driver = "ESRI Shapefile", overwrite = T)

 
# mixed effects model

# first understand the autocorrelation
library(gstat)
gs = gstat(formula = val_cube~pr_cube+speed+dir_sin+delta_60+dem_5000+slope_log, locations = coordinates(training), data = training)
v = variogram(gs)


psill = 2.576787e-06
model = c("Exp", "Sph", "Gau", "Mat")
range = NA
nugget = 1.539471e-06
kappa = 0.5

fv = fit.variogram(v, vgm(psill = psill, model = model[1], range = range, nugget = nugget), fit.ranges = T,fit.kappa = T)

print( plot(v, fv) )

# determine the shape of spatial autocorrelation


glm1 = glm(val_cube~pr_cube+speed+dir_sin+delta_60+dem_5000+slope_log+tave+relhum, data = training, na.action = na.omit)
pr = predict(glm1, newdata = testing, na.action = na.pass)
pr = pr^3
cor(pr, testing$value, use = "complete.obs")
save(glm1, file = "/data/gpfs/assoc/gears/tree_vel/downscale/code/pr_glm1.RData")

glm2 = glm(val_cube~pr_cube+speed+dir_sin+delta_60+dem_5000+slope_log+tave+relhum+dates, data = training, na.action = na.omit)
pr = predict(glm2, newdata = testing, na.action = na.pass)
pr = pr^3
cor(pr, testing$value, use = "complete.obs")
save(glm2, file = "/data/gpfs/assoc/gears/tree_vel/downscale/code/pr_glm2.RData")


train = as.data.frame(training)
test = as.data.frame(testing)

glm3 = glm(val_cube~pr_cube+speed+dir_sin+delta_60+dem_5000+slope_log+coords.x1+date, data = train, na.action = na.omit)
pr = predict(glm3, newdata = testing, na.action = na.pass)
pr = pr^3
cor(pr, testing$value, use = "complete.obs")

# test model assumptions with autocorrelation considered
resids = resid(glm1)

xy = as.data.frame(coordinates(training))
dat<-data.frame(xy$coords.x1,xy$coords.x2, resids=resids)
names(dat) = c('x', 'y', 'resids')
coordinates(dat)<-~x+y
bubble(dat,zcol='resids')


var.mod<-variogram(resids~1,data=dat, alpha=c(0,45, 90,135))#
plot(var.mod)


# strong correlation in most directions

library(nlme)

s = sample(seq(1:nrow(data)), .8*nrow(data))
training = data[s,]
testing = data[s,]

training$dir_sin = sin(training$dir)
training$slope_log = log(training$slope_500)
dummy = rep(1, nrow(training))
training$dummy = dummy
dates = training$date
dates = gsub("_", "", dates)
training$dates = dates
training = as.data.frame(training)

testing$dir_sin = sin(testing$dir)
testing$slope_log = log(testing$slope_500)
dummy = rep(1, nrow(testing))
testing$dummy = dummy
dates = testing$date
dates = gsub("_", "", dates)
testing$dates = dates

gls1 = gls(val_cube~pr_cube+speed+dir_sin+delta_60+dem_5000+slope_log, correlation= corExp(form = ~coords.x1+coords.x2|date, nugget = T), data = training, na.action = na.omit)
save(gls1, file = "/data/gpfs/assoc/gears/tree_vel/downscale/code/pr_gls_id.RData")

pr = predict(gls1, newdata = testing, na.action = na.pass)
pr = pr^3
cor(pr, testing$value, use = "complete.obs")



model = lme(fixed = val_cube~pr_cube+speed+dir_sin+delta_60+dem_5000+slope_log, data = training, random = ~1|dummy, method = "ML") 

summary(model)
save(model, file = "/data/gpfs/assoc/gears/tree_vel/downscale/code/pr_lme1.RData")

model.exp = update(model, correlation = corExp(1,  form = ~coords.x1+coords.x2) , method = "ML")



save(model.exp, file = "/data/gpfs/assoc/gears/tree_vel/downscale/code/pr_lme_exp.RData")
summary(model.exp)



pr = predict(model.exp, newdata = training, na.action = na.pass)
pr = pr^3

min = min(testing$value, pr, na.rm = T)
max = max(testing$value, pr, na.rm = T)

plot(testing$value, pr, xlim = c(min, max), ylim = c(min, max), xlab = "Observed", ylab = "Predicted", main = "")
cor(testing$value, pr, use = "complete.obs")



g1 = glm(val_cube~pr_cube++speed+dir_sin+delta_60+dem_5000+slope_log, data = training, na.action = na.omit)

#save(g1, file = "/data/gpfs/assoc/gears/tree_vel/downscale/code/pr_glm1.RData")

summary(g1)

testing$dir_sin = sin(testing$dir)
testing$slope_log = log(testing$slope_500)


pr = predict(g1, newdata = testing, na.action  = na.pass)
pr = pr^3

min = min(testing$value, pr, na.rm = T)
max = max(testing$value, pr, na.rm = T)

plot(testing$value, pr, xlim = c(min, max), ylim = c(min, max), xlab = "Observed", ylab = "Predicted", main = "")
cor(testing$value, pr, use = "complete.obs")




