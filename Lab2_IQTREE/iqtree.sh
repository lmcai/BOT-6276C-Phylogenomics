#!/bin/sh
#SBATCH --job-name=IQTREE_test   #Job name	
#SBATCH --cpus-per-task=2   # Number of cores: Can also use -c=4 
#SBATCH --mem-per-cpu=4gb   # Per processor memory
#SBATCH -t 12:00:00   # Walltime
#SBATCH -o IQTREE.%j.out   # Name output file 
#
pwd; hostname; date

echo Working directory is $SLURM_SUBMIT_DIR
cd $SLURM_SUBMIT_DIR

echo There are $SLURM_CPUS_ON_NODE cores available.

module load iq-tree

# default run
iqtree3 -s primates.fasta

# 1000 ultrafast bootstrap and a partition file
iqtree3 -s primates.fasta -p primates_partition -B 1000 -nt 2

# constrained tree search
iqtree3 -s primates.fasta -p primates_partition -B 1000 -nt 2 -g primates_constraint.tre