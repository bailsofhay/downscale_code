library(rnoaa)
library(plyr)
library(spatial.tools)
library(raster)
library(shapefiles)
library(rgdal)


years = seq(from = 1982, to = 2018, by = 1)
months = add_leading_zeroes(seq(1:12),2)


# get a list of all unique station locations for CA sing 1982
ca_stations = data.frame()

for (i in 1:length(years))
{
  year = years[i]
  
  startdate  = paste(year, "01-01", sep = "-")
  enddate = paste(year, "12-01", sep = "-")
  
  
  stations = ncdc_stations(datasetid='GSOM', locationid='FIPS:06', token = "NpAYCweVjssSySoIEJejwJlpckCkZSUL", startdate = startdate, enddate = enddate, limit = 1000)
  data = stations$data
  id = data$id
  #lim = print(paste("limit = ", nrow(data), sep = ""))
  
  
  index = which(!(id %in% ca_stations$id))
  if (length(index) > 0)
  {
    ca_stations = rbind(ca_stations, data[index,])} 

  }


# get a list of data per variable for each unique stations for all dates available since 1982


database = data.frame()

for (i in 1:length(stations))
{
  
    start = paste(years[j], "-01-01", sep = "")
    end = paste(years[j], "-12-31", sep = "")
    
    clim = ncdc(datasetid='GSOM', stationid = "FIPS:06", token = "NpAYCweVjssSySoIEJejwJlpckCkZSUL",  startdate = start, enddate = end, limit = 1000) #startdate = start, enddate = end,
    data = clim$data
    var = which(data$datatype == "TMAX")
    
    if (length(index) > 0)
    {
      d$station = data$station
      d$date = data$date
      d$} 
    
  }
  
}



# ghcnd_* - GHCND daily data from NOAA
# ncdc_* - NOAA National Climatic Data Center (NCDC) vignette (examples)

# cars = datasetid, datatypeid, stationid, locationid, startdate, enddate, dataset = , datatype = , station = , location = locationtype, 
states = ghcnd_states(token = "NpAYCweVjssSySoIEJejwJlpckCkZSUL")
ca = ghcnd_stations(locationtype = "State", locationname="CALIFORNIA", token = "NpAYCweVjssSySoIEJejwJlpckCkZSUL")


(datasetid='GHCND', token = "NpAYCweVjssSySoIEJejwJlpckCkZSUL", locationid = "FIPS:06", locationtype = "State", locationname="California")

#ncdc_stations(datasetid='GHCND', locationid='FIPS:06')

stations1 = ncdc_stations(datasetid='GSOM', locationid='FIPS:06', token = "NpAYCweVjssSySoIEJejwJlpckCkZSUL", startdate = "1982-01-01", enddate = "2000-12-31", limit = 1000)
id.data1 = stations$data1

stations2 = ncdc_stations(datasetid='GSOM', locationid='FIPS:06', token = "NpAYCweVjssSySoIEJejwJlpckCkZSUL", startdate = "2001-01-01", enddate = "2018-02-01", limit = 1000)
id.data2 = stations$data2



out <- ncdc(datasetid='GSOY', datatypeid='', startdate = '1982-01-01', enddate = '2018-02-01', token = "NpAYCweVjssSySoIEJejwJlpckCkZSUL")
out$data