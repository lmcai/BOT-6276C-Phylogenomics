# Hipergator and command line basics

Spring 2026

## 1. Prior to this lab you should have done the following:

1. Obtained a Hipergator account and tested that you can login
2. Installed the following software on your laptop:
    + Terminal (Mac) or PC equivalent (e.g., XTerm)
    + Cyberduck (Mac) or PC equivalent (e.g., Putty)
    + BBEdit (Mac) or PC equivalent (e.g., Notepad)
3. Configured Cyberduck (or equivalent) to work with Hipergator
4. Downloaded the file [dummy.txt](Data/dummy.txt) to your laptop

## 2. Getting onto the server

Open Terminal or PC equivalent. At the prompt (the prompt is the $; you do not enter this, it just appears), type the command below, where `<user>` is your username. 

N.B.: In general, where I put these carrot symbols: `< >` it means that the text between them is something variable, sometimes something specific to you; in this case, `<user>` means that you enter your username. Enter your password when asked; it will NOT appear on the screen as you type it. Type carefully; it will lock you out after three incorrect attempts. You can hit delete a bunch of times to erase all the keystrokes you've made if you think you have made a mistake, and start over.

```
ssh <user>@hpg2.rc.ufl.edu
```

Once you are logged on, you will see something like this: 
```
[user@gator2 ~]$
```
This tells you that you are now on Hipergator (HPG). Before you continue, you need to do another step to move to the appropriate place on HPG. By default, the place you land when you logon is your home folder, but this is NOT actually where you want to work. To change to the correct location, you will need to know the group that you're part of, and you'll use the 'cd' function to change directory (that's what cd stands for) to move there. First type 'pwd', which is the command to check your present working directory. You should see something like this:

```
pwd
/home/<user>
```

This is the location where we DON'T want to be. To get to the right place, enter the following:
```
cd /ufrc/<group>/<user>
pwd
```
The last command should now display exactly the location you entered with the `cd` command.

For many of you, the only option of a place to work is your place in the course's directory, so you can use this command:
```
cd /ufrc/bot6276/<user>
```

`pwd` is "present working directory" - this command will always give you your current location, i.e., the folder that you are working in at the moment. You can move around between directories easily, using `cd`, the command above where you moved from the home folder to the scratch folder (`cd` stands for "change directory").

## 3. Basic useful unix commands
Once you are on the server, there are a number of helpful commands that you should memorize, and will find yourself using frequently. These are demonstrated in the code below, which has comments indicated with  #.
```
mkdir Lab1  #this command will create a new directory (folder) called Lab1
cd Lab1  #this will move you into the Lab1 directory
cd ..  #the directory above where you currently are is called .. and this will move you back to it
ls  #this will display a list of the current directory's contents
ls -l  #this displays the directory content list with additional information
```
In addition to `..` being the directory immediately above you, `.` is the directory where you currently are. This is useful to know and will come in handy later.

## 4. Getting files onto hipergator
There are many ways to move files between your local machine and the server; these include commands like `push`, `wget`, `scp`, and many others. I am lazy and like to drag and drop. I also like to be able to view my files more conveniently than as a list on the server. This is a personal preference, and both of these can be accomplished using an FTP program, which you should already have installed.

One useful modification to make to Cyberduck's setup is to make it such that if you double click a file name, it will open that file using your preferred text editing software, directly on the server. The default is to have double clicking download the file, which gets really annoying and cumbersome. To change this, do the following: Select Preferences from the Cyberduck menu, and select Editor. Choose your editor of choice from the dropdown menu, and hit the button for "always...". Now choose the Browser menu option, and check the box next to "Double click opens file in external editor". You're all set!

In Cyberduck, navigate to the new Lab1 directory you created above, and drag "dummy.txt" from wherever it is on your laptop to that directory. It should transfer automatically. Going back to terminal, you can check to be sure that the file shows up. First use `pwd` to be sure you're in your Lab 1 folder, and then use `ls -l` to show you the list of files in that folder. You should see something like this:

```
$ pwd
/ufrc/bot6276/<user>/Lab1
$ ls -l
-rw-rw-r--  1 <user> bot6276  214 Jan 25  2019 dummy.txt
```

Now we can practice a few more commands...

## 5. Other useful commands
A few more you can practice...
```
$ cp dummy.txt ..  #this will copy "dummy.txt" from the current directory to the directory above
$ cp dummy.txt dummy1.txt  #this will make a duplicate of dummy.txt called dummy1.txt
$ mv dummy1.txt ..  #this will move (not copy!) the file to the directory above
$ cd ..  #move yourself to the directory above Basics
$ rm dummy.txt  #this will delete the file IMMEDIATELY - THERE IS NO UNDOING THIS!!!!!!!
```
A note on the `rm` command: there is no UNDO function for this. If you delete a file, or a directory, it is gone, immediately, forever. There is no recovery. Be extremely certain about what you're doing before you delete anything - this applies x1000 to deleting directories, which are entire folders that you then cannot recover!

In fact, basically now forget that you even know that `rm` exists! :)

