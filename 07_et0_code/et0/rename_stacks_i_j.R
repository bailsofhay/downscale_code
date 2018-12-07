library(gtools)

files = list.files(path = "/projects/oa/tree_vel/downscale/averages/rcp8/downscale/tmax/nov",pattern = ".tif", include.dirs = T, full.names = T)
#files = mixedsort(files)
converted = grep(pattern = "convert", files)
files = mixedsort(files[-converted])


i = seq(1:5)
j = seq(1:4)

tiles = as.data.frame(expand.grid(i, j))
tiles = paste("_", tiles$Var1, "_", tiles$Var2, "_modern.tif", sep = "")
tiles = mixedsort(tiles)

#new_names = paste(substr(files, 1, 65), tiles, sep = "")
new_names = gsub("t_", "tile_", files)

file.rename(files, new_names)



