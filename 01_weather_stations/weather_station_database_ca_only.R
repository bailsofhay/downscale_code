files = list.files(path = "P:\\tree_vel\\weather_station//raw//ca//", pattern = ".csv", include.dirs = T, full.names = T)


data = read.csv(files[1])
for (i in 2:length(files))
{
  file = read.csv(files[i])
  data =rbind(data,file)
}

# make temp celcius
data$TAVG = (data$TAVG -32)*(5/9)
data$TMAX = (data$TMAX -32)*(5/9)
data$TMIN = (data$TMIN -32)*(5/9)

# precip to m
data$PRCP = (data$PRCP * 25.4)/1000

write.csv(data, file = "P:\\tree_vel\\weather_station\\weather_database_ca_2006-2016.csv")
