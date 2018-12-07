library(gtools)

start = sort(rep(1:5, 4))
end = rep(1:4, 5)
suffix = paste(start, end, sep = "_")

folders = list.files(path = "/projects/oa/tree_vel/downscale/forest_service/ts/")
folders = folders[-length(folders)]
#folders = folders[-length(folders)]

for (i in 1:length(folders))
{
  setwd(paste("/projects/oa/tree_vel/downscale/forest_service/ts/", folders[i], sep = ""))
  files = list.files(path = paste("/projects/oa/tree_vel/downscale/forest_service/ts/", folders[i], sep = ""))
  files = mixedsort(files)
  new_names = paste("tile_", suffix, ".tif", sep = "")
  file.rename(files, new_names)
}
