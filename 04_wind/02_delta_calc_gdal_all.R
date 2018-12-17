library(spatial.tools)

path = '/projects/oa/tree_vel/climate/resampled/'
yrs = rep(seq(from = 2006, to = 2016, by = 1), 12)
mo = add_leading_zeroes(rep(seq(1:12),11))
yrmo = paste(yrs, mo, sep = "_")


for (j in 1:length(yrmo))
{
  module = print("module load anaconda")
  gdal = print(paste("gdal_calc.py -A /projects/oa/tree_vel/climate/wind/dir/modern/dir_", yrmo[j], ".tif -B /projects/oa/tree_vel/dem/raster/ca_aspect_5000m_fix.tif --outfile /projects/oa/tree_vel/climate/wind/delta/modern/delta_", yrmo[j], ".tif --calc='(numpy.absolute((A-B))>180)*numpy.absolute(numpy.absolute((A-B))-360)+(numpy.absolute((A-B))<=180)*numpy.absolute((A-B))'", sep = "")) #
  combine = rbind(module, gdal)
  write(combine, file = paste("/projects/oa/tree_vel/climate/wind/delta/modern/qsub_files/delta_", j, ".sh", sep = ""))
}


