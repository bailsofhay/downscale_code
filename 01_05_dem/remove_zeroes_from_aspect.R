library(raster)

res = "30m"
in_files = list.files(path = paste('/projects/oa/tree_vel/dem/raster/aspect_tiles/', res, sep = ""), pattern = ".tif", include.dirs =T, full.name= T)
names = list.files(path = paste('/projects/oa/tree_vel/dem/raster/aspect_tiles/', res, sep = ""), pattern = ".tif")
names =substr(names, 1, nchar(names)-4)

ref_files = list.files(path = "/projects/oa/tree_vel/dem/raster/aspect_tiles/5000m/", pattern = ".tif", include.dirs = T, full.names = T)


for (i in 1:length(in_files))
{
  lib = print("library(raster)")
  fix_tile = print(paste("fix_tile = raster('",in_files[i],"')", sep = ""))
  ref_tile = print(paste("ref_tile = raster('",ref_files[i],"')", sep = ""))
  crs = print("crs = crs(fix_tile)")
  e = print("e = extent(fix_tile)")
  nrow = print("nrow = nrow(fix_tile)")
  ncol = print("ncol = ncol(fix_tile)")
  vals.fix = print("vals.fix = getValues(fix_tile)")
  vals.ref = print("vals.ref = getValues(ref_tile)")
  
  na =  print("na = which(is.na(vals.fix))")
  vals.fix.na = print("vals.fix[na] = vals.ref[na]")
  
  new_tile = print("new_tile = raster(vals = vals.fix, ext = e, crs = crs, nrows = nrow, ncols = ncol)")
  write = print(paste("writeRaster(new_tile, file = '/projects/oa/tree_vel/dem/raster/aspect_tiles/", res, "/", names[i], "_fix.tif')", sep = ""))
  
  combine = rbind(lib, fix_tile, ref_tile, crs, e, nrow, ncol, vals.fix, vals.ref, na, vals.fix.na, new_tile, write)
  write(combine, file = paste('/projects/oa/tree_vel/dem/raster/aspect_tiles/',res, '/qsub_files/remove_zeroes_', i, ".R", sep = ""))
}