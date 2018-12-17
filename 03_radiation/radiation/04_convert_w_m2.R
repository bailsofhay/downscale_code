library(spatial.tools)
months = add_leading_zeroes(seq(1:12), 2)

for (i in 1:length(months))
{
  month = months[i]
  files = list.files(path = paste('/projects/oa/tree_vel/radiation/aligned/tiles/', month, sep = ""), pattern = ".tif", include.dirs = T, full.names = T)
  tiles = substr(files, nchar(files)-7, nchar(files)-4)
  
  for (j in 1:length(files))
  {
    file = files[j]
    module = print("module load anaconda")
    gdal = print(paste("gdal_calc.py -A ", file, " --outfile /projects/oa/tree_vel/radiation/aligned/tiles/", month, "/rad_convert", tiles[j], ".tif --NoDataValue=-9999 --calc='A*(0.0036)'", sep = "" ))
    combine = rbind(module, gdal)
    write(combine, file = paste('/projects/oa/tree_vel/radiation/aligned/tiles/qsub_files/', month, '/convert', tiles[j], '.sh', sep = ""))
    
    bin = print("#!/bin/bash")
    pbs = print("#PBS -N convert_rad")
    module = print("module load parallel ")
    cd = print("cd /projects/oa/tree_vel/")
    export = print("export PARALLEL='--env PATH --env LD_LIBRARY_PATH --env LOADEDMODULES --env _LMFILES_ --env MODULE_VERSION --env MODULEPATH --env MODULEVERSION_STACK --env MODULESHOME'")
    parallel = print(paste("parallel -j $PBS_NP sh {} ::: radiation/aligned/tiles/qsub_files/", month, "/convert*.sh", sep = ""))
    combine = rbind(bin, pbs,module, cd, export, parallel)
    write(combine, file = paste("/projects/oa/tree_vel/radiation/aligned/tiles/qsub_files/", month, "/run_files.sh", sep = ""))
  
  }
}