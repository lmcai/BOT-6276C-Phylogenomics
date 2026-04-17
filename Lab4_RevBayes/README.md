# Character dependent diversification rate estimation in RevBayes

## 1. Software we'll cover in lab today:

RevBayes [website](https://revbayes.github.io/)

RevBayes uses its own language, Rev, which is a probabilistic programming language similar to the language used in R. Like the R language, Rev is designed to support interactive analysis. It supports both functional and procedural programming models, and makes a clear distinction between the two. Rev is also more strongly typed than R.

To learn more about the graphic model used in RevBayes, you can refer to this tutorial (https://revbayes.github.io/tutorials/intro/getting_started). Here we will only cover diversification rate estimation in RevBayes.

## 2. Getting onto the server

We will be using the RevBayes version available on HiPerGator. 

By now, you should be able to:

1. Log on to Hipergator using `ssh`
2. `cd` into your working directory (this is either `/ufrc/bot6276/<username>/`, or a folder in your PI's group)
3. Make a new directory for this lab using `mkdir` and `cd` into it.
4. Next, make two additional directories inside this directory:
  - `mkdir Lab4`
5. **Upload** the files (both data and scripts) for today's lab to your new directories.

We need
```
primates_activity_period.nex
primates_tree.nex
mcmc_BiSSE.Rev
```

## 3. The RevBayes script and input file

For this tutorial, we will specify a BiSSE model that allows for speciation and extinction to be correlated with the timing of activity during the day. If you open the file `primates_activity_period.nex` in your text editor, you will see that several species like the mantled howler monkey (Alouatta palliata) have the state 0, indicating that they are diurnal. Whereas other nocturnal species, like the aye-aye (Daubentonia madagascariensis) are coded with 1. We may have an *a priori* hypothesis that diurnal species have higher rates of speciation and by estimating the rates of lineages associated with that trait will allow us to explore this hypothesis.

Let's start by looking at the data files which we will use in this tutorial:

`primates_tree.nex`: Dated primate phylogeny including 233 out of 367 species. This tree is from Magnuson-Ford and Otto (2012), who took it from Vos and Mooers (2006) and then randomly resolved the polytomies using the method of Kuhn et al. (2011).

`primates_activity_period.nex`: A file with the coded character states for primate species activity time. This character has just two states: 0 = diurnal and 1 = nocturnal.

All three nexus files should be stored under the `data` folder.

Now let’s start to analyze an example in RevBayes using the BiSSE model. Take a look at the Rev script to run BISSE model: `mcmc_BiSSE.Rev`. This script allows you to run the analysis all at once (`rb mcmc_BiSSE.Rev`), but you can also call rebvayes using `rb` and input the commands line by line interactively for testing purposes. 

### Read in the Data
For this tutorial, we are assuming that the tree is “observed” and considered data. Thus, we will read in the dated phylogeny first.
```
observed_phylogeny <- readTrees("data/primates_tree.nex")[1]
```
Next, we will read in the observed character states for primate activity period.
```
data <- readCharacterData("data/primates_activity_period.nex")
```
It will be convenient to get the number of sampled species num_taxa from the tree:
```
num_taxa <- observed_phylogeny.ntips()```
Additionally, we initialize a variable for our vector of moves and monitors.
```
moves    = VectorMoves()
monitors = VectorMonitors()```
Finally, create a helper variable that specifies the number of states that the observed character has:
```
NUM_STATES = 2```



