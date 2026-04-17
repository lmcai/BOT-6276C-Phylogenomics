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


### Specify the Model
The basic idea behind the model in this example is that speciation and extinction rates are dependent on a binary character, and the character transitions between its two possible states (Maddison et al. 2007).

**Priors on the Rates**

We start by specifying prior distributions on the diversification rates. Here, we will assume an identical prior log-uniform distribution on each speciation and extinction rate.

Now we can specify our character-specific speciation and extinction rate parameters. Because we will use the same prior for each rate, it’s easy to specify them all in a for-loop. We will use a log-uniform distribution as a prior on the speciation and extinction rates. The loop also allows us to apply moves to each of the rates we are estimating and create a vector of deterministic nodes representing the rate of diversification (λ−μ) associated with each character state.
```
for (i in 1:NUM_STATES) {

    speciation[i] ~ dnLoguniform( 1E-6, 1E2)
    moves.append( mvScale(speciation[i],lambda=0.20,tune=true,weight=3.0) )

    extinction[i] ~ dnLoguniform( 1E-6, 1E2)
    moves.append( mvScale(extinction[i],lambda=0.20,tune=true,weight=3.0) )

    diversification[i] := speciation[i] - extinction[i]

}
```
Next we specify the transition rates between the states 0 and 1: q01 and q10. As a prior, we choose that each transition rate is drawn from an exponential distribution with a mean of 10 character state transitions over the entire tree. This is reasonable because we use this kind of model for traits that transition not-infrequently, and it leaves a fair bit of uncertainty. Note that we will actually use a for-loop to instantiate the transition rates so that our script will also work for non-binary characters.

```
rate_pr := observed_phylogeny.treeLength() / 10
for ( i in 1:(NUM_STATES*(NUM_STATES-1)) ) {
    transition_rates[i] ~ dnExp(rate_pr)
    moves.append( mvScale(transition_rates[i],lambda=0.20,tune=true,weight=3.0) )
}
```
Here, rate[1] is the rate of transition from state 0 (diurnal) to state 1 (nocturnal), and rate[2] is the rate of going from nocturnal to diurnal.

Finally, we put the rates into a matrix, because this is what’s needed by the function for the state-dependent birth-death process.

```
rate_matrix := fnFreeBinary( transition_rates, rescaled=false)
```
**Prior on the Root State**

Create a variable for the root state frequencies. We are using a flat Dirichlet distribution as the prior on each state. There has been some discussion about this in (FitzJohn et al. 2009). You could also fix the prior probabilities for the root states to be equal (generally not recommended), or use empirical state frequencies.
```
root_state_freq ~ dnDirichlet( rep(1,NUM_STATES) )
```
Note that we use the rep() function which generates a vector of length NUM_STATES with each position in the vector set to 1. Using this function and the NUM_STATES variable allows us to easily use this Rev script as a template for a different analysis using a character with more than two states.

We will use a special move for objects that are drawn from a Dirichlet distribution:
```
moves.append( mvDirichletSimplex(root_state_freq,tune=true,weight=2) )
```
**The Probability of Sampling an Extant Species**

All birth-death processes are conditioned on the probability a taxon is sampled in the present. We can get an approximation for this parameter by calculating the proportion of sampled species in our analysis.

We know that we have sampled 233 out of 367 living described primate species. To account for this we can set the sampling probability as a constant node with a value of 233/367.
```
sampling <- num_taxa / 367
```
**Root Age**

The birth-death process also depends on time to the most-recent-common ancestor–i.e., the root. In this exercise we use a fixed tree and thus we know the age of the tree.
```
root_age <- observed_phylogeny.rootAge()
```
**The Time Tree**

Now we have all of the parameters we need to specify the full character state-dependent birth-death model. We initialize the stochastic node representing the time tree and we create this node using the dnCDBDP() function.
```
timetree ~ dnCDBDP( rootAge           = root_age,
                    speciationRates   = speciation,
                    extinctionRates   = extinction,
                    Q                 = rate_matrix,
                    pi                = root_state_freq,
                    delta             = 1.0,
                    rho               = sampling,
                    condition         = "time")
```
Now, we will fix the BiSSE time-tree to the observed values from our data files. We use the standard .clamp() method to give the observed tree and branch times:
```
timetree.clamp( observed_phylogeny )
```
And then we use the .clampCharData() method to set the observed states at the tips of the tree:
```
timetree.clampCharData( data )
```
Finally, we create a workspace object of our whole model. The model() function traverses all of the connections and finds all of the nodes we specified.
```
mymodel = model(timetree)
```
The rest of the code sets up the MCMC sampling process.