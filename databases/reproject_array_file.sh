#!/bin/bash
#
#SBATCH --job-name=v_reproj
#SBATCH --output=/data/gpfs/assoc/gears/tree_vel/climate/reprojected/run_files/output_files/v_%a.txt
#SBATCH --array=1-456
#SBATCH --ntasks=1
#SBATCH --time=00-01:00
#SBATCH --mem-per-cpu=1GB
#SBATCH --cpus-per-task=1

echo "THE OS sees my SLURM_ARRAY_TASK_ID: " $SLURM_ARRAY_TASK_ID
srun --exclusive singularity exec ~/slurm_tutorial/gearslaboratory-gears-singularity-master-general.simg Rscript /data/gpfs/assoc/gears/tree_vel/climate/reprojected/run_files/reproject_v.R




