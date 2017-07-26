##########################################
#
#  Introduction to R 
#  A tutorial for STAMPS 2017
# 
#########################################
#
#  This tutorial is written by Amy Willis, July 2017
#  It is based off an original tutorial by Sue Huse, 2011-16
#  Contributions also made by [please feel free to contribute!]
#
#########################################
#
# If you downloaded this from the website, 
# be sure to rename as "STAMPS2017_R_tutorial_optionA.R", 
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
# some parenthesis. We can also see this by typing in
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
# reads in the file, assuming the first line is a header with column names, 
# that the columns are separated by tabs ("\t") and
# do not change text values to factors, just leave it as is.
sampleInfo <- read.table("FWS_covariates.txt", header=TRUE, sep="\t", as.is=TRUE)
# Typing "a <- 5" assigns value 5 to the variable a
# In the same way, the above command assigns the table read from
# the filename to the variable sampleInfo

# Everytime you import data, look at it before you use it.
# does it look like it came in correctly?
sampleInfo  

# Different object classes have different properties, 
# the class() function returns the name of the object's class
class(sampleInfo)  # what type of object is it?
colnames(sampleInfo)  # what are the names of the columns / fields?

#
#  We are going to use the data frame sampleInfo for a bit while we practice selection
# Let's look at the variable Month
Month

# That doesn't work! That's because Month only exists in the context of
# sampleInfo. Here is how we access Month
sampleInfo$Month

# If we want to make Month available outside of sampleInfo, we need the following command
attach(sampleInfo)   

# Beware! You can only use attach on one dataframe at a time.
# You should know of the existence of attach(), but I (Amy) recommend avoid using it
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
SampleName          # so now I only have to type the column name to return the data
SampleName[1]       # the index value in the vector
SampleName[4:9]     # all indices from 4:9
SampleName[c(2,4,6)]  # a set of  non-consecutive indices
SampleName[c(6,4,2)]  # returns the values in the order selected
SampleName[-5]      # all but the fifth value

# Dual index selection works the same for dataframes and matrices as with vectors, 
# but you need two indices: rows and columns
# a blank selection of rows or columns selects all.
sampleInfo[1:3, c(1,3,5)]    
sampleInfo[ , c("Month", "Season")]  # you can select columns by selecting their names
sampleInfo[ Location == "MBL", ]   # you can match data within a column
sampleInfo[ Type != "Reservoir",]  # ==, !=, >, >=, <, <= 
sampleInfo[ Month %in% c("Jan", "Feb"),]  # %in% specifies a vector of possibilities

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
# !!  working directory, run this without the directory
#taxaAbund <- read.table("/class/stamps-shared/R_tutorial/taxaAbund.txt", header=TRUE, row.names = 1, sep="\t", as.is=TRUE)
taxaAbund <- read.table("FWS_OTUs.txt", header=TRUE, row.names = 1, sep="\t", as.is=TRUE)

# !! Always LOOK at your imported data before you use it.
rownames(taxaAbund)  # check the names of the rows
colnames(taxaAbund)  # check the names of the columns
head(taxaAbund)   # quick check -- does it look okay?
# That was hard to look at.  If not all columns can be displayed, 
# it will repeat the rownames (taxa) for each set of columns.

# Look at the sample names in the covariate data file (remember "attach")
SampleName  #  Notice that the sample names in the covariates file are in the same order as the column names!
SampleName == colnames(taxaAbund) # they are the same!

# Lets look at the abundances from the first sample ("JPA_Jan")
head(sort(taxaAbund[,1])) # what kind of abundances do we see?

# All zeros?
# what if I want to sort decreasing and see the abundant taxa? 
# Get help on the syntax also help(sort)
?sort                       
sort(taxaAbund[,1], decreasing=TRUE)  # Rank abundance for the data, but it includes 0's
sort(taxaAbund[taxaAbund[,1]>0,1], decreasing=TRUE)  # Proper rank abundance without 0's
# Spend a moment deciphering how this command was put together. 
# Do you understand all of the pieces?

# Exercise: How many times was the most abundant OTU
# observed in the second sample?
# STOP HERE and test yourself in finding this. 

# Answer: 3150

# Save the rank abundance for the first sample
myRankAbund <- sort(taxaAbund[taxaAbund[,1]>0,1], decreasing=TRUE)  
# note that nothing was printed out here, because variable assignment
# is done silently. 
head(myRankAbund) # always good to check that this worked as intended!

