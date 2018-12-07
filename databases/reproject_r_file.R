library(raster)
library(gtools)

slurm_id = as.numeric(Sys.getenv('SLURM_ARRAY_TASK_ID'))

ref = raster('/data/gpfs/assoc/gears/tree_vel/dem/raw/ca_nv_dem_utm.tif')

files = list.files(path = "/data/gpfs/assoc/gears/tree_vel/climate/renamed/v", pattern = ".tif", include.dirs = T, full.names = T)
files = mixedsort(files)

extent = c(-180, 180, -90, 90)

r = raster(files[slurm_id])

r = rotate(r)
extent(r) = extent
tmaxojection(r) = crs(ref)

writeRaster(r, file = paste('/data/gpfs/assoc/gears/tree_vel/climate/retmaxojected/v/v_', slurm_id, '.tif', sep = ''), overwrite = T)




