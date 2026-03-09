#!/bin/sh
#SBATCH --account=bot6726
#SBATCH --qos=bot6726
#SBATCH --job-name=ASTRAL   #Job name	
#SBATCH --mail-type=ALL   # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=user@ufl.edu   # Where to send mail	
#SBATCH --cpus-per-task=1   # Number of cores: Can also use -c=4 
#SBATCH --mem-per-cpu=4gb   # Per processor memory
#SBATCH -t 12:00:00   # Walltime
#SBATCH -o ASTRAL.%j.out   # Name output file 
#
pwd; hostname; date

echo Working directory is $SLURM_SUBMIT_DIR
cd $SLURM_SUBMIT_DIR

echo There are $SLURM_CPUS_ON_NODE cores available.

# To allocate memory for ASTRAL: 
export _JAVA_OPTIONS="-Xmx300M"
#export _JAVA_OPTIONS="-Xmx2g"

module load astral
module load python
module load ete3

astral -i song_mammals.424.gene.tre -o song_mammals.424.gene.treout.tre 2>out.log


# Notes:
# Input trees must be in Newick format, can have missing taxa and/or polytomies
# See https://github.com/smirarab/ASTRAL/blob/master/README.md
# Can do multi-locus bootstrapping, etc., see instructions at this link