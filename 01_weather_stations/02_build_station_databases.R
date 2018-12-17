library(raster)
library(shapefiles)
library(rgdal)


# get station locations that have coordinates of stations
ca_stations = read.csv('/data/gpfs/assoc/gears/tree_vel/weather_stations/GSOM_data/ca_stations.csv')
nv_stations = read.csv('/data/gpfs/assoc/gears/tree_vel/weather_stations/GSOM_data/nv_stations.csv')


# combine the ca and nv stations
stations = as.data.frame(rbind(ca_stations, nv_stations))
stations = stations[,c(6, 8, 10, 5)]

# load in climate data that has values, but is missing coordinates
ca_data = read.csv('/data/gpfs/assoc/gears/tree_vel/weather_stations/GSOM_data/ca_prcp_data.csv')
nv_data = read.csv('/data/gpfs/assoc/gears/tree_vel/weather_stations/GSOM_data/nv_prcp_data.csv')
data = as.data.frame(rbind(ca_data, nv_data))

names = names(data)
names[4] = "id"
names(data) = names

dates = data$date
dates = substr(dates, 1, 7)
dates = gsub("-", "_", dates)
data$date = dates

data = data[,c(2,3,4,5)]

# combine stations with climate data 
ids = as.vector(stations$id)

data$name = NA
data$x = NA
data$y = NA

for (i in 1:length(ids))
{
  id = ids[i]
  station = as.character(stations$name[i])
  x = stations$longitude[i]
  y = stations$latitude[i]

  index = which(data$id == id) 
  if (length(index) > 0)
  {
    data$name[index] = station
    data$x[index] = x
    data$y[index] = y
  }
}

ref = raster('/data/gpfs/assoc/gears/tree_vel/dem/raw/ca_nv_dem_utm.tif')

data = data[complete.cases(data),]

coordinates(data) = ~x+y
projection(data) = crs(ref)

boundary = shapefile('/data/gpfs/assoc/gears/tree_vel/shapefiles/ca_nv_boundary/ca_nv_boundary.shp')

plot(boundary)
plot(data, add = T, pch = 20, col = 'red')

data = spTransform(data, CRS = crs(raster('/data/gpfs/assoc/gears/tree_vel/dem/ca_nv_dem_aea.tif')))
boundary = shapefile('/data/gpfs/assoc/gears/tree_vel/shapefiles/ca_nv_boundary/ca_nv_boundary_aea.shp')

plot(boundary)
plot(data, col = 'red', pch = 20, add = T)


writeOGR(data, layer = "rad_data", dsn = "/data/gpfs/assoc/gears/tree_vel/weather_stations/rad_data/", driver = "ESRI Shapefile")

