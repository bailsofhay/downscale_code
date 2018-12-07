
# for et0
var = "et0"

folders = list.files(path = "/projects/oa/tree_vel/downscale/forest_service/et0/et0/")
folders = folders[-length(folders)]

start = sort(rep(1:5, 4))
end = rep(1:4, 5)
suffix = paste(start, end, sep = "_")


for (i in 1:length(suffix))
{
  files = list.files(path = paste("/projects/oa/tree_vel/downscale/forest_service/et0/", var, sep = ""), pattern = suffix[i], include.dirs = T, full.names = T, recursive = T)
  tif = grep(files, pattern = ".tif")
  files = files[tif]
  
  write(files, file = paste('/projects/oa/tree_vel/downscale/forest_service/et0/aet/stacks/', var, '/qsub_files/input_files_', suffix[i], '.txt', sep = ""))
  
  gdal = print(paste("gdalbuildvrt -separate -input_file_list /projects/oa/tree_vel/downscale/forest_service/et0/aet/stacks/", var, "/qsub_files/input_files_", suffix[i], ".txt /projects/oa/tree_vel/downscale/forest_service/et0/aet/stacks/", var, "/et0_stack_", suffix[i], ".vrt", sep = ""))
  write(gdal, file = paste("/projects/oa/tree_vel/downscale/forest_service/et0/aet/stacks/", var, "/qsub_files/gdal_stack_", suffix[i], ".sh", sep = ""))
  
  bin = print("#!/bin/bash")
  pbs = print("#PBS -N input_stack")
  module = print("module load parallel ")
  cd = print("cd /projects/oa/tree_vel/")
  export = print("export PARALLEL='--env PATH --env LD_LIBRARY_PATH --env LOADEDMODULES --env _LMFILES_ --env MODULE_VERSION --env MODULEPATH --env MODULEVERSION_STACK --env MODULESHOME'")
  parallel = print(paste("parallel -j $PBS_NP sh {} ::: downscale/forest_service/et0/aet/stacks/", var, "/qsub_files/gdal_stack*.sh", sep = ""))
  combine = rbind(bin, pbs,module, cd, export, parallel)
  write(combine, file = paste("/projects/oa/tree_vel/downscale/forest_service/et0/aet/stacks/", var, "/qsub_files/run_files.sh", sep = ""))
  
}


# for input water
var = "input"

folders = list.files(path = "/projects/oa/tree_vel/downscale/forest_service/et0/rain_files/input/")
folders = folders[-length(folders)]

start = sort(rep(1:5, 4))
end = rep(1:4, 5)
suffix = paste( start, "_", end,".tif", sep = "")


for (i in 1:length(suffix))
{
  files = list.files(path = paste("/projects/oa/tree_vel/downscale/forest_service/et0/rain_files/", var, sep = ""), pattern = suffix[i], include.dirs = T, full.names = T, recursive = T)
  tif = grep(files, pattern = ".tif")
  files = files[tif]
  
  write(files, file = paste('/projects/oa/tree_vel/downscale/forest_service/et0/aet/stacks/', var, '/qsub_files/input_files_', suffix[i], '.txt', sep = ""))
  
  gdal = print(paste("gdalbuildvrt -separate -input_file_list /projects/oa/tree_vel/downscale/forest_service/et0/aet/stacks/", var, "/qsub_files/input_files_", suffix[i], ".txt /projects/oa/tree_vel/downscale/forest_service/et0/aet/stacks/", var, "/input_stack_", suffix[i], ".vrt", sep = ""))
  write(gdal, file = paste("/projects/oa/tree_vel/downscale/forest_service/et0/aet/stacks/", var, "/qsub_files/gdal_stack_", suffix[i], ".sh", sep = ""))
  
  bin = print("#!/bin/bash")
  pbs = print("#PBS -N input_stack")
  module = print("module load parallel ")
  cd = print("cd /projects/oa/tree_vel/")
  export = print("export PARALLEL='--env PATH --env LD_LIBRARY_PATH --env LOADEDMODULES --env _LMFILES_ --env MODULE_VERSION --env MODULEPATH --env MODULEVERSION_STACK --env MODULESHOME'")
  parallel = print(paste("parallel -j $PBS_NP sh {} ::: downscale/forest_service/et0/aet/stacks/", var, "/qsub_files/gdal_stack*.sh", sep = ""))
  combine = rbind(bin, pbs,module, cd, export, parallel)
  write(combine, file = paste("/projects/oa/tree_vel/downscale/forest_service/et0/aet/stacks/", var, "/qsub_files/run_files.sh", sep = ""))
  
}
