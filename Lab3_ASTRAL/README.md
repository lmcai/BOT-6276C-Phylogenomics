# Summary colascent based species tree inference in ASTRAL

## 1. Software we'll cover in lab today:

ASTRAL [website](https://github.com/chaoszhang/ASTER)

This updated `ASTER` package includes multiple ASTRAL-like tools that can accommodate gene duplications, gene tree uncertainties, etc.

![Families of ASTRAL application from Zhang et al 2025 MBE](./ASTER.jpg)

## 2. Getting onto the server

By now, you should be able to:

1. Log on to Hipergator using `ssh`
2. `cd` into your working directory (this is either `/ufrc/bot6276/<username>/`, or a folder in your PI's group)
3. Make a new directory for this lab using `mkdir` and `cd` into it.
4. Next, make two additional directories inside this directory:
  - `mkdir Lab3`
5. Copy the files for today's lab to your new directories.
  For ASTRAL:
  - song_mammals.424.gene.tre
  - astral.pthreads.slurm

Check the contents of the directories using `ls` to make sure everything copied properly.

## 3. ASTRAL background

ASTRAL is a summary method that will estimate an unrooted species tree from a set of input, unrooted gene trees. ASTRAL is statistically consistent under the multi-species coalescent (meaning that it is theoretically guaranteed to converge on the correct solution as more data are added). The input trees can be unresolved (i.e., have polytomies), contain missing taxa, or multiple tips with the same taxon name. There are various options available for multi-locus bootstrapping and other modifications (see: https://github.com/smirarab/ASTRAL), but here we will focus on the basics of how to use the software.

ASTRAL is a java program that has already been installed on HPG and is easy to use. Another handy feature on HPG is that the command `module load astral` will automatically load the most recent version of the software that has been installed. The current version (as of March 2019) is version 5.6.2, which corresponds to ASTRAL-II. You can always load a specific version by modifying the load command as: `module load astral/4.10.7`, substituting the version number as appropriate to get the one you want. This is especially useful if a beta version has been released that is not the default version loaded with `module load astral`, but you want to test it out.

## 4. The ASTRAL submission script and input file

Let's start by looking at the submission script for ASTRAL: `astral.pthreads.slurm`.

Notice that there's a line we haven't seen in any our scripts before, which allocates memory to ASTRAL (technically, to any java application you have running, but since ASTRAL is the only one you'll run with this script, you can think of it as being specific to ASTRAL).
```
# To allocate memory for ASTRAL: 
export _JAVA_OPTIONS="-Xmx300M"
#export _JAVA_OPTIONS="-Xmx2g"
```
The second command is commented out so that everyone in our class does not request 2GB of memory at the same time, but this is how you would call larger amounts of memory if you had a bigger dataset.

The `astral` command actually executes the program, and its flags are pretty simple: designating an input file, an output file, and where the log file should be saved. 

Open the input file, `song_mammals.424.gene.tre` in TextWrangler and take a look at it. Confirm to yourself that this file contains a set of Newick-formatted gene trees. 

1. How many gene trees are there in the input file? _______________________________

## 5. Running ASTRAL and working with output

Go ahead and run ASTRAL by submitting your job to the queue:
```
sbatch astral.pthreads.slurm
```
Remember that you can check the status of your job with this command; ASTRAL may finish so quickly that there's no job listed by the time you enter this.
```
squeue -u <GatorID>
```
Take a look at the output file in TextWrangler. What does it look like?

Next open up the log file (also in TextWrangler) and use it to answer the following questions:

2. How did ASTRAL root the gene trees and species tree? Any guesses why it used that taxon? _______________________

3. How many quartet trees (4-taxon trees) are present amongst all of your input gene trees? _______________________

The normalized quartet score is the proportion of quartets present in the input gene trees that are present in the species tree. It is a value between 0 and 1, the higher the better.

4. What is the value of the normalized quartet score for this analysis? What does this value mean in terms of discordance between your gene trees? In other words, does higher/lower mean more or less discordance? _______________________

The optimization score is related to the values above, it is the raw number of quartets in the gene trees that is found in the species tree.

5. Open the output tree in FigTree, and set the branch labels to show the values from ASTRAL. In general, what these values are like across the tree? 

![alt text](blank.png)\

A description of these support values and what they mean can be found here: http://eceweb.ucsd.edu/~smirarab/2016/04/15/localpp.html. This post summarizes a paper by two of the ASTRAL authors that describes how local branch support values are described from quartet frequencies: Sayyari and Mirarab. 2016. Fast Coalescent-Based Computation of Local Branch Support from Quartet Frequencies. MBE 33(7): 1654-1668. Basically, the values indicate support for a quadripartition around a particular branch, not a bipartition, which is what is commonly used to calculate these values.

This paper also discusses branch lengths. Note that the branch lengths on this tree are in coalescence units and as such are a measure of discordance among gene trees; they are not analogous to branch lengths in a typical ML tree, for example, which are shown in substitutions/site.

## 6. BUCKy

For reference, the complete BUCKy manual: http://www.stat.wisc.edu/~ane/bucky/v1.4/bucky_manual1.4.4.pdf

For BUCKy, we'll be working interactively, so go ahead and request some time on a development node:
```
module load ufrc
srundev --time=01:00:00
```
First, move from the ASTRAL directory into the BUCKy directory you made. Use `ls -l` and `pwd` if you need to, to figure out where you are and where the BUCKy directory is. 

BUCKy uses Bayesian Concordance Analysis (BCA) to estimate the concordance factor (CF) of each clade in a tree, i.e., the proportion of genes that have the clade (Ané 2007, Baum 2007, Larget et al. 2010), or said another way, the proportion of the genome for which a given clade is true. Clades with moderately low CFs contain relationships that are not in the primary concordance tree, but that are still true for a minority of the genome (Larget et al. 2010), and may be present in secondary or tertiary trees.

We will use a yeast dataset with 106 genes and 8 taxa. By allowing for the possibility that each locus has tracked its own history, BCA allows the user to identify biological processes that may account for different loci having different genealogies, like hybridization, incomplete lineage sorting, or lateral gene transfer. The *a priori* level of discordance among loci is controlled by a single parameter (alpha). BCA is a three-step process, which involves three programs, two of which are part of the package BUCKy. These are the steps:

1. Bayesian phylogenetic analysis of all individual loci, conducted separately in MrBayes. This generates .t files (which you see four of in the files for today; the MrB analysis has already been done to produce these files).
2. Summary of the .t files produced by MrBayes, done in mbsum (this is part of Bucky).
3. Bayesian concordance analysis, also done in BUCKy.

**Choosing the a priori level of discordance (alpha)**

To select an a priori leve of discordance based on biological relevance, the number of taxa and number of genes need to be considered. For example, the user might have a prior idea about the proportion of loci sharing the same genealogy. One can turn this information into a value of alpha since the probability that two randomly chosen loci share the same tree is about 1/(1+alpha) if alpha is small compared to the total number of possible tree topologies. Also, the value of alpha sets the prior distribution on the number of distinct locus genealogies in the sample. 

An interactive way to get this distribution uses two R scripts: `alpha_exploration.r` and `prior_standalone.r`. Download these from the server, and open R or RStudio locally on your laptop. Open the `alpha_exploration.r` script, which calls the `prior_standalone.r` script. Change the first line in `alpha_exploration.r` so that it points to the directory where both scripts are, so that it can find them.

Explore how the expected number of distinct trees changes for a set number of genes and taxa given different values of alpha. Try using 106 genes and 8 taxa, and then other variations.

6. Describe the probability distribution fo various versions of alpha with 106 genes and 8 taxa. Where is the distribution centered, and what is the probability of the highest number of trees? 
 
    - alpha = 0.001? ____________________
    
    - alpha = 1? ____________________
    
    - alpha = 10? ____________________
    
    - alpha = 1000? ____________________

**Running mbsum**

We next need to use mbsum to summarize all the .t files from the different gene trees that have already been generated by MrBayes for each gene. For simplicity, we will just use the four .t tree files that were generated from four separate Bayesian phylogenetic analyses of a single gene, y000, to create one `.in` file that summarizes the results for *just that gene*.
```
module load bucky
mbsum -n 501 -o y000.in y000.run*.t
```
In this command, `-n` specifies the burnin, `-o` give the name of the output file, and the last part tells it to look for all the .t files with a wildcard character after `run`, so that it will use all four of our input files (run1 through run4).

Here we are only doing this for one gene, y000; in reality, we would run this separately for a bunch of genes, each of which would have its own 2-4 .t files. Remember that each time you run MrBayes for a different gene, you tell it to do multiple runs, usually 2-4. The different .t files are therefore the results of separate MrBayes runs for each gene, and this step is putting them together for just a single gene (and you would do this multiple times, once for each gene). The next step will use BUCKy to summarize *across* all these genes. I realize that's all confusing; here's a schematic that describes what a real Bucky run would be summarizing:

![alt text](BUCKY_fig.jpg)\

7. Take a look at the output file the previous command produced (y000.in) and explain in your own words what it is showing.

![alt text](blank.png)\

**Running BUCKy**

For this part, we will pretend that we have already run mbsum for a bunch more genes (a total of 106). For this, you'll need to unzip the buckydata.tar.gz file using this command:
```
tar -zxvf buckydata.tar.gz
```
You now have a new directory called buckydata with its own subdirectories that contains a ton of these mbsum output files, for 106 different genes (each gene has its own folder).

Now, run BUCKy itself with:
```
bucky -a 1 -k 4 -n 1000000 -c 4 -s1 23546 -s2 4564 -o yeast buckydata/yeast/y*/*.in
```
While it is runnning, some notes on the parameters in this command...

- `-a 1` sets alpha to 1
- `-k 4` sets 4 separate runs
- `-n 1000000` sets the number of MCMC generations for BUCKy to run
- `-c 4` sets 4 chains, one cold and three hot 
- `-s1 23546` and `-s2 4564` set random seeds
- `-o yeast` sets the root name for output files
- The last part tells it where to find the input files, and `*.in` tells it the format of the .in file names to use

**Interpret output files**

BUCKy produces the following output files: 

- `.out`: screen output and other information
- `.input`: list of input files (one for each gene)
- `.gene`: summary of information for each gene
- `.cluster`: summary of the number of clusters (different trees)
- `.concordance`: summary of concordance among gene trees

First, look at the .gene file. This gives the list of all topologies supported by each locus, and the posterior probabilities that the locus has this tree given just the locus’s data (‘single’ column) and given the data from all loci (‘joint’ column).

8. How many topologies were sampled for gene 25? _______ And for gene 75? _______

Next, look at the .concordance file. This is the main output of BUCKy. It gives the primary concordance tree topology and the population tree topology. The population tree gives branch lengths in units of coalescence, while the concordance tree gives the CF support values, also as edge lengths (keep that in mind when you look at the tree as a tree in the next step).

9. Are the population tree and concordance tree the same? How do the CFs compare? You don't just have to look at the lines in the output file; you can copy the primary concordance and population tree lines to another file (that ends in .tre) and open it in FigTree. Then use the branch labels option to show the CF values. Draw what the two trees look like below or on another piece of paper.

![alt text](blank.png)\

10. Are there any splits NOT in the primary concordance tree but that do have estimated CF >0.05? How many? What are the splits, and what are their CFs? This information is in the `.concordance` output file.

![alt text](blank.png)\

11. What are the sample-wide and genome-wide CFs for the split {1,2,3|4,5,6,7,8}? Inference on genome-wide cfs assumes that loci were sampled at random from an infinite genome.

![alt text](blank.png)\

12. Look for a topology that has the clade (6,7) and give the number of genes that support it.

![alt text](blank.png)\

Finally, if there's time, rerun the BUCKy analysis using a different alpha value (try either 10 or 1000). Also specify a different output prefix, other than "yeast", otherwise you will overwrite your existing data!

13. How do the results compare? Your answer should include comparisons of the two output tree types and concordance factors in general between the two analyses.