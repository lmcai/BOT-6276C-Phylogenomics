# "Maximum Likelihood in IQ-TREE"

## 1. Software we'll cover in lab today:

IQ-TREE [website](https://iqtree.github.io/)

The walk-through below allows you to perform the analysis on your laptop. If you have a HiperGator account, you can submit a slurm job for IQ-TREE as well (see tutorial at the bottom).

## 2. Installation

Download and install from IQTREE [website](https://iqtree.github.io/#download) or if you have conda installed:
```
conda install bioconda::iqtree
``` 
Notice the latest version is v3.0.1. An older version may use different flags for certain functions.

Make sure you can call iqtree from your environment. Type the following command:
```
iqtree3 -h
```
And you should see this:
```
IQ-TREE version 3.0.1 for MacOS ARM 64-bit built Jul  9 2025
Developed by Bui Quang Minh, Thomas Wong, Nhan Ly-Trong, Huaiyan Ren
Contributed by Lam-Tung Nguyen, Dominik Schrempf, Chris Bielow,
Olga Chernomor, Michael Woodhams, Diep Thi Hoang, Heiko Schmidt

Usage: iqtree [-s ALIGNMENT] [-p PARTITION] [-m MODEL] [-t TREE] ...
```

## 3. Likelihood analyses

IQ-TREE is a standard tool for ML analyses in phylogenetics. The most recent versions allow you to perform bootstrap analysis and search for the best-scoring ML tree in a single run. It can handle substantial datasets with thousands of loci, but we will work with a small primates dataset, which is typically used as an example in courses like this, to keep things fast. IQ-TREE takes FASTA or phylip formatted files for the alignment. You'll need to get the following files into your working folder, and remember to change the email address in the slurm submission script: 

- primates.fasta
- primates_constraint.tre
- primates_partition

1. Perform a default run of IQ-TREE using only the minimum input. Make sure you `cd` into the correct working directory where `primates.fasta` is located.
```
iqtree3 -s primates.fasta
```
2. Look at `primates.fasta.log`, look for the following information

a. What's the `Host` (device) on which the analysis was run? What's the seed number (important for replication)?

b. How many taxa and characters are in this fasta file? How many of them are parsimony-informative? How many singleton?

c. If no models are specified by `-m`, IQ-TREE performs ModelFinder. What does ModelFinder do? Comparing the scores between `JC+I+R3` and `F81+F+I+G4` from the log file, which model is better? Why? What is the best model selected under the AIC, AICc, and BIC criteria? Why are they different?

d. What does `NNI` mean? What is IQ-TREE doing when it says `Optimizing NNI: ...`?

e. What's the final optimal likelihood? What's the inferred rate parameters? Why are some of them equal to each other?

f. View `primates.fasta.treefile` in FigTree or other tree viewing program. Is this a rooted or unrooted tree?

3. We will run IQ-TREE again by adding `-nt 2` to use 2 threads to speed up the program. `-B 1000` to use ultrafast bootstrap to evaluate branch support, and `-p primates_partition`  

a. Look at `primates_partition`, what's the name and range of each partition?

b. Now look at the log file `primates_partition.log`. What's the final optimal likelihood? How does it compare to the previous run?

c. Look at the `primates_partition.best_model.nex` file. This file contains the best partition model inferred from the data, and rate parameters for each individual partition. What is the best model for each partition? Why is the rate different (read the [tutorial](https://iqtree.github.io/doc/Advanced-Tutorial#partitioned-analysis-for-multi-gene-alignments) and think about the difference between `-p`, `-q`, and `-Q`)?

What option have we selected in the submission script, and what will it do? What command would you enter if you wanted to generate a bunch of bootstrapped alignment files from an original alignemnt file? (Note that this flag actually requires a couple additional flags as well, explained by -h).

Scroll further down in the help until you find `-m`. This is where you set the model of nucleotide evolution (or protein, etc.). Notice that RAxML has relatively few models available to it. For nucleotide data, it has GTRCAT and GTRGAMMA, each with or with out the I addition for invariant sites. 

Once you understand the flags in the command line and what they're doing, you're ready to run an analysis! Make sure you're in the correct working directory on HPG, and that the edited submission script and appropriate input file(s) are also there. Then type the following:
```
sbatch raxml.pthreads.slurm 
```
It will spit back a line that gives you a job number for the job you just submitted. To check the status of your job, type this:
```
squeue -u <user>
```
This will report the status of all the jobs you currently have running. In the ST column, the letter R indicates that the job is currently running, and the time next to it tells you how long it's been running. Once it's running, you can refresh Cyberduck to see the new files that are being created, but don't move or open them while it's running or you will mess up the analysis. Depending on your email flag setup, you'll get a message when the analysis starts, ends, and/or aborts.

While it's running, let's look at the remaining two commands lower down in the submission script, the ones that are commented out.

The first of these introduces a data partition. It uses the exact same input file, but how includes a flag to an input script that divides the alignment into partitions based on whether they are coding or non-coding. You'll probably want to partition your data files at some point, so it's very useful to know how to do this (look at the code and note that it's the `-q` flag that adds the partition information). Open the partition info file in Textwrangler to see what it looks like. 

The second command adds a constraint to the analysis. This will force the trees searched to only be those that meet a criterion for backbone relationships. It is the `-g` flag that adds the constraint input file. Open the constraint file in Textwrangler to see what it looks like. You can also open the constraint tree in FigTree and look at it. The way this constraint will work is that RAxML will only consider trees that are compatible with this constraint. Notice that there is no structure within the three big clades, so those relationships are free to vary. We are enforcing two things, essentially: 1. the make-up of each of those three large clades (e.g., one clade must always include Homo, Pan, Gorilla together), and 2. the backbone relationships of those clades to one another and to the outgroup. This is a useful approach if you know something about how your tree should be shaped, and want to save time by not having RAxML consider trees that aren't congruent with your prior knowledge (hmm sounds like Bayesian thinking...).

Once your analysis has completed, you'll have a bunch of output files to look at. This is what the outputs are:

- RAxML_besttree.$identifier                  #single best tree with branch lengths
- RAxML_bipartitions.$identifier              #best tree with bootstrap support values
- RAxML_bipartitionsBranchLabels.$identifier  #another format of the previous output
- RAxML_bootstrap.$identifier                 #topology from each bootstrap replicate
- RAxML_info.$identifier                      #lots of information about the run

For extra practice, go ahead and uncomment the other types of analyses (with partition, and with partition plus constraint) and run them too. When they've all finished, open the RAxML_info files from the three different jobs and scroll through them. You are looking in particular for the ML score of the best ML tree; this is the Final ML Optimization Likelihood. 

3. What are the scores from the best-scoring trees from each of the three jobs? Which of the three commands produced the best tree overall, comparing these three scores?

4. What is your explanation for the relative scores from the three jobs? Is this what you would have expected, and why?

5. How different are the constrained and unconstrained versions of the output tree topologies (open them in Figtree, which you can download here: http://tree.bio.ed.ac.uk/software/figtree/). Was using the constraint necessary to get the "correct" relationships, based on our prior knowledge?

## 2. Getting onto the server

By now, you should be able to:

1. Log on to Hipergator 
2. `cd` into your scratch directory (this is either `/ufrc/zoo6927/<username>/`, or a folder in your PI's group)
3. Make a new directory for RAxML and go into it (see the handout on HPG Basics if you can't remember how to do this)
4. `cp` the files from `/ufrc/zoo6927/share/raxml` to your folder.

Open the .slurm script in TextWrangler or other text editing program and take a look at it. This is a standard submission script for HPG. The way HPG works, you do not in general run jobs interactively, and the HPG folks will get very angry if you do! You run jobs by writing a configuration, or submission, script, like this one, and then you submit it to HPG. HPG handles scheduling of jobs, and allocating resources to them appropriately, so that everyone's jobs get sorted out correctly and jobs run in an ordered and timely manner. 

When you first open a submission script, you'll want to change a few things right away. At the top you will see a whole set of lines that don't mean much to you; these tell the server a bunch of important things it needs to know, and some of them you should edit so they make sense to you later, because they actually concern outputs that you'll want to know about.

```
#!/bin/sh
#SBATCH --account=zoo6927
#SBATCH --qos=zoo6927
#SBATCH --job-name=<RAxML_test>   #Job name  
#SBATCH --mail-type=ALL   # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=<user@ufl.edu>   # Where to send progress emails
#SBATCH --cpus-per-task=1   # Number of cores: Can also use -c=4 
#SBATCH --mem-per-cpu=4gb   # Per processor memory
#SBATCH -t 12:00:00   # Walltime
#SBATCH -o <RAxML10>.%j.out   # Name output file; ONLY change the part between the carrots!
#
pwd; hostname; date
```
You'll want to change the job name, make sure the email address is set to yours, and change the prefix it uses for the output files (this is the last SBATCH line). Make sure that you remove all the carrots (these: `< >`) when you change these things! There are three lines in the middle that handle the request you're making from the server; the first two govern how many cpus you're asking for, how much memory each should get, and how long you want the analysis to run for. You'll get a better feeling for setting these the more you use the server, but in general, ask Emily the first few times you do things. Don't use more than 2-4 cpus for the purposes of this class; it's important to remember that we have a limited number (32, to be exact) allocated to our entire class, for everyone's use. And when you're done with this class, you'll be using the cpus your PI has invested in, so if you use them all up, no one else in the group can run analyses until yours are done. It's important to be a good citizen and not hog the nodes.

The next few lines tell the server some information about where it should be working; in general, you submit a submission script from the working directory you are currently sitting in, which should contain, in addition to the submission script itself, all the files the server will then look for to run the analysis you've asked it to (if this is confusing, ask Emily for clarification). Leave all this alone and don't change it:
```
echo Working directory is $SLURM_SUBMIT_DIR
cd $SLURM_SUBMIT_DIR

echo There are $SLURM_CPUS_ON_NODE cores available.
```
The next line tells the server to load the appropriate modules for the software and analyses that you want to run. In our current case, there's only one:
```
module load raxml
```
There are hundreds of programs installed on the server, and it would be overwhelming for it to keep them constantly "on call". Instead, you call up the individual modules you want for the analysis you're going to run, using this `module load <module name>` command.

Once the module is loaded, there is a single active command line for RAxML, with a commented-out line above it that explains what it will do. Below this there are four more lines, each a command plus an explanatory comment above it, that add additional functionality: using a partitioned dataset, and adding a constraint tree to force the analysis to consider only trees consistent with a particular backbone constraint. 

For the first command, here's a breakdown of what it will do:

```
raxmlHPC-PTHREADS-SSE3 -f a -m GTRGAMMA -s primates.phy -p $RANDOM -x $RANDOM -N 1000 
-n RAxML_primates -T $SLURM_TASKS_PER_NODE

raxmlHPC-PTHREADS-SSE3    #calls the program to use
-f a                      #sets the analysis type we want
-m GTRGAMMA               #tells RAxML the nucleotide substitution model to use
-s primates.phy           #tells it the name of the input file
-p $RANDOM, -x $RANDOM    #these specify some random number seeds for the analyses
-N 1000                   #the number of bootstrap replicates you want to run
-n RAxML_primates         #the output prefix to use
-T $SLURM_TASKS_PER_NODE  #feeds the information from your SBATCH lines into the analysis
```
For a basic analysis that does bootstrapping and a search for the best tree in one run, the only things you would want to change to the above would be: the -m flag, if you're using a different model, the -s flag to tell it the correct input file name; the -N flag if you want a different number of bootstrap replicates; and the -n flag for the output prefix. Leave the rest the same.

For all of the above, you've been looking at the text file in Textwrangler. Next, go onto HPG and type the following:

```
module load raxml
raxmlHPC-PTHREADS-SSE3 -h
```
The long thing (`raxmlHPC-PTHREADS-SSE3`) is the particular flavor of RAxML that we use in the submission script, and this flag/command (`-h`) will call up the help file for it. RAxML is a very powerful program with lots of different options for things it can run, depending on the flags that you give the program. 
