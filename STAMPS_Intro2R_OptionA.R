##########################################
#
#  Introduction to R 
#  Option A: for relatively new users
#  A tutorial for STAMPS 2017
# 
#########################################
#
#  This tutorial is written by Amy Willis, July 2017
#  It is based off an original tutorial by Sue Huse, 2011-16
#  Mike Lee (AstrobioMike) contributed some fantastic explanations!
# 
#########################################
#
# If you downloaded this from the STAMPS website, 
# be sure to rename as "STAMPS_Intro2R_OptionA.R", 
# R and R Studio will not interpret is as an R script with ".txt" suffix

###############################################
# 
# Set your working directory
#
###############################################
# get the directory where you are currently reading and saving files
getwd()

# Set your working directory to wherever you want
# replace "MyProjectDirectory" with a valid location
setwd("~/Documents/MyProjectDirectory")  
getwd()  # check to see where it ended up, just in case

# "getwd" is a function, which we know because it is followed by 
# some parentheses. We can also see this by typing in
getwd
# R tells us that this is an internally defined function

###############################################
# 
# Read in some data and practice making selections
#
###############################################
#
# Read in a tab-delimited text file
#
# The following command reads in the specified file – which as entered here needs 
# to be located in our current working directory – and stores it in the variable 'covariates'.
# With additional arguments we tell R that the first line is a header with 
# names for each column (header=TRUE), that the columns are separated by 
# tabs (sep="\t"), and that we don't want it to change text to factors (as.is=TRUE).
# Don't worry if you aren't sure what a 'factor' is just yet!
covariates <- read.table("FWS_covariates.txt", header=TRUE, sep="\t", as.is=TRUE)
# Typing "a <- 5" assigns value 5 to the variable 'a', just as the
# above command assigns the table read from the filename to the variable 'covariates'.

# Everytime you import data, look at it before you use it.
# does it look like it came in correctly?
covariates  

# If it is too large to view all at once, you can use the head() function to view
# just the first few rows:
head(covariates)

# R stores things in objects called, well, 'objects'. An object
# is just a data structure that has certain properties that are defined by 
# what 'class' the object is.
# Different object classes have different properties. 
# The class() function returns the name of the object's class
class(covariates)  # what type of object is it?
colnames(covariates)  # what are the names of the columns / fields?

#
# We are going to use the data frame covariates for a bit while we practice selection.
# Let's look at the variable Month
Month

# That doesn't work! That's because Month only exists in the context of
# covariates. Here is how we access Month
covariates$Month

# If we want to make Month available outside of covariates, we need the following command
attach(covariates)   
Month
# Beware! You can only use attach on one dataframe at a time.
# You should know of the existence of attach(), but I (Amy) recommend you avoid using it.
# It complicates working with multiple datatypes, and if you change
# a value in the named variable it does not change the data frame. 
# However, this is my opinion, so other educators will tell you differently


###############################################
# 
# Experiment with retrieving data based on its indices
#
###############################################
# Single index selection
# Selecting a single row or column of a dataframe or matrix returns a vector.
SampleName          # so now I only have to type the column name to return the data, because we 'attached' the dataframe 
SampleName[1]       # the first index value in the vector 
SampleName[4:9]     # all indices from 4:9
SampleName[c(2,4,6)]  # a set of non-consecutive indices – the 'c()' function 'combines' the provided arguments
SampleName[c(6,4,2)]  # returns the values in the order selected
SampleName[-5]      # all but the fifth value

# Dual index selection works the same for dataframes and matrices as with vectors like above, 
# but you need two indices: rows and columns.
# In R, the row index is specified before the comma, and the column index is specified after ['row','column'].
# A blank selection of rows or columns selects all.

# Let's look at the covariates data frame again and then use dual indexing to select from it.
covariates

covariates[1:3, c(1,3,5)] # taking rows 1 through 3, and columns 1, 3, and 5
covariates[ ,c(1,3,5)] # since this leaves the 'rows' index blank, it selects all rows
covariates[ , c("Month", "Season")]  # you can select columns by selecting their names

# Often we will want to select certain rows based on their value in a specific column. R's indexing 
# is very useful for such things! Say we wanted all the rows that were from a specific location:
covariates[ Location == "MBL", ]   # this pulls all rows that have "MBL" in their "Location" column
  # note the "==" above, this is a logical operator that asks "does this thing equal this other thing?"
covariates[ Type != "Reservoir", ]  # "!=" is the logical operator that asks "does this thing *not* equal this other thing?"
  # common logical operators: ==, !=, >, >=, <, <= 
