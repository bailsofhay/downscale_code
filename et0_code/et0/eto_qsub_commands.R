files = list.files(path = '/projects/oa/tree_vel/et0/et0/modern/april/qsub_files', pattern = ".R")
time = "modern"
months = c("april", "aug", "dec", "feb", "jan", "july", "june", "mar", "may", "nov", "oct", "sept")
for (i in 1:length(files))
{
  for (j in 1:length(months))
  {
    RCMD = print(paste("R CMD BATCH /projects/oa/tree_vel/et0/et0/", time, "/", months[j], "/qsub_files/", files[i], sep = ""))
    write(RCMD, file = paste('/projects/oa/tree_vel/et0/et0/', time, '/', months[j], '/qsub_files/rcmd_', i, '.sh', sep = ""))
    
    qsub = print(paste("qsub -o out -e err -N eto_", months[j], "_", i, " -l walltime=4:00:00,nodes=1:ppn=20 /projects/oa/tree_vel/et0/et0/", time, "/", months[j], "/qsub_files/rcmd_", i, ".sh", sep = ""))
    write(qsub, file = paste("/projects/oa/tree_vel/et0/et0/", time, "/", months[j], "/qsub_files/qsub_commands.sh", sep = ""), append = T)
    
  }
  
}