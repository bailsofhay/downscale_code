module load taudem

module load mpich

PR_THREADS=$(($PBS_NP / 2))






echo $(date)
echo "Getting Dinf accumulation"
mpiexec -n 20 areadinf -ang /gpfs/largeblockFS/project/oa/tree_vel/tci/angle/ -sca /gpfs/largeblockFS/project/oa/tree_vel/tci/sca/  -mf 1 1
echo "Done"
echo $(date)
