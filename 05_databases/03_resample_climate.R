library(gdalUtils)
library(gtools)


slurm_id = as.numeric(Sys.getenv('SLURM_ARRAY_TASK_ID'))

files = list.files(path = "/data/gpfs/assoc/gears/tree_vel/climate/reprojected/v/", pattern = ".tif", include.dirs = T, full.names = T)
files = mixedsort(files)


align_rasters(unaligned = files[slurm_id], reference = "/data/gpfs/assoc/gears/tree_vel/dem/ca_nv_dem_aea.tif", dstfile = paste('/data/gpfs/assoc/gears/tree_vel/climate/resampled/v/v_', slurm_id, '.tif', sep = ''), verbose = T, output\
_raster = T)


