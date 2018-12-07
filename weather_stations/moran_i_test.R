library(raster)
library(shapefiles)


data = shapefile('/data/gpfs/assoc/gears/tree_vel/weather_stations/tmax_data/tmax_data.shp')

shape = shapefile("/data/gpfs/assoc/gears/tree_vel/shapefiles/ca_nv_boundary/ca_nv_boundary_aea.shp")


stations = unique(data$id)
sample_data = data[!duplicated(data$id),]

# s = sample(1:nrow(data), 5000)
# sample_data =data[s,]


sample_data$index = seq(1:nrow(sample_data))


library(spdep)


dist = as.matrix(dist(coordinates(sample_data)))

w = 1/dist
x = which(w == Inf)
w[x] = 0

listw= mat2listw(x = w)
spweights = spweights.constants(listw)


m = moran.test(x= sample_data$value, listw, randomisation=TRUE, zero.policy=NULL, alternative="greater", rank = FALSE, na.action=na.fail, spChk=NULL, adjust.n=TRUE)



