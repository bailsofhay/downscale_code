library(spatial.tools)

path = '/projects/oa/tree_vel/climate/resampled/'
yrs = rep(seq(from = 2006, to = 2016, by = 1), 12)
mo = add_leading_zeroes(rep(seq(1:12),11))
yrmo = paste(yrs, mo, sep = "_")

for (j in 1:length(yrmo))
{
  module = print("module load anaconda")
  gdal = print(paste("gdal_calc.py -A ", path, "u/u_", yrmo[j], ".tif -B", path, "v/v_", yrmo[j], ".tif --outfile /projects/oa/tree_vel/climate/wind/dir/modern/dir_", yrmo[j], ".tif --calc='(45/numpy.arctan(1))*(numpy.arctan2(A, B))+180'", sep = ""))#(A**3)*1000*2629743.83
  combine = rbind(module, gdal)
  write(combine, file = paste("/projects/oa/tree_vel/climate/wind/dir/modern/qsub_files/dir_", j, ".sh", sep = ""))
}
