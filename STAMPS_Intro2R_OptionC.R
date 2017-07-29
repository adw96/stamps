##########################################
#
#  Introduction to R
#  Option C: For users with a lot of experience with R
#  A tutorial for STAMPS 2017
#
#########################################
#
#  This tutorial is written by Amy Willis, July 2017
#  Contributions also made by [please feel free to contribute!]
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
# plyr
#
###############################################

###############################################
#
# ddply
#
###############################################

# TODO

###############################################
#
# parallelisation
#
###############################################

# TODO

###############################################
#
# Markdown
#
###############################################

# TODO
