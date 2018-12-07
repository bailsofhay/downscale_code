require("raster")
require("spatial.tools")
library(gtools)

slurm_id = as.numeric(Sys.getenv('SLURM_ARRAY_TASK_ID'))


months = add_leading_zeroes(1:12, 5)

#setwd('/data/gpfs/assoc/gears/tree_vel/01_analysis/step4_et0/et0/monthly/')

files = list.files(path = '/data/gpfs/assoc/gears/tree_vel/01_analysis/step4_et0/et0/monthly/input_files/et0_inputs', pattern = '.tif', include.dirs = T, full.names = T)


is = sort(rep(1:4, 4))
js = rep(1:4, 4)
indexs = paste("_", is, "_", js, sep = "")

x = grep(files, pattern = paste( indexs[slurm_id], ".tif", sep = ""))
file = mixedsort(files[x])

elevation_files = subset(brick(file[1]),1)
for (i in 2:length(file))
{
  r = brick(file[i])
  elv = subset(r, 1)
  elevation_files = stack(elevation_files, elv)
}

precipitation_files = subset(brick(file[1]),2)
for (i in 2:length(file))
{
  r = brick(file[i])
  precip = subset(r, 2)
  precipitation_files = stack(precipitation_files, precip)
}

tmean_files = subset(brick(file[1]), 3)
for (i in 2:length(file))
{
  r = brick(file[i])
  tmean = subset(r, 3)
  tmean_files = stack(tmean_files, tmean)
}

tmin_files = subset(brick(file[1]), 4)
for (i in 2:length(file))
{
  r = brick(file[i])
  tmin = subset(r, 4)
  tmin_files = stack(tmin_files, tmin)
}

tmax_files = subset(brick(file[1]), 5)
for (i in 2:length(file))
{
  r = brick(file[i])
  tmax = subset(r, 5)
  tmax_files = stack(tmax_files, tmax)
  
}
wnd_files = subset(brick(file[1]), 6)
for ( i in 2:length(file))
{
  r = brick(file[i])
  wnd = subset(r, 4)
  wnd_files = stack(wnd_files, wnd)
}

rad_files = subset(brick(file[1]), 7)
for (i in 2:length(file))
{
  r = brick(file[i])
  rad = subset(r, 5)
  rad_files = stack(rad_files, rad)
}

years = sort(rep(2014:2018, 12))
months = add_leading_zeroes(rep(1:12, 5), 2)
dates = paste(years, months, sep = "_")

