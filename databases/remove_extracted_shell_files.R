library(spatial.tools)
library(gtools)
var = "v"

setwd(paste("/projects/oa/tree_vel/climate/extracted_climate/qsub_files/", var, sep = ""))

csv.files = list.files(path = paste("/projects/oa/tree_vel/climate/extracted_climate/", var, sep = ""), pattern = ".csv")
csv.yrmo = substr(csv.files, 3,nchar(csv.files)-4)


yr = sort(rep(seq(1975, 2005), 12))
mo = add_leading_zeroes(rep(1:12, 31), 2)
yrmo = paste(yr, mo, sep = "_")

remove = which(yrmo %in% csv.yrmo)

r.files = list.files(path = paste("/projects/oa/tree_vel/climate/extracted_climate/qsub_files/", var, sep = ""), pattern = ".R")
r.order = mixedsort(r.files)

r.remove = r.order[remove]

for (i in 1:length(r.remove))
  {
  file.remove(r.remove[i])
  }