covariates[ Month %in% c("Jan", "Feb"), ]  # %in% specifies a vector of possibilities

# Get the set of unique items from a vector
unique(Season)  # what seasons are represented in the covariate data

# Explore how many of each covariate type you have
table(Location)
table(Type)
table(Season)
###############################################
# 
# Read in a taxa abundance matrix and get it ready to go
#
###############################################
# !!  Remember, if you are running locally and the data are in your 
# !!  working directory, run this without the directory preceding the file name.
#abundances <- read.table("/class/stamps-shared/R_tutorial/FWS_OTUs.txt", header=TRUE, row.names = 1, sep="\t", as.is=TRUE)
abundances <- read.table("FWS_OTUs.txt", header=TRUE, row.names = 1, sep="\t", as.is=TRUE)
  # This time we added an additional argument to read.table(). The "row.names=1" argument
  # tells R that the first column contains the names of the rows.

# !! Always LOOK at your imported data before you use it.
class(abundances) 
rownames(abundances)  # check the names of the rows, what would happen here if we didn't set "row.names=1" when reading in the table? 
colnames(abundances)  # check the names of the columns
head(abundances)   # quick check -- does it look okay?
# That was hard to look at.  If not all columns can be displayed, 
# it will repeat the rownames (taxa) for each set of columns.

# Look at the sample names in the covariate data file (remember "attach")
SampleName  #  Notice that the sample names in the covariates file are in the same order as the column names!
SampleName == colnames(abundances) # they are the same!
  # comparing two vectors with "==" like this pits each element from the first vector 
  # against the corresponding element in the second vector; which is why we get back
  # "TRUE" 12 times.

# Lets look at the abundances from the first sample ("JPA_Jan")
head(sort(abundances[,1])) # what kind of abundances do we see?

# All zeros?
# what if I want to sort decreasing and see the abundant taxa? 
# Get help on the syntax also help(sort)
?sort      
  # by default, sort() puts things in increasing order, we can change that by adding an argument:
sort(abundances[,1], decreasing=TRUE)  # Rank abundance for the data, but it includes 0's
sort(abundances[abundances[,1]>0,1], decreasing=TRUE)  # Proper rank abundance without 0's
  # Spend a moment deciphering how this command was put together. If you're not familiar with R,
  # it may seem a bit confusing at first.
  # Do you understand all of the pieces? If you're unsure, call over a friendly TA to chat 
  # about it! It's important to grasp as this is part of what makes indexing in R so wonderful :) 


# Exercise: How many times was the most abundant OTU
# observed in the second sample?
# STOP HERE and test yourself in finding this. 

# Answer: 3150

# Save the rank abundance for the first sample
myRankAbund <- sort(abundances[abundances[,1]>0,1], decreasing=TRUE)  
# note that nothing was printed out here, because variable assignment
# is done silently. 
head(myRankAbund) # always good to check that this worked as intended!

# Species abundances instead of rank abundances are important in many problems.
# table() provides the frequencies of each value (count)
table(abundances[abundances[,1] > 0 ,1])  # here is excluding those with 0 again
mySpeciesAbund <- table(abundances[,1]) # but we'll store it counting 0s so we know how many of them there are 
mySpeciesAbund

#
# Create a relative abundance matrix from the abundance matrix
#
# To scale the values in each column by dividing the values by the column total,
# we can use the scale() function:
taxaRel <- scale(abundances, center=FALSE, scale=colSums(abundances))  
# Check that the columns now all sum to 1 (=100%)
colSums(taxaRel)  # colSums finds the sum of each column

#
# Lets add a new column, Total, that sums the abundances for each genus
# 
# what is the dimension (size) of the table, how many rows and columns?
dim(taxaRel)       
# Can we add a new column for the total abundance of each row, 
# by assigning data to the next column index?
taxaRel[,13]  <- rowSums(taxaRel)  
#!! Why did that just fail?!?!
class(taxaRel) # it's a matrix now?
  # R handles matrices and data frames differently, and the scale() function we used output a matrix.
  # If something you think should work isn't working, checking the class of what you're working with is a good idea.
taxaRel <- as.data.frame(taxaRel)  # convert it to a data frame, less efficient, but easier to use in tutorials
class(taxaRel)    # double check

# Lets try that again
taxaRel[,13]  <- rowSums(taxaRel)  # Add a new column that is the total abundance of each row
colnames(taxaRel)  # Check your column names
colnames(taxaRel)[13] <- "Total"  # Fix the new column name
colnames(taxaRel)  # Check again 
head(taxaRel$Total)  

