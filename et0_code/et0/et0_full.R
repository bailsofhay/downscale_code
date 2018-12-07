require("raster")
require("spatial.tools")
time = "rcp8"
months = c("jan", "feb", "mar", "april", "may", "june", "july", "aug", "sept", "oct", "nov", "dec")
setwd('/projects/oa/tree_vel/et0/')


for (j in 1:5)
{
  for (k in 1:4)
  {
    # Current best datasets at full resolution:
    
    wd = print("setwd('/projects/oa/tree_vel/et0/')")
    lib1 = print("library(raster)")
    lib2 = print("library(spatial.tools)")
    opt = print("rasterOptions(tmpdir = '/projects/oa/tree_vel/scratch/')")
    ### Souce: Worldclim
    # Elevation, m a.s.l.
    elev_raw = print(paste("elevation_raw=raster('inputs/elv/tile_", j, "_", k, ".tif')", sep = ""))
    # Mean monthly precipitation, 1950-2000, mm
    pr_raw = print(paste("precipitation_raw=brick('inputs/pr/", time, "/pr_stack_", j, "_", k, ".vrt')", sep = ""))
    # Mean monthly tmax, 1950-2000, deg C * 10
    tmax_raw = print(paste("tmax_raw=brick('inputs/tmax/", time, "/tmax_stack_", j, "_", k, ".vrt')", sep = ""))
    # Mean monthly tmin, 1950-2000, deg C * 10
    tmin_raw = print(paste("tmin_raw=brick('inputs/tmin/", time, "/tmin_stack_", j, "_", k, ".vrt')", sep  = ""))
    # Mean monthly tmean, 1950-2000, deg C * 10
    tmean_raw = print(paste("tmean_raw=brick('inputs/ts/", time, "/ts_stack_", j, "_", k, ".vrt')", sep = ""))
    ### Source: NCEP/NCAR
    # Windspeed at 10m, m/s
    wind_raw = print(paste("wnd_raw=brick('inputs/wind/", time, "/wind_stack_", j, "_", k, ".vrt')", sep = "")) # may need to do conversion depending on how close to ground this is.
    # Net radiation (W/m^2)
    rad_raw = print(paste("rad_raw=brick('inputs/rad/rad_stack_", j, "_", k, ".vrt')", sep = "")) 
    # Dunne et al. http://daac.ornl.gov/SOILS/guides/DunneSoil.html
    # Soil water holding capacity; Units: cm
    # whc_raw=raster("water_capacity/tile_3_5.tif") # already in cm
    
    parameters = print("eto_calc_parameters=list(netrad_multiplier=0.0864,tmax_multiplier=1,tmin_multiplier=1,wind_multiplier=1, elev_multiplier=1,tmean_multiplier=1,dpt_correction=-2,sr=100, ks_min=.01, Tl=-10, T0=5,	Th=100, thresh=5,hw=3.54463)")
    
    # number of days function goes here
    
    elev = print("elev=elevation_raw")
    for(i in 1:12)
    {
      
      rad = print(paste("netrad=subset(rad_raw,", i, ")", sep = ""))
      tmean = print(paste("tmean=subset(tmean_raw,", i, ")", sep = ""))
      wind = print(paste("wind=subset(wnd_raw,", i, ")", sep = ""))
      tmin = print(paste("tmin=subset(tmin_raw,",i, ")", sep = ""))
      tmax = print(paste("tmax=subset(tmax_raw,", i, ")", sep = ""))
      f = print(paste("if(",i,"==1) { tmean_prev=subset(tmean_raw,12)", sep = "")) 
      e = print(paste("} else { tmean_prev=subset(tmean_raw,(",i,"-1)) }", sep = ""))
      input_list = print("eto_input_list=list(netrad,tmean,wind,tmin,tmax,elev,tmean_prev)")
      stack = print("eto_input_stack=stack(eto_input_list)")
      # Outfilename
      outname = print(paste("outfilename=paste('eto_',add_leading_zeroes(",i, ",2),sep='')", sep = ""))
      # Figure out days in month.
      date = print(paste("monthDate=as.Date(paste('2005',",i, ",'1',sep='/'))", sep = ""))
      source = print("source('/projects/oa/tree_vel/R/functions/numberOfDdays.R')")
      days = print("daysInMonth=numberOfDays(monthDate)")
      ndays = print("eto_calc_parameters$n_days = daysInMonth")
      
      # calculates Net rad into correct units
      netrad = print("netrad=netrad*eto_calc_parameters$netrad_multiplier")
      
      # Havent figured out what dpt is
      dpt = print("dpt=tmin+eto_calc_parameters$dpt_correction")
      
      # soil heat flux
      g = print("G = 0.14 * (tmean-tmean_prev)")
      
      # converts wind to 2m above surface
      wind_2m = print("wind_2m <- wind*(4.87/log(67*eto_calc_parameters$hw-5.42))  # convert to wind height at 2m")
      
      b4  = print("b4 <- (eto_calc_parameters$Th-eto_calc_parameters$T0)/(eto_calc_parameters$Th-eto_calc_parameters$Tl)")
      b3 = print("b3 <- 1/((eto_calc_parameters$T0-eto_calc_parameters$Tl)*(eto_calc_parameters$Th-eto_calc_parameters$T0)^b4)")
      
      
      ks_pmin = print("ks_pmin=pmin(as.matrix(b3*(tmean-eto_calc_parameters$Tl)*(eto_calc_parameters$Th-tmean)^b4),1)")
      ks_pmin2 = print("ks_pmin = raster(vals = ks_pmin, crs = crs(tmean), nrows = nrow(tmean), ncols = ncol(tmean), ext = extent(tmean))")
      ks = print("ks <- pmax(pmin(as.matrix(b3*(tmean-eto_calc_parameters$Tl)*(eto_calc_parameters$Th-tmean)^b4),1),eto_calc_parameters$ks_min)")
      ks2 = print("ks = raster(vals = ks, crs = crs(tmean), nrows = nrow(tmean), ncols = ncol(tmean), ext = extent(tmean))")
      ks3 = print("ks[is.na(ks)] <- eto_calc_parameters$ks_min")
      ks4 = print("ks[tmean>=eto_calc_parameters$thresh] <- 1")
      
      sr = print("sr  <- eto_calc_parameters$sr/ks")
      
      # ra is aerodynamic resistance, rs is bulk surface resistance
      ra = print("ra  <- 208/wind_2m") #(log((2-2/3*0.12)/(0.123*0.12))*log((2-2/3*0.12)/(0.1*0.123*0.12)))/(0.41^2*wind) # equal to 208/wind for hh=hw=2.
      rs = print("rs <- sr/(0.5*24*0.12)") # value of 70 when sr=100
      
      # Saturation vapor pressure , 
      es = print("es <- 0.6108*exp(tmin*17.27/(tmin+237.3))/2+0.6108*exp(tmax*17.27/(tmax+237.3))/2     ")
      ea = print("ea <- 0.6108*exp((dpt)*17.27/((dpt)+237.3))")
      vpd1 = print("vpd <- es - ea")
      vpd2 = print("vpd[vpd<0] <- 0  ")  # added because this can be negative if dewpoint temperature is greater than mean temp (implying vapor pressure greater than saturation).
      
      # delta - Slope of the saturation vapor pressure vs. air temperature curve at the average hourly air temperature 
      delta = print("delta  <- (4098 * es)/(tmean + 237.3)^2  ")
      
      p = print("P <- 101.3*((293-0.0065*elev)/293)^5.26  # Barometric pressure in kPa")
      lambda = print("lambda <- 2.501-2.361e-3*tmean # latent heat of vaporization    ")
      cp = print("cp  <- 1.013*10^-3 # specific heat of air")
      gamma = print("gamma <- cp*P/(0.622*lambda) # Psychrometer constant (kPa C-1)")
      pa = print("pa <- P/(1.01*(tmean+273)*0.287) # mean air density at constant pressure")
      
      eto = print("et0 <- .408*((delta*(netrad-G))+(pa*cp*vpd/ra*3600*24*eto_calc_parameters$n_days))/(delta+gamma*(1+rs/ra))")
      write = print(paste("writeRaster(et0, file ='/projects/oa/tree_vel/et0/et0/", time, "/", months[i], "/eto_", j, "_", k, ".tif', overwrite = T)", sep = ""))
      
      combine = rbind(wd, lib1, lib2, opt, elev_raw, pr_raw, tmax_raw, tmin_raw, tmean_raw, wind_raw, rad_raw, parameters, elev, rad, tmean, wind, tmin, tmax, f, e, input_list, stack, outname, date, source, days, ndays, netrad, dpt, g, wind_2m, b4, b3, ks_pmin, ks_pmin2, ks, ks2, ks3, ks4, sr, ra, rs, es ,ea, vpd1, vpd2, delta, p, lambda, cp, gamma, pa, eto, write)
      write(combine, file = paste("/projects/oa/tree_vel/et0/et0/", time, "/", months[i], "/qsub_files/eto_", j, "_", k, ".R", sep = ""))
      
      bin = print("#!/bin/bash")
      pbs = print(paste("#PBS -N eto_", months[i], "_", time, sep = ""))
      module  = print("module load parallel")
      cd = print("cd /projects/oa/tree_vel/")
      export = print("export PARALLEL='--env PATH --tempdir /projects/oa/tree_vel/scratch/ --env LD_LIBRARY_PATH --env LOADEDMODULES --env _LMFILES_ --env MODULE_VERSION --env MODULEPATH --env MODULEVERSION_STACK --env MODULESHOME'")
      parallel  = print(paste("parallel -j $PBS_NP R CMD BATCH {} ::: et0/et0/",time,"/",months[i],"/qsub_files/eto*.R", sep  = ""))
      #rm = print("rm /projects/oa/tree_vel/scratch_tile/*")
      combine2 = rbind(bin, pbs, module, cd, export, parallel )
      write(combine2, file = paste("/projects/oa/tree_vel/et0/et0/", time, "/", months[i], "/qsub_files/run_files.sh", sep = ""))
    }
    
  }
}



