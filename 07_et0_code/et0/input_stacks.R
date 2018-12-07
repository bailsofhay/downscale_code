var = "tmin"
time = "rcp8"



#inpath = paste("/projects/oa/tree_vel/downscale/averages/", time, "/downscale/", var, sep = "")
files = list.files(path = paste("/projects/oa/tree_vel/downscale/averages/", time, "/downscale/", var, sep = ""), pattern = ".tif", recursive = T, full.names = T, include.dirs = T)
converted = grep(files, pattern = "convert")
files = files[converted]

for (i in 1:20)
{
  file = files[i]
  tile = substr(file, nchar(file) - 7, nchar(file)- 4)

  g = grep(files, pattern = tile)
  sub_files = files[g]

  order = c(5, 4, 8, 1, 9, 7, 6, 2, 12, 11, 10, 3)
  new_files = sub_files[order]

  write(new_files, file = paste("/projects/oa/tree_vel/et0/inputs/", var,"/", time,  "/qsub_files/input_files", tile, ".txt", sep = ""))
  input_file_list = print(paste("/projects/oa/tree_vel/et0/inputs/", var, "/", time,"/qsub_files/input_files", tile, ".txt", sep = ""))
  outfilename = print(paste("/projects/oa/tree_vel/et0/inputs/", var, "/", time,"/",  var, "_stack", tile,  ".vrt", sep = ""))
  gdal = print(paste("gdalbuildvrt -separate -input_file_list ", input_file_list, outfilename))
  write(gdal, file = paste("/projects/oa/tree_vel/et0/inputs/", var, "/", time,"/qsub_files/gdal_stack", tile, ".sh", sep = ""))

  bin = print("#!/bin/bash")
  pbs = print("#PBS -N input_stack")
  module = print("module load parallel ")
  cd = print("cd /projects/oa/tree_vel/")
  export = print("export PARALLEL='--env PATH --env LD_LIBRARY_PATH --env LOADEDMODULES --env _LMFILES_ --env MODULE_VERSION --env MODULEPATH --env MODULEVERSION_STACK --env MODULESHOME'")
  parallel = print(paste("parallel -j $PBS_NP sh {} ::: et0/inputs/", var, "/", time, "/qsub_files/gdal_stack*.sh", sep = ""))
  combine = rbind(bin, pbs,module, cd, export, parallel)
  write(combine, file = paste("/projects/oa/tree_vel/et0/inputs/", var, "/", time, "/qsub_files/run_files.sh", sep = ""))}







# for wind and rad files
# var = "rad"
# time = ""
# 
# 
# for (i in 1:length(tiles))
# {
# 
#   inpath = paste("/projects/oa/tree_vel/radiation/aligned/tiles/", sep = "")
#   files = list.files(inpath, pattern = '.tif', recursive = TRUE, include.dirs = TRUE, full.names = TRUE)
#   g = grep(files, pattern = 'convert')
#   files = files[g]
#   
#   for (j in 1:20)
#   {
#     tiles = substr(files[j], nchar(files[j])-7, nchar(files[j])-4)
#     g = grep(files, pattern = tiles)
#     sub_files = files[g]
#     order = c(5, 4, 8, 1, 9, 7, 6, 2, 12, 11, 10, 3)
#     sub_files = sub_files[order]
# 
#     write(sub_files, file = paste('/projects/oa/tree_vel/et0/inputs/', var,"/qsub_files/input_files",tiles, ".txt", sep = ""))
#     input_file_list = print(paste("/projects/oa/tree_vel/et0/inputs/", var, "/qsub_files/input_files", tiles, ".txt", sep = ""))
#     outfilename = print(paste("/projects/oa/tree_vel/et0/inputs/", var, "/",  var, "_stack", tiles, ".vrt", sep = ""))
#     gdal = print(paste("gdalbuildvrt -separate -input_file_list ", input_file_list, outfilename))
#     write(gdal, file = paste("/projects/oa/tree_vel/et0/inputs/", var, "/qsub_files/gdal_stack", tiles, ".sh", sep = ""))
# 
# 
#     bin = print("#!/bin/bash")
#     pbs = print("#PBS -N input_stack")
#     module = print("module load parallel ")
#     cd = print("cd /projects/oa/tree_vel/")
#     export = print("export PARALLEL='--env PATH --env LD_LIBRARY_PATH --env LOADEDMODULES --env _LMFILES_ --env MODULE_VERSION --env MODULEPATH --env MODULEVERSION_STACK --env MODULESHOME'")
#     parallel = print(paste("parallel -j $PBS_NP sh {} ::: et0/inputs/", var, "/qsub_files/gdal_stack*.sh", sep = ""))
#     combine = rbind(bin, pbs, module, cd, export, parallel)
#     write(combine, file = paste("/projects/oa/tree_vel/et0/inputs/", var, "/qsub_files/run_files.sh", sep = ""))}
# 
#   }
#   
# 
# 
 
