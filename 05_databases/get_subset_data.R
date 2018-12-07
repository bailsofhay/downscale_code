library(raster)

files = list.files(path = "/projects/oa/alder_sdms/climate/tifs/0BP", pattern = ".tif", include.dirs = T, full.names = T)
files = files[c(2,3,7,11,12,13,14,15,16,17,24,25,32,33,40,41,48,49)]


annual_tmax = raster(files[1])
annual_tmin = raster(files[2])
annual_aet = raster(files[6])
annual_pet = raster(files[9])
annual_pr = raster(files[10])
annual_def = annual_pet-annual_aet

max_warmest_month = raster(files[12])
min_coldest_month = raster(files[14])
temp_annual_range = max_warmest_month-min_coldest_month
mean_diurnal_range = mean(max_warmest_month-min_coldest_month, na.rm = T)

mean_warmest_qrtr = raster(files[16])
mean_colderst_qrtr = raster(files[18])
precip_seasonality = raster(files[3])
temp_seasonality = ((raster(files[4])+raster(files[5]))/2)*100

precip_wettest_month = raster(files[11])
precip_dryest_month = raster(files[13])
precip_wettest_qrtr = raster(files[15])
precip_dryest_qrtr = raster(files[17])

annual_GDD0 = raster(files[7])
annual_GDD5 = raster(files[8])