# Which are the abundant taxa across all samples?
# select the names of rows whose total is > or = to 1%
rownames(taxaRel[taxaRel$Total >= 0.01, ])

#
# Let's practice sorting, then use only the 10 most abundant taxa 
# because it makes the demo easier
#
# Sort based on decreasing Total, and return the values
sort(taxaRel$Total, decreasing=TRUE) 
# Sort based on decreasing Total, but returns the indices
order(taxaRel$Total, decreasing=TRUE)  

# Use the ordered indices to sort the data.frame, 
# and populate a new data frame with those values:
sortedTaxaRel <- taxaRel[ order(taxaRel$Total, decreasing=TRUE) , ] 
  # Again, take a second to break the command down and make sure it's clear to you what
  # it's doing and why. 

# Take the first 10 rows (most abundant taxa) and all of the columns (samples)
topTen <- sortedTaxaRel[1:10,]  
topTen
#
# Labeling with the full taxonomic names is rough, let's just get the genus names
#

# We'll substitute everything up to the last semicolon with nothing, leaving only the genus name.
# And we'll do this using the sub() function and a "regular expression", don't worry about it if 
# you don't completely understand it right now:
# The function is called in this manner:
#   sub(old_pattern, new_pattern, text, use perl regular expressions)
# We want to replace everything up to the last semicolon with nothing. 
# Our 'old_pattern' will be: "^.*;"
# and our 'new_pattern will be: "" 
# There are 3 special characters in the 'old_pattern':
  # ^ starts the string at the beginning of the line, 
  # . means any character, 
  # * means whatever character precedes it any number of times
topGenera <- sub("^.*;", "", rownames(topTen), perl=TRUE)    
topGenera # review the names  --- oops we have a few "genus_NA", not helpful
which(topGenera == "genus_NA")  # this gives us the indices of the genus_NA's
rownames(topTen)[7]  # what are the full taxa names for these rows?
  # seems our taxonomy annotation for this OTU wasn't confident beyond the Kingdom level
topGenera[7] <- "Bacteria"  # fix the genus_NA, by replacing with what we can say about it
topGenera  # Just checking...

####################################
#
# PLOTTING -- Practice a few types of graphs
#
####################################
# simple bar chart of the most abundant taxon:
barplot(topTen[1, ], main=topGenera[1], xlab="Sample", ylab="Relative Abundance")
# STAY CALM!
# Data frames can include characters as well as numbers, 
# so many functions require matrix input to be sure.  
# What is topTen again?
class(topTen)
# Okay it is a data frame and we need it to be a matrix.
topTen  <- as.matrix(topTen)
class(topTen)

# Let's try again
barplot(topTen[1, ], main=topGenera[1], xlab="Sample", ylab="Relative Abundance")
# phooey, sample names don't fit, we better rotate them
barplot(topTen[1, ], main=topGenera[1], ylab="Relative Abundance", las=2)
# the various plotting parameters (main, ylab, las) are explained in 
# par -- graphical PARameters
help(par)

# Remove the "Total" column, it really doesn't belong in our data, now that we have used it to sort
# dim() returns c(row_count, column_count), 
dim(topTen)
topTen <- topTen[ , 1:dim(topTen)[2] - 1 ]  # include all rows, and all but the last column = column count - 1
  # Remember from the indexing examples above that we can specify a range of numbers by putting a colon between them. 
  # That is all we're doing here for choosing which columns to include except we're doing so using the dim() function, and 
  # then indexing the second element of what that returns, and then subtracting one. All this to give us the number 12 in this case.
  # This may seem a bit convoluted, but it is actually more efficient in the long run. If the size of this table changes,
  # but the format is the same, we can use this code still without having to change anything.

# rerun the plot without the Totals column
barplot(topTen[1, ], main=topGenera[1], ylab="Relative Abundance", las=2)

# # Practice an xy and a line plot, default type = "point"
# plot(topTen[2, ], main=topGenera[2], xlab="Sample", ylab="Relative Abundance")
# plot(topTen[2, ], main=topGenera[2], xlab="Sample", ylab="Relative Abundance")
plot(myRankAbund, main="Rank Abundance", xlab="Rank", ylab="Taxon Abundance")
# Yep, sure looks like the standard microbial distribution curve.

#
# Box plots use the quartiles and outliers, so we want the taxa to be the x-axis and the samples to be the spread
boxplot(topTen, cex.axis=0.75, main="Ten Most Common Taxa", xlab=NULL, ylab="Relative Abundance", las=2)
# That wasn't right, we wanted the taxa on the X axis, not the samples
# we will have to rotate the data and try again
# t() will transpose (rotate) the matrix for us
boxplot(t(topTen), names=topGenera, cex.axis=0.75, main="Ten Most Common Taxa", xlab=NULL, ylab="Relative Abundance", las=2)

