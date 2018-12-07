module load taudem

module load mpich

PR_THREADS=$(($PBS_NP / 2))




sleep 5
echo $(date)
echo "Getting Dinf slope and flow direction"
mpiexec -n $PBS_NP dinfflowdir -fel /gpfs/largeblockFS/project/oa/tree_vel/tci/pitrem/ -ang /gpfs/largeblockFS/project/oa/tree_vel/tci/angle/ -slp /gpfs/largeblockFS/project/oa/tree_vel/tci/slope/ -mf 1 1

##echo $(date)
##echo "Getting Dinf accumulation"
##mpiexec -n 20 areadinf  -fel /gpfs/largeblockFS/project/oa/tree_vel/tci/pitrem/ -sca /gpfs/largeblockFS/project/oa/tree_vel/tci/sca/  -mf 1 1
##echo "Done"
##echo $(date)
