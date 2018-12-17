library(raster)
library(gtools)
library(shapefiles)
library(spatial.tools)

ca = shapefile('/data/gpfs/assoc/gears/tree_vel/03_data/raw/shapefiles/ca_only_aea.shp')

slurm_id = as.numeric(Sys.getenv('SLURM_ARRAY_TASK_ID'))


dem = raster('/data/gpfs/assoc/gears/tree_vel/03_data/raw/dem/ca_nv_dem_aea.tif')
precip_files = list.files(path = '/data/gpfs/assoc/gears/tree_vel/01_analysis/step3_downscale/downscale/pr/mosaics/', pattern = '.tif', include.dirs = T, full.names = T)
tave_files = list.files(path = '/data/gpfs/assoc/gears/tree_vel/01_analysis/step3_downscale/downscale/tave/mosaics/', pattern = '.tif', include.dirs = T, full.names = T)
tmin_files = list.files(path = '/data/gpfs/assoc/gears/tree_vel/01_analysis/step3_downscale/downscale/tmin/mosaics/', pattern = '.tif', include.dirs = T, full.names = T)
tmax_files = list.files(path = '/data/gpfs/assoc/gears/tree_vel/01_analysis/step3_downscale/downscale/tmax/mosaics/', pattern = '.tif', include.dirs= T, full.names = T)
wind_files = list.files(path = '/data/gpfs/assoc/gears/tree_vel/03_data/raw/climate/resampled/wind/speed', pattern = '.tif', include.dirs = T, full.names = T)
rad_files = list.files(path = '/data/gpfs/assoc/gears/tree_vel/01_analysis/step2_radiation/radiation/true_sky', pattern = '.tif', include.dirs = T, full.names = T)

yr = sort(rep(1982:2019, 12))
mo = add_leading_zeroes(rep(1:12, 38), 2)
date = paste(yr, mo, sep = "_")
# i1 = which(yr == 2014)
# i2 = which(yr == 2018)


precip_files = mixedsort(precip_files)
tave_files = mixedsort(tave_files)
tmin_files = mixedsort(tmin_files)
tmax_files = mixedsort(tmax_files)
wind_files = mixedsort(wind_files)
rad_files = mixedsort(rad_files)#[i1[1]:i2[12]]

ca = spTransform(ca, CRS = crs(dem))


index = slurm_id
st = stack(dem, precip_files[index], tave_files[index], tmin_files[index], tmax_files[index],wind_files[index], rad_files[index])
names(st) = c("dem", "precip", "tave", "tmin", "tmax", "wind", "rad")

stack = crop(st, extent(ca)) 

clim = subset(stack, 1)


# Determine tile parameters starting with the lower left corner
ntc <- 10000
ntr <- 10000

ex = extent(clim)


scoord = ex[3]
wcoord = ex[1]
ecoord = ex[2]
nsres = yres(clim)
ewres = xres(clim)
ncl <- ncol(clim) #number of columns 
nrw <- nrow(clim) #number of rows

# Determine the raster resolution, lower left corner coordinates and number of rows and columns. This can be used to calculate tile sizes:
cpt <- ceiling(ncl/ntc)  # number of columns per tile
rpt <- ceiling(nrw/ntr)  # number of rows per tile
cptl = ncl-cpt*(ntc-1)
rptl = nrw-rpt*(ntr-1)

scoor = scoord-ntr*nsres
ncoor = scoord
#plot(clim)


for(i in 1:rpt){     
  wcoor <- wcoord-ntc*ewres
  ecoor <- wcoord
  scoor <- scoor+ntr*nsres
  if (i == rpt)
  {
    ncoor <- ncoor+(4751)*nsres
  } else{
    ncoor = ncoor + ntr*nsres
  }
  
  s <- scoor 
  n <- ncoor 
  
  for(j in 1:cpt){   #* changes everthing to rpt instead of cpt
    
    wcoor <- wcoor+ntc*ewres
    
    if (j ==cpt)
    {
      ecoor <- ecoor+(1320)*ewres
    } else{
      ecoor <- ecoor+ntc*ewres
    }
    
    w <- wcoor 
    e <- ecoor 
    
   c = crop(stack, extent(w,e,s,n))
   writeRaster(c, file = paste('/data/gpfs/assoc/gears/tree_vel/01_analysis/step4_et0/et0/monthly/input_files/et0_inputs/stack_', date[index], '_', i, '_', j, '.tif', sep = ""), overwrite =T)
   
    # tl = c(w,n)
    # tr = c(e,n)
    # bl = c(w,s)
    # br = c(e,s)
    # points = rbind( tl, tr, bl, br)
    # points(points, col = "red")
    
    
  }
}
