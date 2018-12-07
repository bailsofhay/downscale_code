require("raster")
require("spatial.tools")

slurm_id = as.numeric(Sys.getenv('SLURM_ARRAY_TASK_ID'))


months = add_leading_zeroes(1:12, 2)

setwd('/data/gpfs/assoc/gears/tree_vel/et0/average/modern/')

is = sort(rep(1:3, 4))
js = rep(1:4, 3)
indexs = paste("_", is, "_", js, sep = "")

elevation_files = list.files(path = "inputs/elv/", pattern = indexs[slurm_id], include.dirs = T, full.names = T)
precipitation_files = list.files(path = "inputs/pr/", pattern = indexs[slurm_id], include.dirs = T, full.names = T)
tmax_files = list.files(path = "inputs/tmax/", pattern = indexs[slurm_id], include.dirs = T, full.names = T)
tmin_files = list.files(path = "inputs/tmin/", pattern = indexs[slurm_id], include.dirs = T, full.names = T)
tmean_files = list.files(path = "inputs/tave/", pattern = indexs[slurm_id], include.dirs = T, full.names = T)
wnd_files = list.files(path = "inputs/wind/", pattern = indexs[slurm_id], include.dirs = T, full.names = T)
rad_files = list.files(path = "inputs/rad/", pattern = indexs[slurm_id], include.dirs = T, full.names = T)


for (i in 1:12)
{
  rasterOptions(tmpdir = '/data/gpfs/assoc/gears/tree_vel/scratch/')
  
  elevation_raw = stack(elevation_files)
  precipitation_raw = stack(precipitation_files)
  tmax_raw = stack(tmax_files)
  tmin_raw = stack(tmin_files)
  tmean_raw = stack(tmean_files)
  wnd_raw = stack(wnd_files)
  rad_raw = stack(rad_files)
  
  eto_calc_parameters=list(netrad_multiplier=0.0864,tmax_multiplier=1,tmin_multiplier=1,wind_multiplier=1, elev_multiplier=1,tmean_multiplier=1,dpt_correction=-2,sr=100, ks_min=.01, Tl=-10, T0=5, Th=100, thresh=5,hw=3.54463)
  
  
  elev = subset(elevation_raw, subset = i)
  netrad = subset(rad_raw, subset = i)
  wind = subset(wnd_raw, subset = i)
  tmin = subset(tmin_raw, subset = i)-273.15
  tmax = subset(tmax_raw, subset = i)-273.15
  tmean = subset(tmean_raw, subset = i)-273.15
  
  if (i == 1)
  {
    tmean_prev = subset(tmean_raw, 12)-273.15
  } else {
    tmean_prev = subset(tmean_raw, (i-1))-273.15
  }
  
  #eto_input_list = list(netrad, tmean, wind, tmin, tmax, elev, tmean_prev)
  
  #eto_input_stack = stack(eto_input_list)
  
  monthDate = as.Date(paste('2005', i, '1', sep = '/'))
  source('/data/gpfs/assoc/gears/tree_vel/R/functions/numberOfDdays.R')
  
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
  
  writeRaster(et0, file = paste('/data/gpfs/assoc/gears/tree_vel/et0/average/modern/et0/et0_', months[i], index, "_modern.tif", sep = ""), overwrite = T)
  
}


  
 
                                  