# Species abundances instead of rank abundances are important in many problems.
# table() provides the frequencies of each value (count)
table(taxaAbund[taxaAbund[,1] > 0 ,1])  
mySpeciesAbund <- table(taxaAbund[,1])
mySpeciesAbund

#
# Create a relative abundance matrix from the abundance matrix
#
# scale the values in each column by dividing the values by the column total
taxaRel <- scale(taxaAbund, center=FALSE, scale=colSums(taxaAbund))  
# Check that the columns now all sum to 1 (=100%)
colSums(taxaRel)  # colSums finds the sum down the rows of the matrix

#
# Lets add a new column, Total, that sums the abundances for each genus
# 
# what is the dimension (size) of the table, how many rows and columns?
dim(taxaRel)       
# Can we add a new column for the total abundance of each row, 
# by assigning data to the next column index
taxaRel[,13]  <- rowSums(taxaRel)  
#!! Why did that just fail?!?!
class(taxaRel)   # R handles matrices and data frames differently
taxaRel <- as.data.frame(taxaRel)  # convert it to a data frame, less efficient, but easier to use in tutorials
class(taxaRel)    # double check

# Lets try that again
taxaRel[,13]  <- rowSums(taxaRel)  # Add a new column that is the total abundance of each row
colnames(taxaRel)  # Check your column names
colnames(taxaRel)[13] <- "Total"  # Fix the new column name
colnames(taxaRel)  # Check again 
head(taxaRel$Total)  

# Which are the abundant taxa?
# select the names of rows whose total is > 1%
rownames(taxaRel[taxaRel$Total >= 0.01, ])

#
# Let's practice sorting, then use only the 10 most abundant taxa 
# because it makes the demo easier
#
# Sort based on decreasing Total, but returns the indices
sort(taxaRel$Total, decreasing=TRUE) 
# Sort based on decreasing Total, but returns the indices
order(taxaRel$Total, decreasing=TRUE)  

# Use the ordered indices to sort the data.frame, 
# and populate a new data frame with those values
sortedTaxaRel <- taxaRel[ order(taxaRel$Total, decreasing=TRUE) , ] 

# Take the first 10 rows (most abundant taxa) and all of the columns (samples)
topTen <- sortedTaxaRel[1:10,]  
topTen
#
# Labeling with the full taxonomic names is rough, let's just get the genus names
#

# we'll substitute everything up to the last semicolon with nothing, leaving only the genus name
# This is a "regular expression", don't worry about it if you don't understand it:
#  sub(old_pattern, new_pattern, text, use perl regular expressions)
# replace up to the last semicolon ("^.*;") with nothing ("")
# ^ starts the string at the beginning of the line, 
# . means any character, 
# * that previous character as many times as you like
topGenera <- sub("^.*;", "", rownames(topTen), perl=TRUE)    
topGenera # review the names  --- oops we have a few "genus_NA", not helpful
which(topGenera == "genus_NA")  # this gives us the indices of the genus_NA's
rownames(topTen)[7]  # what are the full taxa names for these rows?
topGenera[7] <- "Bacteria"  # fix the genus_NAs, by replacing with the family names
topGenera  # Just checking...

####################################
#
# PLOTTING -- Practice a few types of graphs
#
####################################
# simple bar chart of the first taxon most abundant taxon
barplot(topTen[1, ], main=topGenera[1], xlab="Sample", ylab="Relative Abundance")
# Data frames can include characters as well as numbers, 
# so many functions require matrix input to be sure.  
# What is topTen again?
class(topTen)
# Okay it is a data frame and we need it to be a matrix.
topTen  <- as.matrix(topTen)

# Let's try again
barplot(topTen[1, ], main=topGenera[1], xlab="Sample", ylab="Relative Abundance")
# phooey, sample names don't fit, we better rotate them
barplot(topTen[1, ], main=topGenera[1], ylab="Relative Abundance", las=2)
# the various plotting parameters (main, ylab, las) are explained in 
# par -- graphical PARameters
help(par)

# Remove the "Total" column, it really doesn't belong in our data, now that we have used it to sort
# dim() returns c(row_count, column_count), 
topTen <- topTen[ , 1:dim(topTen)[2] - 1 ]  # include all rows, and all but the last column = column count - 1

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
# t() will transform (rotate) the matrix for us
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
colnames(sampleInfo)
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