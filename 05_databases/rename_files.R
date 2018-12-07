setwd('/projects/oa/tree_vel/climate/unprojected/modern/v/')
files = list.files(path = "/projects/oa/tree_vel/climate/unprojected/modern/v", pattern = "v")

newname = gsub("-", "_", files)
file.rename(files, newname)


