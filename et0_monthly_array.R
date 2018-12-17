#!/bin/bash
#
#SBATCH --job-name=et0_monthly
#SBATCH --output=/data/gpfs/assoc/gears/tree_vel/01_analysis/step4_et0/et0/monthly/et0/run_files/output_files/et0_%a.txt
#SBATCH --array=1-16
#SBATCH --ntasks=1

echo "THE OS sees my SLURM_ARRAY_TASK_ID: " $SLURM_ARRAY_TASK_ID
srun --exclusive singularity exec /data/gpfs/home/baileymorrison/my_containers/gearslaboratory-gears-singularity-master-general.simg Rscript /data/gpfs/assoc/gears/tree_vel/01_analysis/step4_et0/et0/monthly/et0/run_files/et0_monthly.R

