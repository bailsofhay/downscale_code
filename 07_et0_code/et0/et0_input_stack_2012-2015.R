
# for pr, tmin, tmax, ts, and wind
var = "pr"

folders = list.files(path = "/projects/oa/tree_vel/downscale/forest_service/pr/pr/")
folders = folders[-length(folders)]

start = sort(rep(1:5, 4))
end = rep(1:4, 5)
suffix = paste(start, end, sep = "_")


for (i in 1:length(suffix))
{
  files = list.files(path = paste("/projects/oa/tree_vel/downscale/forest_service/", var, sep = ""), pattern = paste(suffix[i], "_convert.tif", sep = ""), include.dirs = T, full.names = T, recursive = T)
  
  write(files, file = paste('/projects/oa/tree_vel/downscale/forest_service/et0/stacks/', var, '/qsub_files/input_files_', suffix[i], '.txt', sep = ""))
  
  gdal = print(paste("gdalbuildvrt -separate -input_file_list /projects/oa/tree_vel/downscale/forest_service/et0/stacks/", var, "/qsub_files/input_files_", suffix[i], ".txt /projects/oa/tree_vel/downscale/forest_service/et0/stacks/", var, "/tmin_stack_", suffix[i], ".vrt", sep = ""))
  write(gdal, file = paste("/projects/oa/tree_vel/downscale/forest_service/et0/stacks/", var, "/qsub_files/gdal_stack_", suffix[i], ".sh", sep = ""))
  
  bin = print("#!/bin/bash")
  pbs = print("#PBS -N input_stack")
  module = print("module load parallel ")
  cd = print("cd /projects/oa/tree_vel/")
  export = print("export PARALLEL='--env PATH --env LD_LIBRARY_PATH --env LOADEDMODULES --env _LMFILES_ --env MODULE_VERSION --env MODULEPATH --env MODULEVERSION_STACK --env MODULESHOME'")
  parallel = print(paste("parallel -j $PBS_NP sh {} ::: downscale/forest_service/et0/stacks/", var, "/qsub_files/gdal_stack*.sh", sep = ""))
  combine = rbind(bin, pbs,module, cd, export, parallel)
  write(combine, file = paste("/projects/oa/tree_vel/downscale/forest_service/et0/stacks/", var, "/qsub_files/run_files.sh", sep = ""))

}

# # for rad 

var = "rad"
for (i in 1:length(suffix))
{
  files = list.files(path = "/projects/oa/tree_vel/downscale/forest_service/rad/", pattern = paste("convert_", suffix[i], sep = ""), include.dirs = T, full.names = T, recursive = T)
  #order = c(5, 4, 8,1,9,7,6,2,12,11,10,3)
  #files = files[order]

  write(files, file = paste('/projects/oa/tree_vel/downscale/forest_service/et0/stacks/', var, '/qsub_files/input_files_', suffix[i], '.txt', sep = ""))

  gdal = print(paste("gdalbuildvrt -separate -input_file_list /projects/oa/tree_vel/downscale/forest_service/et0/stacks/", var, "/qsub_files/input_files_", suffix[i], ".txt /projects/oa/tree_vel/downscale/forest_service/et0/stacks/", var, "/tmin_stack_", suffix[i], ".vrt", sep = ""))
  write(gdal, file = paste("/projects/oa/tree_vel/downscale/forest_service/et0/stacks/", var, "/qsub_files/gdal_stack_", suffix[i], ".sh", sep = ""))

  bin = print("#!/bin/bash")
  pbs = print("#PBS -N input_stack")
  module = print("module load parallel ")
  cd = print("cd /projects/oa/tree_vel/")
  export = print("export PARALLEL='--env PATH --env LD_LIBRARY_PATH --env LOADEDMODULES --env _LMFILES_ --env MODULE_VERSION --env MODULEPATH --env MODULEVERSION_STACK --env MODULESHOME'")
  parallel = print(paste("parallel -j $PBS_NP sh {} ::: downscale/forest_service/et0/stacks/", var, "/qsub_files/gdal_stack*.sh", sep = ""))
  combine = rbind(bin, pbs,module, cd, export, parallel)
  write(combine, file = paste("/projects/oa/tree_vel/downscale/forest_service/et0/stacks/", var, "/qsub_files/run_files.sh", sep = ""))

}
