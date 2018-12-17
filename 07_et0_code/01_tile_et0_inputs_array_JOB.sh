#!/bin/bash
#
#SBATCH --job-name=tile_inputs
#SBATCH --output=/data/gpfs/assoc/gears/tree_vel/01_analysis/step4_et0/et0/monthly/input_files/run_files/output_files/tile_%a.txt
#SBATCH --array=328-338
#SBATCH --ntasks=1
#SBATCH --time=00-04:00

echo "THE OS sees my SLURM_ARRAY_TASK_ID: " $SLURM_ARRAY_TASK_ID
srun --exclusive singularity exec /data/gpfs/home/baileymorrison/my_containers/gearslaboratory-gears-singularity-master-general.simg Rscript /data/gpfs/assoc/gears/tree_vel/01_analysis/step4_et0/et0/monthly/input_files/run_files/tile_et0_inputs.R