for (i in 1:60)
{
  rasterOptions(tmpdir = '/data/gpfs/assoc/gears/tree_vel/scratch/')
  
  dates[i]
  
  elevation_raw = elevation_files
  precipitation_raw = precipitation_files
  
  tmean_raw = tmean_files
  tmin_raw = tmin_files
  tmax_raw = tmax_files
  wnd_raw = wnd_files
  rad_raw = rad_files
  
  eto_calc_parameters=list(netrad_multiplier=0.0864,tmax_multiplier=1,tmin_multiplier=1,wind_multiplier=1, elev_multiplier=1,tmean_multiplier=1,dpt_correction=-2,sr=100, ks_min=.01, Tl=-10, T0=5, Th=100, thresh=5,hw=3.54463)
  
  
  elev = subset(elevation_raw, subset = i)
  netrad = subset(rad_raw, subset = i)
  wind = subset(wnd_raw, subset = i)
 
  tmean = subset(tmean_raw, subset = i)-273.15
  tmin = subset(tmin_raw, subset = i)-273.15
  tmax = subset(tmax_raw, subset = i)-273.15
  
  if (i == 1)
  {
    tmean_prev = subset(tmean_raw, 12)-273.15
  } else {
    tmean_prev = subset(tmean_raw, (i-1))-273.15
  }
  
  #eto_input_list = list(netrad, tmean, wind, tmin, tmax, elev, tmean_prev)
  
  #eto_input_stack = stack(eto_input_list)
  
  monthDate = as.Date(paste(years[i], months[i], '1', sep = '/'))
  source('/data/gpfs/assoc/gears/tree_vel/02_code/R/functions/numberOfDdays.R')
  
  daysInMonth = numberOfDays(monthDate)
  eto_calc_parameters$n_days = daysInMonth
  
  netrad = netrad * eto_calc_parameters$netrad_multiplier
  
  dpt=tmin+eto_calc_parameters$dpt_correction
  
  G = 0.14 * (tmean-tmean_prev)
  
  wind_2m = wind
  
  b4 <- (eto_calc_parameters$Th-eto_calc_parameters$T0)/(eto_calc_parameters$Th-eto_calc_parameters$Tl)
  b3 <- 1/((eto_calc_parameters$T0-eto_calc_parameters$Tl)*(eto_calc_parameters$Th-eto_calc_parameters$T0)^b4)
  
  # ks_pmin=pmin((b3*(tmean-eto_calc_parameters$Tl)*(eto_calc_parameters$Th-tmean)^b4)[],1)
  # ks_pmin=pmin(as.matrix(b3*(tmean-eto_calc_parameters$Tl)*(eto_calc_parameters$Th-tmean)^b4),1)
  # ks_pmin = raster(vals = ks_pmin, crs = crs(tmean), nrows = nrow(tmean), ncols = ncol(tmean), ext = extent(tmean))
  # ks <- pmax(pmin(as.matrix(b3*(tmean-eto_calc_parameters$Tl)*(eto_calc_parameters$Th-tmean)^b4),1),eto_calc_parameters$ks_min)
  # ks = raster(vals = ks, crs = crs(tmean), nrows = nrow(tmean), ncols = ncol(tmean), ext = extent(tmean))
  # ks[is.na(ks)] <- eto_calc_parameters$ks_min
  # ks[tmean>=eto_calc_parameters$thresh] <- 1
  
  one = tmean
  one[is.finite(one[])] = 1
  
  s1 = stack((b3*(tmean-eto_calc_parameters$Tl)*(eto_calc_parameters$Th-tmean)^b4), one)
  
  ks_pmin = stackApply(s1, indices = c(1,1), fun = min, na.rm = T)
  
  ks_min = tmean
  ks_min[is.finite(ks_min[])] = eto_calc_parameters$ks_min
  
  s2 = stack(ks_pmin, ks_min)
  
  ks = stackApply(s2, indices = c(1,1), fun = max, na.rm = T)
  
  ks[is.na(ks[])] <- eto_calc_parameters$ks_min
  ks[tmean[]>=eto_calc_parameters$thresh] <- 1
  
  sr  <- eto_calc_parameters$sr/ks
  
  ra = 208/wind_2m
  rs = sr/(0.5*24*0.12)
  
  es <- 0.6108*exp(tmin*17.27/(tmin+237.3))/2+0.6108*exp(tmax*17.27/(tmax+237.3))/2     
  ea <- 0.6108*exp((dpt)*17.27/((dpt)+237.3))
  
  vpd = es-ea
  vpd[vpd<0] = 0
  
  
  delta  <- (4098 * es)/(tmean + 237.3)^2  
  P <- 101.3*((293-0.0065*elev)/293)^5.26
  lambda <- 2.501-2.361e-3*tmean
  cp  <- 1.013*10^-3
  gamma <- cp*P/(0.622*lambda)
  pa <- P/(1.01*(tmean+273)*0.287)
  
  et0 <- .408*((delta*(netrad-G))+(pa*cp*vpd/ra*3600*24*eto_calc_parameters$n_days))/(delta+gamma*(1+rs/ra))
  
  writeRaster(et0, file = paste('//data/gpfs/assoc/gears/tree_vel/01_analysis/step4_et0/et0/monthly/et0/et0_', dates[i],indexs[slurm_id], ".tif", sep = ""), overwrite = T)
  
}




