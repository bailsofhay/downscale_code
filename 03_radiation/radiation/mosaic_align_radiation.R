

months = c("april", "aug", "dec", "feb", "jan", "july", "june", "mar", "may", "nov", "oct", "sept")

for (i in 1:length(months))
{
  lib = print("library(gdalUtils)")
  files = print(paste("files = list.files(path = paste('/projects/oa/tree_vel/radiation/', '", months[i], "', sep = ''), pattern = '.tif', include.dirs = T, full.names = T)", sep = ""))
  mosaic = print(paste("mosaic_rasters(files, dst_dataset = '/projects/oa/tree_vel/radiation/aligned/", months[i], "_unprojected.tif')", sep = ""))
  unaligned = print(paste("unaligned = '/projects/oa/tree_vel/radiation/aligned/", months[i], "_unprojected.tif'", sep = ""))
  ref = print("ref = '/projects/oa/tree_vel/dem/raster/dem_aea.tif'")
  align = print(paste("align_rasters(unaligned = unaligned, reference = ref, dstfile = '/projects/oa/tree_vel/radiation/aligned/", months[i], "_aligned.tif', nThreads = 20)", sep = ""))
  
  combine = rbind(lib, files, mosaic, unaligned, ref, align)
  write(combine, file = paste('/projects/oa/tree_vel/radiation/aligned/qsub_files/align_', months[i], '.R', sep = ''))
  
  RCMD = print(paste("R CMD BATCH /projects/oa/tree_vel/radiation/aligned/qsub_files/align_", months[i], ".R", sep = ""))
  write(RCMD, file = paste('/projects/oa/tree_vel/radiation/aligned/qsub_files/RCMD_', months[i], '.sh', sep = ''))
  
  qsub = print(paste("qsub -o out -e err -l walltime=3:00:00,nodes=1:ppn=20 /projects/oa/tree_vel/radiation/aligned/qsub_files/RCMD_", months[i], ".sh -N align_", months[i], sep = ""))
  write(qsub, file = "/projects/oa/tree_vel/radiation/aligned/qsub_files/qsub_commands.sh", append = T)
}