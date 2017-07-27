##########################################
#
#  Introduction to R 
#  Option B: For users with some experience with R
#  A tutorial for STAMPS 2017
# 
#########################################
#
#  This tutorial is written by Amy Willis, July 2017
#  Contributions also made by [please feel free to contribute!]
#
#########################################
#
# If you downloaded this from the website, 
# be sure to rename as "STAMPS_Intro2R_OptionB.R", 
# R and R Studio will not interpret is as an R script with ".txt" suffix

#########################################
#
# Disclaimer: The level of hand-holding in this tutorial will be
# less than in Option A. There will be some expectation on you to
# attempt to solve your issues. By all means request help from the TAs,
# but in order to obtain mastery of any language it is important to practice 
# correcting yourself, and now is a great opportunity to practice :)
# 
#########################################


###############################################
# 
# Get some context 
#
###############################################
# Set your working directory (refer to Option A if you're not sure how)
setwd("~/Documents/MyProjectDirectory") 

# If you already worked through Option A, feel free to skip until the next section

# In Option A, we loaded in some covariate and OTU data and briefly
# made some plots and looked at some summaries
covariates <- read.table("FWS_covariates.txt", header=TRUE, sep="\t", as.is=TRUE)
abundances <- read.table("FWS_OTUs.txt", header=TRUE, row.names = 1, sep="\t", as.is=TRUE)

# take a moment to have a look at the data here

###############################################
# 
# ggplot
#
###############################################

# Last night you learned how to install a package from CRAN
# We're now going to use the package ggplot2

# If this doesn't work for you, look at the Installing R website
library(ggplot2)

# check that the following produces a plot
ggplot(data.frame("x"=c(1,2,3), "y"=c(4,4.6, 5)))+geom_point(aes(x,y))
# and don't worry about what this means for now

# base graphics in R, such as plot() and boxplot(), are not very pretty
# enter: ggplot! (everyone calls the package ggplot2 "ggplot") 

# ggplot makes simple things difficult, difficult things simple, and
# everything beautiful

# ggplot has a different structure to base graphics
# here is how you make a ggplot
abundances <- data.frame(abundances)
ggplot(abundances, aes(x = JPA_Jan)) 

# nothing happened! why?
# we need to add components, such as a scatterplot or a histogram, 
# to build up a plot
ggplot(abundances, aes(x = JPA_Jan)) +
  geom_histogram()

# obviously there are lots of taxa that were not observed in this sample, hence the zeros
# let's restrict our attention to taxa that we did see
# Subsetting 2 different variables is done like this
ggplot(subset(abundances, JPA_Jan > 0), aes(JPA_Jan)) + 
  geom_histogram()

# the first argument is the data frame of interest
# aes() specifies which column we want
# and the geom_histogram() says that we want a histogram

# The range of this histogram is huge, so we want to focus on the distribution of
# OTUs that were observed once or more but less than 60 times, we would do
ggplot(subset(abundances, JPA_Jan > 0 & JPA_Jan < 60), aes(JPA_Jan)) + 
  geom_histogram()

# a scatterplot shows how correlated the abundances are between january and february
ggplot(subset(abundances, JPA_Jan > 0 & JPA_Feb > 0), 
       aes(JPA_Jan, JPA_Feb)) + 
  geom_point()
# again, ggplot() specifies what we want plotted
# geom_point() specifies that we want a scatterplot

ggplot(subset(abundances, JPA_Jan > 0 & JPA_Feb > 0), 
       aes(JPA_Jan, JPA_Feb)) + 
  geom_point() + 
  theme_classic() # changes the styling
  
ggplot(abundances, aes(JPA_Jan, JPA_Feb)) + 
  geom_point() + 
  labs(title="My first scatterplot") + # adds a title
  xlab("January OTU counts") + # adds labels
  ylab("February OTU counts")
  
  


# this doesn't work in

###############################################
# 
# The apply family
#
###############################################

taxaRel <- scale(taxaAbund, center=FALSE, scale=colSums(taxaAbund))  

sortedTaxaRel <- taxaRel[ order(taxaRel$Total, decreasing=TRUE) , ] 

topTen <- sortedTaxaRel[1:10,]  

topGenera <- sub("^.*;", "", rownames(topTen), perl=TRUE)    


###############################################
# 
# loops
#
###############################################

###############################################
# 
# Function writing
#
###############################################



