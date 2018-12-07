#!/bin/bash

#PBS -N tauDEM_ca_dinf

#PBS -S /bin/bash

#PBS -m ae
#PBS -M bdmorri2@illinois.edu

#PBS -e localhost:/projects/oa/tree_vel/tci/west.err
#PBS -o localhost:/projects/oa/tree_vel/tci/west.log
 
#PBS -l nodes=10:ppn=20



#PBS -l walltime=48:00:00

/bin/bash /projects/oa/tree_vel/tci/code/dinfaccum_west.sh

