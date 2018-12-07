months = c('april', 'aug', 'dec', 'feb', 'jan', 'july', 'june', 'mar', 'may', 'nov', 'oct', 'sept')
time = "rcp8"

for (j in 1:12)
{
  files = list.files(path = paste("/projects/oa/tree_vel/downscale/pr_tile/", time, "/", months[j], sep = ""), pattern = ".tif", include.dirs = T, full.names = T)
  names = list.files(path = paste("/projects/oa/tree_vel/downscale/pr_tile/", time, "/", months[j], sep = ""), pattern = ".tif")
  for (i in 1:length(files))
  {
    module = print("module load anaconda")
    gdal = print(paste("gdal_calc.py -A ", files[i], " --outfile /projects/oa/tree_vel/downscale/pr_tile/", time, "/cubic/", months[j], "/", names[i], " NoDataValue=-9999 --calc='A**(1.0/3.0)'", sep = ""))#(A**3)*1000*2629743.83
    combine = rbind(module, gdal)
    write(combine, file = paste("/projects/oa/tree_vel/downscale/pr_tile/", time, "/cubic/", months[j], "/qsub_files/cubic_", i, ".sh", sep = ""))
  }
}
