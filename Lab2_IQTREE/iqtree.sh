#!/bin/sh
#SBATCH --account=bot6276  #group name with which you are affiliated and resource will be used
#SBATCH --qos=bot6276
#SBATCH --job-name=IQTREE_test   #Job name	
#SBATCH --cpus-per-task=2   # Number of cores: Can also use -c=4 
#SBATCH --mem-per-cpu=2gb   # Per processor memory
#SBATCH -t 01:00:00   # Walltime
#SBATCH -o IQTREE.%j.out   # Name output file 
#
pwd; hostname; date

echo Working directory is $SLURM_SUBMIT_DIR
cd $SLURM_SUBMIT_DIR

echo There are $SLURM_CPUS_ON_NODE cores available.

module load iq-tree

# default run
iqtree3 -s primates.fasta -pre run1

# 1000 ultrafast bootstrap and a partition file
iqtree3 -s primates.fasta -p primates_partition -B 1000 -nt 2 -pre run2

# constrained tree search
iqtree3 -s primates.fasta -p primates_partition -B 1000 -nt 2 -g primates_constraint.tre -pre run3