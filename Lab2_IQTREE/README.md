# Maximum Likelihood in IQ-TREE

## 1. Software we'll cover in lab today:

IQ-TREE [website](https://iqtree.github.io/)

The walk-through below allows you to perform the analysis **locally on your laptop**. If you have a HiperGator account, you can submit a slurm job for IQ-TREE as well (**see tutorial at the bottom**). If you cannot run it on your computer or HiperGator, you can look at the outputs in the output folders.

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

Based on the IQTREE help information, how do you specify the input alignment? How about output prefix? 

ANS: `-s` for input aln and `--prefix` for output prefix

Scroll further down in the help until you find the `MODEL-FINDER` section. The default behaviour of IQ-TREE will run model test among all models available. But you can specify a subset to be included, such as `-m GTR`, which will only explore `GTR`, `GTR+F`, `GTR+I+F`, `GTR+I+F+G2`, etc.

Once you understand the flags in the command line and what they're doing, you're ready to run an analysis! Make sure you're in the correct working directory.

## 3. Likelihood analyses

IQ-TREE is a standard tool for ML analyses in phylogenetics. The most recent versions allow you to perform bootstrap analysis and search for the best-scoring ML tree in a single run. It can handle substantial datasets with thousands of loci, but we will work with a small primates dataset, which is typically used as an example in courses like this, to keep things fast. IQ-TREE takes FASTA or phylip formatted files for the alignment. You'll need to get the following files into your working folder: 
```
primates.fasta
primates_constraint.tre
primates_partition
```

1. Perform a default run of IQ-TREE using only the minimum input. Make sure you `cd` into the correct working directory where `primates.fasta` is located.
```
iqtree3 -s primates.fasta
```

Once your analysis has completed, you'll have a bunch of output files to look at. This is what the outputs are:

```
- primates.fasta.treefile		#single best tree with branch lengths
- primates.fasta.log			#log file containing lots of information about the run
- primates.fasta.iqtree			#main report file detailing model selection, log-likelihood, and branch support
- primates.fasta.mldist			#pairwise genetic distance calculated from the best model
- primates.fasta.ckp.gz			#check point file if you need to resume the run
```

2. Look at `primates.fasta.log`, look for the following information

a. What's the `Host` (device) on which the analysis was run? What's the seed number (important for replication)?

ANS: This will be specific to your run.

b. How many taxa and characters are in this fasta file? How many of them are parsimony-informative? How many singleton?

ANS: Alignment has 12 sequences with 898 sites. 367 parsimony-informative, 154 singleton sites.

c. If no models are specified by `-m`, IQ-TREE performs ModelFinder. What does ModelFinder do? Comparing the scores between `JC+I+R3` and `F81+F+I+G4` from the log file, which model is better? Why? What is the best model selected under the AIC, AICc, and BIC criteria? Why are they different?

ANS: ModelFinder tries to identify the best-fitting subsitution model. To compare `JC+I+R3` and `F81+F+I+G4`, locate their coresponding lines:

```
No. Model         -LnL         df  AIC          AICc         BIC
15  JC+I+R3       6266.414     26  12584.828    12586.440    12709.632
...
69  F81+F+G4      6125.746     25  12301.491    12302.982    12421.495
```
F81+F+G4 is superior based on AIC, AICc, and BIC scores because the values are lower.

The best model under each criteria is follows:
```
Akaike Information Criterion:           TVM+F+G4
Corrected Akaike Information Criterion: TVM+F+G4
Bayesian Information Criterion:         TPM2u+F+G4
```
They are different because of how free parameters are penalized, with BIC penalize strongly on the number of free parameters.

d. What does `NNI` mean? What is IQ-TREE doing when it says `Optimizing NNI: ...`?

ANS: `NNI` is a tree topology refining algorithm. IQ-TREE alternates tree tologies around the current tree to explore tree space and identify better fitting trees.

e. What's the final optimal likelihood? What's the inferred rate parameters? Why are some of them equal to each other?

ANS: 
```
Optimal log-likelihood: -5721.623
Rate parameters:  A-C: 3.34392  A-G: 26.76078  A-T: 3.34392  C-G: 1.00000  C-T: 26.76078  G-T: 1.00000
Base frequencies:  A: 0.324  C: 0.304  G: 0.106  T: 0.266
```
Some rates are equal to each other because they are symmatrical under the best model `TPM2u`, which has its specific assumptions: 
```
rAG=rCT(transitions share one rate)
rAC=rAT!=rCG=rGT
```

f. View `primates.fasta.treefile` in FigTree or other tree viewing program. Is this a rooted or unrooted tree?

ANS: unrooted

3. We will run IQ-TREE again by adding `-nt 2` to use 2 threads to speed up the program. `-B 1000` to use ultrafast bootstrap to evaluate branch support, and `-p primates_partition`.

The `-p` flag introduces a data partition. It uses the exact same input file, but how includes a flag to an input script that divides the alignment into partitions based on whether they are coding or non-coding. You'll probably want to partition your data files at some point, so it's very useful to know how to do this. 

```
iqtree3 -s primates.fasta -p primates_partition -B 1000 -nt 2
```
a. Open the partition info file `primates_partition`, what's the name and range of each partition?

b. Now look at the log file `primates_partition.log`. What's the final optimal likelihood? How does it compare to the previous run?

ANS: best likelihood score= -5899.779. It is lower than previous run, but it does not necessarily mean the tree is worse. We have included more parameters this time because of data partition, the likelihood is expected to drop a little.

c. Look at the `primates_partition.best_model.nex` file. This file contains the best partition model inferred from the data, and rate parameters for each individual partition. What is the best model for each partition? Why is the rate different (read the [tutorial](https://iqtree.github.io/doc/Advanced-Tutorial#partitioned-analysis-for-multi-gene-alignments) and think about the difference between `-p`, `-q`, and `-Q`)? More specifically, how does the rate between coding and non-coding regions differ from each other?

ANS: GTR for both partitions. the non-coding rate is higher as expected (GTR{15.122,45.6549,9.10676,9.82992,98.3016} for non-coding compared to GTR{6.79421,22.3723,4.10071,1.78118,22.4811} for coding)

d. View `primates.fasta.treefile` in FigTree or other tree viewing program. Display the node labels. What's the ultrafast support value for the common ancestor of Homo_sapiens and Pongo?

ANS: 97

e. What command would you use if you want to run non-parametric bootstrap?

ANS: `-b 100` for 100 non-parametric bootstrap

4. We can also constrain the topology of the phylogeny and only optimize the branch length. 

This will force the trees searched to only be those that meet a criterion for backbone relationships. It is the `-g` flag that adds the constraint input file. Open the constraint file to see what it looks like. You can also open the constraint tree in FigTree and look at it. The way this constraint will work is that IQTREE will only consider trees that are compatible with this constraint. Notice that there is no structure within the three big clades, so those relationships are free to vary. We are enforcing two things, essentially: 1. the make-up of each of those three large clades (e.g., one clade must always include Homo, Pan, Gorilla together), and 2. the backbone relationships of those clades to one another and to the outgroup. This is a useful approach if you know something about how your tree should be shaped, and want to save time by not having IQTREE consider trees that aren't congruent with your prior knowledge.

To do so, use the following commands
```
iqtree3 -s primates.fasta -p primates_partition -B 1000 -nt 2 -g primates_constraint.tre
```

a. What is the best score from this tree? How does it compare to previous results? What is your explanation for the relative scores from the three jobs? Is this what you would have expected, and why?

ANS: best score -6059.482 is lowest compared to prevous runs. The very short internal branches of the constraint search plus the lower likelihood score indicate that the constrained topology fit worse to the data.

b. Check the support values of constrained nodes? Why are they all 100?

ANS: becuase the relationship of the constrained nodes does not change during tree search, they are expected to occur 100% in the boostrap replicate trees.

c. Do you notice super-short branches in the tree from the constrained search? Why could it be the case?

ANS: see above.

d. How different are the constrained and unconstrained versions of the output tree topologies? Was using the constraint necessary to get the "correct" relationships, based on our prior knowledge?

ANS: the constrained relationship of monophyletic (Pongo,Hylobates,Tarsius_syrichta,Saimiri_sciureus), which includes Orangutans to Gibbons and Squirrel Monkey, is unrealistic.

######################################################
# If you have access to HiperGator

Complete the same steps above on HiperGtor

1. Log on to Hipergator 
2. `cd` into your scratch directory
```
cd /blue/bot6276/<user>
```
3. Make a new directory for IQTREE and go into it
```
mkdir Lab2
cd Lab2
```

4. Upload all files from your computer to `/blue/bot6276/<user>/Lab2`. When you list the files under this folder, you should see this:
```
$ls /blue/bot6276/<user>/Lab2
primates_constraint.tre
primates_partition
primates.fasta
iqtree.sh
```

Open the .slurm script in BBEdit or other text editing program and take a look at it. This is a standard submission script for HPG. The way HPG works, you do not in general run jobs interactively, and the HPG folks will get very angry if you do! You run jobs by writing a configuration, or submission, script, like this one, and then you submit it to HPG. HPG handles scheduling of jobs, and allocating resources to them appropriately, so that everyone's jobs get sorted out correctly and jobs run in an ordered and timely manner. 

When you first open a submission script, you'll want to change a few things right away. At the top you will see a whole set of lines that don't mean much to you; these tell the server a bunch of important things it needs to know, and some of them you should edit so they make sense to you later, because they actually concern outputs that you'll want to know about.

```
#!/bin/sh
#SBATCH --account=bot6276  #group name with which you are affiliated and resource will be used
#SBATCH --qos=bot6276
#SBATCH --job-name=IQTREE   #Job name  
#SBATCH --cpus-per-task=1   # Number of cores: Can also use -c=4 
#SBATCH --mem-per-cpu=4gb   # Per processor memory limit
#SBATCH -t 12:00:00   # Walltime limit to run the script
#SBATCH -o IQTREE.%j.out   # Name output file; ONLY change the part between the carrots!
pwd; hostname; date
```
You can also make SLURM send you email when the job is done by adding:
```
#SBATCH --mail-type=END,FAIL          # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=<email>@ufl.edu     # Where to send mail      
```
Make sure the email address is set to yours. Make sure that you remove all the carrots (these: `< >`) when you change these things! There are three lines in the middle that handle the request you're making from the server; the first two govern how many cpus you're asking for, how much memory each should get, and how long you want the analysis to run for. You'll get a better feeling for setting these the more you use the server. And when you're done with this class, you'll be using the cpus your PI has invested in, so if you use them all up, no one else in the group can run analyses until yours are done. It's important to be a good citizen and not hog the nodes.

The next few lines tell the server some information about where it should be working; in general, you submit a submission script from the working directory you are currently sitting in, which should contain, in addition to the submission script itself, all the files the server will then look for to run the analysis you've asked it to (if this is confusing, ask Emily for clarification). Leave all this alone and don't change it:
```
echo Working directory is $SLURM_SUBMIT_DIR
cd $SLURM_SUBMIT_DIR

echo There are $SLURM_CPUS_ON_NODE cores available.
```
The next line tells the server to load the appropriate modules for the software and analyses that you want to run. In our current case, there's only one:
```
module load gcc/14.2.0 openmpi/5.0.7 iq-tree/3.0.1
```
There are hundreds of programs installed on the server, and it would be overwhelming for it to keep them constantly "on call". Instead, you call up the individual modules you want for the analysis you're going to run, using this `module load <module name>` command.

Once the module is loaded, there are active command lines for the three IQTree runs. The job can be simply submitted by the following command:
```
$sbatch iqtree.sh
```
It will spit back a line that gives you a job number for the job you just submitted. To check the status of
your job, type this:
```
squeue -u <user>
```
This will report the status of all the jobs you currently have running. In the ST column, the letter R indicates that the job is currently running, and the time next to it tells you how long it’s been running. Once it’s running, you can refresh Cyberduck to see the new files that are being created, but don’t move or open them while it’s running or you will mess up the analysis. Depending on your email flag setup, you’ll get a message when the analysis starts, ends, and/or aborts.

You can then follow the tutorial above to complete the analysis and look at the results.


