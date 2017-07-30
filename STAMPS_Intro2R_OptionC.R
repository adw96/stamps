##########################################
#
#  Introduction to R
#  Option C: For users with a lot of experience with R
#  A tutorial for STAMPS 2017
#
#########################################
#
#  This tutorial was written in July 2017
#  A collaborative effort by 
#  Kris Sankaran, Amy Willis, [please feel free to contribute!]
#
#########################################
#
# Disclaimer: TA support is primarily for Options A and B.
# Please make every effort to resolve any difficulties that you encounter
# on your own. That said, we hope that you learn something new from this
# tutorial!
#
#########################################
# Set your working directory and load data
setwd("~/Documents/MyProjectDirectory")
covariates <- read.table("FWS_covariates.txt", header=TRUE, sep="\t", as.is=TRUE)
abundances <- read.table("FWS_OTUs.txt", header=TRUE, row.names = 1, sep="\t", as.is=TRUE)

# take a moment to have a look at the data here

###############################################
#
# more ggplot, reshape, cast, melt
# By Kris Sankaran
#
###############################################
library(ggplot2)
library(reshape2) # melt and cast
library(dplyr) # filter, group_by, and mutate

# let's try to plot the abundance of the dominant 2
# taxa against each other, and colour the points
# based on Season

# We need to reshape the data so that what will go
# in the x and y for the scatterplot are their own
# columns. We need to *melt* the data. This takes it
# from "wide" (one sample per column) to tall
# (different samples stacked on top of one another).

# First let's retrieve the taxonomic information,
# using strsplit to split the rownames according to
# the ";" character
taxa <- strsplit(rownames(abundances), split = ";")
taxa <- do.call(rbind, taxa) # bind the list into a matrix
colnames(taxa) <- c("Kingdom", "Phylum", "Class", "Order", "Family", "Genus")

# We can use the %>% operation so that we don't need
# to keep track of temporary variables. Melt converts
# the data from wide to tall
melted_abundances <- data.frame(taxa, abundances) %>%
  melt(
    id.vars = colnames(taxa),
    variable.name = "SampleName",
    value.name = "abundance"
  )

# We can incorporate the season information using
# left_join, and get the taxa abundances using
# group_by_at and summarise
melted_abundances <- melted_abundances %>%
  group_by_at(colnames(taxa)) %>%
  mutate(total = sum(abundance)) %>%
  left_join(covariates) %>%
  ungroup()

# To get the most abundant taxa, we filter down
# to the top two totals. Then, we cast the data.frame
# so that there is one column for what will become
# each axis in the plot
top_abundances <- melted_abundances %>%
  filter(total >= sort(rowSums(abundances), decreasing = TRUE)[2]) %>%
  dcast(SampleName + Season ~ Genus, value.var = "abundance")

# Now we can make the plot! Notice that most of
# the work was in defining data with the appropriate
# input format
ggplot(top_abundances) +
  geom_point(aes(x = Burkholderia, y = Ralstonia, col = Season))

###############################################
#
# source and system
#
###############################################

# write a script to separate out the different taxonomy data in shell
# and run it through R

# TODO

###############################################
#
# parallelisation
# By Lan Huong Nguyen
#
###############################################

# In Option B we calculated the relative abundance of the taxa
# using for loops
# Now try to perform the same but in parallel

# If you haven't done it before, install the 'foreach' and 'doParallel' packages
# install.packages("foreach")
# install.packages("doParallel")

# Load the packages 
library(doParallel)

# Set the number of cores
no_cores <- detectCores() - 1
cl<-makeCluster(no_cores)
registerDoParallel(cl)

# Use foreach function to compute the relative abundances
relative_abundances <- 
  foreach(current_index = 1:(dim(abundances)[2]), 
          .combine = cbind)  %dopar% {
            number_reads <- sum(abundances[, current_index]) 
            abundances[, current_index]/number_reads
          }


# Check if results match the standard calculations
all(relative_abundances == scale(abundances, center = F, scale = colSums(abundances)))

# Note that:'.combine' argument tells foreach function how to combine results
# from multiple threads. '.combine' can be specified as a function or 
# a character string e.g. c, cbind, rbind, list, '+', '*'

# Also observe that variables from the local environment are by default available
# for each thread without specification. This is not true of the variables
# in the parent environment, e.g. the following gives an error:

test <- function () {
  foreach(current_index = 1:(dim(abundances)[2]), 
          .combine = cbind)  %dopar% {
            number_reads <- sum(abundances[, current_index]) 
            abundances[, current_index]/number_reads
          }
}
relative_abundances <- test()

# To export specific variables to the cluster use the 'export' argument
test <- function () {
  foreach(current_index = 1:(dim(abundances)[2]), 
          .combine = cbind,
          .export = "abundances")  %dopar% {
            number_reads <- sum(abundances[, current_index]) 
            abundances[, current_index]/number_reads
          }
}
relative_abundances <- test()

# Check if results match the standard calculations
all(relative_abundances == scale(abundances, center = F, scale = colSums(abundances)))

# When you are done working in paralel close the cluster so that resources 
# are returned to the operating system
stopCluster(cl)


# In R  lapply() is a faster and cleaner way to perform for loop tasks. 
# You can speed things up even further by using parallel equivalent of 
# lapply() and  sapply(), parLapply() and parSapply() respectively. These
# functions are available in the package, 'parallel'.

# install.packages("parallel")

library(parallel)

# Calculate the number of cores
no_cores <- detectCores() - 1

# Initiate cluster
cl <- makeCluster(no_cores)

# Export variable 'abundances' to the cluster
clusterExport(cl, "abundances")

# If you are using some specific packages inside parLapply, you need to load 
# them through  clusterEvalQ(), e.g. clusterEvalQ(cl, library(phyloseq))

# Use parLapply() function
relative_abundances <- 
  parLapply(cl, 
            1:(dim(abundances)[2]),
            function(current_index) {
              print(class(current_index))
              number_reads <- sum(abundances[, current_index]) 
              abundances[, current_index]/number_reads
            })

# Close the cluster
stopCluster(cl)

# Currently, 'relative_abundances' is a list. To converti it to a matrix do
# the following:
relative_abundances <- do.call("cbind", relative_abundances)

# Check if results match the standard calculations
all(relative_abundances == scale(abundances, center = F, scale = colSums(abundances)))

# For more details on parallelisms check the following link:
# http://gforge.se/2015/02/how-to-go-parallel-in-r-basics-tips/

###############################################
#
# Markdown
#
###############################################

# TODO