#
# Heatmaps give a sense of how the data behave across samples and taxa
#
heatmap(topTen, main="Common Taxa", labRow=topGenera)
heatmap(topTen, main="Common Taxa", labRow=topGenera, labCol=Location)
heatmap(topTen, main="Common Taxa", labRow=topGenera, labCol=Season)
heatmap(topTen, main="Common Taxa", labRow=topGenera, labCol=Season, col=terrain.colors(128))
heatmap(topTen, main="Common Taxa", labRow=topGenera, labCol=Season, col=topo.colors(255))

pdf("heatmap_top10.pdf")  # Send all subsequent plot output to a pdf file
heatmap(topTen, main="Common Taxa", labRow=topGenera)
dev.off()  # Close the pdf file, return to using the plot window.
# If you try to open the pdf outside of R and it fails, 
# come back and be sure you closed it with dev.off()

####################################
#
#  Look for patterns by season
#
####################################
# Lets look at that heat map again, any interesting patterns?
heatmap(topTen, main="Common Taxa", labRow=topGenera, labCol=Seasons)
# Oops! 'Seasons' not found?  Why is that?
colnames(covariates)
# Oh, we misspelled it.
heatmap(topTen, main="Common Taxa", labRow=topGenera, labCol=Season)


# Burkholderia, Curvibacter, Undibacterium, Pelomonas look by winter, sorta
topGenera  # What is the order of the genera again?  what is the index for Burkholderia
t.test(topTen[2,Season == "Winter"], topTen[2,Season=="Summer"])  #Burkholderia appear different by season, p-value <<0.05
t.test(topTen[1,Season == "Winter"], topTen[1,Season=="Summer"])  #Ralstonia appear different by season, p-value <<0.05
t.test(topTen[9,Season == "Winter"], topTen[9,Season=="Summer"])  #Not so with Midichloria, p>>0.05
# There is one other one that is significant, if you want to test that one too.
# Extra credit, perform a one-tailed t-test of Burkholderia, using the help

# Disclaimer: Amy does not endorse t-tests performed in this manner, 
# because we did not set out in advance to investigate these taxa

####################################
#
#  Statistical summaries
#
####################################

# We just did some sketchy hypothesis tests. Instead, let's calculate some
# sample means and standard deviations of the
# Ralstonia abundances

topTen[1,Season == "Winter"] # the abundances themselves
mean(topTen[1,Season == "Winter"]) # the sample mean of the abundances
sd(topTen[1,Season == "Winter"]) # the sample standard deviation of the abundances
var(topTen[1,Season == "Winter"]) # the sample variance of the abundances

# Let's investigate a basic model for Ralstonia abundances
# First create the abundance vector 
ral_abundances <- topTen[1, ]
ral_model <- lm(ral_abundances ~ Season)
ral_model
# We just fit a linear model to abundances based on season
# The fitted model is
# Ralstonia abundance = 0.0683 in Summer
# Ralstonia abundance = 0.0683 + 0.2606 in Winter

# To get more details about the standard errors of these estimates:
summary(ral_model)$coef


####################################
#
#  Save your work!
#
####################################

# this saves all of the objects (functions and variables)
# that you created as a file in your current working directory
save.image("optionA-objects.Rdata")


# next time, when you want to load these objects:
load("optionA-objects.Rdata")

# you can see how this works by first removing an object
rm(abundances) # remove this matrix
abundances # it no longer exists
load("optionA-objects.Rdata") # reload the saved data
abundances # look! it exists again

####################################
#
#  Great work!  You just saw some key concepts in R!
#  Here are some exercises to practice with before you move on to the next tutorial
#
####################################

# 1. Pick your favourite Genus out of topGenera (this exercise is not a R exercise)
# 2. Construct a vector giving the abundances of this genus in the samples
# 3. Pick your favourite covariate 
# 4. Make an effective plot to investigate if the abundance of this genus changes with the covariate
# 5. Calculate the mean and standard deviation of the abundance across the covariate gradient
# 6. Construct a linear model for the abundance of this genus with your covariate

# If you can complete these exercises you've achieved all 5 of the learning objectives
# that we set out to do!
# (reading in data, creating summaries, fitting basic models, 
# using data types, plotting)

# Congratulate yourself and take a break before moving on to Lab B