Often the files we work with will be too long to display on screen, but seeing the first or last few lines can be very helpful:
```
$ head dummy.txt  #displays first 10 lines
$ tail dummy.txt  #displays last 10 lines
$ wc -l dummy.txt  #tells how many total lines are in the file; instead of -l, you can use 
-w to give words, -c to give characters, or a combination of these, e.g., -lc
```
As you probably noticed by trying out the above commands, that dummy.txt file had the word "dummy" in it quite a few times. We can find out exactly how many times using a standard unix command called `grep`, and various options, or flags, that you can use with it. 
```
$ grep dummy dummy.txt  #prints out each line that contains the word dummy, in the file dummy.txt
$ grep -i dummy dummy.txt  #the -i flag makes the search case-insensitive (sensitive by default)

Other options:
-v display those lines that do NOT match 
-n precede each matching line with the line number 
-c print only the total count of matched lines 

You can combine these, e.g.:
$ grep -vc dummy dummy.txt  #this prints out the number only, for the lines that do NOT match
```

## 6. Tab to complete
Once of the most useful tips for working on the command line is to use the Tab key to auto-complete file and directory names as you type. This is an essential trick, and you should get used to using the tab key extensively. Besides Enter, it should be the key you hit the most often. Try this:
```
$ cp du  #now hit the Tab key. "dummy.txt" should autofill on the command line.
$ cp di  #hit Tab again. This time nothing happens (or it will flash or make a noise).
```
This is a beautiful tool for several reasons: first, it saves you time from having to type out a long file name or path, if you want to reach a file that is several directories away from you. Second, if the file you are searching for is not actually in the directory where you are located, or you are typing the name wrong, you will figure it out very quickly, because pressing Tab will produce no results (or it will flash or beep at you). This prevents you from typing out a whole long file address, only to discover the file is not actually present in the folder where you are located, or that you made a typo way back at the beginning. Use tab constantly!

## 7. Editing text directly on HPG with nano
Nano is a text editor built directly into unix. There are other such programs, including vim, but nano is one of the most user-friendly. It is useful if you don't want to use Cyberduck to edit a text file using Textwrangler.
```
$ nano dummy.txt  #this will open the file in nano, in the same terminal window. 
Did you use tab??? 
```
You can edit the file as you like. On a mac, ctrl-X closes it. Type 'Y' and then 'enter' to save it to the appropriate file name (you can save it as something different at this point if you wish), and then close it.

## 8. Filetypes in phylogenetics/phylogenomics, and some practice
### Nexus - very common (used in PAUP, MrBayes, etc.)
First let's practice using the `cp`, or copy, command, to move some files from the shared area in our course directory to your personal directory. By using the copy command, you just create a copy in your directory rather than moving the file; in this way, it remains accessible to everyone else in the class (you all have access to the shared folder).

First, check on where you are with `pwd`, and then move to your /ufrc/bot6276/<user>/Lab1 directory using `cd`.

Next, type the following:
```
cp ../../share/Lab1files/primates.nex .
cp ../../share/Lab1files/primates.phy .
cp ../../share/Lab1files/primates.tre .
```
What did we just do? Remember that `..` is the directory immediately above you; in this case we needed to go back two directories from your Lab1 directory; first, to your user directory, and then to the one above that, the bot6276 directory. We told the server to go back two, then forward into the /share/Lab1files directory. In there it finds these three files, and we tell it to copy them each to `.`, which if you recall, is the place where you currently are. Ask Emily if this does not make sense! This is basic movement around on the server (or inside any computer), so make sure you are comfortable with this now.

Next, use `nano` to view the primates.nex file. Note that the file is composed of "blocks"; each block starts with the words `begin <block type>;` and somewhere later (sometimes many lines later), each block ends with `end;`. Also note that every single individual line ends with `;`. 

\newpage
Use the skills you learned in the lab above, including `grep`, to answer the questions below.

1. How many taxa are in primates.nex and how can you tell without counting the lines in the matrix? How many characters are in the matrix?

![alt text](blank.png)\

2. How many times does the sequence motif "ACCTCGCTCCAAT" appear in primates.nex?  

![alt text](blank.png)\

3. Which species have the same sequence motif, "ACCTCGCTCCAAT",  in the alignment?  

![alt text](blank.png)\



### The remaining are optional things to try if you want to

### Newick - a commonly used tree format
To look at a phylogenetic tree, a commonly used piece of software is FigTree. Look it up and download it to your laptop.

Download the file primates.tre to your laptop from HPG using your FTP program. Open the file in FigTree, and play with the options in the left sidebar. You can use the File > Export Trees... function to export the file in Nexus (or Newick) format, though the original file is already in Newick format. Note that in order for Figree to open files, they usually need to end with `.tre`.

Now open the original file in TextWrangler. Use the graphical representation in Figtree and the text version in TextWrangler (both derived from the Newick-formatted file) to answer these questions:

4. How long is the branch that subtends the clade including Homo_sapiens, Pan, and Gorilla?

![alt text](blank.png)\

5. What is the appropriate section of Newick code (meaning, the notation using parentheses) that defines this clade? You can either find it and copy it out of the Newick file, or try to write it yourself by looking at the figure.

![alt text](blank.png)\


### Phylip - used with RAxML, among other things
Download the primates.phy file to your laptop, and open it with TextWrangler. Notice the differences between this and the Nexus file. 




